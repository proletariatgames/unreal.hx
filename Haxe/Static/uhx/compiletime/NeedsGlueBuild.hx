package uhx.compiletime;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import uhx.compiletime.types.*;
import uhx.meta.MetaDef;

using Lambda;
using uhx.compiletime.tools.MacroHelpers;
using haxe.macro.Tools;

class NeedsGlueBuild
{
  static var checkedVersion = false;
  public static function build():Array<Field>
  {
    #if bake_externs
    return null;
    #end
    var localClass = Context.getLocalClass(),
        cls:ClassType = localClass.get();
    if (Context.defined('UHX_DISPLAY') || (Context.defined('LIVE_RELOAD_BUILD') && !Globals.cur.liveReloadModules[cls.module])) {
      if (cls.isInterface || cls.isExtern) {
        return null;
      }
      if (Context.defined('UHX_DISPLAY')) {
        var displayPos = haxe.macro.Compiler.getDisplayPos();
        if (displayPos == null ||
            sys.FileSystem.fullPath(displayPos.file).toLowerCase() != sys.FileSystem.fullPath(Context.getPosInfos(cls.pos).file).toLowerCase()
          )
        {
          return null;
        }
      }

      var fields:Array<Field> = Context.getBuildFields(),
          needsUpdate = false,
          toAdd = [];

      var fieldNames = [for (field in fields) field.name => field];
      if (cls.meta.has(':uclass') && !fieldNames.exists('StaticClass')) {
        var dummy = macro class {
          public static function StaticClass():unreal.UClass { return null; }
        };
        needsUpdate = true;
        toAdd.push(dummy.fields[0]);
      }
      for (field in fields) {
        switch (field.kind) {
        case FFun(fn):
          if (fn.expr == null) {
            fn.expr = macro {throw "Not Implemented";};
            needsUpdate = true;
          }
          if (field.meta.hasMeta(':ufunction') || field.meta.hasMeta(':uexpose')) {
            var glueFnName = '_get_${field.name}_methodPtr';
            if (!fieldNames.exists(glueFnName)) {
              needsUpdate = true;

              var dummy = macro class {
                private static function $glueFnName() : unreal.UIntPtr {
                  return cast 0;
                }
              }
              toAdd.push(dummy.fields[0]);
            }
          }
        case _:
        }
      }
      if (needsUpdate) {
        return fields.concat(toAdd);
      } else {
        return null;
      }
    }

    // check version level
    if (!checkedVersion) {
      Globals.cur.checkBuildVersionLevel();
      checkedVersion = true;
    }
    var thisType = TypeRef.fromBaseType(cls, cls.pos);

    var disableUObject = Context.defined('UHX_NO_UOBJECT');
    if (disableUObject) {
      var cur = cls;
      while (cur != null) {
        if (cur.name == 'UObject') {
          switch(localClass.toString()) {
          case 'unreal.UObject' | 'unreal.UClass':
            // don't exclude
          case _:
            cls.exclude();
          }
          return [];
        }

        if (cur.superClass != null) {
          cur = cur.superClass.t.get();
        } else {
          break;
        }
      }
    }

    if (Globals.cur.gluesTouched.exists(localClass.toString()))
      return null;

    Globals.cur.gluesTouched[localClass.toString()] = true;

    if (cls.meta.has(':ueGluePath')) {
      Globals.cur.gluesToGenerate = Globals.cur.gluesToGenerate.add(thisType.getClassPath());
    }
    if (cls.meta.has(':ueNoGlue')) {
      return null;
    }

    var superClass = cls.superClass == null ? null : cls.superClass.t.get();

    if (!cls.meta.has(':uextern')) {
      cls.meta.add(':uextension', [], cls.pos);
      if (!Globals.cur.staticModules.exists(cls.module)) {
        cls.meta.add(':uscript', [], cls.pos);
      } else {
        var hxPath = localClass.toString();
        var uname = MacroHelpers.getUName(cls);
        Globals.cur.staticUTypes[hxPath] = { hxPath:hxPath, uname: uname, type: CompiledClassType.CUClass };
      }
      // FIXME: allow any namespace by using @:native; add @:native handling
      if (cls.pack.length == 0)
        throw new Error('Unreal Glue Extension: Do not extend Unreal types on the global namespace. Use a package', cls.pos);
      // if we don't have the @:uextern meta, it means
      // we're subclassing an extern class

      // non-extern type that derives from UObject:
      // change uproperties to call getter/setters
      // warn if constructors are created
      var fields:Array<Field> = Context.getBuildFields();
      var ret = processType(cls, function(str) return Globals.cur.typedClassCache.findField(superClass, str,false), thisType, fields);
      if (ret != null && cls.isInterface) {
        for (field in ret) {
          switch(field.kind) {
          case FFun(fn):
            fn.expr = null;
          case _:
          }
        }
      }
      return ret;
    }

    return null;
  }

  public static function processType(type:BaseType, findSuperField:Null<String->ClassField>, thisType:TypeRef, fields:Array<Field>):Array<Field> {
    var hadErrors = false,
        toAdd:Array<Field> = [];
    var delayedglue = macro uhx.internal.DelayedGlue;
    if (Context.defined('UHX_DISPLAY') || (Context.defined('cppia') && Globals.cur.staticModules.exists(type.module))) {
      // don't spend precious macro processing time if this is not a script module
      delayedglue = macro cast null;
    }

    var isDynamicUType = Globals.isDynamicUType(type),
        superClass = null,
        firstExternSuper = null,
        hasNativeInterfaces = false,
        nonNativeFunctions = new Map();
    var typeSuper = (cast type : ClassType).superClass;
    var parent = typeSuper == null ? null : Globals.classCache.getClassData(typeSuper.t.get());
    {
      if (parent != null) {
        superClass = typeSuper.t.get();
        var cur = parent;
        while(cur != null) {
          if (cur.meta.has(':uextern')) {
            firstExternSuper = cur;
            break;
          }
          for (field in cur.members) {
            nonNativeFunctions[field.name] = true;
          }
          cur = cur.parent;
        }
      }

      var ifaces = (cast type : ClassType).interfaces;
      if (ifaces != null) {
        function checkInterface(iface:ClassType) {
          if (hasNativeInterfaces) return;
          if (iface.meta.has(':uextern')) {
            hasNativeInterfaces = true;
            return;
          }
          for (iface in iface.interfaces) {
            checkInterface(iface.t.get());
          }
        }
        for (iface in ifaces) {
          checkInterface(iface.t.get());
        }
      }
    }

    if (isDynamicUType && hasNativeInterfaces) {
      Context.error(
        'The class ${type.name} is a dynamic script class, but it implements native interfaces.' +
        'Consider adding @:upropertyExpose to this class so no uproperties are dynamically created', type.pos);
    }

    if (!isDynamicUType && superClass != null && Globals.isDynamicUType(superClass)) {
      Context.error(
        'A @:upropertyExpose class definition cannot have a Dynamic script superclass.' +
        'Consider adding @:upropertyExpose to the superclass, or taking it off from the current class definition', type.pos);
    }

    var changed = false;
    var superCalls = new Map(),
        uprops = [];
    var nativeCalls = new Map();
    if (Context.defined('cppia') && !Globals.cur.staticModules.exists(type.module)) {
      Globals.cur.classesToAddMetaDef.push(thisType.getClassPath());
    }

    if (type.meta.has(':uclass') && Context.defined('cppia') || Context.defined('WITH_CPPIA')) {
      var dummy = macro class {
        @:noUsing @:noCompletion private function dummy() {
          $delayedglue.checkClass();
        }
      }
      var cur = dummy.fields[0];
      cur.name = 'uhx_dummy_check_' + type.name;
      toAdd.push(cur);
    }

    var methodPtrs = new Map();
    var usesCppia = Context.defined('cppia') || Context.defined("WITH_CPPIA");
    var clsName = type.pack.join('_') + '_' + type.name;
    for (field in fields) {
      if (field.kind.match(FFun(_)) && usesCppia) {
        var needsStatic = field.meta.hasMeta(':uexpose');
        if (!needsStatic && isDynamicUType) {
          needsStatic = field.access != null && field.access.has(AOverride) && !nonNativeFunctions.exists(field.name);
        }
        if (needsStatic) {
          var dummy = macro class {
            #if !haxe4 @:extern #end @:noUsing @:noCompletion inline private function dummy() {
              $delayedglue.checkCompiled($v{field.name}, @:pos(field.pos) $i{field.name}, $v{field.access != null && field.access.has(AStatic)});
            }
          };
          var cur = dummy.fields[0];
          cur.name = 'uhx_dummy_check_' + field.name;
          toAdd.push(cur);
        }
      }

      if (field.access != null && (field.access.has(AOverride) || field.meta.hasMeta(':hasSuper'))) {
        field.meta.push({ name:':keep', pos:field.pos });
        // TODO: should we check for non-override fields as well? This would
        //       add some overhead for all override fields, which is something I'd like to avoid for now
        //       specially since super calling in other fields doesn't seem particularly useful
        switch (field.kind) {
        case FFun(fn) if (fn.expr != null):
          var fnName = field.name;

          var hasSuper = false;
          function map(e:Expr) {
            return switch (e.expr) {
            case ECall(macro super.$sfield, args):
              superCalls[sfield] = { expr: EConst(CString(sfield)), pos:e.pos };
              var args = [ for (arg in args) map(arg) ];
              changed = true;
              hasSuper = true;
              if (Context.defined('LIVE_RELOAD_BUILD')) {
                var name = field.name + '_super_' + clsName;
                { expr:ECall(macro @:pos(e.pos) this.$name, args), pos:e.pos };
              } else {
                { expr:ECall(macro @:pos(e.pos) $delayedglue.getSuperExpr, [macro $v{sfield}, macro $v{sfield}].concat(args)), pos:e.pos };
              }
            case _:
              e.map(map);
            }
          }
          var shouldMap = !Context.defined('cppia') || Globals.cur.inScriptPass || !Globals.cur.staticModules.exists(type.module);
          if (shouldMap) {
            fn.expr = map(fn.expr);
          }
          if (hasSuper && Context.defined('WITH_LIVE_RELOAD'))
          {
            superCalls[fnName] = { expr: EConst(CString(fnName)), pos:field.pos };
            var args = [ for (i in 0...fn.args.length) macro @:pos(field.pos) $i{'arg$i'} ];
            var superCall = Context.defined('LIVE_RELOAD_BUILD') ? macro throw 'assert' : { expr:ECall(macro @:pos(field.pos) $delayedglue.getSuperExprSeparate, [macro $v{fnName}, macro $v{fnName + '_super_' + clsName}].concat(args)), pos:field.pos };
            toAdd.push({
              name: field.name + '_super_' + clsName,
              pos: field.pos,
              access: [APrivate],
              meta: [{ name:':noCompletion', pos:field.pos }, { name:':compilerGenerated', pos:field.pos }],
              kind: FFun({
                args: [for (i in 0...fn.args.length) {
                  name: 'arg$i',
                  opt: fn.args[i].opt,
                  type: null
                }],
                ret: fn.ret,
                expr: superCall
              })
            });
          }
        case _:
        }
      }
      var isExposedProp = false,
          isDynamic = false,
          isStatic = field.access != null && field.access.has(AStatic);

      switch(field.kind) {
      case FVar(_) | FProp(_):
        var hasExpose = field.meta.hasMeta(":uexpose");
        isExposedProp = Globals.shouldExposePropertyExpr(field, isDynamicUType);
        isDynamic = !hasExpose && isDynamicUType;

        if (!isStatic && isDynamicUType && hasExpose) {
          // check if the parent is also dynamic
          if (superClass != null && Globals.isDynamicUType(superClass)) {
            Context.warning(
              'Unreal Glue Extension: uexpose properties can only exist in subclasses of non-dynamic script UClasses. ' +
              'Consider adding @:upropExpose on the superclass, or taking the @:uexpose off from this property.',
              field.pos);
            hadErrors = true;
          }
        }
      case _:
      }

      var shouldAddGetterSetter = isExposedProp;
      if (!shouldAddGetterSetter && Context.defined('cppia') && field.meta.hasMeta(':uproperty')) {
        shouldAddGetterSetter = true;
      }

      if (shouldAddGetterSetter) {
        field.meta.push({ name:':keep', pos:field.pos });
        changed = true;
        switch (field.kind) {
          case FVar(t,e) | FProp('default','default',t,e) if (t != null):
            if (isDynamic) {
              var staticPropName = 'uhx__prop_${field.name}';
              var dummy = macro class {
                private static var $staticPropName:unreal.UProperty;
              };
              toAdd.push(dummy.fields[0]);
            }
            var fieldUName = field.meta.extractStringsFromMetadata(':uname')[0];
            if (fieldUName == null) {
              fieldUName = field.name;
            }
            uprops.push(field.name);
            var getter = 'get_' + field.name,
                setter = 'set_' + field.name;
            var dummy = macro class {
              private function $getter():$t {
                return $delayedglue.getGetterSetterExpr($v{field.name}, $v{isStatic}, false, $v{isDynamic}, $v{fieldUName});
              }
              private function $setter(value:$t):$t {
                $delayedglue.getGetterSetterExpr($v{field.name}, $v{isStatic}, true, $v{isDynamic}, $v{fieldUName});
                return value;
              }
            };
            if (isStatic) {
              for (field in dummy.fields) field.access.push(AStatic);
            }

            for (field in dummy.fields) toAdd.push(field);
            field.kind = FProp("get", "set", t, e);
          case FProp(_,_,_,_):
            Context.warning(
              'Unreal Glue Extension: uproperty properties with getters and setters are not supported by Unreal',
              field.pos);
            hadErrors = true;
          case FFun(_):
            Context.warning('Unreal Glue Extension: uproperty is not compatible with functions', field.pos);
            hadErrors = true;
          case _:
            Context.warning(
              'Unreal Glue Extension: uproperty properties must have a type',
              field.pos);
            hadErrors = true;
        }
      }

      // add the methodPtr accessor for any functions that are exposed/implemented in C++
      var overridesNative = field.access != null && field.access.has(AOverride) && firstExternSuper == null && !isStatic &&
                            firstExternSuper != null && !nonNativeFunctions.exists(field.name);
      var originalNativeField = overridesNative && firstExternSuper != null ? firstExternSuper.findField(field.name) : null;
      var shouldExposeFn = Globals.shouldExposeFunctionExpr(
          field,
          isDynamicUType,
          originalNativeField == null ? null : originalNativeField.meta);
      if (!isStatic && shouldExposeFn) {
        field.meta.push({ name:':keep', pos:field.pos });
        switch (field.kind) {
        case FFun(_):
          var uname = field.name;
          var unameMeta = MacroHelpers.extractMeta(field.meta, ':uname');
          if (unameMeta != null) {
            uname = switch(unameMeta.params[0].expr) {
              case EConst(CIdent(s)): s;
              case EConst(CString(s)): s;
              default: field.name;
            };
          }

          var glueFnName = '_get_${field.name}_methodPtr';

          var dummy = macro class {
            private static function $glueFnName() : unreal.UIntPtr {
              return $delayedglue.getNativeCall($v{glueFnName}, true);
            }
          }
          methodPtrs[field.name] = field.name;
          toAdd.push(dummy.fields[0]);
        case _:
        }
      }
      var parentField = originalNativeField != null || parent == null || (field.access != null && field.access.has(AStatic)) ?
          originalNativeField :
          parent.findField(field.name);
      if (parentField != null && parentField.meta.has(':ufunction')) {
        var ufunc = parentField.meta.extract(":ufunction");
        for (meta in ufunc) {
          for (meta in meta.params) {
            if (UExtensionBuild.ufuncBlueprintOverridable(meta)) {
              if (isDynamicUType) {
                field.meta.push({name:':ufunction', params:[], pos:field.pos});
                changed = true;
              } else {
                field.meta.push({name:':uname', params:[macro $v{field.name + '_Implementation'}], pos:field.pos});
                if (!UExtensionBuild.ufuncBlueprintNativeEvent(meta)) {
                  field.meta.push({name:':ufunction', params:[], pos:field.pos});
                  field.meta.push({name:'uhx_OverridesNative', params:[macro $v{field.name}], pos:field.pos});
                }
                changed = true;
              }
              break;
            }
          }
        }
      }

      for (meta in field.meta) {
        if (meta.name == ':ufunction' && meta.params != null) {
          var fn = switch (field.kind) {
          case FFun(f):
            f;
          case _:
            throw new Error('Unreal Glue Extension: @:ufunction meta on a non-function', field.pos);
          };
          for (param in meta.params) {
            if (UExtensionBuild.ufuncMetaNoImpl(param)) {
              var name = switch (param.expr) {
              case EConst(CIdent(i)):
                i;
              case _: throw 'assert';
              }

              if (fn.expr != null) {
                Context.warning('Unreal Glue Extension: $name ufunctions should not contain any implementation', field.pos);
                hadErrors = true;
              }
              var call:Expr = null;
              if (shouldExposeFn) {
                nativeCalls[field.name] = field.name;
                call = {
                  expr:ECall(
                    macro @:pos(field.pos) $delayedglue.getNativeCall,
                    [macro $v{field.name}, macro $v{isStatic}].concat([ for (arg in fn.args) macro $i{arg.name} ])),
                  pos: field.pos
                };
              } else {
                var uname = field.name;
                var callArgs = [ for (arg in fn.args) macro $i{arg.name} ];
                var exprCall = macro unreal.ReflectAPI.callUFunction(this, fn, $a{callArgs});
                var implCheck = macro { },
                    implCall = macro { };
                if (meta.params.exists(UExtensionBuild.ufuncMetaNeedsImpl)) {
                  var impl = field.name + '_Implementation';
                  implCall = { expr:ECall(macro this.$impl, callArgs), pos:field.pos };
                  exprCall = macro if (fn != null) $exprCall else $implCall;
                  if (!meta.params.exists(UExtensionBuild.ufuncMetaIsNet)) {
                    implCheck = macro if (fn.HasAllFunctionFlags(unreal.EFunctionFlags.FUNC_Native)) {
                      fn = null;
                    };
                  }
                }
                if (meta.params.exists(UExtensionBuild.ufuncNeedsValidation)) {
                  var name = field.name + '_Validate';
                  var validationCall = { expr:ECall(macro @:pos(field.pos) this.$name, callArgs), pos:field.pos };
                  var validationCheck = macro if (!$validationCall) {
                    UObject.RPC_ValidateFailed($v{name});
                    @:pos(field.pos) return;
                  };
                  toAdd.push({
                    name: field.name + '_DynamicRun',
                    kind: FFun({
                      args: fn.args,
                      ret: fn.ret,
                      expr: macro {
                        $validationCheck;
                        $implCall;
                      }
                    }),
                    pos: field.pos,
                    meta:[ { name:':noCompletion', params:[], pos:field.pos } ]
                  });
                }

                call = macro {
                  var fn = null;
                  fn = unreal.ReflectAPI.getUFunctionFromObject(this, $v{uname});
                  $implCheck;
                  $exprCall;
                };
              }

              switch (fn.ret) {
              case null | TPath({ pack:[], name:"Void" }):
                fn.expr = macro { $call; };
              case _:
                fn.expr = macro { return cast $call; };
              }
              changed = true;
              if (!meta.params.exists(function(meta) return UExtensionBuild.ufuncBlueprintOverridable(meta) && !UExtensionBuild.ufuncBlueprintNativeEvent(meta))) {
                field.meta.push({ name:':final', params:[], pos:field.pos });
              }
            }

            if (UExtensionBuild.ufuncMetaNeedsImpl(param) || UExtensionBuild.ufuncNeedsValidation(param)) {
              var suffix = UExtensionBuild.ufuncMetaNeedsImpl(param) ? "_Implementation" : "_Validate";
              var name = switch (param.expr) {
              case EConst(CIdent(i)):
                i;
              case _: throw 'assert';
              }

              var found = false;
              for (impl in fields) {
                if (impl.name == field.name + suffix) {
                  found = true;
                  if (shouldExposeFn) {
                    // expose Implementation as well
                    impl.meta.push({ name:':uexpose', params:[], pos:impl.pos });
                  }
                  break;
                }
              }
              if (!found) {
                Context.warning('Unreal Glue Extension: $name ufunctions need a `$suffix` function which is missing for function ${field.name}', field.pos);
                hadErrors = true;
              }
            }
          }
        } else if (meta.name == ':uproperty' && meta.params != null) {
          for (param in meta.params) {
            if (UExtensionBuild.upropReplicated(param) && !field.meta.hasMeta(":ureplicate")) {
              Context.warning('Do not use `Replicated`. Instead, use the @:ureplicate metadata. Please refer to the Unreal.hx documentation for more information', param.pos);
            }
            switch(param.expr) {
              case EBinop(OpAssign, { expr:EConst(CIdent(left) | CString(left)) }, { expr:EConst(CIdent(right) | CString(right)) }):
                if (left.toLowerCase() == 'blueprintgetter' || left.toLowerCase() == 'blueprintsetter') {
#if (UE_VER < 4.17)
                  Context.warning('Unreal Glue Extension: $left is not available for this unreal version (for field ${field.name})', param.pos);
                  hadErrors = true;
                  continue;
#end
                  // make sure that the function exists and has the correct metadata
                  var fn = fields.find(function(f) return f.name == right);
                  if (fn == null) {
                    Context.warning('Unreal Glue Extension: ${field.name} requires the function $right, as specified in $left', param.pos);
                    hadErrors = true;
                    continue;
                  }
                  if (!fn.meta.hasMeta(':ufunction')) {
                    Context.warning('Unreal Glue Extension: $left must be a ufunction, as specified by ${field.name} ($left)', fn.pos);
                    hadErrors = true;
                    continue;
                  }
                  var fnMeta = [ for (meta in fn.meta.extractStringsFromMetadata(':ufunction')) meta.toLowerCase() ];
                  if (!fnMeta.has(left.toLowerCase())) {
                    // just add it
                    var meta = fn.meta.extractMeta(':ufunction');
                    if (meta.params == null) {
                      meta.params = [];
                    }
                    meta.params.push(macro $i{left});
                  }

                  // make sure that the function has the correct type
                  // delay the type test to an expression, so it can be inferred
                  var fieldName = field.name;
                  var expr = left.toLowerCase() == 'blueprintgetter' ?
                    macro @:pos(fn.pos) $i{fieldName} = $i{right}() :
                    macro @:pos(fn.pos) $i{right}($i{fieldName});
                  var dummy = macro class {
                    #if !haxe4 @:extern #end @:noCompletion private function dummy() {
                      $expr;
                    }
                  };
                  var field = dummy.fields[0];
                  field.name = 'uhx_type_check_${fieldName}_$right';
                  toAdd.push(field);
                }
              case EConst(CIdent(s) | CString(s)):
                if (s.toLowerCase() == 'blueprintgetter' || s.toLowerCase() == 'blueprintsetter') {
                  Context.warning('Unreal Glue Extension: Missing the target function specifier for $s', param.pos);
                  hadErrors = true;
                }
              case _:
            }
          }
        }
      }
    }

    if (!type.meta.has(':ustruct')) {
      var uname = MacroHelpers.getUName(type);
      var thisClassName = thisType.getClassPath(true);
      var staticClassDef = macro class {
        public static function StaticClass() : unreal.UClass {
          return $delayedglue.getNativeCall('StaticClass', true);
        }

        @:ifFeature($v{thisClassName})
        @:glueCppBody($v{'return (int) sizeof(' + uname + ')'})
        public static function CPPSize() : Int {
          return $delayedglue.getNativeCall('CPPSize', true);
        }

        @:keep private static var _uhx_isHaxeType:Bool = true;
      };
      if (Context.defined('cppia')) {
        staticClassDef.fields[0].access.push(ADynamic);
        if (!Context.defined('UHX_DISPLAY') && !Globals.cur.compiledScriptGluesExists(thisClassName + ':')) {
          Context.warning('UHXERR: The @:uclass ${thisClassName} was never compiled into C++. It is recommended to run a full C++ compilation', type.pos);
        }
      }

      for (field in staticClassDef.fields) {
        toAdd.push(field);
      }
      nativeCalls.set('StaticClass', 'StaticClass');
      nativeCalls.set('CPPSize', 'CPPSize');
      if (isDynamicUType && (superClass == null || !Globals.isDynamicUType(superClass))) {
        var ufuncCallDef = macro class {
          @:ifFeature($v{thisClassName})
          @:glueCppIncludes("IntPtr.h", "CoreMinimal.h","UObject/Class.h")
          @:glueCppBody($v{'{
            UFunction *realFn = ((UFunction*)fn);
            FNativeFuncPtr native = (FNativeFuncPtr)&' + uname + '::' + Globals.UHX_CALL_FUNCTION + ';
            ((UClass *) cls)->AddNativeFunction(*realFn->GetName(), native);
            ((UFunction*) fn)->SetNativeFunc(native);
          }'})
          public static function setupFunction(cls:unreal.UIntPtr, fn:unreal.UIntPtr):Void {
            $delayedglue.getNativeCall('setupFunction', true, cls, fn);
          }
        };

        for (field in ufuncCallDef.fields) {
          toAdd.push(field);
        }
        nativeCalls.set('setupFunction', 'setupFunction');
      }
    }
    if (Context.defined('cppia') && !Context.defined('LIVE_RELOAD_BUILD')) {
      var def = macro class {
        @:noCompletion static var uhx_glueScript(get,null):Dynamic;
        @:noCompletion static function get_uhx_glueScript():Dynamic {
          if (uhx_glueScript == null) {
            uhx_glueScript = Type.resolveClass($v{thisType.getScriptGlueType().getClassPath(true)});
          }
          return uhx_glueScript;
        }
      };
      type.meta.add(':hasGlueScriptGetter', [], type.pos);
      for (field in def.fields) {
        toAdd.push(field);
      }
    }

    if (uprops.length > 0)
      type.meta.add(':uproperties', [ for (prop in uprops) macro $v{prop} ], type.pos);
    type.meta.add(':usupercalls', [ for (call in superCalls) call ], type.pos);
    type.meta.add(':unativecalls', [ for (call in nativeCalls) macro $v{call} ], type.pos);
    type.meta.add(':umethodptrs', [ for(call in methodPtrs) macro $v{call} ], type.pos);

    // mark to add the haxe-side glue helper
    if (!type.meta.has(':ustruct')) {
      Globals.cur.uextensions = Globals.cur.uextensions.add(thisType.getClassPath());
    } else {
      // Haxe-defined USTRUCTs are handled specially in DelayedGlue
    }

    if (hadErrors)
      Context.error('Unreal Glue Extension: Build failed', type.pos);
    changed = uhx.compiletime.LiveReloadBuild.injectProloguesForFields(type, fields) || changed;
    var meta = { name:':compilerGenerated', params:[], pos:type.pos };

    // add the glueRef definition if needed
    for (field in toAdd) {
      if (field.meta == null)
      {
        field.meta = [meta];
      } else {
        field.meta.push(meta);
      }
      fields.push(field);
    }

    if (toAdd.length > 0 || changed)
      return fields;
    return null;
  }
}
