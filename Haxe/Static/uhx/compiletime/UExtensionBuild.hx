package uhx.compiletime;
import uhx.compiletime.tools.*;
import uhx.compiletime.tools.CodeFormatter;
import uhx.compiletime.tools.HelperBuf;
import uhx.compiletime.types.*;
import uhx.compiletime.types.TypeConv;
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
        var ret = new UExtensionBuild().generate(typeToGen);
        ret;
      case _:
        throw 'assert';
    }
  }

  private var pos:Position;
  public function new() {
  }

  public static function upropReplicated(meta:Expr) {
    var name = switch(meta.expr) {
      case EConst(CIdent(c)):
        c.toLowerCase();
      case _:
        return false;
    };
    switch(name) {
    case "replicated":
      return true;
    case _:
      return false;
    }
  }

  public static function ufuncMetaNoImpl(meta:Expr) {
    var name = switch(meta.expr) {
      case EConst(CIdent(c)):
        c.toLowerCase();
      case _:
        return false;
    };
    switch(name) {
    case "blueprintimplementableevent" |
      "blueprintnativeevent" | "server" |
      "client" | "netmulticast":
      return true;
    case _:
      return false;
    }
  }

  public static function ufuncMetaNeedsImpl(meta:Expr) {
    var name = switch(meta.expr) {
      case EConst(CIdent(c)):
        c.toLowerCase();
      case _:
        return false;
    };
    switch(name) {
    case "blueprintnativeevent" |
      "server" | "client" | "netmulticast":
      return true;
    case _:
      return false;
    }
  }

  public static function ufuncMetaIsNet(meta:Expr) {
    var name = switch(meta.expr) {
      case EConst(CIdent(c)):
        c.toLowerCase();
      case _:
        return false;
    };
    switch(name) {
    case "server" | "client" | "netmulticast":
      return true;
    case _:
      return false;
    }
  }

  public static function ufuncNeedsValidation(meta:Expr) {
    var name = switch(meta.expr) {
      case EConst(CIdent(c)):
        c.toLowerCase();
      case _:
        return false;
    };
    switch(name) {
    case "withvalidation":
      return true;
    case _:
      return false;
    }
  }

  public static function ufuncBlueprintOverridable(meta:Expr) {
    var name = switch(meta.expr) {
      case EConst(CIdent(c)):
        c.toLowerCase();
      case _:
        return false;
    };
    switch(name) {
    case "blueprintimplementableevent" | "blueprintnativeevent":
      return true;
    case _:
      return false;
    }
  }

  public static function ufuncBlueprintNativeEvent(meta:Expr) {
    var name = switch(meta.expr) {
      case EConst(CIdent(c)):
        c.toLowerCase();
      case _:
        return false;
    };
    switch(name) {
    case "blueprintnativeevent":
      return true;
    case _:
      return false;
    }
  }

  public function generate(t:Type):Type {
    switch (Context.follow(t)) {
    case TInst(cl,tl):
      var ctx = new ConvCtx(); //["hasParent" => "false"];
      var clt = cl.get();
      var curPos = Context.getPosInfos(clt.pos);
      curPos.min = curPos.max = 0;
      curPos.file += ' (${clt.name})';
      this.pos = clt.pos;
      var invariantPos = Context.makePosition(curPos);
      var typeRef = TypeRef.fromBaseType(clt, this.pos),
          thisConv = TypeConv.get(t, this.pos);
      var nativeUe = thisConv.ueType;
      var expose = typeRef.getExposeHelperType();
      var toExpose = new Map(),
          uprops = [];
      var isDynamicClass = Globals.isDynamicUType(clt);

      for (field in clt.statics.get()) {
        if ( field.kind.match(FVar(_)) && Globals.shouldExposeProperty(field, isDynamicClass) ) {
          uprops.push({ field:field, isStatic: true });
        } else if (Globals.shouldExposeFunction(field, isDynamicClass, null)) {
          toExpose[field.name] = getMethodDef(field, null, Static);
        }
      }

      var nativeMethods = collectNativeMethods(clt),
          haxeMethods = collectHaxeMethods(clt);
      for (field in clt.fields.get()) {
        if ( (!isDynamicClass && field.meta.has(UhxMeta.UProperty)) || (field.kind.match(FVar(_)) && field.meta.has(UhxMeta.UExpose))) {
          uprops.push({ field:field, isStatic: false });

          // We also need to expose any functions that are used for custom replication conditions
          var repType = MacroHelpers.extractStrings(field.meta, UhxMeta.UReplicate)[0];
          if (isCustomReplicationType(repType)) {
            var fnField = clt.fields.get().find(function(fld) return fld.name == repType);
            if (fnField == null) {
              throw new Error('Unreal Extension: Custom replication function not found: $repType', field.pos);
            }
            toExpose[field.name] = getMethodDef(fnField, null, nativeMethods.exists(repType) && field.meta.has('uhx_OverridesNative') ? Override : Member);
          }

          continue;
        }

        if (haxeMethods.exists(field.name))
          continue; // our methods are already virtual and we don't need to override anything

        var isOverride = nativeMethods.exists(field.name);

        switch (field.kind) {
        case FMethod(_):
          if (field.meta.has(':ufunction') && field.name.toLowerCase().startsWith('onrep_')) {
            var propName = field.name.substr('onrep_'.length);
            // ensure that the variable this replication function is for exists.
            // Can match the field uname or, if none exists, the field name
            var prop = clt.fields.get().find(function(t){
              return (MacroHelpers.getUName(t) == propName); // getUName() returns name if no uname
            });
            if (prop == null) {
              throw new Error('Unreal Glue: Replication function defined for property that doesn\'t exist: $propName', field.pos);
            }
          }
        default:
        }

        if (Globals.shouldExposeFunction(field, isDynamicClass, isOverride ? nativeMethods[field.name].meta : null)) {
          toExpose[field.name] = getMethodDef(field, isOverride ? nativeMethods[field.name] : null, isOverride && !field.meta.has('uhx_OverridesNative') ? Override : Member);
          // if (isOverride) {
          //   var sig = UhxMeta.getStaticMetas(field.meta.get()) + field.name;
          //   clt.meta.add(':ugenerated', [macro $v{sig}], field.pos);
          // }
        }
      }

      var buildFields = [];

      var glueHeaderIncs = new IncludeSet(),
          glueCppIncs = new IncludeSet(),
          headerForwards = new Map();

      var isScript = clt.meta.has(UhxMeta.UScript);
      var scriptBase = null;
      if (isScript) {
        scriptBase = TypeConv.get(Context.getType('unreal.UObject'), clt.pos);
      }
      for (field in toExpose) {
        var uname = MacroHelpers.getUName(field.cf);
        var callExpr = null;
        if (!isScript) {
          if (field.type.isStatic()) {
            callExpr = typeRef.getClassPath() + '.' + field.cf.name + '(';
          } else {
            callExpr = thisConv.glueToHaxe('self', ctx) + '.' + field.cf.name + '(';
          }
        } else {
          if (field.type.isStatic()) {
            callExpr = '(cast std.Type.resolveClass("${typeRef.getClassPath(true)}")).' + field.cf.name + '(';
          } else {
            callExpr = '( cast (' + scriptBase.glueToHaxe('self', ctx) + ') ).' + field.cf.name + '(';
          }
        }
        callExpr += [ for (arg in field.args) arg.type.glueToHaxe(arg.name, ctx) ].join(', ') + ')';

        if (!field.ret.haxeType.isVoid()) {
          if (isScript) {
            if (field.ret.data.match(CUObject(OScriptHaxe,_,_))) {
              callExpr = '' + scriptBase.haxeToGlue( '(cast ($callExpr) : unreal.UObject)' , ctx);
            } else {
              callExpr = '' + field.ret.haxeToGlue( '(cast ($callExpr) : ${field.ret.haxeType})' , ctx);
            }
          } else {
            callExpr = '' + field.ret.haxeToGlue( callExpr , ctx);
          }
        }

        var fnArgs:Array<FunctionArg> =
          [ for (arg in field.args) { name: arg.name, type: arg.type.haxeGlueType.toComplexType() } ];
        if (!field.type.isStatic())
          fnArgs.unshift({ name: 'self', type: thisConv.haxeGlueType.toComplexType() });
        var headerDef = new CodeFormatter(),
            cppDef = new CodeFormatter();
        headerDef.begin('').begin('');
        var ret = field.ret.ueType.getCppType().toString();

        var implementCpp = true,
            name = uname,
            cppName = uname;

        // mark each field as public or protected in the generated C++
        // Can't mark it as private here, but then you can't legitimately
        // extern a private field anyway.
        if (field.cf.isPublic) {
          headerDef << 'public:' << new Newline();
        } else {
          headerDef << 'protected:' << new Newline();
        }

        var isBlueprintOverridable = false;
        var ufunc = field.cf.meta.extract(UhxMeta.UFunction);
        if (ufunc != null && ufunc[0] != null) {
          if (field.cf.doc != null) {
            headerDef << new Comment(field.cf.doc);
          }
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
                if (ufuncBlueprintOverridable(param)) {
                  isBlueprintOverridable = true;
                }
              }
            }
          }
          headerDef << ')' << new Newline();
        }

        cppDef << ret << ' ' << nativeUe.getCppClass() << '::' << cppName << '(';
        var modifier = if (field.type.isStatic())
          'static ';
        else if (!isBlueprintOverridable && !field.cf.meta.has(UhxMeta.Final))
          'virtual ';
        else
          '';

        headerDef << modifier << ret << ' ' << name << '(';
        var args = [ for (arg in field.args) arg.type.ueType.getCppType() + ' ' + arg.name ].join(', ') + ')';
        cppDef << args; headerDef << args;
        var native = nativeMethods[field.cf.name];
        var thisConst = field.cf.meta.has(UhxMeta.ThisConst) || (native != null && native.meta.has(UhxMeta.ThisConst));

        if (thisConst) {
          headerDef << ' const';
          cppDef << ' const';
        }

        if (field.type == Override) {
          headerDef << ' override';
        }
        headerDef << ';' << new Newline();

        if (!field.type.isStatic()) {
          headerDef << 'public:' << new Newline();
          headerDef << 'typedef $ret (${nativeUe.getCppClass()}::*_${field.cf.name}_methodPtr_T)(' << args << (thisConst ? ' const' : '') << ';' << new Newline();
          headerDef << 'static const _${field.cf.name}_methodPtr_T& _get_${field.cf.name}_methodPtr()' << new Begin(' {')
            << 'static auto Fn = &${nativeUe.getCppClass()}::$name;' << new Newline()
            << 'return Fn;' << new End('}') << new Newline();
        }

        cppDef << new Begin(' {');
        var args = [ for (arg in field.args) arg.type.ueToGlue( arg.name , ctx) ];
        if (!field.type.isStatic())
          args.unshift( thisConv.ueToGlue(thisConst ? 'const_cast<${ nativeUe.getCppType() }>(this)' : 'this', ctx) );
        var cppBody = expose.getCppClass() + '::' + field.cf.name + '(' +
          args.join(', ') + ')';
        if (!field.ret.haxeType.isVoid()) {
          cppBody = 'return ' + field.ret.glueToUe( cppBody , ctx);
        }
        cppDef << cppBody << ';' << new End('}') << new Newline();

        var allTypes = [ for (arg in field.args) arg.type ];
        if (!field.type.isStatic())
          allTypes.push(thisConv);
        allTypes.push(field.ret);
        var headerIncludes = new IncludeSet(),
            cppIncludes = new IncludeSet(),
            headerForwards = new Map();
        var i = -1;
        while (++i < allTypes.length) {
          var t = allTypes[i];
          t.collectUeIncludes(headerIncludes, headerForwards, cppIncludes);
        }

        if (!implementCpp) cppDef = new CodeFormatter();
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
          pos: invariantPos
        });
      }

      var metas = [
        { name: UhxMeta.UExpose, params:[], pos:clt.pos },
        { name: ':keep', params:[], pos:clt.pos },
      ];

      var headerIncludes = IncludeSet.fromUniqueArray(['<uhx/GcRef.h>']),
          cppIncludes = IncludeSet.fromUniqueArray(['<' + expose.getClassPath().replace('.','/') + '.h>']);
      var info = addNativeUeClass(nativeUe, clt, headerIncludes, metas);
      metas.push({ name:':glueCppIncludes', params:[ for (inc in cppIncludes) macro $v{inc} ], pos:clt.pos });

      var hasReplicatedProperties = false;
      var replicatedProps = new Map();

      {
        // add createHaxeWrapper
        var headerCode = 'public:\n\t\tstatic unreal::UIntPtr createHaxeWrapper(unreal::UIntPtr self)' + (info.hasHaxeSuper ? ';\n\n\t\t' : ';\n\n\t\t') +
          'virtual unreal::UIntPtr createEmptyHaxeWrapper()' + (info.hasHaxeSuper ? ' override;\n\n\t\t' : ';\n\n\t\t');
        var cppCode = '';
        for (upropDef in uprops) {
          var uprop = upropDef.field,
              isStatic = upropDef.isStatic;
          var uname = MacroHelpers.getUName(uprop);
          var tconv = TypeConv.get(uprop.type, uprop.pos);
          var data = new StringBuf();

          // regardless of the Haxe definition, we make all properties public in C++ so
          // that the glue code doesn't have to jump through hoops to access the properties.
          // TODO when this code is unified with the extern baking code, this difference
          // should go away.
          data.add('public:\n\t\t');

          if (uprop.meta.has(UhxMeta.UProperty)) {
            if (uprop.doc != null) {
              data.add('/**\n${uprop.doc.replace('**/','')}\n**/\n\t\t');
            }
            data.add('UPROPERTY(');
            var first = true;
            for (meta in uprop.meta.extract(UhxMeta.UProperty)) {
              if (meta.params != null) {
                for (param in meta.params) {
                  if (first) first = false; else data.add(', ');
                  data.add(param.toString().replace('[','(').replace(']',')'));
                }
              }
              break;
            }

            if (uprop.meta.has(UhxMeta.UReplicate)) {
              if (first) first = false; else data.add(', ');

              var replicateFn = clt.fields.get().find(function(fld) {
                return switch (fld.type) {
                  case TFun(_): fld.name.toLowerCase().startsWith("onrep_") && fld.name.substr("onrep_".length) == uname;
                  default: false;
                }
              });

              if (replicateFn != null) {
                if (!replicateFn.meta.has(UhxMeta.UFunction)) {
                  throw new Error('${replicateFn.name} must be a ufunction to use ReplicatedUsing', uprop.pos);
                }
                data.add('ReplicatedUsing=${replicateFn.name}');
              } else {
                data.add('Replicated');
              }

              var repType = MacroHelpers.extractStrings(uprop.meta, UhxMeta.UReplicate)[0];
              replicatedProps[MacroHelpers.getUName(uprop)] = repType;
              hasReplicatedProperties = true;
            }

            headerCode += data + ')\n\t\t';
          }

          var cppType = tconv.ueType.getCppType(null) + '';
          if (tconv.data.match(CEnum(EExternal|EAbstract,_))) {
            cppType = 'TEnumAsByte< $cppType >';
            glueCppIncs.add('CoreMinimal.h');
          }
          if (isStatic) {
            if (!tconv.data.match(CUObject(_))) {
              throw new Error('Unreal Extension: @:uexpose on static properties must be of a uobject-derived type', uprop.pos);
            }

            headerCode += 'static ';
            cppCode += cppType + ' ' + thisConv.ueType.getCppClass() + '::' + uname + ' = nullptr;\n';
          }
          headerCode += cppType + ' ' + uname + ';\n\n\t\t';
          // we are using cpp includes here since glueCppIncludes represents the includes on the Unreal side
          var types = [tconv];
          var i = -1;
          while (++i < types.length) {
            var tconv = types[i];
            tconv.collectUeIncludes( glueHeaderIncs, headerForwards, glueHeaderIncs );
          }
        }

        cppCode += 'unreal::UIntPtr ${nativeUe.getCppClass()}::createHaxeWrapper(unreal::UIntPtr self) {\n\t'
          + 'return ${expose.getCppClass()}::createHaxeWrapper(self);\n}\n';
        cppCode += 'unreal::UIntPtr ${nativeUe.getCppClass()}::createEmptyHaxeWrapper() {\n\t'
          + 'return ${expose.getCppClass()}::createEmptyHaxeWrapper((unreal::UIntPtr) this);\n}\n';
        // Implement GetLifetimeReplicatedProps
        var aactor = Globals.cur.aactor;
        if (aactor == null) {
          Globals.cur.aactor = aactor = Context.getType('unreal.AActor');
        }
        var uactorcomponent = Globals.cur.uactorcomponent;
        if (uactorcomponent == null) {
          Globals.cur.uactorcomponent = uactorcomponent = Context.getType('unreal.UActorComponent');
        }
        if (isDynamicClass) {
          glueCppIncs.add('VariantPtr.h');
          glueCppIncs.add('IntPtr.h');
          glueCppIncs.add('CoreMinimal.h');
          glueCppIncs.add('uhx/expose/HxcppRuntime.h');
          glueCppIncs.add('uhx/Wrapper.h');
          glueCppIncs.add('UnrealNetwork.h');

          headerCode += 'virtual void GetLifetimeReplicatedProps(TArray<FLifetimeProperty>& OutLifetimeProps) const override;\n\n\t\t';
          cppCode += 'void ${nativeUe.getCppClass()}::GetLifetimeReplicatedProps(TArray<FLifetimeProperty>& OutLifetimeProps) const {\n';
          cppCode += '\tSuper::GetLifetimeReplicatedProps(OutLifetimeProps);\n';
          cppCode += '\tuhx::expose::HxcppRuntime::setLifetimeProperties(' +
              '(unreal::UIntPtr) this->GetClass(), ' +
              '"${nativeUe.getCppClass()}", ' +
              'uhx::TemplateHelper<TArray<FLifetimeProperty>>::fromPointer(&OutLifetimeProps));\n';
          cppCode += '}\n\n';

          if (Context.unify(t, aactor) || Context.unify(t, uactorcomponent)) {
            headerCode += 'virtual void PreReplication( IRepChangedPropertyTracker & ChangedPropertyTracker ) override;\n\n\t\t';

            cppCode += 'void ${nativeUe.getCppClass()}::PreReplication(IRepChangedPropertyTracker& ChangedPropertyTracker) {\n';
            cppCode += '\tSuper::PreReplication(ChangedPropertyTracker);\n';
            cppCode += '\tuhx::expose::HxcppRuntime::instancePreReplication(' +
                '(unreal::UIntPtr) this, ' +
                'unreal::VariantPtr::fromExternalPointer(&ChangedPropertyTracker));\n';
            cppCode += '}\n\n';
          }
        } else if (hasReplicatedProperties) {
          var hasCustomReplications = false;
          var customReplications = new Map();

          // Needs to be included for DOREPLIFETIME/etc
          glueCppIncs.add('UnrealNetwork.h');

          cppCode += 'void ${nativeUe.getCppClass()}::GetLifetimeReplicatedProps(TArray<FLifetimeProperty>& OutLifetimeProps) const {\n';
          cppCode += '\tSuper::GetLifetimeReplicatedProps(OutLifetimeProps);\n';
          var repKeys = [ for (prop in replicatedProps.keys()) prop ];
          repKeys.sort(Reflect.compare);
          for (uname in repKeys) {
            var repType = replicatedProps[uname];
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
        var nameGet = Context.defined('NO_DYNAMIC_UCLASS') ?
          '"${typeRef.getClassPath(true)}"' :
          'uhx.runtime.UReflectionGenerator.getClassName("${nativeUe.getCppClass()}", "${typeRef.getClassPath(true)}")';
        var createExpr = if (isScript) {
          '{
            var cls = std.Type.resolveClass($nameGet);
            if (cls != null) {
              shouldPop = true;
            }
            cls == null ? null : std.Type.createInstance(cls, [ ((cast ueType) : unreal.UIntPtr) ]);
           }';
        } else {
          '@:privateAccess new ${typeRef.getClassPath()}( ((cast ueType) : unreal.UIntPtr) )';
        }
        createExpr = '{
          var ret:unreal.UObject = null,
              shouldPop = false;
          try {
            ret = cast $createExpr;
            if (ret != null) {
              shouldPop = true;
            }
          }
          catch(e:Dynamic) {
            uhx.ClassWrap.popCtor(ret);
            cpp.Lib.rethrow(e);
          }
          if (ret == null) {
            trace("Error", "Error while creating ${typeRef.getClassPath()}: It does not exist");
          }
          if (shouldPop) {
            uhx.ClassWrap.popCtor(ret);
          }
          return uhx.internal.HaxeHelpers.dynamicToPointer(ret);
        }';
        buildFields.push({
          name: 'createHaxeWrapper',
          access: [APublic, AStatic],
          kind: FFun({
            args: [{ name: 'ueType', type: thisConv.haxeGlueType.toComplexType() }],
            ret: thisConv.glueType.toComplexType(),
            expr: Context.parse(createExpr, invariantPos)
          }),
          meta: metas,
          pos: invariantPos
        });
        var createEmptyExpr = '{ ' +
          'var cls = std.Type.resolveClass($nameGet);' +
          'if (cls == null) { trace("Error", "Trying to create empty object of nonexistent class ${typeRef.getClassPath(true)}"); return 0; }' +
          'var ret:unreal.UObject = cast (' + 'std.Type.createEmptyInstance(cls)' + ');' +
          '@:privateAccess ret.wrapped = ueType;' +
          'uhx.internal.HaxeHelpers.dynamicToPointer(ret);' +
        '}';
        buildFields.push({
          name: 'createEmptyHaxeWrapper',
          access: [APublic, AStatic],
          kind: FFun({
            args: [{ name: 'ueType', type: thisConv.haxeGlueType.toComplexType() }],
            ret: thisConv.glueType.toComplexType(),
            expr: Context.parse(createEmptyExpr, invariantPos)
          }),
          meta: [],
          pos: invariantPos
        });
      }

      for (field in buildFields) {
        switch(field.kind) {
        case FFun(fn):
          var fnRet = fn.ret;
          var isVoid = fnRet.match(TPath({ name:'Void' }));
          var nullExpr = macro cast null;
          var nameVal = typeRef.name + '.' + field.name;
          var oldExpr = fn.expr;
          if (hasReturn(oldExpr)) {
            if (isVoid) {
              oldExpr = macro {
                function uhx_run() {
                  $oldExpr;
                }
                uhx_run();
              };
            } else {
              oldExpr = macro {
                function uhx_run():$fnRet {
                  var ret = $oldExpr;
                  @:pos(field.pos) return ret;
                }
                uhx_run();
              };
            }
          }
          var newExpr = null;
          if (isVoid) {
            newExpr = macro uhx.HaxeCodeDispatcher.runVoid(function() $oldExpr);
          } else {
            newExpr = macro return uhx.HaxeCodeDispatcher.runWithValue(function() return $oldExpr);
          }
          if (field.meta == null)
          {
            field.meta = [];
          }
          fn.expr = newExpr;
        case _:
        }
      }

      Globals.cur.gluesToGenerate = Globals.cur.gluesToGenerate.add(expose.getClassPath());
      Globals.cur.cachedBuiltTypes.push(expose.getClassPath());
      Globals.cur.hasUnprocessedTypes = true;
      metas.push({ name:':skipUExternCheck', params:[], pos:clt.pos });
      Context.defineType({
        pack: expose.pack,
        name: expose.name,
        pos: clt.pos,
        meta: metas,
        kind: TDClass(),
        fields: buildFields
      }
#if (haxe_ver >= 4)
      , clt.module // make sure that the class module is added as a dependency
#end
      );
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
    var uclass = clt.meta.extract(UhxMeta.UClass)[0];
    if (uclass != null) {
      includes.add('${fileName}.generated.h');
    } else {
      // We might want to add a new metadata to allow these
      // For now, I don't really see the value of having a non-uclass that extends a uobject
      // so we'll just fail
      throw new Error('Unreal Extension: This UObject-derived class does not contain a `@:uclass` metadata', clt.pos);
    }

    var hasHaxeSuper = false;
    if (clt.superClass != null) {
      // TESTME - test extending Haxe classes
      var tconv = TypeConv.get( TInst(clt.superClass.t, clt.superClass.params), clt.pos );
      // any superclass here should also be present in the native side
      extendsAndImplements.push('public ' + tconv.ueType.getCppClass());

      hasHaxeSuper =  !clt.superClass.t.get().meta.has(UhxMeta.UExtern);
      // we're using the ueType so we'll include the glueCppIncludes
      tconv.collectUeIncludes( includes );
    }
    for (iface in clt.interfaces) {
      var impl = iface.t.get();
      // TODO: support UE4 interface declaration in Haxe; for now we'll only add @:uextern interfaces
      // look into @:uextern.
      if (impl.meta.has(UhxMeta.UExtern)) {
        var tconv = TypeConv.get( TInst(iface.t, iface.params), clt.pos );
        extendsAndImplements.push('public ' + tconv.ueType.getCppClass());
        // we're using the ueType so we'll include the glueCppIncludes
        tconv.collectUeIncludes( includes );
      }
    }

    var targetModule = Globals.cur.module;
    var headerDef = new CodeFormatter(),
        cppDef = null;
    if (Globals.isDynamicUType(clt)) {
      includes.add('uhx/DynamicClass.h');
      headerDef.add('#if true // UHT bug: it will not find a UCLASS specifier if the following is not enclosed in a ifdef\n');
      headerDef.add('DECLARE_UHX_DYNAMIC_UCLASS(${ueName});\n');
      headerDef.add('#endif\n\n');
      cppDef = new StringBuf();
      cppDef.add('DEFINE_UHX_DYNAMIC_UCLASS(${ueName});\n');
    }
    if (clt.doc != null) {
      headerDef << new Comment(clt.doc);
    }
    if (uclass != null) {
      headerDef.add('UCLASS(');
      MacroHelpers.addHaxeGenerated(uclass, typeRef);
      if (uclass.params != null) {
        var first = true;
        for (param in uclass.params) {
          if (first) first = false; else headerDef.add(', ');
          headerDef.add(param.toString().replace('[','(').replace(']',')'));
        }
      }
      headerDef.add(')') << new Newline();
    }
    headerDef.add('class ${targetModule.toUpperCase()}_API ${ueName} ');
    if (extendsAndImplements.length > 0) {
      headerDef.add(' : ');
      headerDef.add(extendsAndImplements.join(', '));
    }
    headerDef << new Begin(' {');
    if (uclass != null) {
      headerDef << 'GENERATED_BODY()' << new Newline();
    }
    var superConv = TypeConv.get( TInst(clt.superClass.t, clt.superClass.params), clt.pos);
    var superName = superConv.ueType.getCppClass();

    headerDef << 'private:' << new Newline() << 'static FName uhx_className;' << new Newline();
    if (cppDef == null) {
      cppDef = new StringBuf();
    }
    headerDef << 'public:' << new Newline();
    // include class map
    includes.add('uhx/ue/ClassMap.h');
    headerDef << 'static unreal::UIntPtr getHaxePointer(unreal::UIntPtr inUObject)' << new Begin(' {')
      << 'return (unreal::UIntPtr) ( (${ueName} *) inUObject )->haxeGcRef.get();' << new End('}') << new Newline();

    var objectInit = new HelperBuf() << 'ObjectInitializer';
    var useObjInitializer = clt.meta.has(UhxMeta.NoDefaultConstructor) || (clt.superClass != null && clt.superClass.t.get().meta.has(UhxMeta.NoDefaultConstructor));
    for (fld in clt.meta.extract(UhxMeta.UOverrideSubobject)) {
      useObjInitializer = true;
      if (fld.params == null || fld.params.length != 2) {
        throw new Error(':uoverrideSubobject requires two parameters: the name of the component, and the override type', clt.pos);
      }
      var overrideName = switch (fld.params[0].expr) {
      case EConst(CString(s)): '"${s.replace("\n","\\n").replace("\t","\\t").replace("'","\\'").replace('"',"\\\"")}"';
      case EField(_) | EConst(CIdent(_)):
        fld.params[0].toString().replace('.','::');
      default: throw new Error('@:uoverrideSubobject first parameter should be the name of the component to override', clt.pos);
      }

      var overrideType = Context.getType(fld.params[1].toString());
      var overrideTypeConv = TypeConv.get(overrideType, clt.pos).withModifiers(null);
      overrideTypeConv.collectUeIncludes(includes);
      objectInit << '.SetDefaultSubobjectClass<${overrideTypeConv.ueType.getCppClass()}>($overrideName)';
    }

    cppDef.add('FName ${ueName}::uhx_className = uhx::UEHelpers::setIsHaxeGenerated( FName(TEXT("${ueName.substr(1)}")) );\n');

    includes.add('uhx/UEHelpers.h');
    var ctorBody = new HelperBuf();
    // first add our unwrapper to the class map
    ctorBody << 'static bool addToMap = ::uhx::ue::ClassMap_obj::addWrapper((unreal::UIntPtr) $ueName::StaticClass(), &getHaxePointer);\n'
      << 'static bool addFunctions = ::uhx::expose::HxcppRuntime::addHaxeBlueprintOverrides("${typeRef.getClassPath(true)}", (unreal::UIntPtr) $ueName::StaticClass());\n'
      << 'UClass *curClass = ObjectInitializer.GetClass();\n'
      << '::uhx::UEHelpers::create${Context.defined("WITH_CPPIA") ? "Dynamic" : ""}WrapperIfNeeded(uhx_className,curClass,this->haxeGcRef,this,&createHaxeWrapper);';

    if (!hasHaxeSuper) {
      headerDef << '::uhx::GcRef haxeGcRef;' << new Newline();
      if (useObjInitializer) {
        headerDef.add('${ueName}(const FObjectInitializer& ObjectInitializer = FObjectInitializer::Get()) : $superName($objectInit)');
      } else {
        headerDef.add('${ueName}(const FObjectInitializer& ObjectInitializer = FObjectInitializer::Get())');
      }
    } else {
      headerDef.add('${ueName}(const FObjectInitializer& ObjectInitializer = FObjectInitializer::Get()) : $superName($objectInit)');
    }
    headerDef << new Begin(' {');
      headerDef.addNewlines(ctorBody.toString());
    headerDef << new End('}') << new Newline();

    if (Globals.isDynamicUType(clt) && (clt.superClass == null || !Globals.isDynamicUType(clt.superClass.t.get()))) {
      includes.add('UObject/Stack.h');
      headerDef << 'public:' << new Newline()
        << 'static void ${Globals.UHX_CALL_FUNCTION}( UObject* Context, FFrame& Stack, RESULT_DECL ) ' << new Begin(" {")
          << '::uhx::expose::HxcppRuntime::callHaxeFunction(reinterpret_cast<unreal::UIntPtr>(Context), unreal::VariantPtr::fromExternalPointer(&Stack), reinterpret_cast<unreal::UIntPtr>(RESULT_PARAM));'
        << new End('}') << new Newline();
    }

    // metas.push({ name: ':haxeGenerated', params:[], pos: clt.pos });
    metas.push({ name: ':glueHeaderIncludes', params:[for (inc in includes) macro $v{inc}], pos: clt.pos });
    metas.push({ name: ':ueHeaderDef', params:[macro $v{headerDef.toString()}], pos: clt.pos });
    metas.push({ name: ':uexportheader', params:[], pos: clt.pos });
    if (cppDef != null) {
      metas.push({ name: ':ueCppDef', params:[macro $v{cppDef.toString()}], pos: clt.pos });
    }

    return { hasHaxeSuper: hasHaxeSuper };
  }

  private static function getMethodDef(field:ClassField, overriddenField:ClassField, fieldType:FieldType) {
    if (overriddenField != null && !field.meta.has(':supressOverrideCheck')) {
      var reason = [];
      switch [Context.follow(field.type), Context.follow(overriddenField.type)] {
      case [TFun(a1,r1), TFun(a2,r2)]:
        if (a1.length != a2.length) {
          reason.push('different number of arguments');
        } else {
          for (i in 0...a1.length) {
            var t2 = TypeConv.get(a2[i].t, field.pos);
            if (!TypeConv.get(a1[i].t, field.pos).equivalentTo(t2) && t2.ueType.withoutPointer(true).name != 'FString') {
              reason.push('the type of the argument ${a1[i].name} should be ${t2.haxeType}');
            }
          }
          var r2 = TypeConv.get(r2, field.pos);
          if (!TypeConv.get(r1, field.pos).equivalentTo(r2)) {
            reason.push('the return type should be ${r2.haxeType}');
          }
        }
      case _:
        throw 'assert';
      }
      if (reason.length > 0) {
        var msg = 'Unreal.hx: The function ${field.name} override has invalid argument issues:\n'
                  + reason.join('\n') + '\n'
                  + 'If this is intentional, you can add a @:supressOverrideCheck metadata to your function definition';
        Context.warning(msg, field.pos);
      }
    }

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
      if (cur.meta.has(UhxMeta.UExtern)) {
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
        if (cl.meta.has(UhxMeta.UExtern)) {
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
      if (cur.meta.has(UhxMeta.UExtern)) {
        break;
      }
      for (field in cur.fields.get())
        ret[field.name] = true;
      sclass = cur.superClass;
    }
    return ret;
  }

  private static function isCustomReplicationType(repType:String) : Bool {
    if (repType == null) {
      return false;
    }

    return switch(repType) {
      case 'InitialOnly', 'OwnerOnly',
      #if proletariat
      'OwnerOrSpectatingOwner',
      #end
      'SkipOwner', 'SimulatedOnly', 'AutonomousOnly', 'SimulatedOrPhysics', 'InitialOrOwner': false;
      default: true;
    }
  }

  private static function hasReturn(e:Expr) {
    var ret = false;
    function check(e:Expr) {
      switch(e.expr) {
      case EReturn(_): ret = true;
      case _:
        if (!ret){
          e.iter(check);
        }
      }
    }
    check(e);
    return ret;
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
