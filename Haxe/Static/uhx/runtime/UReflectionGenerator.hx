package uhx.runtime;
import uhx.meta.MetaDef;
import uhx.ue.RuntimeLibrary;
import unreal.*;
import unreal.EFunctionFlags;
import unreal.EPropertyFlags.*;
import unreal.EPropertyFlags;
import unreal.CoreAPI;
import haxe.rtti.Meta;

enum HotReloadStatus {
  Success;
  Failure;
  WaitingRebind;
}

/**
  Given a metadata setting, generates an Unreal UClass/UStruct/UEnum
 **/
class UReflectionGenerator {
#if (WITH_CPPIA && !NO_DYNAMIC_UCLASS)
  private static var uclassDefs:Map<String, MetaDef>;
  private static var uclassToHx:Map<String, String>;
  private static var nativeCompiled:Map<String, UStruct>;
  private static var uclassNames:Array<String>;
  private static var propertiesAdded:Map<String, Bool>;

  private static var staticHxToUClass:Map<String, StaticMeta>;
  private static var staticUClassToHx:Map<String, StaticMeta>;
  private static var scriptDelegates:Map<String, UDelegateDef>;

  private static var createdClasses:Map<String, Bool>;

  private static var haxeGcRefOffset(default, null) = RuntimeLibrary.getHaxeGcRefOffset();
#if DEBUG_HOTRELOAD
  public static var id:unreal.UIntPtr = untyped __cpp__("(unreal::UIntPtr) &uclassDefs");
#end

  @:allow(UnrealInit) static function initializeDelegate(def:UDelegateDef) {
    if (scriptDelegates == null) {
      scriptDelegates = new Map();
    }
    scriptDelegates[def.uname] = def;
  }

  @:allow(UnrealInit) static function initializeDef(uclassName:String, hxClassName:String, meta:MetaDef) {
    if (uclassDefs == null) {
      uclassDefs = new Map();
      uclassToHx = new Map();
      nativeCompiled = new Map();
      uclassNames = [];
      propertiesAdded = new Map();
      createdClasses = new Map();
    }
    uclassDefs[uclassName] = meta;
    uclassToHx[uclassName] = hxClassName;
    if (uclassNames.indexOf(uclassName) >= 0) {
      trace('Error', 'Initializing the same class twice: $uclassName');
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
    for (uclass in uclassNames) {
      var def = uclassDefs[uclass],
          ustruct = nativeCompiled[uclass];
      if (ustruct != null) {
        var sig = ustruct.GetMetaData(CoreAPI.staticName("UHX_PropSignature"));
        if (sig.toString() != def.uclass.propSig) {
#if DEBUG_HOTRELOAD
          trace('$id: Class $uclass changed its properties and needs to be reinstanced');
#end
          needsReinstancing = true;
          break;
        }
      }
    }
    var touched = [];
    // 2nd pass - only create classes that need to be created
    // var haxePackage = UObject.FindPackage(null, '/Script/HaxeCppia');
    var haxePackage = UObject.GetTransientPackage();
    var toAdd = [],
        deletedDynamicClasses = new Map();
    if (!needsReinstancing) {
      for (uclass in uclassNames) {
        var def = uclassDefs[uclass],
            ustruct = nativeCompiled[uclass],
            nativeCompiled = true,
            createProps = false;
        if (def.uclass != null && def.uclass.isClass) {
          if (ustruct == null) {
            nativeCompiled = false;
            var old = getUClass(uclass.substr(1));
            if (old != null) {
              var sig = old.GetMetaData(CoreAPI.staticName("UHX_PropSignature"));
              if (sig.toString() != def.uclass.propSig || deletedDynamicClasses[def.uclass.superStructUName]) {
                deletedDynamicClasses[uclass] = true;
                markHotReloaded(old, null, uclass);
              } else {
                ustruct = old;
                var hxPath = uclassToHx[uclass],
                    hxClass = Type.resolveClass(hxPath);
                if (hxClass == null) {
                  trace('Error', 'While loading dynamic class $uclass: The class $hxPath was not found');
                  continue;
                }
                Reflect.setField(hxClass, 'StaticClass', function() {
                  return old;
                });
              }
            }
            if (ustruct == null) {
              var parentName = def.uclass.superStructUName;
              var parent = getUClass(parentName.substr(1));
              if (parent == null) {
                trace('Error', 'A new UStruct called $uclass was defined since the latest C++ compilation, but its parent class $parentName was not found');
                continue;
              }
              ustruct = createClass(haxePackage, uclass, parent, true, uclassToHx[uclass]);
              createProps = true;
            }
          }
          if (ustruct == null) {
            trace('Warning', 'Could not find or create the class $uclass. Skipping');
            continue;
          }
          var sig = ustruct.GetMetaData(CoreAPI.staticName("UHX_PropSignature"));
          if (!createProps && sig.toString() != def.uclass.propSig) {
            throw 'assert: ${uclass}';
          }
          toAdd.push({ ustruct:ustruct, name:uclass, alsoProperties:createProps, isNative:nativeCompiled });
        }
      }

      for (del in scriptDelegates) {
        createDelegate(del);
      }
    }

    // 3rd pass - add the functions/properties
    for (add in toAdd) {
      var changed = false;
      if (add.alsoProperties) {
        changed = true;
        addProperties(add.ustruct, add.name, add.isNative);
      }
      if (addFunctions(cast add.ustruct, add.name, add.isNative)) {
        changed = true;
      }
      if (add.alsoProperties) {
        // bind the class
        var uclass:UClass = cast add.ustruct;
        uclass.Bind();
        uclass.StaticLink(true);
        uclass.GetDefaultObject(true);
        if (!uclass.ClassFlags.hasAny(CLASS_TokenStreamAssembled)) {
          uclass.AssembleReferenceTokenStream(false);
        }
      }

      if (changed && Std.is(add.ustruct, UClass)) {
        touched.push(cast add.ustruct);
      }
    }

    if (needsReinstancing) {
      needsReinstancing = false;
      // reinstance!
      var outer = uhx.UCallHelper.StaticClass().GetOuter();
      var packName = unreal.FPackageName.GetShortFName(outer.GetFName());

      var manager = unreal.FModuleManager.Get();
      var info = new unreal.FModuleStatus();
      if (!manager.QueryModule(packName, info)) {
        trace('Error', 'Trying to hot reload, but module $packName was not found!');
        return Failure;
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

#if DEBUG_HOTRELOAD
      trace('$id: Copying module to $path');
#end
      sys.io.File.copy(info.FilePath.toString(), path.toString());

      if (unreal.editor.UEditorEngine.GEditor != null) {
        return WaitingRebind;
      } else {
        // TODO check this before making any changes and do not load the new cppia type if that's the case
        trace('Error', 'Changing properties with hot reload only works if the editor is running. You will need to restart the game for all changes to take place');
        return Failure;
      }
    } else {
      refreshBlueprints(touched);
      return Success;
    }
  }

  private static function markHotReloaded(obj:UObject, cls:UClass, name:String) {
#if DEBUG_HOTRELOAD
    trace('Marking $name as hot reloaded');
#end
    propertiesAdded.remove(name);
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
          return;
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
        return;
      }
    }

    var outer = uhx.UCallHelper.StaticClass().GetOuter();
    var dummyClass:UClass = getUClass(def.uname.substr(1));
    if (dummyClass == null) {
      dummyClass = cast UObject.NewObject_NoTemplate( outer, UBlueprintGeneratedClass.StaticClass(), def.uname.substr(1), RF_Public );
      var bp = UObject.NewObjectByClass(new TypeParam<UBlueprint>(), outer, UBlueprint.StaticClass());
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

    var old = getDelegateSignature(def.uname.substr(1));
    if (old != null) {
      if (def.signature.propSig == old.GetMetaData(CoreAPI.staticName("UHX_PropSignature")).toString()) {
        // up to date
#if DEBUG_HOTRELOAD
        trace('$id: ${def.uname} is up-to-date');
#end
        return;
      } else {
        markHotReloaded(old, dummyClass, old.GetName().toString());
      }
    }

    def.signature.uname = def.uname.substr(1) + '__DelegateSignature';
    var fn = generateUFunction(dummyClass, def.signature, null, null);
    dummyClass.Children = fn;
    fn.FunctionFlags |= FUNC_Delegate;
    if (def.isMulticast) {
      fn.FunctionFlags |= FUNC_MulticastDelegate;
    }
  }

  public static function startLoadingDynamic() {
#if DEBUG_HOTRELOAD
    trace('$id: startLoadingDynamic');
#end
    nativeCompiled = new Map();
  }

  public static function addProperties(struct:UStruct, uname:String, isNative:Bool) {
#if DEBUG_HOTRELOAD
    trace('$id: addProperties $uname $isNative');
#end
    var meta = uclassDefs[uname];
    if (propertiesAdded.exists(uname)) {
      var oldSig = struct.GetMetaData(CoreAPI.staticName("UHX_PropSignature"));
      if(!oldSig.IsEmpty() && meta != null && meta.uclass != null && meta.uclass.propSig != null) {
        if (meta.uclass.propSig != oldSig.toString()) {
          // properties changed. We need a full hot reload
          trace('Error', 'THe properties of $uname have changed, but no hot reload call was made');
        }
        return;
      } else {
        trace('Error', 'Properties were added, but missing meta / signature for $uname');
      }
      return;
    }
    if (isNative) {
      nativeCompiled[uname] = struct;
    }
    if (meta == null || meta.uclass == null) {
      trace('Error', 'Cannot find properties for dynamic class $uname');
      return;
    }

    var sup = struct.GetInheritanceSuper();
    var superUName = sup != null ? sup.GetPrefixCPP().toString() + sup.GetName() : null;
    if (sup != null && uclassDefs.exists(superUName)) {
      if (!propertiesAdded.exists(superUName)) {
        addProperties(sup, superUName, isNative);
      }
    }

    for (propDef in meta.uclass.uprops) {
      var prop = generateUProperty(struct, struct, propDef, false);
      if (prop == null) {
        trace('Error', 'Error while creating property ${propDef.uname} for class $uname');
        continue;
      }
      prop.SetMetaData(CoreAPI.staticName('HaxeGenerated'),"true");
      struct.AddCppProperty(prop);
    }
    if (isNative) {
      bindProperties(uname, struct);
    }
    propertiesAdded[uname] = true;
    if (meta.uclass.propSig != null) {
      struct.SetMetaData(CoreAPI.staticName('UHX_PropSignature'), meta.uclass.propSig);
    }
  }

  public static function addFunctions(uclass:UClass, uname:String, isNative:Bool):Bool {
#if DEBUG_HOTRELOAD
    trace('$id: addFunctions $uname');
#end
    var meta = uclassDefs[uname];
    var changed = false;
    if (uclass == null) {
      trace('Error', 'Cannot find class $uname to create ufunctions');
      return false;
    }

    if (meta == null || meta.uclass == null) {
      trace('Warning', 'Cannot find metadata to add functions for $uname');
      return false;
    }
    if (meta.uclass.ufuncs == null) {
      return false;
    }
    var hxClassName = uclassToHx[uname];
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
          trace('Error', 'Trying to hot reload a function that was not created by cppia: ${funcDef.uname} on $uname');
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
          // nothing has changed
          continue;
        }
      }
      var parent = sup == null ? null : sup.FindFunctionByName(funcDef.uname, ExcludeSuper);
      var func = generateUFunction(uclass, funcDef, parent, setupFunction);
      changed = true;
      if (func != null) {
        uclass.AddFunctionToFunctionMap(func);
        func.Next = uclass.Children;
        uclass.Children = func;
      }
    }
    return changed;
  }

  private static function generateUFunction(outer:UObject, func:UFunctionDef, parent:UFunction, setupFunction:UIntPtr->UIntPtr->Void):UFunction {
    var fn:UFunction = cast UObject.NewObject_NoTemplate(outer, UFunction.StaticClass(), func.uname, RF_Public);
    if (parent != null) {
      fn.SetSuperStruct(parent);
    }
    if (func.hxName != null && func.hxName != func.uname) {
      fn.SetMetaData(CoreAPI.staticName('HaxeName'), func.hxName);
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
          trace('Error', 'Error while creating property ${arg.uname} for function ${func.uname} (class ${outer.GetName()})');
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
        trace('Error', 'Error while creating return value for function ${func.uname} (class ${outer.GetName()})');
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
      case _:
        if (meta.value != null) {
          fn.SetMetaData(meta.name, meta.value);
        }
      }
    }

    return flags;
  }

  private static function bindProperties(uname:String, struct:UStruct) {
    if (!struct.HasMetaData(CoreAPI.staticName("HaxeGenerated"))) {
      struct.SetMetaData(CoreAPI.staticName('HaxeGenerated'),"true");
    }

    var size = struct.PropertiesSize;
    var ar = new FArchive();

    var sup = struct.GetInheritanceSuper();
    if (sup != null) {
      struct.MinAlignment = sup.GetMinAlignment();
      var superUName = sup.GetPrefixCPP().toString() + sup.GetName();
      if (uclassDefs.exists(superUName)) {
        // super class is dynamic as well - use its property size then
        struct.PropertiesSize = sup.GetPropertiesSize();
      } else {
        // we are the first dynamic class. Use the cpp size then
        var clsName = uclassToHx[uname];
        if (clsName == null) {
          throw 'Haxe class for dynamic class $uname was not registered';
        }
        var cls:Dynamic = Type.resolveClass(clsName);
        if (cls == null) {
          throw 'Haxe class for dynamic class $uname was not found ($clsName)';
        }

        struct.PropertiesSize = cls.CPPSize();
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

  private static function createDynamicClass(haxePackage:UObject, uclassName:String, def:MetaDef) {
    if (def.uclass.isClass) {
#if DEBUG_HOTRELOAD
      trace('$id: Creating dynamic class $uclassName');
#end
      var hxPath = uclassToHx[uclassName];
      var parentName = def.uclass.superStructUName;
      var isHxGenerated = uclassToHx.exists(parentName) || staticUClassToHx.exists(parentName);

      var parent = getUClass(parentName.substr(1));
      if (parent == null) {
        trace('Warning', 'A new UStruct called $uclassName was defined since the latest C++, but its parent class $parentName could not be found');
        return null;
      }

      var uclass = createClass(haxePackage, uclassName, parent, isHxGenerated, hxPath);
      if (uclass == null) {
        return null;
      }

      addFunctions(uclass, uclassName, false);
      addProperties(uclass, uclassName, false);
      return uclass;
    } else {
      trace('Warning', 'A new UStruct called $uclassName was defined since the latest C++ compilation, and only UClasses currently support dynamic loading. Please recompile the C++ module and try again');
    }
    return null;
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
    var uclassDefs = uclassDefs,
        uclassToHx = uclassToHx,
        nativeCompiled = nativeCompiled;
    // var haxePackage = UObject.CreatePackage(null, '/Script/HaxeCppia');
    var haxePackage = UObject.GetTransientPackage();
    if (uclassNames == null) {
      uclassNames = [];
    }

    var deletedDynamicClasses = new Map();
    for (uclassName in uclassNames) {
      var def = uclassDefs[uclassName];
      var ustruct = nativeCompiled[uclassName],
          nativeClass = true;
      if (ustruct == null) {
        nativeClass = false;
        var old = getUClass(uclassName.substr(1));
        // the class might exist because this might be a hot reload session
        if (old != null) {
          var sig = old.GetMetaData(CoreAPI.staticName("UHX_PropSignature"));
          // we need to delete this if either the superclass changed, or if the superclas is a native haxe class the reason
          // why we need to delete it if the superclass is a native compiled class is that the superclass will be hot reloaded
          if (sig.toString() != def.uclass.propSig ||
              deletedDynamicClasses[def.uclass.superStructUName] ||
              nativeCompiled.exists(def.uclass.superStructUName))
          {
            deletedDynamicClasses[uclassName] = true;
            markHotReloaded(old, null, uclassName);
          } else {
            // we don't need to create it - just need to update its functions
            var parentName = def.uclass.superStructUName,
                parentHxGenerated = staticUClassToHx.exists(parentName);
            if (parentHxGenerated) {
              RuntimeLibrary.setSuperClassConstructor(@:privateAccess old.wrapped);
            } else {
              RuntimeLibrary.setupClassConstructor(@:privateAccess old.wrapped);
            }
            addFunctions(old, uclassName, false);
            continue;
          }
        }

        // this is a class that was never compiled into the current binaries
        // so we are going to create it
        ustruct = createDynamicClass(haxePackage, uclassName, def);
        if (ustruct == null) {
          continue;
        }
      } else {
        var uclass:UClass = cast ustruct;
        if (uclass != null) {
          uclass.Bind();
        }
      }

      if (!nativeClass) {
        var uclass:UClass = cast ustruct;
        uclass.Bind();
        uclass.StaticLink(true);

        uclass.GetDefaultObject(true);
        if (!uclass.ClassFlags.hasAny(CLASS_TokenStreamAssembled)) {
          uclass.AssembleReferenceTokenStream(false);
        }
      }
    }

    uclassNames = [];

    // add numReplicatedProperties
    for (del in scriptDelegates) {
      var sig = getDelegateSignature(del.uname.substr(1));
      if (sig == null) {
        createDelegate(del);
      } else {
        if (!sig.HasMetaData(CoreAPI.staticName("UHX_PropSignature_Native"))) {
          sig.SetMetaData(CoreAPI.staticName("UHX_PropSignature_Native"), del.signature.propSig);
        }
      }
    }
  }

  private static function refreshBlueprints(changed:Array<UClass>) {
    var db = unreal.editor.blueprintgraph.FBlueprintActionDatabase.Get();
    for (changed in changed) {
      db.RefreshClassActions(changed);
    }
  }

  private static function createClass(outer:UObject, uclassName:String, parent:UClass, parentHxGenerated:Bool, hxPath:String) {
    var hxClass = Type.resolveClass(hxPath);
    if (hxClass == null) {
      trace('Error', 'While loading dynamic class $uclassName the class $hxPath was not found');
      return null;
    }
    var name = uclassName.substr(1);
    var uclass:UBlueprintGeneratedClass = cast UObject.NewObject_NoTemplate(outer, UBlueprintGeneratedClass.StaticClass(), uclassName.substr(1), 0);
    var bp = UObject.NewObjectByClass(new TypeParam<UBlueprint>(), outer, UBlueprint.StaticClass());
    bp.GeneratedClass = uclass;
    uclass.ClassGeneratedBy = bp;

    uclass.PropertyLink = parent.PropertyLink;
    uclass.ClassWithin = parent.ClassWithin;
    uclass.ClassConfigName = parent.ClassConfigName;

    uclass.SetSuperStruct(parent);
    var flags:EClassFlags = uclass.ClassFlags;
    flags = flags | CLASS_Inherit | CLASS_ScriptInherit | CLASS_CompiledFromBlueprint;
    if (!Std.is(parent, UBlueprintGeneratedClass)) {
      flags = flags | CLASS_Native;
    }
    uclass.ClassFlags = flags;
    uclass.ClassCastFlags = uclass.ClassCastFlags | parent.ClassCastFlags;
    uclass.SetMetaData(CoreAPI.staticName('HaxeClass'),hxPath);
    uclass.SetMetaData(CoreAPI.staticName('HaxeGenerated'),"true");
    uclass.SetMetaData(CoreAPI.staticName('HaxeDynamicClass'),"true");
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
      return uclass;
    });
    return uclass;
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
      }
    }

    return flags;
  }

  private static function newProperty(outer:UObject, cls:UClass, name:FName, flags:EObjectFlags):UProperty {
    return cast UObject.NewObject_NoTemplate( outer, cls, name, flags);
  }

  private static function generateUProperty(outer:UObject, ownerStruct:UStruct, def:UPropertyDef, isReturn:Bool):UProperty {
    // var isLoading = !uhx.glues.UObject_Glue.IsA(outer, uhx.glues.UClass_Glue.get_ClassWithin(uhx.glues.UBoolProperty_Glue.StaticClass()));
    var isLoading = true;
    var objFlags:EObjectFlags = EObjectFlags.RF_Public;

    var name = new FName(def.uname);
    var prop:UProperty = null;
    var flags = def.flags;
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
        var cls = getUClass(def.typeUName.substr(1));
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
          if (cls.IsA(UClass.StaticClass())) {
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
        ret.SetInterfaceClass(cls);
        prop = ret;
      case TStruct:
        var ret:UStructProperty = cast newProperty(outer, UStructProperty.StaticClass(), name, objFlags);
        var cls = getUStruct(def.typeUName.substr(1));
        ret.Struct = cls;
        prop = ret;
      case TEnum:
        var ret:UByteProperty = cast newProperty(outer, UByteProperty.StaticClass(), name, objFlags);
        var cls = getUEnum(def.typeUName.substr(1));
        ret.Enum = cls;
        prop = ret;

      case TDynamicDelegate:
        var sigFn = getDelegateSignature(def.typeUName.substr(1));
        if (sigFn == null) {
          if (scriptDelegates.exists(def.typeUName)) {
            createDelegate(scriptDelegates[def.typeUName]);
          }
          sigFn = getDelegateSignature(def.typeUName.substr(1));
        }
        if (sigFn == null) {
          trace('Error', 'Cannot find the delegate signature for type ${def.typeUName}');
          return null;
        }
        var ret:UDelegateProperty = cast newProperty(outer, UDelegateProperty.StaticClass(), name, objFlags);
        ret.SignatureFunction = sigFn;
        prop = ret;

      case TDynamicMulticastDelegate:
        var sigFn = getDelegateSignature(def.typeUName.substr(1));
        if (sigFn == null) {
          if (scriptDelegates.exists(def.typeUName)) {
            createDelegate(scriptDelegates[def.typeUName]);
          }
          sigFn = getDelegateSignature(def.typeUName.substr(1));
        }
        if (sigFn == null) {
          trace('Error', 'Cannot find the delegate signature for type ${def.typeUName}');
          return null;
        }
        var ret:UMulticastDelegateProperty = cast newProperty(outer, UMulticastDelegateProperty.StaticClass(), name, objFlags);
        ret.SignatureFunction = sigFn;
        prop = ret;

      case t:
        throw 'No property found for type $t for property $def';
    };
    if (flags.hasAny(FSubclassOf)) {
      prop.PropertyFlags |= CPF_UObjectWrapper;
    }
    if (isReturn) {
      prop.PropertyFlags |= CPF_ReturnParm;
      prop.PropertyFlags |= CPF_OutParm;
      if (flags.hasAny(FConst)) {
        prop.PropertyFlags |= CPF_ConstParm;
      }
      if (flags.hasAny(FRef)) {
        prop.PropertyFlags |= CPF_ReferenceParm;
      }
    } else {
      if (flags.hasAny(FRef)) {
        if (flags.hasAny(FConst)) {
          prop.PropertyFlags |= CPF_ConstParm | CPF_ReferenceParm;
        } else {
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

    if (def.replication != null) {
      prop.PropertyFlags |= CPF_Net;
    }
    if (def.hxName != null && def.hxName != def.uname) {
      prop.SetMetaData(CoreAPI.staticName('HaxeName'), def.hxName);
    }
    return prop;
  }

  /**
    Finds a script struct given its name (without the prefix (U,A,...))
   **/
  public static function getUStruct(name:String):UScriptStruct {
    return cast UObject.StaticFindObjectFast(UScriptStruct.StaticClass(), null, new FName(name), false, true, EObjectFlags.RF_NoFlags);
  }

  /**
    Finds a script struct given its name (without the prefix (U,A,...))
   **/
  public static function getUEnum(name:String):UEnum {
    return cast UObject.StaticFindObjectFast(UEnum.StaticClass(), null, new FName(name), false, true, EObjectFlags.RF_NoFlags);
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
    var ret = UObject.StaticFindObjectFast(UClass.StaticClass(), null, new FName(name), false, true, EObjectFlags.RF_NoFlags);
    if (ret == null) {
      ret = UObject.StaticFindObjectFast(UClass.StaticClass(), null, new FName(name), false, true, EObjectFlags.RF_NoFlags);
    }
    return cast ret;
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
