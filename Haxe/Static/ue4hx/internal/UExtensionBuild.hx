package ue4hx.internal;
import ue4hx.internal.buf.HelperBuf;
import ue4hx.internal.TypeConv;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

using haxe.macro.Tools;
using StringTools;

/**
  Generates the Haxe @:uexpose class which allows Unreal types to access Haxe types
 **/
class UExtensionBuild {
  public static function build():Type {
    return switch (Context.getLocalType()) {
      case TInst(_, [typeToGen]):
        new UExtensionBuild().generate(typeToGen);
      case _:
        throw 'assert';
    }
  }

  private var pos:Position;
  public function new() {
  }

  public static function ufuncMetaNoImpl(meta:Expr) {
    var name = switch(meta.expr) {
      case EConst(CIdent(c)):
        c;
      case _:
        return false;
    };
    switch(name) {
    case "BlueprintImplementableEvent" |
      "BlueprintNativeEvent" | "Server" |
      "Client" | "NetMulticast":
      return true;
    case _:
      return false;
    }
  }

  public static function ufuncMetaNeedsImpl(meta:Expr) {
    var name = switch(meta.expr) {
      case EConst(CIdent(c)):
        c;
      case _:
        return false;
    };
    switch(name) {
    case "BlueprintNativeEvent" |
      "Server" | "Client" | "NetMulticast":
      return true;
    case _:
      return false;
    }
  }

  public function generate(t:Type):Type {
    switch (Context.follow(t)) {
    case TInst(cl,tl):
      var ctx = null;
      var clt = cl.get();
      this.pos = clt.pos;
      var typeRef = TypeRef.fromBaseType(clt, this.pos),
          thisConv = TypeConv.get(t, this.pos);
      var nativeUe = thisConv.ueType;
      var expose = typeRef.getExposeHelperType();
      var toExpose = [],
          uprops = [];
      for (field in clt.statics.get()) {
        if (field.meta.has(':uproperty'))
          uprops.push(field);
        else if (shouldExpose(field))
          toExpose.push(getMethodDef(field, Static));
      }

      var nativeMethods = collectNativeMethods(clt),
          haxeMethods = collectHaxeMethods(clt);
      for (field in clt.fields.get()) {
        if (field.meta.has(':uproperty')) {
          uprops.push(field);
          continue;
        }

        if (haxeMethods.exists(field.name))
          continue; // our methods are already virtual and we don't need to override anything

        var isOverride = nativeMethods.exists(field.name);
        if (isOverride || shouldExpose(field)) {
          toExpose.push(getMethodDef(field, isOverride ? Override : Member));
        }
      }

      var buildFields = [];
      for (field in toExpose) {
        var uname = MacroHelpers.extractStrings(field.cf.meta, ':uname')[0];
        if (uname == null)
          uname = field.cf.name;
        var callExpr = if (field.type.isStatic())
          typeRef.getClassPath() + '.' + field.cf.name + '(';
        else
          thisConv.glueToHaxe('self', ctx) + '.' + field.cf.name + '(';
        callExpr += [ for (arg in field.args) arg.type.glueToHaxe(arg.name, ctx) ].join(', ') + ')';

        if (!field.ret.haxeType.isVoid())
          callExpr = 'return ' + field.ret.haxeToGlue( callExpr , ctx);

        var fnArgs:Array<FunctionArg> =
          [ for (arg in field.args) { name: arg.name, type: arg.type.haxeGlueType.toComplexType() } ];
        if (!field.type.isStatic())
          fnArgs.unshift({ name: 'self', type: thisConv.haxeGlueType.toComplexType() });
        var headerDef = new HelperBuf(),
            cppDef = new HelperBuf();
        var ret = field.ret.ueType.getCppType().toString();

        var implementCpp = true,
            name = uname,
            cppName = uname;
        var ufunc = field.cf.meta.extract(':ufunction');
        if (ufunc != null && ufunc[0] != null) {
          headerDef << 'UFUNCTION(';
          var first = true;
          for (meta in ufunc) {
            if (meta.params != null) {
              for (param in meta.params) {
                if (first) first = false; else headerDef << ', ';
                headerDef << param.toString().replace('[','(').replace(']',')');
                if (ufuncMetaNoImpl(param)) {
                  implementCpp = false;
                }
              }
            }
          }
          headerDef << ')\n\t\t';
        }

        cppDef << ret << ' ' << nativeUe.getCppClass() << '::' << cppName << '(';
        var modifier = if (field.type.isStatic())
          'static ';
        else if (!field.cf.meta.has(':final'))
          'virtual ';
        else
          '';

        headerDef << modifier << ret << ' ' << name << '(';
        var args = [ for (arg in field.args) arg.type.ueType.getCppType() + ' ' + arg.name ].join(', ') + ')';
        cppDef << args; headerDef << args;
        var native = nativeMethods[field.cf.name];
        var thisConst = field.cf.meta.has(':thisConst') || (native != null && native.meta.has(':thisConst'));

        if (thisConst) {
          headerDef << ' const';
          cppDef << ' const';
        }

        if (field.type == Override)
          headerDef << ' override';
        headerDef << ';\n';
        cppDef << '{\n\t';
        var args = [ for (arg in field.args) arg.type.ueToGlue( arg.name , ctx) ];
        if (!field.type.isStatic())
          args.unshift( thisConv.ueToGlue(thisConst ? 'const_cast<${ nativeUe.getCppType() }>(this)' : 'this', ctx) );
        var cppBody = expose.getCppClass() + '::' + field.cf.name + '(' +
          args.join(', ') + ')';
        if (!field.ret.haxeType.isVoid())
          cppBody = 'return ' + field.ret.glueToUe( cppBody , ctx);
        cppDef << cppBody << ';\n}\n';

        var allTypes = [ for (arg in field.args) arg.type ];
        if (!field.type.isStatic())
          allTypes.push(thisConv);
        allTypes.push(field.ret);
        var headerIncludes = new Map(),
            cppIncludes = new Map(),
            headerForwards = new Map();
        for (t in allTypes) {
          if (!t.forwardDeclType.isNever()) {
            for (decl in t.forwardDecls) {
              headerForwards[decl] = decl;
            }
            t.getAllCppIncludes( cppIncludes );
          } else {
            // we only care about glue Header includes here since we're using the actual UE type
            t.getAllCppIncludes( headerIncludes );
          }
        }

        if (!implementCpp) cppDef = new HelperBuf();
        var metas:Metadata = [
          { name: ':glueHeaderCode', params:[macro $v{headerDef.toString()}], pos: field.cf.pos },
          { name: ':glueCppCode', params:[macro $v{cppDef.toString()}], pos: field.cf.pos },
          { name: ':glueHeaderIncludes', params:[for (inc in headerIncludes) macro $v{inc}], pos: field.cf.pos },
          { name: ':glueCppIncludes', params:[for (inc in cppIncludes) macro $v{inc}], pos: field.cf.pos },
          { name: ':headerForwards', params:[for (fwd in headerForwards) macro $v{fwd}], pos: field.cf.pos }
        ];
        if (field.ret.haxeType.isVoid())
          metas.push({ name: ':void', pos: field.cf.pos });
        buildFields.push({
          name: field.cf.name,
          access: [APublic, AStatic],
          kind: FFun({
            args: fnArgs,
            ret: field.ret.haxeGlueType.toComplexType(),
            expr: Context.parse(callExpr, field.cf.pos)
          }),
          meta: metas,
          pos: field.cf.pos
        });
      }

      var metas = [
        { name: ':uexpose', params:[], pos:clt.pos },
        { name: ':keep', params:[], pos:clt.pos },
        { name: ':uextern', params:[], pos:clt.pos },
      ];

      var headerIncludes = ['<unreal/helpers/GcRef.h>'],
          cppIncludes = ['<' + expose.getClassPath().replace('.','/') + '.h>'];
      var headerIncludes = [ for (inc in headerIncludes) inc => inc ],
          cppIncludes = [ for (inc in cppIncludes) inc => inc ];
      var info = addNativeUeClass(nativeUe, clt, headerIncludes, metas);
      metas.push({ name:':glueCppIncludes', params:[ for (inc in cppIncludes) macro $v{inc} ], pos:clt.pos });

      // add createHaxeWrapper
      {
        var headerCode = 'virtual void *createHaxeWrapper()' + (info.hasHaxeSuper ? ' override;\n\t\t' : ';\n\t\t');
        var glueHeaderIncs = new Map(),
            glueCppIncs = new Map(),
            headerForwards = new Map();
        for (uprop in uprops) {
          var uname = MacroHelpers.extractStrings(uprop.meta, ':uname')[0];
          if (uname == null)
            uname = uprop.name;
          var tconv = TypeConv.get(uprop.type, uprop.pos);
          var data = new StringBuf();
          data.add('UPROPERTY(');
          var first = true;
          for (meta in uprop.meta.extract(':uproperty')) {
            if (meta.params != null) {
              for (param in meta.params) {
                if (first) first = false; else data.add(', ');
                data.add(param.toString().replace('[','(').replace(']',')'));
              }
            }
          }
          headerCode += data + ')\n\t\t';
          headerCode += tconv.ueType.getCppType(null) + ' ' + uname + ';\n\t';
          // we are using cpp includes here since glueCppIncludes represents the includes on the Unreal side
          switch (tconv.forwardDeclType) {
          case null | Never | AsFunction:
            tconv.getAllCppIncludes( glueHeaderIncs );
          case Templated(incs):
            for (inc in incs) {
              glueHeaderIncs[inc] = inc;
            }
            for (fwd in tconv.forwardDecls) {
              headerForwards[fwd] = fwd;
            }
            tconv.getAllCppIncludes(glueCppIncs);
          case Always:
            for (fwd in tconv.forwardDecls) {
              headerForwards[fwd] = fwd;
            }
            tconv.getAllCppIncludes(glueCppIncs);
          }
        }
        var cppCode = 'void *${nativeUe.getCppClass()}::createHaxeWrapper() {\n\treturn ${expose.getCppClass()}::createHaxeWrapper((void *) this);\n}\n';

        var metas = [
          { name: ':glueHeaderCode', params: [macro $v{headerCode}], pos: this.pos },
          { name: ':glueCppCode', params: [macro $v{cppCode}], pos: this.pos },
          { name: ':glueHeaderIncludes', params: [for (inc in glueHeaderIncs) macro $v{inc}], pos: this.pos },
          { name: ':glueCppIncludes', params: [for (inc in glueCppIncs) macro $v{inc}], pos: this.pos },
          { name: ':headerForwards', params: [ for (fwd in headerForwards) macro $v{fwd}], pos: this.pos }
        ];
        buildFields.push({
          name: 'createHaxeWrapper',
          access: [APublic, AStatic],
          kind: FFun({
            args: [{ name: 'ueType', type: thisConv.haxeGlueType.toComplexType() }],
            ret: thisConv.glueType.toComplexType(),
            expr: Context.parse(
              'return ' + thisConv.haxeToGlue('@:privateAccess new ${typeRef.getClassPath()}( cpp.Pointer.fromRaw(cast ueType) )', ctx), this.pos)
          }),
          meta: metas,
          pos: this.pos
        });
      }

      Globals.cur.gluesToGenerate = Globals.cur.gluesToGenerate.add(expose.getClassPath());
      Context.defineType({
        pack: expose.pack,
        name: expose.name,
        pos: clt.pos,
        meta: metas,
        kind: TDClass(),
        fields: buildFields
      });
      return Context.getType(expose.getClassPath());
    case _:
      throw new Error('Unreal Haxe Glue: Type $t not supported', Context.currentPos());
    }
  }

  private static function addNativeUeClass(nativeUe:TypeRef, clt:ClassType, includes:Map<String, String>, metas:Metadata):{ hasHaxeSuper:Bool } {
    var typeRef = TypeRef.fromBaseType(clt, clt.pos);
    var extendsAndImplements = [];
    var ueName = nativeUe.getCppClassName(),
        fileName = nativeUe.withoutPrefix().getCppClassName();
    // this ueGluePath is later added to gluesToGenerate (before defineType is called)
    metas.push({ name: ':ueGluePath', params: [macro $v{fileName}], pos: clt.pos });
    var uclass = clt.meta.extract(':uclass')[0];
    if (uclass != null)
      includes['${fileName}.generated.h'] = '${fileName}.generated.h';

    var hasHaxeSuper = false;
    if (clt.superClass != null) {
      // TESTME - test extending Haxe classes
      var tconv = TypeConv.get( TInst(clt.superClass.t, clt.superClass.params), clt.pos );
      // any superclass here should also be present in the native side
      extendsAndImplements.push('public ' + tconv.ueType.getCppClass());

      hasHaxeSuper =  !clt.superClass.t.get().meta.has(':uextern');
      // we're using the ueType so we'll include the glueCppIncludes
      tconv.getAllCppIncludes( includes );
    }
    for (iface in clt.interfaces) {
      var impl = iface.t.get();
      // TODO: support UE4 interface declaration in Haxe; for now we'll only add @:uextern interfaces
      // look into @:uextern.
      if (impl.meta.has(':uextern')) {
        var tconv = TypeConv.get( TInst(iface.t, iface.params), clt.pos );
        extendsAndImplements.push('public ' + tconv.ueType.getCppClass());
        // we're using the ueType so we'll include the glueCppIncludes
        tconv.getAllCppIncludes( includes );
      }
    }

    var targetModule = MacroHelpers.extractStrings(clt.meta, ':umodule')[0];
    if (targetModule == null)
      targetModule = Globals.cur.module;

    var headerDef = new StringBuf(),
        cppDef = new StringBuf();
    if (uclass != null) {
      headerDef.add('UCLASS(');
      if (uclass.params != null) {
        var first = true;
        for (param in uclass.params) {
          if (first) first = false; else headerDef.add(', ');
          headerDef.add(param.toString().replace('[','(').replace(']',')'));
        }
      }
      headerDef.add(')\n');
    }
    headerDef.add('class ${targetModule.toUpperCase()}_API ${ueName} ');
    if (extendsAndImplements.length > 0) {
      headerDef.add(' : ');
      headerDef.add(extendsAndImplements.join(', '));
    }
    if (uclass != null) {
      headerDef.add(' {\n\tGENERATED_BODY()\n\n');
    } else {
      headerDef.add(' {\n\n');
    }
    // headerDef.add(' {\n\t');
    headerDef.add('public:\n');
    if (!hasHaxeSuper) {
      headerDef.add('\t\t::unreal::helpers::GcRef haxeGcRef;\n');
      // headerDef.add('\t\tpublic virtual void *createHaxeWrapper();\n');
      if (clt.meta.has(':noDefaultConstructor')) {
        headerDef.add('\t\t${ueName}(const FObjectInitializer& ObjectInitializer = FObjectInitializer::Get()) : Super(ObjectInitializer) { this->haxeGcRef.set(this->createHaxeWrapper()); }\n');
      } else {
        headerDef.add('\t\t${ueName}() { this->haxeGcRef.set(this->createHaxeWrapper()); }\n');
      }
    } else {
      // headerDef.add('\t\tpublic virtual void *createHaxeWrapper() override;\n');
    }

    metas.push({ name: ':glueHeaderIncludes', params:[for (inc in includes) macro $v{inc}], pos: clt.pos });
    metas.push({ name: ':ueHeaderDef', params:[macro $v{headerDef.toString()}], pos: clt.pos });
    var umodule = clt.meta.extract(':umodule');
    if (umodule != null && umodule.length > 0)
      metas.push({ name:':utargetmodule', params:umodule[0].params, pos:umodule[0].pos });

    return { hasHaxeSuper: hasHaxeSuper };
  }

  private static function getMethodDef(field:ClassField, fieldType:FieldType) {
    var args = null, ret = null;
    switch(Context.follow(field.type)) {
      case TFun(a,r):
        args = [ for (arg in a) { name:arg.name, type: TypeConv.get(arg.t, field.pos) } ];
        ret = TypeConv.get(r, field.pos);
      case _: throw 'assert'; // we only allow FMethod here
    }

    return {
      cf: field,
      args: args,
      ret: ret,
      type: fieldType
    };
  }

  private static function collectNativeMethods(cls:ClassType) {
    var ret = new Map();
    var sclass = cls.superClass;
    while (sclass != null) {
      var cur = sclass.t.get();
      if (cur.meta.has(':uextern')) {
        for (field in cur.fields.get())
          ret[field.name] = field;
      }
      sclass = cur.superClass;
    }
    if (cls.interfaces.length > 0) {
      var touched = new Map();
      function touch(iface:Ref<ClassType>) {
        var name = iface.toString();
        if (touched.exists(name))
          return;
        touched[name] = true;
        var cl = iface.get();
        if (cl.meta.has(':uextern')) {
          for (field in cl.fields.get()) {
            if (!ret.exists(field.name)) {
              ret[field.name] = field;
            }
          }
          for (iface in cl.interfaces)
            touch(iface.t);
        }
      }
      for (iface in cls.interfaces)
        touch(iface.t);
    }
    return ret;
  }

  private static function collectHaxeMethods(cls:ClassType) {
    var ret = new Map();
    var sclass = cls.superClass;
    while (sclass != null) {
      var cur = sclass.t.get();
      if (cur.meta.has(':uextern')) {
        break;
      }
      for (field in cur.fields.get())
        ret[field.name] = true;
      sclass = cur.superClass;
    }
    return ret;
  }

  private static function shouldExpose(cf:ClassField):Bool {
    // we will only expose methods that either have @:uexpose metadata
    // or that override or implement an unreal method
    switch (cf.kind) {
    case FMethod(_):
    case _:
      // we won't expose our non-@:uproperty vars;
      // and uproperty vars will be already generated in the UE side
      return false;
    }

    if (cf.meta.has(':uexpose') || cf.meta.has(':ufunction'))
      return true;
    return false;
  }
}

@:enum abstract FieldType(Int) to Int {
  var Static = 1;
  var Member = 2;
  var Override = 3;

  inline public function isStatic() {
    return this == Static;
  }
}
