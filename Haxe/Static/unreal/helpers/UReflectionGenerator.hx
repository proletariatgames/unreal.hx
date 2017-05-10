package unreal.helpers;
import ue4hx.internal.meta.Metadata;
import unreal.helpers.UnrealReflection;
import haxe.rtti.Meta;

/**
  Given a metadata setting, generates an Unreal UClass/UStruct/UEnum
 **/
class UReflectionGenerator {
#if (WITH_CPPIA && !NO_DYNAMIC_UCLASS)
  public static var ANY_PACKAGE(default, null) = @:privateAccess new UPackage(-1);

  private static var uclassDefs:Map<String, Metadata>;
  private static var uclassToHx:Map<String, String>;
  private static var nativeCompiled:Map<String, UStruct>;
  private static var uclassNames:Array<String>;
  private static var propertiesAdded:Map<String, Bool>;

  private static var staticHxToUClass:Map<String, StaticMeta>;
  private static var staticUClassToHx:Map<String, StaticMeta>;

  private static var haxeGcRefOffset(default, null) = unreal.helpers.UnrealReflection.getHaxeGcRefOffset();

  @:allow(UnrealInit) static function initializeDef(uclassName:String, hxClassName:String, meta:Metadata) {
    if (uclassDefs == null) {
      uclassDefs = new Map();
      uclassToHx = new Map();
      nativeCompiled = new Map();
      uclassNames = [];
      propertiesAdded = new Map();
    }
    uclassDefs[uclassName] = meta;
    uclassToHx[uclassName] = hxClassName;
    uclassNames.push(uclassName);
  }

  @:allow(UnrealInit) static function initializeStaticMeta(meta:StaticMeta) {
    if (staticHxToUClass == null) {
      staticHxToUClass = new Map();
      staticUClassToHx = new Map();
    }
    staticHxToUClass[meta.hxPath] = meta;
    staticUClassToHx[meta.uname] = meta;
  }

  public static function startLoadingDynamic() {
    nativeCompiled = new Map();
  }

  public static function addProperties(struct:UStruct, uname:String, isNative:Bool) {
    if (propertiesAdded.exists(uname)) {
      trace('Error', 'Trying to add properties to already bound $uname');
      return;
    }
    nativeCompiled[uname] = struct;
    var meta = uclassDefs[uname];
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
      struct.AddCppProperty(prop);
    }
    if (isNative) {
      bindProperties(uname, struct);
    }
    propertiesAdded[uname] = true;
  }

  private static function bindProperties(uname:String, struct:UStruct) {
    if (!struct.HasMetaData("HaxeGenerated")) {
      struct.SetMetaData('HaxeGenerated',"true");
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

  public static function endLoadingDynamic() {
    trace('end loading dynamic');
    var uclassDefs = uclassDefs,
        uclassToHx = uclassToHx,
        nativeCompiled = nativeCompiled;
    var haxePackage = UObject.CreatePackage(null, '/Script/HaxeCppia');
    for (uclassName in uclassNames) {
      var def = uclassDefs[uclassName];
      var ustruct = nativeCompiled[uclassName],
          nativeClass = true;
      if (ustruct == null) {
        // this is a class that was never compiled into the current binaries
        // so we are going to create it
        nativeClass = false;
        if (def.uclass.isClass) {
          var hxPath = uclassToHx[uclassName];
          var parentName = def.uclass.superStructUName;
          var isHxGenerated = uclassToHx.exists(parentName) || staticUClassToHx.exists(parentName);

          var parent = getUClass(parentName.substr(1));
          if (parent == null) {
            trace('Warning', 'A new UStruct called $uclassName was defined since the latest C++, but its parent class $parentName could not be found');
            continue;
          }

          var uclass = createClass(haxePackage, uclassName, parent, isHxGenerated, hxPath);
          if (uclass == null) {
            continue;
          }
          ustruct = uclass;

          addProperties(ustruct, uclassName, false);
        } else {
          trace('Warning', 'A new UStruct called $uclassName was defined since the latest C++ compilation, and only UClasses currently support dynamic loading. Please recompile the C++ module and try again');
          continue;
        }
      } else {
        var uclass:UClass = cast ustruct;
        if (uclass != null) {
          uclass.Bind();
        }
      }

      // add ufunction

      if (!nativeClass) {
        var uclass:UClass = cast ustruct;
        uclass.Bind();
        uclass.StaticLink(true);

        uclass.GetDefaultObject(true);
      }
    }

    uclassNames = [];

    // add numReplicatedProperties
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
    uclass.SetMetaData('HaxeClass',hxPath);
    uclass.SetMetaData('HaxeGenerated',"true");

    // TODO add class flags from metadata
    if (!parentHxGenerated) {
      // create the new property where the gc ref will be
      var haxeGcRef:UStructProperty = cast newProperty(uclass, UStructProperty.StaticClass(), "haxeGcRef", 0);
      haxeGcRef.Struct = uhx.FHaxeGcRef.StaticStruct();
      uclass.AddCppProperty(haxeGcRef);
    }
    UnrealReflection.setupClassConstructor(@:privateAccess uclass.wrapped, @:privateAccess parent.wrapped, parentHxGenerated);

    Reflect.setField(hxClass, 'StaticClass', function() {
      return uclass;
    });
    return uclass;
  }

  private static function getPropertyFlags(ownerStruct:UStruct, prop:UProperty, propDef:UPropertyDef):UInt64 {
    var flags:UInt64 = 0;
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
        flags |= PropertyFlags.CPF_AdvancedDisplay;
      case 'assetregistrysearchable':
        flags |= PropertyFlags.CPF_AssetRegistrySearchable;
      case 'blueprintassignable':
        flags |= PropertyFlags.CPF_BlueprintAssignable;
      case 'blueprintauthorityonly':
        flags |= PropertyFlags.CPF_BlueprintAuthorityOnly;
      case 'blueprintcallable':
        flags |= PropertyFlags.CPF_BlueprintCallable;
      case 'blueprintreadonly':
        // TODO check if there is another edit specifier while compiling
        flags |= PropertyFlags.CPF_BlueprintVisible | PropertyFlags.CPF_BlueprintReadOnly;
      case 'blueprintreadwrite':
        // TODO check if there is another edit specifier while compiling
        flags |= PropertyFlags.CPF_BlueprintVisible;
      case 'config':
        flags |= PropertyFlags.CPF_Config;
      case 'const':
        flags |= PropertyFlags.CPF_ConstParm;
      case 'duplicatetransient':
        flags |= PropertyFlags.CPF_DuplicateTransient;
      case 'editanywhere':
        // TODO check if other edit calls were made while compiling
        flags |= PropertyFlags.CPF_Edit;
      case 'editdefaultsonly':
        // TODO check if other edit calls were made while compiling
        flags |= PropertyFlags.CPF_Edit | PropertyFlags.CPF_DisableEditOnInstance;
      case 'editfixedsize':
        flags |= PropertyFlags.CPF_EditFixedSize;
      case 'editinline':
        // TODO deprecated warning while compiling
      case 'editinstanceonly':
        // TODO check if other edit calls were made while compiling
        flags |= PropertyFlags.CPF_Edit | PropertyFlags.CPF_DisableEditOnTemplate;
      case 'export':
        flags |= PropertyFlags.CPF_ExportObject;
      case 'globalconfig':
        flags |= PropertyFlags.CPF_GlobalConfig | PropertyFlags.CPF_Config;
      case 'instanced':
        flags |= PropertyFlags.CPF_PersistentInstance | PropertyFlags.CPF_ExportObject | PropertyFlags.CPF_InstancedReference;
        prop.SetMetaData('EditInline', 'true');
      case 'interp':
        flags |= PropertyFlags.CPF_Edit | PropertyFlags.CPF_BlueprintVisible | PropertyFlags.CPF_Interp;
      case 'localized':
        // TODO deprecated
      // TODO Native ?
      case 'noclear':
        flags |= PropertyFlags.CPF_NoClear;
      case 'nonpieduplicatetransient':
        flags |= PropertyFlags.CPF_NonPIEDuplicateTransient;
      case 'nonpietransient':
        // TODO deprecated
        flags |= PropertyFlags.CPF_NonPIEDuplicateTransient;
      case 'nontransactional':
        flags |= PropertyFlags.CPF_NonTransactional;
      case 'notreplicated':
        if (Std.is(ownerStruct, UScriptStruct)) {
          flags |= PropertyFlags.CPF_RepSkip;
        }
      case 'ref':
        flags |= PropertyFlags.CPF_OutParm | PropertyFlags.CPF_ReferenceParm;
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

          flags |= PropertyFlags.CPF_Net;
        }
      case 'repretry':
        // TODO deprecated
      case 'savegame':
        flags |= PropertyFlags.CPF_SaveGame;
      case 'simpledisplay':
        flags |= PropertyFlags.CPF_SimpleDisplay;
      case 'skipserialization':
        flags |= PropertyFlags.CPF_SkipSerialization;
      case 'textexporttransient':
        flags |= PropertyFlags.CPF_TextExportTransient;
      case 'transient':
        flags |= PropertyFlags.CPF_Transient;
      case 'visibleanywhere':
        // TODO check edit specifier
        flags |= PropertyFlags.CPF_Edit | PropertyFlags.CPF_EditConst;
      case 'visibledefaultsonly':
        // TODO check edit specifier
        flags |= PropertyFlags.CPF_Edit | PropertyFlags.CPF_EditConst | PropertyFlags.CPF_DisableEditOnInstance;
      case 'visibleinstanceonly':
        // TODO check edit specifier
        flags |= PropertyFlags.CPF_Edit | PropertyFlags.CPF_EditConst | PropertyFlags.CPF_DisableEditOnTemplate;
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
    var flags:EObjectFlags = EObjectFlags.RF_Public;

    var name = new FName(def.uname);
    var prop:UProperty = null;
    switch(def.flags.type) {
      case TBool:
        prop = newProperty( outer, UBoolProperty.StaticClass(), name, flags);
      case TI8:
        prop = newProperty( outer, UInt8Property.StaticClass(), name, flags);
      case TU8:
        prop = newProperty( outer, UByteProperty.StaticClass(), name, flags);
      case TI16:
        prop = newProperty( outer, UInt16Property.StaticClass(), name, flags);
      case TU16:
        prop = newProperty( outer, UUInt16Property.StaticClass(), name, flags);
      case TI32:
        prop = newProperty( outer, UIntProperty.StaticClass(), name, flags);
      case TU32:
        prop = newProperty( outer, UUInt32Property.StaticClass(), name, flags);
      case TI64:
        prop = newProperty( outer, UInt64Property.StaticClass(), name, flags);
      case TU64:
        prop = newProperty( outer, UUInt64Property.StaticClass(), name, flags);

      case F32:
        prop = newProperty( outer, UFloatProperty.StaticClass(), name, flags);
      case F64:
        prop = newProperty( outer, UDoubleProperty.StaticClass(), name, flags);

      case TString:
        prop = newProperty( outer, UStrProperty.StaticClass(), name, flags);
      case TText:
        prop = newProperty( outer, UTextProperty.StaticClass(), name, flags);
      case TName:
        prop = newProperty( outer, UNameProperty.StaticClass(), name, flags);

      case TArray:
        var ret:UArrayProperty = cast newProperty(outer, UArrayProperty.StaticClass(), name, flags);
        var inner = generateUProperty(@:privateAccess ret, ownerStruct, def.params[0], false);
        ret.Inner = inner;
        prop = ret;

      case TUObject:
        var cls = getUClass(def.typeUName.substr(1));
        if (def.flags.hasAny(FWeak)) {
          var ret:UWeakObjectProperty = cast newProperty(outer, UWeakObjectProperty.StaticClass(), name, flags);
          ret.SetPropertyClass(cls);
          prop = ret;
        } else if (def.flags.hasAny(FSubclassOf)) {
          var ret:UClassProperty = cast newProperty(outer, UClassProperty.StaticClass(), name, flags);
          ret.PropertyFlags |= PropertyFlags.CPF_UObjectWrapper;
          ret.SetPropertyClass(UClass.StaticClass());
          ret.MetaClass = cls;
          prop = ret;
        } else {
          if (cls.IsA(UClass.StaticClass())) {
            var ret:UClassProperty = cast newProperty(outer, UClassProperty.StaticClass(), name, flags);
            ret.SetPropertyClass(cls);
            ret.MetaClass = UObject.StaticClass();
            prop = ret;
          } else {
            var ret:UObjectProperty = cast newProperty(outer, UObjectProperty.StaticClass(), name, flags);
            ret.SetPropertyClass(cls);
            prop = ret;
          }
        }
      case TInterface:
        var ret:UInterfaceProperty = cast newProperty(outer, UInterfaceProperty.StaticClass(), name, flags);
        var cls = getUClass(def.typeUName.substr(1));
        ret.SetInterfaceClass(cls);
        prop = ret;
      case TStruct:
        var ret:UStructProperty = cast newProperty(outer, UStructProperty.StaticClass(), name, flags);
        var cls = getUStruct(def.typeUName.substr(1));
        ret.Struct = cls;
        prop = ret;
      case TEnum:
        var ret:UByteProperty = cast newProperty(outer, UByteProperty.StaticClass(), name, flags);
        var cls = getUEnum(def.typeUName.substr(1));
        ret.Enum = cls;
        prop = ret;
      case t:
        throw 'No property found for type $t for property $def';
    };
    var flags = def.flags;
    if (flags.hasAny(FSubclassOf)) {
      prop.PropertyFlags |= PropertyFlags.CPF_UObjectWrapper;
    }
    if (isReturn) {
      prop.PropertyFlags |= PropertyFlags.CPF_ReturnParm;
      if (flags.hasAny(FConst)) {
        prop.PropertyFlags |= PropertyFlags.CPF_ConstParm;
      }
      if (flags.hasAny(FRef)) {
        prop.PropertyFlags |= PropertyFlags.CPF_ReferenceParm;
      }
    } else {
      if (flags.hasAny(FRef)) {
        if (flags.hasAny(FConst)) {
          prop.PropertyFlags |= PropertyFlags.CPF_ConstParm | PropertyFlags.CPF_ReferenceParm;
        } else {
          prop.PropertyFlags |= PropertyFlags.CPF_OutParm;
        }
      } else if (flags.hasAny(FConst)) {
          prop.PropertyFlags |= PropertyFlags.CPF_ConstParm;
      }
    }
    if (flags.hasAny(FAutoWeak)) {
      prop.PropertyFlags |= PropertyFlags.CPF_ConstParm;
    }
    if (def.metas != null) {
      prop.PropertyFlags |= getPropertyFlags(ownerStruct, prop, def);
    }

    if (def.replication != null) {
      prop.PropertyFlags |= PropertyFlags.CPF_Net;
    }
    return prop;
  }

  /**
    Finds a class given its name (without the prefix (U,A,...))
   **/
  public static function getUClass(name:String):UClass {
    return cast UObject.StaticFindObjectFast(UClass.StaticClass(), null, new FName(name), true, true, EObjectFlags.RF_NoFlags);
  }

  /**
    Finds a script struct given its name (without the prefix (U,A,...))
   **/
  public static function getUStruct(name:String):UScriptStruct {
    return cast UObject.StaticFindObjectFast(UScriptStruct.StaticClass(), null, new FName(name), true, true, EObjectFlags.RF_NoFlags);
  }

  /**
    Finds a script struct given its name (without the prefix (U,A,...))
   **/
  public static function getUEnum(name:String):UEnum {
    return cast UObject.StaticFindObjectFast(UEnum.StaticClass(), null, new FName(name), true, true, EObjectFlags.RF_NoFlags);
  }

  public static function getField(name:String):UField {
    return cast UObject.StaticFindObjectFast(UField.StaticClass(), null, new FName(name), true, true, EObjectFlags.RF_NoFlags);
  }
#end
}
