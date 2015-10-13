package ue4hx.internal;
import haxe.macro.Context;
import sys.FileSystem;
import haxe.macro.Expr;
import haxe.macro.Type;

using StringTools;
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
    var ret = switch (Context.getType('ue4hx.internal.AnyTypeParam')) {
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

    var tconv = TypeConv.get(typeToGen, pos);
    var tparam = tconv.ueType.getTypeParamType();
    try {
      Context.getType( tparam.getClassPath() );
    }
    catch(e:Dynamic) {
      var msg = Std.string(e);
      if (msg.startsWith('Type not found')) {
        // type is not built. Build it!
        new TypeParamBuild(typeToGen, tconv, pos).createCpp();
      } else {
        neko.Lib.rethrow(e);
      }
    }
    return ret;
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

  var typeToGen:Type;
  var tconv:TypeConv;
  var pos:Position;

  public function new(typeToGen, tconv, pos) {
    this.typeToGen = typeToGen;
    this.tconv = tconv;
    this.pos = pos;
  }

  public function createCpp():Void {
    var tparam = this.tconv.ueType.getTypeParamType();
    trace(tparam);
    if (this.tconv.isBasic) {
      trace('is basic');
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
        @:keep public static function haxeToUe(haxe:cpp.RawPointer<cpp.Void>):$haxeTypeComplex {
          var dyn:Dynamic = unreal.helpers.HaxeHelpers.pointerToDynamic(haxe);
          var real:$glueTypeComplex = dyn;
          return cast real;
        }

        @:keep public static function ueToHaxe(ue:$haxeTypeComplex):cpp.RawPointer<cpp.Void> {
          var glue:$glueTypeComplex = cast ue;
          var dyn:Dynamic = glue;
          return unreal.helpers.HaxeHelpers.dynamicToPointer(dyn);
        }
      };

      var includeLocation = NativeGlueCode.haxeRuntimeDir.replace('\\','/') + '/Generated/TypeParam.h';

      var cppCode = new HelperBuf();
      var module = NativeGlueCode.module;
      cppCode += '#ifndef TypeParam_h_included__\n#include "$includeLocation"\n#endif\n\n';
      // get the concrete type
      var hxType = TypeRef.fromType( Context.follow(Context.getType( this.tconv.haxeType.getClassPath() )), pos );
      hxType = switch (hxType.pack) {
        case ['unreal'] | ['haxe']:
          hxType.withPack(['cpp']);
        case _:
          hxType;
      }
      var hxType = hxType.getCppType().toString();

      var cppName = tparam.getCppClass();

      cppCode += 'template<>\n$hxType TypeParam<$hxType>::haxeToUe(void *haxe) {\n';
        cppCode += '\treturn $cppName::haxeToUe(haxe);\n}\n\n';
      cppCode += 'template<>\nvoid *TypeParam<$hxType>::ueToHaxe($hxType ue) {\n';
        cppCode += '\treturn $cppName::ueToHaxe(ue);\n}\n';
      cls.name = tparam.name;
      cls.pack = tparam.pack;
      cls.meta = extractMeta(
        macro
          @:nativeGen
          @:cppFileCode($v{cppCode.toString()})
          null
      );

      Context.defineType(cls);
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
          return ${Context.parse(this.tconv.haxeToGlue('haxeTyped', null), pos)};
        }

        public static function glueToHaxe(glue:cpp.RawPointer<cpp.Void>):cpp.RawPointer<cpp.Void> {
          var glueTyped:$glueTypeComplex = cast glue;
          return unreal.helpers.HaxeHelpers.dynamicToPointer(${Context.parse(this.tconv.glueToHaxe('glueTyped', null), pos)});
        }
      };

      cls.name = tparam.name;
      cls.pack = tparam.pack;
      cls.meta = extractMeta(
        macro
          @:uexpose
          @:keep
          null
      );

      // ue type
      var path = NativeGlueCode.haxeRuntimeDir + '/Generated/Private/' + tparam.getClassPath().replace('.','/') + '.cpp';
      var dir = haxe.io.Path.directory(path);
      if (!FileSystem.exists(dir))
        FileSystem.createDirectory(dir);

      var writer = new GlueWriter(null, path, tparam.getClassPath());
      writer.addCppInclude('<${tparam.getClassPath().replace('.','/')}.h>');
      writer.addCppInclude('<TypeParam.h>');
      var ueType = this.tconv.ueType.getCppType();
      var cppName = tparam.getCppClass();

      if (this.tconv.glueCppIncludes != null) {
        for (inc in this.tconv.glueCppIncludes)
          writer.addCppInclude(inc);
      }
      if (this.tconv.glueHeaderIncludes != null) {
        for (inc in this.tconv.glueHeaderIncludes)
          writer.addHeaderInclude(inc);
      }

      writer.wcpp('template<>\n$ueType TypeParam<$ueType>::haxeToUe(void *haxe) {\n');
        writer.wcpp('\treturn ${this.tconv.glueToUe( cppName + '::haxeToGlue(haxe)', null )};\n}\n\n');
      writer.wcpp('template<>\nvoid *TypeParam<$ueType>::ueToHaxe($ueType ue) {\n');
        writer.wcpp('\treturn $cppName::glueToHaxe( ${this.tconv.ueToGlue( 'ue', null )} );\n}\n\n');
      writer.close();
      Context.defineType(cls);
    }
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
