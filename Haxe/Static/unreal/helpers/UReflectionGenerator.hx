package unreal.helpers;
import ue4hx.internal.meta.Metadata;
import haxe.rtti.Meta;

/**
  Given a metadata setting, generates an Unreal UClass/UStruct/UEnum
 **/
class UReflectionGenerator {
#if (WITH_CPPIA && !NO_DYNAMIC_UCLASS)
  public static var ANY_PACKAGE(default, null) = @:privateAccess new UPackage(-1);

  private static var uclassDefs:Map<String, Metadata>;
  private static var uclassToHx:Map<String, String>;

  public static function initializeDef(uclassName:String, hxClassName:String, meta:Metadata) {
    if (uclassDefs == null) {
      uclassDefs = new Map();
      uclassToHx = new Map();
    }
    uclassDefs[uclassName] = meta;
    uclassToHx[uclassName] = hxClassName;
  }

  public static function addProperties(struct:UIntPtr, uname:String) {
    var meta = uclassDefs[uname];
    if (meta == null || meta.uclass == null) {
      trace('Error', 'Cannot find properties for dynamic class $uname');
      return;
    }

    for (propDef in meta.uclass.uprops) {
      generateUProperty(struct, struct, propDef, false);
    }
  }

  @:keep private static function keepTypes() {
    // make sure DCE keeps our used glue code
    UBoolProperty.StaticClass();
    UInt8Property.StaticClass();
    UByteProperty.StaticClass();
    UInt16Property.StaticClass();
    UUInt16Property.StaticClass();
    UIntProperty.StaticClass();
    UUInt32Property.StaticClass();
    UInt64Property.StaticClass();
    UUInt64Property.StaticClass();
    UFloatProperty.StaticClass();
    UDoubleProperty.StaticClass();
    UStrProperty.StaticClass();
    UTextProperty.StaticClass();
    UNameProperty.StaticClass();
    UArrayProperty.StaticClass();
    UObjectProperty.StaticClass();
    UInterfaceProperty.StaticClass();
    UStructProperty.StaticClass();
    UByteProperty.StaticClass();
    UObject.NewObject_NoTemplate( null, null, null, 0);
    var s:UStruct = null;
    s.Children = null;
    var c:UClass = null;
    c = c.ClassWithin;
    s.IsA(c);
  }

  // public static function generate(classOrEnum:Dynamic, meta:Metadata):Void {
  //   if (meta.uclass != null) {
  //     // generateUClass(cls, classOrEnum, meta.uclass);
  //   }
  //   // return null;
  // }

  // public static function addProperties(struct:UIntPtr, classDef:UClassDef) {
  //   for (propDef in classDef.uprops) {
  //     var uprop = generateUProperty(struct, struct, propDef, false);
  //   }
  // }

  // private static function generateUClass(outer:UObject, cls:Class<Dynamic>, classDef:UClassDef):UStruct {
  //   var allProps = [],
  //       allFuncs = [];
  //   // var firstScriptClass = collectFields(cls, allProps, allFuncs);
  //   for (prop in classDef.uprops) {
  //     allProps.push(prop);
  //   }
  //   if (classDef.ufuncs != null) {
  //     for (fn in classDef.ufuncs) {
  //       allFuncs.push(fn);
  //     }
  //   }
  //
  //   var replicatedProps = null;
  //   if (Reflect.hasField(cls, "replicatedProps")) {
  //     replicatedProps = [];
  //     Reflect.setField(cls, "replicatedProps", replicatedProps);
  //   }
  //
  //   // var uclass = UObject.NewObjectByClass(new TypeParam<UBlueprintGeneratedClass>(),
  //   //     outer, classDef.uname.substr(1));
  //   // var bp = UObject.NewObjectByClass(new TypeParam<UBlueprint>(), outer, UBlueprint.StaticClass());
  //   // bp.GeneratedClass = uclass;
  //   // uclass.ClassGeneratedBy = bp;
  //
  //   // check if we need to create a class constructor. right now it seems we can actually use
  //   // the native constructor instead
  //
  //   for (prop in allProps) {
  //     // var uprop = generateUProperty(
  //   }
  // }

  private static function getPropertyFlags(ownerStruct:UIntPtr, prop:UProperty, propDef:UPropertyDef):UInt64 {
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
        // if (Std.is(ownerStruct, UScriptStruct)) {
          // TODO error when compiling
          flags |= PropertyFlags.CPF_RepSkip;
        // }
      case 'ref':
        flags |= PropertyFlags.CPF_OutParm | PropertyFlags.CPF_ReferenceParm;
      case 'replicated' | 'replicatedusing':
        // if (!Std.is(ownerStruct, UScriptStruct)) {
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
        // }
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

  private static function newProperty(outer:UIntPtr, cls:UIntPtr, name:Struct, flags:EObjectFlags):UProperty {
    var ret = unreal.UObject.wrap(uhx.glues.UObject_Glue.NewObject_NoTemplate( outer, cls, name, flags));
    return cast ret;
  }

  private static function generateUProperty(outer:UIntPtr, ownerStruct:UIntPtr, def:UPropertyDef, isReturn:Bool):UProperty {
    // var isLoading = !uhx.glues.UObject_Glue.IsA(outer, uhx.glues.UClass_Glue.get_ClassWithin(uhx.glues.UBoolProperty_Glue.StaticClass()));
    var isLoading = true;
    var flags:EObjectFlags = EObjectFlags.RF_Public;

    var name = new FName(def.uname);
    var prop:UProperty = null;
    switch(def.flags.type) {
      case TBool:
        prop = newProperty( outer, uhx.glues.UBoolProperty_Glue.StaticClass(), name, flags);
      case TI8:
        prop = newProperty( outer, uhx.glues.UInt8Property_Glue.StaticClass(), name, flags);
      case TU8:
        prop = newProperty( outer, uhx.glues.UByteProperty_Glue.StaticClass(), name, flags);
      case TI16:
        prop = newProperty( outer, uhx.glues.UInt16Property_Glue.StaticClass(), name, flags);
      case TU16:
        prop = newProperty( outer, uhx.glues.UUInt16Property_Glue.StaticClass(), name, flags);
      case TI32:
        prop = newProperty( outer, uhx.glues.UIntProperty_Glue.StaticClass(), name, flags);
      case TU32:
        prop = newProperty( outer, uhx.glues.UUInt32Property_Glue.StaticClass(), name, flags);
      case TI64:
        prop = newProperty( outer, uhx.glues.UInt64Property_Glue.StaticClass(), name, flags);
      case TU64:
        prop = newProperty( outer, uhx.glues.UUInt64Property_Glue.StaticClass(), name, flags);

      case F32:
        prop = newProperty( outer, uhx.glues.UFloatProperty_Glue.StaticClass(), name, flags);
      case F64:
        prop = newProperty( outer, uhx.glues.UDoubleProperty_Glue.StaticClass(), name, flags);

      case TString:
        prop = newProperty( outer, uhx.glues.UStrProperty_Glue.StaticClass(), name, flags);
      case TText:
        prop = newProperty( outer, uhx.glues.UTextProperty_Glue.StaticClass(), name, flags);
      case TName:
        prop = newProperty( outer, uhx.glues.UNameProperty_Glue.StaticClass(), name, flags);

      case TArray:
        var ret:UArrayProperty = cast newProperty(outer, uhx.glues.UArrayProperty_Glue.StaticClass(), name, flags);
        var inner = generateUProperty(@:privateAccess ret.wrapped, ownerStruct, def.params[0], false);
        ret.Inner = inner;
        prop = ret;

      case TUObject:
        var ret:UObjectProperty = cast newProperty(outer, uhx.glues.UObjectProperty_Glue.StaticClass(), name, flags);
        var cls = getUClass(def.typeUName.substr(1));
        ret.SetPropertyClass(cls);
        prop = ret;
      case TInterface:
        var ret:UInterfaceProperty = cast newProperty(outer, uhx.glues.UInterfaceProperty_Glue.StaticClass(), name, flags);
        var cls = getUClass(def.typeUName.substr(1));
        ret.SetInterfaceClass(cls);
        prop = ret;
      case TStruct:
        var ret:UStructProperty = cast newProperty(outer, uhx.glues.UStructProperty_Glue.StaticClass(), name, flags);
        var cls = getUStruct(def.typeUName.substr(1));
        ret.Struct = cls;
        prop = ret;
      case TEnum:
        var ret:UByteProperty = cast newProperty(outer, uhx.glues.UByteProperty_Glue.StaticClass(), name, flags);
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

  // private static function collectFields(cls:Dynamic, allProps:Array<UPropertyDef>, allFuncs:Array<UFunctionDef>):UClassDef {
  //   var meta = Meta.getType(cls),
  //       metaDef = meta != null ? meta.UMetaDef : null;
  //   if (metaDef == null) {
  //     return null;
  //   }
  //
  //   var meta:Metadata = metaDef[0];
  //   if (meta == null || meta.uclass == null) {
  //     trace('Error', 'The metadata descriptor of ${Type.getClassName(cls)} was expected but is not in the correct format');
  //     return null;
  //   }
  //   // we must first try to collect the parent class' fields
  //   var parent = Type.getSuperClass(cls),
  //       ret = null;
  //   if (parent != null) {
  //     ret = collectFields(parent, allProps, allFuncs);
  //   }
  //   if (ret == null) {
  //     ret = meta.uclass;
  //   }
  //
  //   var uclass = meta.uclass;
  //   for (prop in uclass.uprops) {
  //     allProps.push(prop);
  //   }
  //   for (fn in uclass.ufuncs) {
  //     allFuncs.push(fn);
  //   }
  //
  //   return ret;
  // }
#end
}
