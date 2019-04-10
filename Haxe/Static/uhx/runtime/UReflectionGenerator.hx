package uhx.runtime;
import uhx.meta.MetaDef;
import uhx.ue.RuntimeLibrary;
import unreal.*;
import unreal.EFunctionFlags;
import unreal.EPropertyFlags.*;
import unreal.EPropertyFlags;
import unreal.CoreAPI;
import haxe.rtti.Meta;

using StringTools;
using Lambda;

enum HotReloadStatus {
  Success;
  Failure;
  WaitingRebind;
}

/**
  Given a metadata setting, generates an Unreal UClass/UStruct/UEnum
 **/
class UReflectionGenerator {
#if !UHX_NO_UOBJECT

public static function addHaxeBlueprintOverrides(clsName:String, uclass:UClass) {
  var cls = Type.resolveClass(clsName);
  if (cls == null) {
    trace('Error', 'Could not add haxe blueprint overrides for $clsName: it was not found!');
    return;
  }
  var fields:haxe.DynamicAccess<Dynamic<Array<Dynamic>>> = cast haxe.rtti.Meta.getFields(cls);
  for (field in fields.keys()) {
    if (fields[field].uhx_OverridesNative != null) {
      var fn = uclass.FindFunctionByName(field + '_Implementation');
      if (fn == null) {
        trace('Error', 'The ufunction ${field}_Implementation was not found on $clsName!');
        continue;
      }
#if (UE_VER < 4.19)
      uclass.AddFunctionToFunctionMapWithOverriddenName(fn, field);
#else
      uclass.AddFunctionToFunctionMap(fn, field);
#end
    }
  }
}

#if (WITH_CPPIA && !NO_DYNAMIC_UCLASS)
  private static var registry:Map<String, DynamicRegistry>;

  private static var uclassNames:Array<String>;

  private static var staticHxToUClass:Map<String, StaticMeta>;
  private static var staticUClassToHx:Map<String, StaticMeta>;

  private static var scriptDelegates:Map<String, UDelegateDef>;
  private static var customReplicationProps:Map<String, Array<{ uname:String, index:Int, funcName:String }>> = new Map();

  private static var haxeGcRefOffset(default, null) = RuntimeLibrary.getHaxeGcRefOffset();
  private static var delays:Array<Void->Void> = [];
#if DEBUG_HOTRELOAD
  public static var id:unreal.UIntPtr = untyped __cpp__("(unreal::UIntPtr) &registry");
#end

  @:allow(UnrealInit) static function initializeDelegate(def:UDelegateDef) {
#if DEBUG_HOTRELOAD
    trace('$id: Delegate ${def.uname} initializeDelegate');
#end
    if (scriptDelegates == null) {
      scriptDelegates = new Map();
    }
    scriptDelegates[def.uname] = def;
  }

  @:allow(UnrealInit) static function initializeDef(uclassName:String, hxClassName:String, meta:MetaDef) {
#if DEBUG_HOTRELOAD
    trace('$id: Class $uclassName initializeDef');
#end
    if (registry == null) {
      registry = new Map();
      uclassNames = [];
    }

    var reg = registry[uclassName];
    if (reg == null) {
      registry[uclassName] = reg = new DynamicRegistry(meta, hxClassName, uclassName);
    } else {
      reg.updateDef(meta, hxClassName);
    }

    if (uclassNames.indexOf(uclassName) >= 0) {
      trace('Warning', 'Initializing the same class twice: $uclassName');
    } else {
      uclassNames.push(uclassName);
    }
  }

  @:allow(UnrealInit) static function initializeStaticMeta(meta:StaticMeta) {
    if (staticHxToUClass == null) {
      staticHxToUClass = new Map();
      staticUClassToHx = new Map();
    }
    staticHxToUClass[meta.hxPath] = meta;
    staticUClassToHx[meta.uname] = meta;
  }

  @:allow(UnrealInit) static function cppiaHotReload():HotReloadStatus {
    // 1st pass - check if we need to reinstance the dll
    var needsReinstancing = false;
    #if UHX_ALWAYS_REINSTANCE
    needsReinstancing = true;
    #else
    for (uclass in uclassNames) {
      if (!registry.exists(uclass)) {
        trace('Warning', 'Cannot find metadata definitions for $uclass. Perhaps it was deleted?');
        continue;
      }
      var reg = registry[uclass],
          def = reg.def,
          ustruct = reg.nativeUClass;
      if (ustruct != null) {
        var sig = ustruct.GetMetaData(CoreAPI.staticName("UHX_PropSignature"));
        if (sig.toString() != def.uclass.propSig) {
          // if the signature is empty, it means this is compiled in C++ - so we
          // trust that if that's the case UhxBuild would do the right thing and perform a full compilation
          if (!(sig.IsEmpty() && (def.uclass.upropExpose || !reg.isDynamic))) {
#if DEBUG_HOTRELOAD
            trace('$id: Class $uclass changed its properties and needs to be reinstanced ($sig != ${def.uclass.propSig})');
#end
            needsReinstancing = true;
            break;
          }
        }
        if (def.uclass.ufuncs != null) {
          for (fn in def.uclass.ufuncs) {
            if (fn.uname.toLowerCase().startsWith('onrep_') && ustruct.FindFunctionByName(fn.uname) == null) {
              // if onRep is found, perform a full hot reload
              needsReinstancing = true;
              break;
            }
          }
        }
      }
    }
    #end
    var touched = [];
    // 2nd pass - only create classes that need to be created
    var toAdd = [];
    if (!needsReinstancing) {
      for (uclass in uclassNames) {
        if (!registry.exists(uclass)) {
          trace('Warning', 'Cannot find metadata definitions for $uclass. Perhaps it was deleted?');
          continue;
        }
        var reg = registry[uclass],
            def = reg.def;
        if (reg.nativeUClass == null) {
          reg.resetUpdated();
          getUpdatedClass(reg);
        }
        if (!reg.isUpdated) {
          trace('Warning', 'Could not find or create the class $uclass. Skipping');
          continue;
        }
        var sig = reg.getUpdated().GetMetaData(CoreAPI.staticName("UHX_PropSignature"));
        if (!reg.wasDeleted && !reg.needsToAddProperties && sig.toString() != def.uclass.propSig) {
          if (sig.IsEmpty() && (def.uclass.upropExpose || !reg.isDynamic)) {
#if DEBUG_HOTRELOAD
            trace('$id: Class $uclass is a @:upropertyExpose class / non-dynamic class. Ignoring propSig');
#end
          } else {
            throw 'assert: ${uclass}';
          }
        }
        toAdd.push(reg);
      }

      if (scriptDelegates != null) {
        for (del in scriptDelegates) {
          createDelegate(del);
        }
      }

      // 3rd pass - add the functions/properties
      for (add in toAdd) {
        var changed = false,
            needsToAddProperties = add.needsToAddProperties;
        if (needsToAddProperties) {
          changed = true;
          addProperties(add.getUpdated(), add.uclassName, add.nativeUClass != null);
        } else {
          updateProperties(add.getUpdated(), add.uclassName);
        }
        if (addFunctions(add.getUpdated(), add.uclassName, add.nativeUClass != null)) {
          changed = true;
        }
        if (add.wasDeleted || needsToAddProperties) {
          // bind the class
          var uclass = add.getUpdated();
          uclass.Bind();
          uclass.StaticLink(true);
          uclass.GetDefaultObject(true);
          if (!uclass.ClassFlags.hasAny(CLASS_TokenStreamAssembled)) {
            uclass.AssembleReferenceTokenStream(false);
          }
        }

        touched.push(add.getUpdated());
      }

      refreshBlueprints(touched);
      uclassNames = [];
      return Success;
    } else {
      needsReinstancing = false;
      // reinstance!
      var outer = uhx.UCallHelper.StaticClass().GetOuter();
      var packName = unreal.FPackageName.GetShortFName(outer.GetFName());

      var manager = unreal.FModuleManager.Get();
      var infos = unreal.TArray.create(new TypeParam<FModuleStatus>());
      manager.QueryModules(infos);
      for (info in infos) {
        if (!info.bIsGameModule) {
          continue;
        }
        var path = new haxe.io.Path(info.FilePath.toString());
        var file = path.file;
        var regex = ~/\-(\d+)$/;
        if (regex.match(file)) {
          file = regex.matchedLeft();
        }
        var add = Std.random(1000000);
        path.file = file + '-$add';
        while(sys.FileSystem.exists(path.toString())) {
          add = Std.random(1000000);
          path.file = file + '-$add';
        }

        {
#if DEBUG_HOTRELOAD
          trace('$id: Copying module to $path');
#end
          var copiedModule = false;
          var maxRetries = 10;
          var backOffSeconds = 0.1;
          var backOffSecondsIncr = 0.1;
          for (numRetries in 0...maxRetries) {
            try {
              sys.io.File.copy(info.FilePath.toString(), path.toString());
              copiedModule = true;
              break;
            } catch (e:Dynamic) {
              trace('Warning', 'Failed to copy ${info.FilePath} -> $path, try $numRetries/$maxRetries');
              Sys.sleep(backOffSeconds);
              backOffSeconds += backOffSecondsIncr;
            }
          }

          if (!copiedModule)
          {
            trace('Error', 'Failed to copy module in order to trigger hotreload!');
            return Failure;
          }
        }
      }

      if (unreal.editor.UEditorEngine.GEditor != null) {
        return WaitingRebind;
      } else {
        // TODO check this before making any changes and do not load the new cppia type if that's the case
        trace('Error', 'Changing properties with hot reload only works if the editor is running. You will need to restart the game for all changes to take place');
        return Failure;
      }
    }
  }

  private static function getUpdatedClass(reg:DynamicRegistry) {
#if DEBUG_HOTRELOAD
      trace('$id: Getting updated class ${reg.uclassName}');
#end
    if (reg == null || reg.def == null) {
      return null;
    }

    if (reg.isUpdated) {
#if DEBUG_HOTRELOAD
      trace('$id: ${reg.uclassName} is already updated');
#end
      return reg.getUpdated();
    }

    var old = getUClass(reg.uclassName.substr(1)),
        unameWithPrefix = reg.uclassName,
        def = reg.def;
    var superReg = registry[def.uclass.superStructUName];
    if (old != null) {
      var sig = old.GetMetaData(CoreAPI.staticName("UHX_PropSignature"));
      // make sure we update the super struct first
      if (superReg != null) {
        getUpdatedClass(superReg);
      }
#if DEBUG_HOTRELOAD
      trace('$id: SuperReg of ${reg.uclassName} (${def.uclass.superStructUName}) ${superReg != null ? "found" : "not found"}');
#end

      // we need to delete this if either the superclass changed, or if the superclas is a native haxe class the reason
      // why we need to delete it if the superclass is a native compiled class is that the superclass might be hot reloaded
      if (sig.toString() != def.uclass.propSig ||
          (superReg != null && (superReg.wasDeleted || superReg.nativeUClass != null))
         )
      {
#if DEBUG_HOTRELOAD
        trace('$id: Setting deleted ${reg.uclassName}');
#end
        reg.setDeleted();
        markHotReloaded(old, null, unameWithPrefix);
        old = null;
      } else {
        reg.setUpdated(old);
        var hxPath = reg.hxClassName,
            hxClass = Type.resolveClass(hxPath);
        if (hxClass == null) {
          trace('Warning', 'While loading dynamic class $unameWithPrefix: The class $hxPath was not found');
          return null;
        }
#if DEBUG_HOTRELOAD
        trace('$id: Updating StaticClass reference for $unameWithPrefix');
#end
        Reflect.setField(hxClass, 'StaticClass', function() {
          Sys.println('here old $old ($hxPath)');
          return old;
        });
        return old;
      }
    }
    var parentName = def.uclass.superStructUName,
        parent = null;
    if (superReg != null) {
      getUpdatedClass(superReg);
      parent = superReg.getUpdated();
    } else {
      parent = getUClass(parentName.substr(1));
    }

    if (parent == null) {
      trace('Error', 'A new UStruct called $unameWithPrefix was defined since the latest C++ compilation, but its parent class $parentName was not found');
      return null;
    }
    var haxePackage = UObject.CreatePackage(null, '/Script/HaxeCppia');
    var uclass = createClass(haxePackage, unameWithPrefix, parent, superReg != null, reg.hxClassName);
    reg.setUpdated(uclass, true);
    return uclass;
  }

  private static function markHotReloaded(obj:UObject, cls:UClass, name:String) {
#if DEBUG_HOTRELOAD
    trace('Marking $name as hot reloaded');
#end
    if (Std.is(obj, UClass)) {
      var cls:UClass = cast obj;
      var cdo = uhx.glues.UClass_Glue.GetDefaultObject(@:privateAccess cls.wrapped, false);
      if (cdo != 0) {
        markHotReloaded(@:privateAccess new UObject(cdo), cls, name);
      }
    }
    obj.ClearFlags(RF_Public);
    var name = 'HOTRELOADED_CPPIA_$name';
    if (cls != null) {
      name = UObject.MakeUniqueObjectName( obj.GetOuter(), cls, 'HOTRELOADED_CPPIA_${name}').toString();
    } else {
      var stamp = Std.string(Math.fceil(Date.now().getTime()));
      name = '${name}_$stamp';
    }
    obj.Rename( name, null, 0 );
    obj.RemoveFromRoot();
    obj.MarkPendingKill();
  }

  private static function createDelegate(def:UDelegateDef) {
    var sig = getDelegateSignature(def.uname.substr(1));
    if (sig != null) {
      var propSig = sig.GetMetaData(CoreAPI.staticName("UHX_PropSignature"));
      if (!propSig.IsEmpty()) {
        if (def.signature.propSig != propSig.toString()) {
          markHotReloaded(sig, null, def.uname);
          sig = null;
        } else {
          // nothing changed
          return sig;
        }
      } else {
        var nativeSig = sig.GetMetaData(CoreAPI.staticName("UHX_PropSignature_Native"));
        if (nativeSig.IsEmpty()) {
          // this should not happen - unless a dynamic delegate changes from Static to Script folder
          // and no full compilation was made
          trace('Warning', 'Trying to change a non-cppia compiled delegate: ${def.uname}');
        } else if (nativeSig.toString() != def.signature.propSig) {
          // TODO check while compiling cppia
          trace('Warning', 'Trying to change a statically compiled delegate: ${def.uname}');
        }
        return null;
      }
    }

    var outer = UObject.CreatePackage(null, '/Script/HaxeCppia');
    var dummyClass:UClass = getUClass(def.uname.substr(1));
    if (dummyClass == null) {
      dummyClass = UObject.NewObject( outer, UBlueprintGeneratedClass.StaticClass(), def.uname.substr(1), RF_Public );
      var bp = UObject.NewObject(new TypeParam<UBlueprint>(), outer, UBlueprint.StaticClass());
      bp.GeneratedClass = dummyClass;
      dummyClass.ClassGeneratedBy = bp;

      var parent = UObject.StaticClass();
      dummyClass.SetSuperStruct(parent);
      dummyClass.ClassFlags |= EClassFlags.CLASS_Inherit | EClassFlags.CLASS_ScriptInherit | EClassFlags.CLASS_CompiledFromBlueprint;

      dummyClass.PropertyLink = parent.PropertyLink;
      dummyClass.ClassWithin = parent.ClassWithin;
      dummyClass.ClassConfigName = parent.ClassConfigName;

      RuntimeLibrary.setSuperClassConstructor(@:privateAccess dummyClass.wrapped);

      dummyClass.Bind();
      dummyClass.StaticLink(true);
      dummyClass.GetDefaultObject(true);
      dummyClass.AddToRoot();
    }

    if (sig != null) {
      // we don't need to check the prop signature anymore
      markHotReloaded(sig, dummyClass, sig.GetName().toString());
    }

    def.signature.uname = def.uname.substr(1) + '__DelegateSignature';
    var fn = generateUFunction(dummyClass, def.signature, null, null);
    dummyClass.Children = fn;
    fn.FunctionFlags |= FUNC_Delegate;
    if (def.isMulticast) {
      fn.FunctionFlags |= FUNC_MulticastDelegate;
    }
    return fn;
  }

  public static function startLoadingDynamic() {
#if DEBUG_HOTRELOAD
    trace('$id: startLoadingDynamic');
#end
  }

  public static function setNativeTypes() {
    if (uclassNames == null) {
      trace('Warning', 'No haxe type was found');
      return;
    }
    for (uclassName in uclassNames) {
      var reg = registry[uclassName];
      if (reg == null) {
        continue;
      }
      if (reg.nativeUClass == null) {
        var cls = getUClass(reg.uclassName.substr(1));
        if (cls != null && !cls.HasMetaData(CoreAPI.staticName('HaxeDynamicClass'))) {
          reg.setNative(cls);
        }
      }
    }
  }

  public static function setDynamicNative(cls:UClass, uname:String) {
    if (registry == null) {
      trace('Warning', 'No dynamic uclass was initialized by cppia, but there were dynamic classes found: $uname.');
      registry = new Map();
    }
    var reg = registry[uname];
    if (reg == null) {
      trace('Warning', 'Setting dynamic native on $uname, but no metadef was done');
      return;
    }
#if DEBUG_HOTRELOAD
    trace('$id: Setting dynamic native $uname');
#end
    reg.setNative(cls);
    reg.setDynamic(true);
  }

  public static function updateClass(struct:UStruct, uname:String) {
#if DEBUG_HOTRELOAD
    trace('$id: updateClass $uname');
#end
    var reg = registry[uname];
    if (reg == null) {
      trace('Warning', 'Trying to update class on deleted class $uname');
      return;
    }
    var meta = reg.def;
    if (meta.uclass.metas != null) {
      for (meta in meta.uclass.metas) {
        if (meta.isMeta) {
          struct.SetMetaData(meta.name, meta.value == null ? "" : meta.value);
        }
      }
    }
  }

  private static function updateProperties(struct:UStruct, uname:String) {
#if DEBUG_HOTRELOAD
    trace('$id: updateProperty $uname');
#end
    var reg = registry[uname];
    if (reg == null) {
      trace('Warning', 'Trying to update properties on deleted class $uname');
      return;
    }
    var meta = reg.def;
    if (meta.uclass.metas != null) {
      for (meta in meta.uclass.metas) {
        if (meta.isMeta) {
          struct.SetMetaData(meta.name, meta.value == null ? "" : meta.value);
        }
      }
    }

    for (propDef in meta.uclass.uprops) {
      if (propDef.metas == null || propDef.isCompiled) {
        continue;
      }
      var prop = ReflectAPI.getUPropertyFromClass(cast struct, propDef.uname);
      if (prop != null) {
        for (meta in propDef.metas) {
          if (meta.isMeta) {
            prop.SetMetaData(meta.name, meta.value == null ? "": meta.value);
          }
        }
      }
    }
  }

  private static function containsInstancedData(def:UPropertyDef) : Bool {
    if (def.metas != null) {
      for (meta in def.metas) {
        if (meta.name.toLowerCase() == 'instanced') {
          return true;
        }
      }
    }
    switch (def.flags.type) {
    case TMap | TArray | TSet:
      for (param in def.params) {
        if (containsInstancedData(param)) {
          return true;
        }
      }
    case _:
    }
    return false;
  }

  public static function addProperties(struct:UStruct, uname:String, isNative:Bool) {
#if DEBUG_HOTRELOAD
    trace('$id: addProperties $uname $isNative');
#end
    var reg = registry[uname];
    if (reg == null) {
      trace('Warning', 'Trying to add properties on deleted class $uname');
      return;
    }
    var meta = reg.def;
    if (reg.propertiesAdded) {
      var oldSig = struct.GetMetaData(CoreAPI.staticName("UHX_PropSignature"));
      if(!oldSig.IsEmpty() && meta != null && meta.uclass != null && meta.uclass.propSig != null) {
        if (meta.uclass.propSig != oldSig.toString()) {
          // properties changed. We need a full hot reload
          trace('Error', 'The properties of $uname have changed, but no hot reload call was made');
        }
        return;
      } else {
        trace('Warning', 'Properties were added, but missing meta / signature for $uname');
      }
      return;
    }

    var oldSig = struct.GetMetaData(CoreAPI.staticName("UHX_PropSignature"));
    if(!oldSig.IsEmpty() && meta != null && meta.uclass != null && meta.uclass.propSig != null && meta.uclass.propSig == oldSig.toString()) {
#if DEBUG_HOTRELOAD
      trace('$id: $uname has not changed');
#end
      return;
    }
    if (meta == null || meta.uclass == null) {
      trace('Error', 'Cannot find properties for dynamic class $uname');
      return;
    }

    var sup = struct.GetInheritanceSuper();
    var superUName = sup != null ? sup.GetPrefixCPP().toString() + sup.GetName() : null;
    var supReg = null;
    if (sup != null && (supReg = registry[superUName]) != null) {
      if (!supReg.propertiesAdded) {
        addProperties(sup, superUName, isNative);
      }
    }

    var isClass = Std.is(struct, UClass);
    var uprops = meta.uclass.uprops,
        i = uprops.length;
    while (i --> 0) {
      var propDef = uprops[i];
      if (propDef.isCompiled) {
        continue;
      }
      if (isClass && containsInstancedData(propDef)) {
        var cls:UClass = cast struct;
        cls.ClassFlags = cls.ClassFlags | CLASS_HasInstancedReference;
      }
      var prop = generateUProperty(struct, struct, propDef, false);
      if (prop == null) {
        trace('Warning', 'Error while creating property ${propDef.uname} for class $uname');
        continue;
      }
      prop.SetMetaData(CoreAPI.staticName('HaxeGenerated'),"true");
      struct.AddCppProperty(prop);
    }
    if (isNative) {
      bindNativeProperties(uname, struct);
    }
    reg.setPropertiesAdded();
    if (meta.uclass.propSig != null) {
      struct.SetMetaData(CoreAPI.staticName('UHX_PropSignature'), meta.uclass.propSig);
    }
  }

  public static function addFunctions(uclass:UClass, uname:String, isNative:Bool):Bool {
#if DEBUG_HOTRELOAD
    trace('$id: addFunctions $uname');
#end
    var reg = registry[uname];
    if (reg == null) {
      trace('Warning', 'Trying to add functions on deleted class $uname');
      return false;
    }
    var changed = false;
    if (uclass == null) {
      trace('Error', 'Cannot find class $uname to create ufunctions');
      return false;
    }

    if (reg == null) {
      trace('Warning', 'Cannot find registry to add functions for $uname');
      return false;
    }

    var meta = reg.def;
    if (meta == null || meta.uclass == null) {
      trace('Warning', 'Cannot find metadata to add functions for $uname');
      return false;
    }
    if (meta.uclass.ufuncs == null) {
      return false;
    }
    var hxClassName = reg.hxClassName;
    if (hxClassName == null) {
      trace('Warning', 'Cannot find Haxe class name for $uname');
      return false;
    }
    var hxClass = Type.resolveClass(hxClassName);
    if (hxClass == null) {
      trace('Warning', 'Cannot find Haxe class for $uname');
      return false;
    }
    var setupFunction = null;
    {
      var cur = hxClass;
      while (cur != null) {
        setupFunction = Reflect.field(hxClass, 'setupFunction');
        if (setupFunction != null) {
          var getGlueScript = Reflect.field(hxClass, 'get_uhx_glueScript');
          if (getGlueScript != null && !Reflect.hasField(getGlueScript(), "setupFunction")) {
            // this was compiled only by cppia
            setupFunction = null;
          } else {
            break;
          }
        }
        cur = Type.getSuperClass(cur);
      }
    }
    if (setupFunction == null) {
      // this is not exactly right, but it works correctly as the function is not a virtual function
      setupFunction = uhx.UCallHelper.setupFunction;
    }

    var sup = uclass.GetSuperClass();
    for (funcDef in meta.uclass.ufuncs) {
      var old = uclass.FindFunctionByName(funcDef.uname, ExcludeSuper);
      if (old != null) {
        var sig = old.GetMetaData(CoreAPI.staticName('UHX_PropSignature'));
        if (sig.IsEmpty()) {
          if (!funcDef.isCompiled) {
            trace('Error', 'Trying to hot reload a function that was not created by cppia: ${funcDef.uname} on $uname');
          }
          continue;
        }
        if (sig.toString() != funcDef.propSig) {
#if DEBUG_HOTRELOAD
          trace('$id: Cppia: Hot reloading function ${funcDef.uname} on $uname');
#end
          var child = uclass.Children,
              last:UField = null;
          while (child != null) {
            if (child == old) {
              if (last == null) {
                uclass.Children = child.Next;
              } else {
                last.Next = child.Next;
              }
              break;
            }
            last = child;
            child = child.Next;
          }
          markHotReloaded(old, uclass, funcDef.uname);
        } else {
          // nothing has changed, but we need to update the ufunction native pointer
          setupFunction(@:privateAccess uclass.wrapped,@:privateAccess old.wrapped);
          continue;
        }
      }
      if (isNative && funcDef.isCompiled) {
        continue;
      }
      var parent = sup == null ? null : sup.FindFunctionByName(funcDef.uname, ExcludeSuper);
      var func = generateUFunction(uclass, funcDef, parent, setupFunction);
      changed = true;
      if (func != null) {
        // we already do this when creating the property, but we must do it again so that we catch the cases
        // where the onRep function was created after the property was already created (cppia hot reload)
        if (funcDef.uname.toLowerCase().startsWith('onrep_')) {
          var propName = funcDef.uname.substr('onrep_'.length);
#if DEBUG_HOTRELOAD
          trace('$id: Found onRep function for property $propName');
#end
          var prop = uclass.PropertyLink;
          while (prop != null) {
            if (prop.GetName().toString() == propName) {
#if DEBUG_HOTRELOAD
              trace('$id: Found property. Setting repNotify (${prop.RepNotifyFunc})');
#end
              prop.PropertyFlags |= CPF_RepNotify;
              prop.RepNotifyFunc = funcDef.uname;
              break;
            }
            prop = prop.PropertyLinkNext;
          }
        }

#if (UE_VER < 4.19)
        uclass.AddFunctionToFunctionMap(func);
#else
        uclass.AddFunctionToFunctionMap(func, funcDef.uname);
#end
#if DEBUG_HOTRELOAD
        trace('setting func.Next from (${func.GetName()}) to ${uclass.Children == null ? null : uclass.Children.GetName().toString()}');
#end
        func.Next = uclass.Children;
        uclass.Children = func;
      }
    }
    return changed;
  }

  static function generateUFunction(outer:UObject, func:UFunctionDef, parent:UFunction, setupFunction:UIntPtr->UIntPtr->Void):UFunction {
    var fn:UFunction = UObject.NewObject(outer, UFunction.StaticClass(), func.uname, RF_Public);
    if (parent != null) {
      fn.SetSuperStruct(parent);
    }
    if (func.propSig != null) {
      fn.SetMetaData(CoreAPI.staticName("UHX_PropSignature"), func.propSig);
    }
    var uclass:UClass = Std.is(outer, UClass) ? cast outer : null;

    var curChild = null,
        curProp = null;
    if (func.args != null) {
      for (arg in func.args) {
        var prop = generateUProperty(fn, uclass, arg, false);
        if (prop == null) {
          trace('Warning', 'Error while creating property ${arg.uname} for function ${func.uname} (class ${outer.GetName()})');
          return null;
        }
        prop.PropertyFlags |= CPF_Parm;
        if (curChild == null) {
          curChild = fn.Children = prop;
          curProp = fn.PropertyLink = prop;
        } else {
          curChild.Next = prop;
          curProp.PropertyLinkNext = prop;
          curProp = prop;
          curChild = prop;
        }
      }
    }
    fn.NumParms = func.args.length;
    if (func.ret != null) {
      var prop = generateUProperty(fn, uclass, func.ret, true);
      if (prop == null) {
        trace('Warning', 'Error while creating return value for function ${func.uname} (class ${outer.GetName()})');
        return null;
      }
      prop.PropertyFlags |= CPF_Parm | CPF_ReturnParm | CPF_OutParm;
      if (curChild == null) {
        curChild = fn.Children = prop;
        curProp = fn.PropertyLink = prop;
      } else {
        curChild.Next = prop;
        curProp.PropertyLinkNext = prop;
        curProp = prop;
        curChild = prop;
      }
    }

    var flags = getFunctionFlags(uclass, fn, func);
    fn.FunctionFlags |= flags;

    var hxName = func.hxName;
    if (flags.hasAny(FUNC_Net)) {
      hxName = func.uname + '_Implementation';
      for (meta in func.metas) {
        if (meta.name.toLowerCase() == 'withvalidation') {
          hxName = func.uname + '_DynamicRun';
          break;
        }
      }
    }
    if (hxName != null && hxName != func.uname) {
      fn.SetMetaData(CoreAPI.staticName('HaxeName'), hxName);
    }

    if (setupFunction != null && uclass != null) {
      setupFunction(@:privateAccess uclass.wrapped,@:privateAccess fn.wrapped);
    } else {
      fn.FunctionFlags = fn.FunctionFlags & ~FUNC_Native;
    }
    fn.Bind();
    fn.StaticLink(true);

    var arg = fn.PropertyLink;
    while (arg != null) {
      if (arg.PropertyFlags.hasAny(CPF_Parm)) {
        fn.ParmsSize = arg.GetOffset_ForUFunction() + arg.GetSize();

        if (arg.PropertyFlags.hasAny(CPF_OutParm)) {
          fn.FunctionFlags |= FUNC_HasOutParms;
        }

        if (arg.PropertyFlags.hasAny(CPF_ReturnParm)) {
          fn.ParmsSize = arg.GetOffset_ForUFunction() + arg.GetSize();
        }
      }

      arg = arg.PropertyLinkNext;
    }

    return fn;
  }

  private static function getFunctionFlags(owner:UClass, fn:UFunction, funcDef:UFunctionDef):EFunctionFlags {
    var flags:EFunctionFlags = FUNC_Native;
    if (funcDef.metas == null) {
      return flags;
    }

    for (meta in funcDef.metas) {
      if (meta.isMeta) {
        fn.SetMetaData(meta.name, meta.value == null ? "" : meta.value);
        continue;
      }

      switch(meta.name.toLowerCase()) {
      case 'blueprintnativeevent':
        // TODO cannot be FUNC_Net - it cannot be replicated
        // TODO cannot be BlueprintEvent but not native
        flags |= FUNC_Event;
        flags |= FUNC_BlueprintEvent;
      case 'blueprintimplementableevent':
        // TODO cannot beFUNC_Net - it cannot be replicated
        // TODO cannot be BlueprintEvent but native
        flags |= FUNC_Event;
        flags |= FUNC_BlueprintEvent;
        flags &= ~FUNC_Native;
      case 'exec':
        flags |= FUNC_Exec;
        // TODO cannot be FUNC_Net
      case 'sealedevent':
        // TODO
        // fn.bSealedEvent = true;
      case 'server':
        // TODO cannot be blueprintevent
        // TODO cannot be exec
        flags |= FUNC_Net;
        flags |= FUNC_NetServer;
      case 'client':
        // TODO cannot be blueprintevent
        flags |= FUNC_Net;
        flags |= FUNC_NetClient;
      case 'netmulticast':
        // TODO cannot be blueprintevent
        flags |= FUNC_Net;
        flags |= FUNC_NetMulticast;
      case 'servicerequest':
        // TODO cannot be blueprintevent
        // flags |= FUNC_Net;
        // flags |= FUNC_NetReliable;
        // flags |= FUNC_NetRequest;
        // set FUNCEXPORT_CustomThunk
        // ParseNetServiceIdentifiers
        trace('Warning', 'ServiceRequest not supported');
      case 'serviceresponse':
        // TODO cannot be blueprintevent
        trace('Warning', 'ServiceResponse not supported');
      case 'reliable':
        flags |= FUNC_NetReliable;
      case 'unreliable':
        // TODO - what exactly do we do with that?
      case 'customthunk':
        // TODO - FUNCEXPORT_CustomThunk. Don't think we need this
      case 'blueprintcallable':
        flags |= FUNC_BlueprintCallable;
      case 'blueprintpure':
        flags |= FUNC_BlueprintCallable;
        flags |= FUNC_BlueprintPure;
      case 'blueprintauthorityonly':
        flags |= FUNC_BlueprintAuthorityOnly;
      case 'blueprintcosmetic':
        flags |= FUNC_BlueprintCosmetic;
      case 'withvalidation':
        // TODO
#if (UE_VER >= 4.17)
      case 'blueprintgetter':
        flags |= FUNC_BlueprintCallable | FUNC_BlueprintPure;
        fn.SetMetaData('BlueprintGetter', "");
      case 'blueprintsetter':
        flags |= FUNC_BlueprintCallable;
        fn.SetMetaData('BlueprintSetter', "");
#end
      case _:
        if (meta.value != null) {
          fn.SetMetaData(meta.name, meta.value);
        }
      }
    }

    return flags;
  }

  private static function bindNativeProperties(uname:String, struct:UStruct) {
    if (!struct.HasMetaData(CoreAPI.staticName("HaxeGenerated"))) {
      struct.SetMetaData(CoreAPI.staticName('HaxeGenerated'),"true");
    }

    var size = struct.PropertiesSize;
    var ar = new FArchive();

    var sup = struct.GetInheritanceSuper();
    if (sup != null) {
      struct.MinAlignment = sup.GetMinAlignment();
      var superUName = sup.GetPrefixCPP().toString() + sup.GetName();
      if (registry.exists(superUName)) {
        // super class is dynamic as well - use its property size then
        struct.PropertiesSize = sup.GetPropertiesSize();
      } else {
        // we are the first dynamic class. Use the cpp size then
        var reg = registry[uname];
        if (reg == null) {
          trace('Warning', 'Trying to bind deleted class $uname');
          return;
        }
        var clsName = reg.hxClassName;
        if (clsName == null) {
          throw 'Haxe class for dynamic class $uname was not registered';
        }
        var cls:Dynamic = Type.resolveClass(clsName);
        if (cls == null) {
          throw 'Haxe class for dynamic class $uname was not found ($clsName)';
        }

        try {
          struct.PropertiesSize = cls.CPPSize();
        }
        catch(e:Dynamic) {
          trace('Warning', 'The class $uname was compiled with another path. Its size cannot be computed correctly. Please perform a full C++ build.');
          struct.PropertiesSize = sup.PropertiesSize + uhx.ue.RuntimeLibrary.getGcRefSize();
        }
      }
    }

    var field = struct.Children;
    while(field != null) {
      if (Std.is(field, UProperty)) {
        var prop:UProperty = cast field;
        struct.PropertiesSize = prop.Link(ar);
        var a1 = struct.MinAlignment,
            a2 = prop.GetMinAlignment();

        struct.MinAlignment = a1 > a2 ? a1 : a2;
      }
      field = field.Next;
    }
  }

  public static function getClassName(uname:String, fallback:String) {
    if (registry == null) {
      return fallback;
    }
    var reg = registry[uname];
    if (reg != null) {
      return reg.hxClassName == null ? fallback : reg.hxClassName;
    } else {
      return fallback;
    }
  }

  public static function onHotReload() {
#if DEBUG_HOTRELOAD
    trace('$id: onHotReload');
#end
  }

  public static function endLoadingDynamic() {
#if DEBUG_HOTRELOAD
    trace('$id: end loading dynamic');
#end
    uhx.UHaxeGeneratedClass.cdoInit();
    var registry = registry;
    var haxePackage = UObject.CreatePackage(null, '/Script/HaxeCppia');

    if (uclassNames != null) {
      for (uclassName in uclassNames) {
        var reg = registry[uclassName];
        if (reg == null) {
          continue;
        }
        var def = reg.def;
        if (reg.nativeUClass == null) {
          getUpdatedClass(reg);
          addFunctions(reg.getUpdated(), uclassName, false);
          if (!reg.wasDeleted && !reg.needsToAddProperties) {
            // we don't need to create it - just need to update its functions
            var parentName = def.uclass.superStructUName,
                parentHxGenerated = staticUClassToHx.exists(parentName);
            if (parentHxGenerated) {
              RuntimeLibrary.setSuperClassConstructor(@:privateAccess reg.getUpdated().wrapped);
            } else {
              RuntimeLibrary.setupClassConstructor(@:privateAccess reg.getUpdated().wrapped);
            }
            continue;
          }
        } else {
          reg.getUpdated().Bind();
        }

        if (reg.nativeUClass == null) {
          if (reg.needsToAddProperties) {
            addProperties(reg.getUpdated(), uclassName, false);

            var uclass = reg.getUpdated();
            uclass.Bind();
            uclass.StaticLink(true);

            uclass.GetDefaultObject(true);
            if (!uclass.ClassFlags.hasAny(CLASS_TokenStreamAssembled)) {
              uclass.AssembleReferenceTokenStream(false);
            }
          } else {
            updateProperties(reg.getUpdated(), uclassName);
          }
        }
      }
    }

    uclassNames = [];

    if (scriptDelegates != null) {
      for (del in scriptDelegates) {
        var sig = getDelegateSignature(del.uname.substr(1));
        if (sig != null && !sig.HasMetaData("UHX_PropSignature") && !sig.HasMetaData("UHX_PropSignature_Native")) {
          if (!sig.HasMetaData(CoreAPI.staticName("UHX_PropSignature_Native"))) {
            sig.SetMetaData(CoreAPI.staticName("UHX_PropSignature_Native"), del.signature.propSig);
          }
        } else {
          createDelegate(del);
        }
      }
    }

    var curDelays = delays;
    delays = [];
    for (delay in curDelays) {
      delay();
    }
  }

  private static function refreshBlueprints(changed:Array<UClass>) {
    var db = unreal.editor.blueprintgraph.FBlueprintActionDatabase.Get();
    for (changed in changed) {
      db.RefreshClassActions(changed);
    }
  }

  private static function getReplication(kind:UPropReplicationKind):ELifetimeCondition {
    return switch (kind) {
      case Always:
        return COND_None;
      case InitialOnly:
        return COND_InitialOnly;
      case OwnerOnly:
        return COND_OwnerOnly;
      case SkipOwner:
        return COND_SkipOwner;
      case SimulatedOnly:
        return COND_SimulatedOnly;
      case AutonomousOnly:
        return COND_AutonomousOnly;
      case SimulatedOrPhysics:
        return COND_SimulatedOrPhysics;
      case InitialOrOwner:
        return COND_InitialOrOwner;
      case ReplayOrOwner:
        return COND_ReplayOrOwner;
      case ReplayOnly:
        return COND_ReplayOnly;
      case SimulatedOnlyNoReplay:
        return COND_SimulatedOnlyNoReplay;
      case SimulatedOrPhysicsNoReplay:
        return COND_SimulatedOrPhysicsNoReplay;
      #if proletariat
      case OwnerOrSpectatingOwner:
        return COND_OwnerOrSpectatingOwner;
      #end
    };
  }

  public static function setLifetimeProperties(uclass:UClass, uname:String, out:TArray<FLifetimeProperty>) {
    var reg = registry[uname];
    if (reg == null) {
      trace('Fatal', 'Trying to set lifetime properties for class $uclass, but it was not registrated');
      return;
    }
    var meta = reg.def;

    if (meta == null || meta.uclass == null) {
      trace('Fatal', 'Trying to set lifetime properties for class $uclass, but no metadata was found');
      return;
    }
    var meta = reg.def;

    var customRepls = [];
    for (prop in meta.uclass.uprops) {
      if (prop.replication != null && prop.customReplicationName == null) {
        var uprop = uclass.FindPropertyByName(prop.uname);
        if (uprop == null) {
          trace('Fatal', 'Could not find property ${prop.uname} in class $uname while setting lifetime properties');
        }
        out.push(new FLifetimeProperty(uprop.RepIndex, getReplication(prop.replication), REPNOTIFY_OnChanged));
      } else if (prop.customReplicationName != null) {
        var uprop = uclass.FindPropertyByName(prop.uname);
        if (uprop == null) {
          trace('Fatal', 'Could not find property ${prop.uname} in class $uname while setting lifetime properties');
        }
        customRepls.push({ uname:prop.uname, index:(uprop.RepIndex : Int), funcName: prop.customReplicationName });
        out.push(new FLifetimeProperty(uprop.RepIndex, COND_Custom, REPNOTIFY_OnChanged));
      }
    }

    if (customRepls.length == 0) {
      customRepls = null;
    }
    customReplicationProps[uclass.GetName().toString()] = customRepls;
  }

  public static function instancePreReplication(obj:UObject, changedPropertyTracker:IRepChangedPropertyTracker) {
    var uclass = obj.GetClass();
    var customRepls = customReplicationProps[uclass.GetName().toString()];
    if (customRepls != null) {
      for (repl in customRepls) {
        var customReplFunc = Reflect.field(obj, repl.funcName);
        if (customReplFunc == null)
        {
          trace('Fatal', 'Custom replication function \'${repl.funcName}\' not found on ${uclass.GetName().toString()}. Function is either missing, or the replication condition was improperly referenced.');
          return;
        }
        var active = customReplFunc();
        changedPropertyTracker.SetCustomIsActiveOverride(repl.index, active);
      }
    }
  }

  private static function createClass(outer:UObject, uclassName:String, parent:UClass, parentHxGenerated:Bool, hxPath:String):UClass {
#if DEBUG_HOTRELOAD
    trace('$id: creating class $uclassName (hxPath $hxPath)');
#end
    var hxClass = Type.resolveClass(hxPath);
    if (hxClass == null) {
      trace('Error', 'While loading dynamic class $uclassName the class $hxPath was not found');
      return null;
    }
    var name = uclassName.substr(1);
    var uclass:UBlueprintGeneratedClass = UObject.NewObject(outer, uhx.UHaxeGeneratedClass.StaticClass(), uclassName.substr(1), 0);
    var bp = UObject.NewObject(new TypeParam<UBlueprint>(), outer, UBlueprint.StaticClass());
    bp.GeneratedClass = uclass;
    bp.ParentClass = parent;
    uclass.ClassGeneratedBy = bp;

    uclass.PropertyLink = parent.PropertyLink;
    uclass.ClassWithin = parent.ClassWithin;
    uclass.ClassConfigName = parent.ClassConfigName;

    uclass.SetSuperStruct(parent);
    var flags:EClassFlags = uclass.ClassFlags;
    var parentFlags = parent.ClassFlags;
    flags = flags | (parentFlags & (CLASS_Inherit | CLASS_ScriptInherit)) | CLASS_CompiledFromBlueprint;
    // if we don't set this, bShouldInitializeProperties is set to true at UClass::CreateDefaultObject, which makes the old properties
    // to be initialized from the parent CDO, which is not what we want
    flags = flags | CLASS_Native;
    uclass.ClassFlags = flags;
    uclass.ClassCastFlags = uclass.ClassCastFlags | parent.ClassCastFlags;
    uclass.SetMetaData(CoreAPI.staticName('HaxeDynamicClass'),hxPath);
    uclass.SetMetaData(CoreAPI.staticName('HaxeGenerated'),"true");
    uclass.AddToRoot();

    // TODO add class flags from metadata
    if (!parentHxGenerated) {
      // create the new property where the gc ref will be
      var haxeGcRef:UStructProperty = cast newProperty(uclass, UStructProperty.StaticClass(), "haxeGcRef", 0);
      haxeGcRef.SetMetaData(CoreAPI.staticName('HaxeGenerated'),"true");
      haxeGcRef.Struct = uhx.FHaxeGcRef.StaticStruct();
      uclass.AddCppProperty(haxeGcRef);
    }
    if (parentHxGenerated) {
      RuntimeLibrary.setSuperClassConstructor(@:privateAccess uclass.wrapped);
    } else {
      RuntimeLibrary.setupClassConstructor(@:privateAccess uclass.wrapped);
    }

    Reflect.setField(hxClass, 'StaticClass', function() {
      Sys.println('here $uclass ($hxPath)');
      return uclass;
    });
    return uclass;
  }

  private static function doesAnythingInHierarchyHaveDefaultToInstanced(cls:UClass) {
    var found = false;

    while(!found && cls != null) {
      found = cls.ClassFlags.hasAny(CLASS_DefaultToInstanced);
      cls = cls.GetSuperClass();
    }

    return found;
  }

  private static function getPropertyFlags(ownerStruct:UStruct, prop:UProperty, propDef:UPropertyDef):EPropertyFlags {
    var flags:EPropertyFlags = 0;
    if (propDef.metas == null) {
      return flags;
    }

    for (meta in propDef.metas) {
      if (meta.isMeta) {
        prop.SetMetaData(meta.name, meta.value == null ? "" : meta.value);
        continue;
      }

      switch(meta.name.toLowerCase()) {
      case 'advanceddisplay':
        flags |= CPF_AdvancedDisplay;
      case 'assetregistrysearchable':
        flags |= CPF_AssetRegistrySearchable;
      case 'blueprintassignable':
        flags |= CPF_BlueprintAssignable;
      case 'blueprintauthorityonly':
        flags |= CPF_BlueprintAuthorityOnly;
      case 'blueprintcallable':
        flags |= CPF_BlueprintCallable;
      case 'blueprintreadonly':
        // TODO check if there is another edit specifier while compiling
        flags |= CPF_BlueprintVisible | CPF_BlueprintReadOnly;
      case 'blueprintreadwrite':
        // TODO check if there is another edit specifier while compiling
        flags |= CPF_BlueprintVisible;
      case 'config':
        if (Std.is(ownerStruct, UClass)) {
          var cls:UClass = cast ownerStruct;
          cls.ClassFlags |= EClassFlags.CLASS_Config;
        }
        flags |= CPF_Config;
      case 'const':
        flags |= CPF_ConstParm;
      case 'duplicatetransient':
        flags |= CPF_DuplicateTransient;
      case 'editanywhere':
        // TODO check if other edit calls were made while compiling
        flags |= CPF_Edit;
      case 'editdefaultsonly':
        // TODO check if other edit calls were made while compiling
        flags |= CPF_Edit | CPF_DisableEditOnInstance;
      case 'editfixedsize':
        flags |= CPF_EditFixedSize;
      case 'editinline':
        // TODO deprecated warning while compiling
      case 'editinstanceonly':
        // TODO check if other edit calls were made while compiling
        flags |= CPF_Edit | CPF_DisableEditOnTemplate;
      case 'export':
        flags |= CPF_ExportObject;
      case 'globalconfig':
        flags |= CPF_GlobalConfig | CPF_Config;
      case 'instanced':
        flags |= CPF_PersistentInstance | CPF_ExportObject | CPF_InstancedReference;
        prop.SetMetaData(CoreAPI.staticName('EditInline'), 'true');
      case 'interp':
        flags |= CPF_Edit | CPF_BlueprintVisible | CPF_Interp;
      case 'localized':
        // TODO deprecated
      // TODO Native ?
      case 'noclear':
        flags |= CPF_NoClear;
      case 'nonpieduplicatetransient':
        flags |= CPF_NonPIEDuplicateTransient;
      case 'nonpietransient':
        // TODO deprecated
        flags |= CPF_NonPIEDuplicateTransient;
      case 'nontransactional':
        flags |= CPF_NonTransactional;
      case 'notreplicated':
        if (Std.is(ownerStruct, UScriptStruct)) {
          flags |= CPF_RepSkip;
        }
      case 'ref':
        flags |= CPF_OutParm | CPF_ReferenceParm;
      case 'replicated' | 'replicatedusing':
        if (!Std.is(ownerStruct, UScriptStruct)) {
          // TODO error if otherwise when compiling
          // TODO check if ureplicate is used instead
          if (propDef.replication == null ||
              (meta.name.toLowerCase() == 'replicatedusing' && propDef.customReplicationName != meta.value))
          {
            trace('Error',
                  // '${ownerStruct.GetName()}: ${prop.GetName()}: When setting replicated properties, ' +
                  'use @:ureplicate instead of @:uproperty(ReplicatedUsing). Property replication will be ignored');
            continue;
          }

          flags |= CPF_Net;
        }
      case 'repretry':
        // TODO deprecated
      case 'savegame':
        flags |= CPF_SaveGame;
      case 'simpledisplay':
        flags |= CPF_SimpleDisplay;
      case 'skipserialization':
        flags |= CPF_SkipSerialization;
      case 'textexporttransient':
        flags |= CPF_TextExportTransient;
      case 'transient':
        flags |= CPF_Transient;
      case 'visibleanywhere':
        // TODO check edit specifier
        flags |= CPF_Edit | CPF_EditConst;
      case 'visibledefaultsonly':
        // TODO check edit specifier
        flags |= CPF_Edit | CPF_EditConst | CPF_DisableEditOnInstance;
      case 'visibleinstanceonly':
        // TODO check edit specifier
        flags |= CPF_Edit | CPF_EditConst | CPF_DisableEditOnTemplate;
#if (UE_VER >= 4.17)
      case 'blueprintgetter':
        flags |= CPF_BlueprintVisible;
        prop.SetMetaData('BlueprintGetter', meta.value);
      case 'blueprintsetter':
        flags |= CPF_BlueprintVisible;
        prop.SetMetaData('BlueprintSetter', meta.value);
#end
      case _:
        if (meta.value != null) {
          prop.SetMetaData(meta.name, meta.value);
        } else {
          trace('Warning', 'Unprocessed metadata ${meta.name} for property ${propDef.uname}');
        }
      }
    }

    return flags;
  }

  private static function newProperty(outer:UObject, cls:UClass, name:FName, flags:EObjectFlags):UProperty {
    return UObject.NewObject( outer, cls, name, flags);
  }

  private static function generateUProperty(outer:UObject, ownerStruct:UStruct, def:UPropertyDef, isReturn:Bool):UProperty {
    // var isLoading = !uhx.glues.UObject_Glue.IsA(outer, uhx.glues.UClass_Glue.get_ClassWithin(uhx.glues.UBoolProperty_Glue.StaticClass()));
    var isLoading = true;
    var objFlags:EObjectFlags = EObjectFlags.RF_Public;

    var name = new FName(def.uname);
    var prop:UProperty = null;
    var flags = def.flags,
        curCls = null;
    switch(flags.type) {
      case TBool:
        prop = newProperty( outer, UBoolProperty.StaticClass(), name, objFlags);
      case TI8:
        prop = newProperty( outer, UInt8Property.StaticClass(), name, objFlags);
      case TU8:
        prop = newProperty( outer, UByteProperty.StaticClass(), name, objFlags);
      case TI16:
        prop = newProperty( outer, UInt16Property.StaticClass(), name, objFlags);
      case TU16:
        prop = newProperty( outer, UUInt16Property.StaticClass(), name, objFlags);
      case TI32:
        prop = newProperty( outer, UIntProperty.StaticClass(), name, objFlags);
      case TU32:
        prop = newProperty( outer, UUInt32Property.StaticClass(), name, objFlags);
      case TI64:
        prop = newProperty( outer, UInt64Property.StaticClass(), name, objFlags);
      case TU64:
        prop = newProperty( outer, UUInt64Property.StaticClass(), name, objFlags);

      case F32:
        prop = newProperty( outer, UFloatProperty.StaticClass(), name, objFlags);
      case F64:
        prop = newProperty( outer, UDoubleProperty.StaticClass(), name, objFlags);

      case TString:
        prop = newProperty( outer, UStrProperty.StaticClass(), name, objFlags);
      case TText:
        prop = newProperty( outer, UTextProperty.StaticClass(), name, objFlags);
      case TName:
        prop = newProperty( outer, UNameProperty.StaticClass(), name, objFlags);

      case TArray:
        var ret:UArrayProperty = cast newProperty(outer, UArrayProperty.StaticClass(), name, objFlags);
        var inner = generateUProperty(@:privateAccess ret, ownerStruct, def.params[0], false);
        if (inner == null) {
          ret.MarkPendingKill();
          return null;
        }
        ret.Inner = inner;
        prop = ret;

      case TUObject:
        var reg = registry[def.typeUName],
            cls = null;
        if (reg != null) {
          if (!reg.isUpdated) {
            getUpdatedClass(reg);
          }
          curCls = cls = reg.getUpdated();
        } else {
          curCls = cls = getUClass(def.typeUName.substr(1));
        }
        if (flags.hasAny(FWeak)) {
          var ret:UWeakObjectProperty = cast newProperty(outer, UWeakObjectProperty.StaticClass(), name, objFlags);
          ret.SetPropertyClass(cls);
          prop = ret;
        } else if (flags.hasAny(FSubclassOf)) {
          var ret:UClassProperty = cast newProperty(outer, UClassProperty.StaticClass(), name, objFlags);
          ret.PropertyFlags |= CPF_UObjectWrapper;
          ret.SetPropertyClass(UClass.StaticClass());
          ret.MetaClass = cls;
          prop = ret;
        } else {
          if (cls == UClass.StaticClass()) {
            var ret:UClassProperty = cast newProperty(outer, UClassProperty.StaticClass(), name, objFlags);
            ret.SetPropertyClass(cls);
            ret.MetaClass = UObject.StaticClass();
            prop = ret;
          } else {
            var ret:UObjectProperty = cast newProperty(outer, UObjectProperty.StaticClass(), name, objFlags);
            ret.SetPropertyClass(cls);
            prop = ret;
          }
        }
      case TInterface:
        var ret:UInterfaceProperty = cast newProperty(outer, UInterfaceProperty.StaticClass(), name, objFlags);
        var cls = getUClass(def.typeUName.substr(1));
        ret.SetInterfaceClass(curCls = cls);
        prop = ret;
      case TStruct:
        var ret:UStructProperty = cast newProperty(outer, UStructProperty.StaticClass(), name, objFlags);
        var cls = getUStruct(def.typeUName.substr(1));
        ret.Struct = cls;
        prop = ret;
      case TEnum:
        var ret:UByteProperty = cast newProperty(outer, UByteProperty.StaticClass(), name, objFlags);
        delays.push(function() {
          var uenum = getUEnum(def.typeUName, true);
          if (uenum == null) {
            trace('Error', 'Could not find UENUM ${def.typeUName} while creating property $name');
          }
          ret.Enum = uenum;
        });
        prop = ret;
      case TDynamicDelegate:
        var delDef = scriptDelegates[def.typeUName],
            sigFn = getDelegateSignature(def.typeUName.substr(1));
        if (delDef != null &&
            (sigFn == null || (!sigFn.HasMetaData(CoreAPI.staticName("UHX_PropSignature_Native")) &&
                                sigFn.HasMetaData(CoreAPI.staticName("UHX_PropSignature")))))
        {
          sigFn = createDelegate(delDef);
        }
        if (sigFn == null) {
          trace('Error', 'Cannot find the delegate signature for type ${def.typeUName}');
          return null;
        }
        var ret:UDelegateProperty = cast newProperty(outer, UDelegateProperty.StaticClass(), name, objFlags);
        ret.SignatureFunction = sigFn;
        prop = ret;

      case TDynamicMulticastDelegate:
        var delDef = scriptDelegates[def.typeUName],
            sigFn = getDelegateSignature(def.typeUName.substr(1));
        if (delDef != null &&
            (sigFn == null || (!sigFn.HasMetaData(CoreAPI.staticName("UHX_PropSignature_Native")) &&
                                sigFn.HasMetaData(CoreAPI.staticName("UHX_PropSignature")))))
        {
          sigFn = createDelegate(delDef);
        }
        if (sigFn == null) {
          trace('Error', 'Cannot find the delegate signature for type ${def.typeUName}');
          return null;
        }
        var ret:UMulticastDelegateProperty = cast newProperty(outer, UMulticastDelegateProperty.StaticClass(), name, objFlags);
        ret.SignatureFunction = sigFn;
        prop = ret;

      case TSet:
        var ret:USetProperty = cast newProperty(outer, USetProperty.StaticClass(), name, objFlags);
        var inner = generateUProperty(@:privateAccess ret, ownerStruct, def.params[0], false);
        if (inner == null) {
          ret.MarkPendingKill();
          return null;
        }
        ret.ElementProp = inner;
        prop = ret;

      case TMap:
        var ret:UMapProperty = cast newProperty(outer, UMapProperty.StaticClass(), name, objFlags);
        var key = generateUProperty(@:privateAccess ret, ownerStruct, def.params[0], false);
        var value = generateUProperty(@:privateAccess ret, ownerStruct, def.params[1], false);
        if (key == null || value == null) {
          if (key != null) {
            key.MarkPendingKill();
          } else if (value != null) {
            value.MarkPendingKill();
          }
          ret.MarkPendingKill();
          return null;
        }
        ret.KeyProp = key;
        ret.ValueProp = value;
        prop = ret;

      case _:
        throw 'No property found for type ${flags.type} for property $def';
    };
    if (flags.hasAny(FSubclassOf)) {
      prop.PropertyFlags |= CPF_UObjectWrapper;
    }
    if (isReturn) {
      prop.PropertyFlags |= CPF_ReturnParm;
      prop.PropertyFlags |= CPF_OutParm;
      prop.PropertyFlags |= CPF_Parm;
      if (flags.hasAny(FConst)) {
        prop.PropertyFlags |= CPF_ConstParm;
      }
    } else {
      if (flags.hasAny(FRef)) {
        if (!flags.hasAny(FConst)) {
          prop.PropertyFlags |= CPF_OutParm;
        }
      } else if (flags.hasAny(FConst)) {
          prop.PropertyFlags |= CPF_ConstParm;
      }
    }
    if (flags.hasAny(FAutoWeak)) {
      prop.PropertyFlags |= CPF_ConstParm;
    }
    if (def.metas != null) {
      prop.PropertyFlags |= getPropertyFlags(ownerStruct, prop, def);
    }
    if (curCls != null && doesAnythingInHierarchyHaveDefaultToInstanced(curCls)) {
      prop.PropertyFlags |= CPF_InstancedReference | CPF_ExportObject;
      prop.SetMetaData("EditInline", "true");
    }

    if (def.replication != null) {
      prop.PropertyFlags |= CPF_Net;
    }
    if (def.repNotify != null) {
      prop.PropertyFlags |= CPF_RepNotify;
      prop.RepNotifyFunc = def.repNotify;
    }
    switch(def.flags.type) {
    case TMap|TArray|TSet if (containsInstancedData(def)):
      prop.PropertyFlags |= CPF_ContainsInstancedReference;
    case _:
    }

    if (def.hxName != null && def.hxName != def.uname) {
      prop.SetMetaData(CoreAPI.staticName('HaxeName'), def.hxName);
    }


    return prop;
  }

  /**
    Finds a script struct given its name (without the prefix (U,A,...))
   **/
  public static function getUEnum(name:String, force:Bool):UEnum {
    var ret:UEnum = cast UObject.StaticFindObjectFast(UEnum.StaticClass(), null, new FName(name), false, true, EObjectFlags.RF_NoFlags);
    if (ret == null && force) {
      var outer = uhx.UCallHelper.StaticClass().GetOuter();
      ret = cast UObject.StaticFindObjectFast(UEnum.StaticClass(), outer, new FName(name), false, true, EObjectFlags.RF_NoFlags);
    }
#if (UE_VER >= 4.17)
    if (ret == null && force) {
      ret = cast UObject.ConstructDynamicType(name, OnlyAllocateClassObject);
    }
#end
    return ret;
  }

  public static function getField(name:String):UField {
    return cast UObject.StaticFindObjectFast(UField.StaticClass(), null, new FName(name), false, true, EObjectFlags.RF_NoFlags);
  }
#end

  public static var ANY_PACKAGE(default, null) = @:privateAccess new UPackage(-1);

  /**
    Finds a class given its name (without the prefix (U,A,...))
   **/
  public static function getUClass(name:String):UClass {
    return cast UObject.StaticFindObjectFast(UClass.StaticClass(), null, new FName(name), false, true, EObjectFlags.RF_NoFlags);
  }

  /**
    Finds a script struct given its name (without the prefix (U,A,...))
   **/
  public static function getUStruct(name:String):UScriptStruct {
    return cast UObject.StaticFindObjectFast(UScriptStruct.StaticClass(), null, new FName(name), false, true, EObjectFlags.RF_NoFlags);
  }

  /**
    Finds a delegate signature given the delegate's name (without the prefix)
   **/
  public static function getDelegateSignature(name:String):Null<UFunction> {
    var delName = name + '__DelegateSignature';
    var ret:UFunction = UObject.FindObject(ANY_PACKAGE, delName);
    if (ret == null) {
      var cls = getUClass(name);
      if (cls != null && Std.is(cls.Children, UFunction) && cls.Children.GetName().toString() == delName) {
        return cast cls.Children;
      }
    }
    return ret;
  }
}

class DynamicRegistry {
  public var def(default, null):MetaDef;
  public var hxClassName(default, null):String;
  public var uclassName(default, null):String;

  public var nativeUClass(default, null):UClass;
  public var isUpdated(default, null):Bool;
  public var wasDeleted(default, null):Bool;
  public var needsToAddProperties(default, null):Bool;

  public var isDynamic(default, null):Bool;

  public var bound:Bool;

  var updatedClass:UClass;

  public var propertiesAdded(default, null):Bool;

  public function new(def:MetaDef, hxClassName:String, uclassName:String) {
    this.def = def;
    this.hxClassName = hxClassName;
    this.uclassName = uclassName;
  }

  public function setNative(uclass:UClass) {
    this.nativeUClass = uclass;
    this.updatedClass = uclass;
    this.isUpdated = true;
    this.needsToAddProperties = true;
  }

  public function setDynamic(val:Bool) {
    this.isDynamic = val;
  }

  public function setUpdated(uclass:UClass, needsToAddProperties:Bool = false) {
    if (this.updatedClass != null || this.isUpdated) {
      trace('Warning', 'An updated class was set (${uclass.GetName()}), but it was already updated: ${uclass.GetName()}');
    }
    this.isUpdated = true;
    this.updatedClass = uclass;
    this.needsToAddProperties = needsToAddProperties;
  }

  public function setPropertiesAdded() {
    if (!this.needsToAddProperties) {
      trace('Warning', 'Class $uclassName added properties twice');
      trace(haxe.CallStack.toString(haxe.CallStack.callStack()));
    }
    this.needsToAddProperties = false;
  }

  public function getUpdated() {
    if (!this.isUpdated) {
      trace('Warning', 'Trying to get updated class when registry is not updated for $uclassName');
    }
    return this.updatedClass;
  }

  public function updateDef(def:MetaDef, hxClassName:String) {
    this.def = def;
    this.hxClassName = hxClassName;
    if (this.nativeUClass != null) {
      this.isUpdated = true;
      this.updatedClass = this.nativeUClass;
      this.wasDeleted = false;
      this.needsToAddProperties = false;
    }
  }

  public function setDeleted() {
    if (this.wasDeleted) {
      trace('Warning', 'Setting class $uclassName as deleted twice in the same compilation');
    }
    this.wasDeleted = true;
    this.needsToAddProperties = true;
  }

  public function resetUpdated() {
    this.wasDeleted = false;
    this.isUpdated = false;
    this.updatedClass = null;
  }

#end
}
