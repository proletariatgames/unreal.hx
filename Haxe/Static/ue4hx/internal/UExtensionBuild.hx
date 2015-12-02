package ue4hx.internal;
import ue4hx.internal.buf.HelperBuf;
import ue4hx.internal.TypeConv;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

using Lambda;
using haxe.macro.Tools;
using haxe.macro.ExprTools;
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
      var toExpose = new Map(),
          uprops = [];

      for (field in clt.statics.get()) {
        if (field.meta.has(':uproperty') || (field.kind.match(FVar(_)) && field.meta.has(':uexpose'))) {
          uprops.push({ field:field, isStatic: true });
        } else if (shouldExpose(field)) {
          toExpose[field.name] = getMethodDef(field, Static);
        }
      }

      var nativeMethods = collectNativeMethods(clt),
          haxeMethods = collectHaxeMethods(clt);
      for (field in clt.fields.get()) {
        if (field.meta.has(':uproperty') || (field.kind.match(FVar(_)) && field.meta.has(':uexpose'))) {
          uprops.push({ field:field, isStatic: false });

          // We also need to expose any functions that are used for custom replication conditions
          var repType = MacroHelpers.extractStrings(field.meta, ':ureplicate')[0];
          if (isCustomReplicationType(repType)) {
            var fnField = clt.fields.get().find(function(fld) return fld.name == repType);
            if (fnField == null) {
              throw new Error('Unreal Extension: Custom replication function not found: $repType', field.pos);
            }
            toExpose[field.name] = getMethodDef(fnField, nativeMethods.exists(repType) ? Override : Member);
          }

          continue;
        }

        if (haxeMethods.exists(field.name))
          continue; // our methods are already virtual and we don't need to override anything

        var isOverride = nativeMethods.exists(field.name);

        switch (field.kind) {
        case FMethod(_):
          if (field.name.startsWith('onRep_')) {
            var propName = field.name.substr('onRep_'.length);
            // ensure that the variable this replication function is for exists.
            // Can match the field uname or, if none exists, the field name
            var prop = clt.fields.get().find(function(t){
              return (getUName(t) == propName); // getUName() returns name if no uname
            });
            if (prop == null) {
              throw new Error('Unreal Glue: Replication function defined for property that doesn\'t exist: $propName', field.pos);
            }
          }
        default:
        }

        if (isOverride || shouldExpose(field)) {
          toExpose[field.name] = getMethodDef(field, isOverride ? Override : Member);
        }
      }

      var buildFields = [];
      for (field in toExpose) {
        var uname = getUName(field.cf);
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

        // mark each field as public or protected in the generated C++
        // Can't mark it as private here, but then you can't legitimately
        // extern a private field anyway.
        if (field.cf.isPublic) {
          headerDef << 'public:\n\t\t';
        } else {
          headerDef << 'protected:\n\t\t';
        }

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

        if (!field.type.isStatic()) {
          headerDef << 'public:\n\t\t';
          headerDef << 'typedef $ret (${nativeUe.getCppClass()}::*_${field.cf.name}_methodPtr_T)(' << args << (thisConst ? ' const' : '') << ';\n\t\t';
          headerDef << 'static const _${field.cf.name}_methodPtr_T& _get_${field.cf.name}_methodPtr() { static auto Fn = &${nativeUe.getCppClass()}::$name; return Fn; }\n';
        }

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
        var headerIncludes = new IncludeSet(),
            cppIncludes = new IncludeSet(),
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
            // TODO @:privateAccess shouldn't be necessary here, but the @:access metadata isn't working
            expr: Context.parse('@:privateAccess (' + callExpr + ' )', field.cf.pos)
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

      var headerIncludes = IncludeSet.fromUniqueArray(['<unreal/helpers/GcRef.h>']),
          cppIncludes = IncludeSet.fromUniqueArray(['<' + expose.getClassPath().replace('.','/') + '.h>']);
      var info = addNativeUeClass(nativeUe, clt, headerIncludes, metas);
      metas.push({ name:':glueCppIncludes', params:[ for (inc in cppIncludes) macro $v{inc} ], pos:clt.pos });

      var hasReplicatedProperties = false;
      var replicatedProps = new Map();

      // add createHaxeWrapper
      {
        var headerCode = 'public:\n\t\tvirtual void *createHaxeWrapper()' + (info.hasHaxeSuper ? ' override;\n\n\t\t' : ';\n\n\t\t');
        var cppCode = '';
        var glueHeaderIncs = new IncludeSet(),
            glueCppIncs = new IncludeSet(),
            headerForwards = new Map();
        for (upropDef in uprops) {
          var uprop = upropDef.field,
              isStatic = upropDef.isStatic;
          var uname = getUName(uprop);
          var tconv = TypeConv.get(uprop.type, uprop.pos);
          var data = new StringBuf();

          // regardless of the Haxe definition, we make all properties public in C++ so
          // that the glue code doesn't have to jump through hoops to access the properties.
          // TODO when this code is unified with the extern baking code, this difference
          // should go away.
          data.add('public:\n\t\t');

          if (uprop.meta.has(':uproperty')) {
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

            if (uprop.meta.has(":ureplicate")) {
              if (first) first = false; else data.add(', ');

              var fnName = 'onRep_$uname';
              var replicateFn = clt.fields.get().find(function(fld) {
                return switch (fld.type) {
                  case TFun(_): fld.name == fnName;
                  default: false;
                }
              });

              if (replicateFn != null) {
                if (!replicateFn.meta.has(":ufunction")) {
                  throw new Error('$fnName must be a ufunction to use ReplicatedUsing', uprop.pos);
                }
                data.add('ReplicatedUsing=$fnName');
              } else {
                data.add('Replicated');
              }

              var repType = MacroHelpers.extractStrings(uprop.meta, ':ureplicate')[0];
              replicatedProps[uprop] = repType;
              hasReplicatedProperties = true;
            }

            headerCode += data + ')\n\t\t';
          }
          if (isStatic) {
            if (!tconv.isUObject) {
              throw new Error('Unreal Extension: @:uexpose on static properties must be of a uobject-derived type', uprop.pos);
            }

            headerCode += 'static ';
            cppCode += tconv.ueType.getCppType(null) + ' ' + thisConv.ueType.getCppClass() + '::' + uname + ' = nullptr;\n';
          }
          headerCode += tconv.ueType.getCppType(null) + ' ' + uname + ';\n\n\t\t';
          // we are using cpp includes here since glueCppIncludes represents the includes on the Unreal side
          switch (tconv.forwardDeclType) {
          case null | Never | AsFunction:
            tconv.getAllCppIncludes( glueHeaderIncs );
          case Templated(incs):
            glueHeaderIncs.append(incs);
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

        // Implement GetLifetimeReplicatedProps
        cppCode += 'void *${nativeUe.getCppClass()}::createHaxeWrapper() {\n\treturn ${expose.getCppClass()}::createHaxeWrapper((void *) this);\n}\n';
        if (hasReplicatedProperties) {
          var hasCustomReplications = false;
          var customReplications = new Map();

          // Needs to be included for DOREPLIFETIME/etc
          glueCppIncs.add('UnrealNetwork.h');

          cppCode += 'void ${nativeUe.getCppClass()}::GetLifetimeReplicatedProps(TArray<FLifetimeProperty>& OutLifetimeProps) const {\n';
          cppCode += '\tSuper::GetLifetimeReplicatedProps(OutLifetimeProps);\n';
          for (replicatedProp in replicatedProps.keys()) {
            var uname = getUName(replicatedProp);
            var repType = replicatedProps[replicatedProp];
            if (repType == null) {
              cppCode += '\tDOREPLIFETIME(${nativeUe.getCppClass()}, $uname);\n';
            } else {
              if (isCustomReplicationType(repType)) {
                cppCode += '\tDOREPLIFETIME_CONDITION(${nativeUe.getCppClass()}, $uname, COND_Custom);\n';
                customReplications[uname] = repType;
                hasCustomReplications = true;
              } else {
                cppCode += '\tDOREPLIFETIME_CONDITION(${nativeUe.getCppClass()}, $uname, COND_$repType);\n';
              }
            }
          }
          cppCode += '}\n\n';

          if (hasCustomReplications) {
            headerCode += 'virtual void PreReplication( IRepChangedPropertyTracker & ChangedPropertyTracker ) override;\n\n\t\t';

            cppCode += 'void ${nativeUe.getCppClass()}::PreReplication(IRepChangedPropertyTracker& ChangedPropertyTracker) {\n';
            cppCode += '\tSuper::PreReplication(ChangedPropertyTracker);\n';
            for (uname in customReplications.keys()) {
              cppCode += '\tDOREPLIFETIME_ACTIVE_OVERRIDE(${nativeUe.getCppClass()}, $uname, ${customReplications[uname]}());\n';
            }
            cppCode += '}\n\n';
          }
        }

        var metas = [
          { name: ':glueHeaderCode', params: [macro $v{headerCode}], pos: this.pos },
          { name: ':glueCppCode', params: [macro $v{cppCode}], pos: this.pos },
          { name: ':glueHeaderIncludes', params: [for (inc in glueHeaderIncs) macro $v{inc}], pos: this.pos },
          { name: ':glueCppIncludes', params: [for (inc in glueCppIncs) macro $v{inc}], pos: this.pos },
          { name: ':headerForwards', params: [ for (fwd in headerForwards) macro $v{fwd}], pos: this.pos }
          // TODO this should work instead of forcing the @:privateAccess
          //{ name: ':access', params: [ Context.parse(thisConv.haxeType.getClassPath(true),this.pos) ], pos: this.pos }
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

  private static function addNativeUeClass(nativeUe:TypeRef, clt:ClassType, includes:IncludeSet, metas:Metadata):{ hasHaxeSuper:Bool } {
    var typeRef = TypeRef.fromBaseType(clt, clt.pos);
    var extendsAndImplements = [];
    var ueName = nativeUe.getCppClassName(),
        fileName = nativeUe.withoutPrefix().getCppClassName();
    // this ueGluePath is later added to gluesToGenerate (before defineType is called)
    metas.push({ name: ':ueGluePath', params: [macro $v{fileName}], pos: clt.pos });
    var uclass = clt.meta.extract(':uclass')[0];
    if (uclass != null)
      includes.add('${fileName}.generated.h');

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
    var superConv = TypeConv.get( TInst(clt.superClass.t, clt.superClass.params), clt.pos);
    var superName = superConv.ueType.getCppClass();

    headerDef.add('public:\n');
    // include class map
    includes.add('ClassMap.h');
    headerDef.add('\t\tstatic void *getHaxePointer(void *inUObject) {\n');
      headerDef.add('\t\t\treturn ( (${ueName} *) inUObject )->haxeGcRef.get();\n\t\t}\n');

    var objectInit = new HelperBuf() << 'ObjectInitializer';
    var useObjInitializer = clt.meta.has(':noDefaultConstructor');
    for (fld in clt.meta.extract(':uoverrideSubobject')) {
      useObjInitializer = true;
      if (fld.params == null || fld.params.length != 2) {
        throw new Error(':uoverrideSubobject requires two parameters: the name of the component, and the override type', clt.pos);
      }
      var overrideName = switch (fld.params[0].expr) {
      case EConst(CIdent(s)) | EConst(CString(s)): s;
      default: throw new Error('@:uoverrideSubobject first parameter should be the name of the component to override', clt.pos);
      }

      var overrideType = Context.getType(fld.params[1].toString());
      var overrideTypeConv = TypeConv.get(overrideType, clt.pos, 'unreal.PStruct');
      overrideTypeConv.getAllCppIncludes(includes);
      objectInit << '.SetDefaultSubobjectClass<${overrideTypeConv.ueType.getCppClass()}>("$overrideName")';
    }

    var ctorBody = new HelperBuf();
    // first add our unwrapper to the class map
    ctorBody << '\n\t\t\tstatic bool addToMap = ::unreal::helpers::ClassMap_obj::addWrapper($ueName::StaticClass(), &getHaxePointer);\n\t\t\t'
      << 'UClass *curClass = ObjectInitializer.GetClass();\n\t\t\t'
      << 'while (!curClass->HasAllClassFlags(CLASS_Native)) {\n\t\t\t\t'
      << 'curClass = curClass->GetSuperClass();\n\t\t\t}\n\t\t\t'
      << 'if (curClass->GetName() == TEXT("${ueName.substr(1)}")) this->haxeGcRef.set(this->createHaxeWrapper());\n\t\t';

    if (!hasHaxeSuper) {
      headerDef.add('\t\t::unreal::helpers::GcRef haxeGcRef;\n');
      if (useObjInitializer) {
        headerDef.add('\t\t${ueName}(const FObjectInitializer& ObjectInitializer = FObjectInitializer::Get()) : $superName($objectInit) {$ctorBody}\n');
      } else {
        headerDef.add('\t\t${ueName}(const FObjectInitializer& ObjectInitializer = FObjectInitializer::Get()) {$ctorBody}\n');
      }
    } else {
      headerDef.add('\t\t${ueName}(const FObjectInitializer& ObjectInitializer = FObjectInitializer::Get()) : $superName($objectInit) {$ctorBody}\n');
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

  private static function isCustomReplicationType(repType:String) : Bool {
    if (repType == null) {
      return false;
    }

    return switch(repType) {
      case 'InitialOnly', 'OwnerOnly', 'SkipOwner', 'SimulatedOnly',
           'AutonomousOnly', 'SimulatedOrPhysics', 'InitialOrOwner': false;
      default: true;
    }
  }

  private static function getUName(cf:ClassField) {
    var uname = MacroHelpers.extractStrings(cf.meta, ':uname')[0];
    return uname != null ? uname : cf.name;
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

