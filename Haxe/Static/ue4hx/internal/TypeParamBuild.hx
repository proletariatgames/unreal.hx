package ue4hx.internal;
import ue4hx.internal.buf.HelperBuf;
import ue4hx.internal.buf.CodeFormatter;
import haxe.macro.Context;
import haxe.macro.Compiler;
import sys.FileSystem;
import haxe.macro.Expr;
import haxe.macro.Type;

using StringTools;
using ue4hx.internal.MacroHelpers;
using haxe.macro.Tools;

class TypeParamBuild {
  public static function build():Type {
    switch (Context.getLocalType()) {
    case TInst(_, [typeToGen]):
      var pos = Context.currentPos();
      return ensureBuilt(typeToGen, pos, true); /* we allow incomplete here because this might be just a definition */
    case _:
      throw 'assert';
    }
  }

  public static function ensureBuilt(typeToGen:Type, pos:Position, allowPartial:Bool):Type {
    var ret = switch (Context.getType('unreal.TypeParam')) {
      case TAbstract(a,tl):
        TAbstract(a,[typeToGen]);
      case _:
        throw 'assert';
    }
    if (isPartial(typeToGen, pos)) {
      if (allowPartial) {
        return ret;
      } else {
        throw new Error('The type $typeToGen cannot be used as a type parameter because it has type parameters itself, ' +
          'and this is not supported on Unreal Glue types', pos);
      }
    }

    // if it's built through the genericBuild, use keep
    var last = Globals.cur.currentFeature;
    Globals.cur.currentFeature = 'keep';
    var tconv = TypeConv.get(typeToGen, pos);
    ensureTypeConvBuilt(typeToGen, tconv, pos, 'keep');
    Globals.cur.currentFeature = last;

    return ret;
  }

  public static function ensureTypeConvBuilt(type:Type, tconv:TypeConv, pos:Position, feature:String):Void {
    if (!Globals.cur.canCreateTypes) {
      Context.warning("Unreal Glue: Ensuring type parameters are built outside create type context", pos);
    }
    if (tconv.ownershipModifier == 'unreal.PRef' || tconv.ownershipModifier == 'ue4hx.internal.PRefDef') {
      tconv = TypeConv.get(type, pos, 'unreal.PStruct');
    }

    var tparam = tconv.ueType.getTypeParamType();
    Globals.cur.addDep( tparam, feature );
    if (!Globals.cur.toDefineTParams.exists( tparam.getClassPath() )) {
      // type is not built. Build it!
      new TypeParamBuild(type, tconv, pos).createCpp();
    }
  }

  public static function checkBuiltFields( type:Type ) {
    // this will just check a type and make sure all TypeConvs are built - so they in turn
    // will be added to `Globals.typeParamsToBuild`
    switch(Context.follow(type)) {
    case TInst(c, tl):
      var cl = c.get();
      var name = TypeRef.fromBaseType(cl, cl.pos).getClassPath(true);
      for (field in cl.fields.get().concat(cl.statics.get())) {
        if (field.meta.has(':needsTypeParamGlue')) {
          Globals.cur.currentFeature = '$name.${field.name}';
          switch(Context.follow(field.type)) {
          case TFun(args,ret):
            // just make sure they are built so
            for (arg in args) TypeConv.get(arg.t, field.pos);
            TypeConv.get(ret, field.pos);
          case t:
            TypeConv.get(t, field.pos);
          }
        }
      }
    case _:
    }
    Globals.cur.currentFeature = null;
  }

  public static function ensureTypesBuilt(baseType:BaseType, args:Array<TypeConv>, pos:Position, feature:String):Void {
    var applied = [ for (arg in args) arg.haxeType ];
    var built = baseType.pack.join('.') + '.' + baseType.name + '<' + [ for (arg in args) arg.haxeType ].join(',') + '>';
    if (Context.definedValue('dce') == 'full') {
      built += '-' + feature;
    }
    if (Globals.cur.builtParams.exists(built)) return;
    Globals.cur.builtParams[built] = true;
    var old = Globals.cur.currentFeature;
    Globals.cur.currentFeature = feature;
    var meta = baseType.meta.extractStrings(':ueDependentTypes');
    var params = [ for (p in baseType.params) p.name ];
    if (args.length != params.length) {
      throw 'assert: ${args.length} != ${params.length} for $baseType';
    }

    // TODO make some kind of cache to avoid huge amount of lookups
    if (meta != null) {
      for (depType in meta) {
        var tref = TypeRef.parse( depType ).applyParams(params, applied);
        if (tref.name == baseType.name) {
          var isEq = true;
          if (tref.pack.length == baseType.pack.length) {
            for (i in 0...tref.pack.length) {
              if (tref.pack[i] != baseType.pack[i]) {
                isEq = false;
                break;
              }
            }
          }
          if (isEq) continue; // do not recurse on our own type
        }
        var type = tref.toComplexType().toType();
        var tconv = TypeConv.get(type, pos);
        ensureTypeConvBuilt(type, tconv, pos, feature);
      }
    }

    Globals.cur.currentFeature = old;
  }

  public static function isPartial(t:Type, pos:Position):Bool {
    return switch(Context.follow(t)) {
      case TInst(i, tl):
        switch(i.get().kind) {
        case KTypeParameter(_):
          true;
        case _:
          for (t in tl) {
            if (isPartial(t, pos))
              return true;
          }
          false;
        }
      case TEnum(_,_):
        false;
      case TAbstract(_,tl):
        for (t in tl) {
          if (isPartial(t, pos))
            return true;
        }
        false;
      case _:
        throw new Error('Unreal Glue: The type $t cannot be used as a type parameter!', pos);
    }
  }

  var tconv:TypeConv;
  var type:Type;
  var pos:Position;

  private function new(type, tconv, pos) {
    this.tconv = tconv;
    this.pos = pos;
    this.type = type;
  }

  /**
    If we are generating code to another module, we must take care to export our symbols
    properly.
   **/
  private static function createDllExporter(tparam:TypeRef, cppType:String, toGlue:Bool) {
    var exportHeader = new CodeFormatter(),
        exportCpp = new CodeFormatter();
    var module = Globals.cur.module;
    if (Globals.cur.glueTargetModule != null) {
      module = Globals.cur.glueTargetModule;
    }

    var cppName = tparam.getCppClass();
    for (pack in tparam.pack) {
      exportHeader << 'namespace $pack {' << new Newline();
    }
    var haxeTo = toGlue ? 'haxeToGlue' : 'haxeToUe',
        toHaxe = toGlue ? 'glueToHaxe' : 'ueToHaxe';
    exportHeader << 'HXCPP_CLASS_ATTRIBUTES $cppType ${tparam.name}_$haxeTo(void *haxe);' << new Newline();
    exportHeader << 'HXCPP_CLASS_ATTRIBUTES void *${tparam.name}_$toHaxe($cppType ue);' << new Newline();
    for (pack in tparam.pack) {
      exportHeader << '}' << new Newline();
    }

    // export
    exportCpp << '$cppType ${tparam.name}_$haxeTo(void *haxe)' << new Begin('{') <<
      'return $cppName::$haxeTo(haxe);' <<
    new End('}');
    exportCpp << 'void *${tparam.name}_$toHaxe($cppType ue)' << new Begin('{') <<
      'return $cppName::$toHaxe(ue);' <<
    new End('}');
    cppName = '${tparam.name}_';

    var writer = new ue4hx.internal.buf.CppWriter(
      Globals.cur.haxeRuntimeDir + '/../$module/Generated/Private/${tparam.pack.join("/")}/${tparam.name}.cpp'
    );
    writer.buf.add(NativeGlueCode.prelude);
    writer.include('${tparam.pack.join("/")}/${tparam.name}.h');
    writer.close(module);

    return { header:exportHeader.toString(), cppName:tparam.pack.join('::') + '::' + cppName };
  }

  public function createCpp():Void {
    var feats = [];
    var tparam = this.tconv.ueType.getTypeParamType();
    var cppName = tparam.getCppClass() + '::';

    var module = Globals.cur.module;
    if (Globals.cur.glueTargetModule != null) {
      module = Globals.cur.glueTargetModule;
    }

    if (this.tconv.isBasic) {
      // basic types are present on both hxcpp and UE, so
      // we don't need an intermediate glue type
      var glueType = this.tconv.haxeType;
      var haxeType = if (glueType.name.startsWith('Fake')) {
        new TypeRef(['cpp'], glueType.name.substr('Fake'.length));
      } else {
        glueType;
      }
      var glueTypeComplex = glueType.toComplexType(),
          haxeTypeComplex = haxeType.toComplexType();
      var cls = macro class {
        public static function haxeToUe(haxe:cpp.RawPointer<cpp.Void>):$haxeTypeComplex {
          var dyn:Dynamic = unreal.helpers.HaxeHelpers.pointerToDynamic(haxe);
          var real:$glueTypeComplex = dyn;
          return cast real;
        }

        public static function ueToHaxe(ue:$haxeTypeComplex):cpp.RawPointer<cpp.Void> {
          var glue:$glueTypeComplex = cast ue;
          var dyn:Dynamic = glue;
          return unreal.helpers.HaxeHelpers.dynamicToPointer(dyn);
        }
      };

      var includeLocation = 'TypeParamGlue.h';

      var cppCode = new HelperBuf();
      cppCode << '#ifndef TypeParamGlue_h_included__\n#include "$includeLocation"\n#endif\n\n';
      // get the concrete type
      var hxType = TypeRef.fromType( Context.follow(Context.getType(haxeType.getClassPath())), pos );
      hxType = switch (hxType.pack) {
        case ['unreal'] | ['haxe']:
          hxType.withPack(['cpp']);
        case _:
          hxType;
      }
      var hxType = hxType.getCppType().toString();
      switch (hxType) {
      case 'cpp::Int64':
        hxType = 'long long int';
      case 'cpp::UInt64':
        hxType = 'unsigned long long int';
      case _:
      }

      var extraMeta:Metadata = null;
      if (Globals.cur.glueTargetModule != null) {
        var exp = createDllExporter(tparam, hxType, false);
        extraMeta = [
          { name: ':uexpose', pos: pos },
          { name: ':headerCode', params:[macro $v{exp.header}], pos: pos },
        ];
        cppName = exp.cppName;
      }
      cppCode << 'template<>\n$hxType TypeParamGlue<$hxType>::haxeToUe(void *haxe) {\n';
        cppCode << '\treturn ${cppName}haxeToUe(haxe);\n}\n\n';
      cppCode << 'template<>\nvoid *TypeParamGlue<$hxType>::ueToHaxe($hxType ue) {\n';
        cppCode << '\treturn ${cppName}ueToHaxe(ue);\n}\n';
      cppCode << 'template<>\nPtrMaker<$hxType>::Type TypeParamGluePtr<$hxType>::haxeToUePtr(void *haxe) {\n';
        cppCode << '\treturn PtrMaker<$hxType>::Type(${cppName}haxeToUe(haxe));\n}\n\n';
      cppCode << 'template<>\nvoid *TypeParamGluePtr<$hxType>::ueToHaxeRef($hxType& ue) {\n';
        cppCode << '\treturn ${cppName}ueToHaxe(ue);\n}\n';
      var meta = extractMeta(
        macro
          @:nativeGen
          @:cppFileCode($v{cppCode.toString()})
          null
      );
      if (extraMeta != null) {
        for (m in extraMeta) {
          meta.push(m);
        }
      }
      cls.name = tparam.name;
      cls.pack = tparam.pack;
      cls.meta = meta;

      Globals.cur.toDefineTParams[tparam.getClassPath()] = cls;
    } else {
      // we need to generate two classes in here:
      // one @:uexpose with the haxeToGlue / glueToHaxe variants
      // and one in the UE side which implements the ueToGlue / glueToUe expressions
      var hxType = this.tconv.haxeType,
          hxTypeComplex = hxType.toComplexType();
      var glueType = this.tconv.haxeGlueType,
          glueTypeComplex = glueType.toComplexType();

      var cls = macro class {
        public static function haxeToGlue(haxe:cpp.RawPointer<cpp.Void>):cpp.RawPointer<cpp.Void> {
          var haxeTyped:$hxTypeComplex = unreal.helpers.HaxeHelpers.pointerToDynamic(haxe);
          return cast (${Context.parse(this.tconv.haxeToGlue('haxeTyped', null), pos)});
        }

        public static function glueToHaxe(glue:cpp.RawPointer<cpp.Void>):cpp.RawPointer<cpp.Void> {
          var glueTyped:$glueTypeComplex = cast glue;
          return unreal.helpers.HaxeHelpers.dynamicToPointer(${Context.parse(this.tconv.glueToHaxe('glueTyped', null), pos)});
        }
      };
      if (this.tconv.isEnum == true) {
        cls = macro class {
          public static function haxeToGlue(haxe:cpp.RawPointer<cpp.Void>):Int {
            var haxeTyped:$hxTypeComplex = unreal.helpers.HaxeHelpers.pointerToDynamic(haxe);
            return cast (${Context.parse(this.tconv.haxeToGlue('haxeTyped', null), pos)});
          }

          public static function glueToHaxe(glue:Int):cpp.RawPointer<cpp.Void> {
            var glueTyped:$glueTypeComplex = cast glue;
            return unreal.helpers.HaxeHelpers.dynamicToPointer(${Context.parse(this.tconv.glueToHaxe('glueTyped', null), pos)});
          }
        };
      }

      cls.name = tparam.name;
      cls.pack = tparam.pack;
      cls.meta = extractMeta(
        macro
          @:uexpose
          null
      );
      if (Globals.cur.glueTargetModule != null) {
        var exp = createDllExporter(tparam, this.tconv.isEnum ? 'int' : 'void*', true);
        cls.meta.push({ name: ':headerCode', params:[macro $v{exp.header}], pos: pos });
        cppName = exp.cppName;
      }

      var path = Globals.cur.haxeRuntimeDir;
      var targetModule = Globals.cur.module;
      if (Globals.cur.glueTargetModule != null && !needsMainModule(tconv)) {
        path += '/../${Globals.cur.glueTargetModule}';
        targetModule = Globals.cur.glueTargetModule;
        cls.meta.push({ name:':utargetmodule', params:[macro $v{Globals.cur.glueTargetModule}], pos:cls.pos });
      } else {
        cls.meta.push({ name:':umainmodule', params:[], pos:cls.pos });
      }

      // ue type
      path += '/Generated/Private/' + tparam.getClassPath().replace('.','/') + '.cpp';
      var dir = haxe.io.Path.directory(path);
      if (!FileSystem.exists(dir))
        FileSystem.createDirectory(dir);

      var writer = new ue4hx.internal.buf.CppWriter(path);
      writer.buf.add(NativeGlueCode.prelude);
      writer.include('<${tparam.getClassPath().replace('.','/')}.h>');
      var incs = new IncludeSet();
      this.tconv.getAllCppIncludes(incs);
      this.tconv.getAllHeaderIncludes(incs);
      for (inc in incs) {
        writer.include(inc);
      }
      writer.include('<TypeParamGlue.h>');
      var ueType = this.tconv.ueType.getCppType();

      if (this.tconv.glueCppIncludes != null) {
        for (inc in this.tconv.glueCppIncludes)
          writer.include(inc);
      }

      var glueType = this.tconv.glueType.getCppType();
      writer.buf.add('template<>\n$ueType TypeParamGlue<$ueType>::haxeToUe(void *haxe) {\n');
        writer.buf.add('\treturn ${this.tconv.glueToUe( '( (' + glueType + ')' +  cppName + 'haxeToGlue(haxe)' + ')', null )};\n}\n\n');
      writer.buf.add('template<>\nvoid *TypeParamGlue<$ueType>::ueToHaxe($ueType ue) {\n');
        writer.buf.add('\treturn ${cppName}glueToHaxe( ${this.tconv.ueToGlue( 'ue', null )} );\n}\n\n');

      switch (this.tconv.ownershipModifier) {
      case 'unreal.PStruct' | 'ue4hx.internal.PStructRef' if (!this.tconv.isUObject):
        // in this case, we need to generate the get pointer code for glueToHaxePtr
        var pointerConv = TypeConv.get(this.type, this.pos, 'unreal.PExternal');
        writer.buf.add('template<>\nPtrMaker<$ueType>::Type TypeParamGluePtr<$ueType>::haxeToUePtr(void *haxe) {\n');
          writer.buf.add('\treturn PtrMaker<$ueType>::Type(${pointerConv.glueToUe( '( (' + glueType + ')' + cppName + 'haxeToGlue(haxe)' + ')', null)});\n}\n\n');
        writer.buf.add('template<>\nvoid *TypeParamGluePtr<$ueType>::ueToHaxeRef($ueType& ue) {\n');
          writer.buf.add('\treturn ${cppName}glueToHaxe( ${pointerConv.ueToGlue( '&ue', null )} );\n}\n\n');
      case 'unreal.PStruct' | 'ue4hx.internal.PStructRef':
        var pointerConv = TypeConv.get(this.type, this.pos, 'unreal.PRef');
        writer.buf.add('template<>\nPtrMaker<$ueType>::Type TypeParamGluePtr<$ueType>::haxeToUePtr(void *haxe) {\n');
          writer.buf.add('\treturn PtrMaker<$ueType>::Type(&(${pointerConv.glueToUe( '( (' + glueType + ')' + cppName + 'haxeToGlue(haxe)' + ')', null)}));\n}\n\n');
        writer.buf.add('template<>\nvoid *TypeParamGluePtr<$ueType>::ueToHaxeRef($ueType& ue) {\n');
          writer.buf.add('\treturn ${cppName}glueToHaxe( ${pointerConv.ueToGlue( 'ue', null )} );\n}\n\n');
      case _:
        writer.buf.add('template<>\nPtrMaker<$ueType>::Type TypeParamGluePtr<$ueType>::haxeToUePtr(void *haxe) {\n');
          writer.buf.add('\treturn PtrMaker<$ueType>::Type(${this.tconv.glueToUe( '( (' + glueType + ')' + cppName + 'haxeToGlue(haxe)' + ')', null)});\n}\n\n');
        writer.buf.add('template<>\nvoid *TypeParamGluePtr<$ueType>::ueToHaxeRef($ueType& ue) {\n');
          writer.buf.add('\treturn ${cppName}glueToHaxe( ${this.tconv.ueToGlue( '( ( ' + ueType +' ) ue )', null )} );\n}\n\n');
      }

      writer.close(targetModule);
      Globals.cur.toDefineTParams[tparam.getClassPath()] = cls;
    }
  }

  private static function needsMainModule(tconv:TypeConv) {
    if (tconv.baseType != null) {
      if (tconv.baseType.meta.has(':uextension') || (tconv.isEnum && !tconv.baseType.meta.has(':uextern'))) {
        return true;
      } else if (tconv.baseType.meta.has(':umodule') && MacroHelpers.extractStrings(tconv.baseType.meta, ':umodule')[0] == Globals.cur.module) {
        return true;
      }
    }
    if (tconv.args != null) {
      for (arg in tconv.args) {
        if (needsMainModule(arg)) {
          return true;
        }
      }
    }
    return false;
  }

  private static function extractMeta(expr:Expr, ?meta:Metadata):Metadata {
    if (meta == null) meta = [];
    return switch(expr.expr) {
      case EMeta(m, e):
        meta.push(m);
        extractMeta(e,meta);
      case _:
        meta;
    }
  }
}
