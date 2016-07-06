package unreal;
using StringTools;

class ReflectAPI {
#if !UHX_NO_UOBJECT
  /**
    Sets the `obj` `field` to `value`.
    Additionally from the basic types supported by Haxe, the following type transformations are made:
     * if `value` is an `Array<>` and `field` denotes an external `TArray<>`, the `TArray` will be populated from the array contents
     * if `value` is an anonymous object and `field` denotes an external C++ struct, the struct's fields will be populated from the anonymous' object fields
     * if `value` is a `String` and `field` denotes an external `FString`, `FText` or `FName`, the `String` will be converted to the target type
    This function works recursively and is only guaranteed to work with external fields (the ones that are either defined in extern code, or are `@:uproperty` or `@:uexpose` fields) of UObject-derived classes

    Remarks:
     * `unreal.PPtr`, `unreal.PRef`, `unreal.TSharedPtr/TWeakPtr` are not supported for automatic anonymous types / Array automatic conversion
     * Array of anonymous types to TArray of structs is supported, but the default constructor will not be called in this case. So make sure the struct used supports that
     * Blueprint-only classes are partially supported. See `bpSetField`
   **/
  public static function extSetField(obj:IInterface, field:String, value:Dynamic) {
    extSetField_rec(obj, field, value, field);
  }

  /**
    Sets the `obj` `field` to `value` - while `obj` is a blueprint-only instance.
    There is only limited support for that right now - only basic types and string are supported
   **/
  public static function bpSetField(obj:unreal.IInterface, field:String, value:Dynamic) {
    var cls = cast(obj, UObject).GetClass();
    var prop = cls.FindPropertyByName(field);
    if (prop != null) {
      bpSetField_rec(AnyPtr.fromUObject(cast obj), prop, value, field);
    } else {
      throw 'Field `$field` does not exist on ${cls.GetDesc()}';
    }
  }

  private static function extSetField_rec(obj:Dynamic, field:String, value:Dynamic, path:String) {
    if (Std.is(obj, UObject)) {
      var obj:UObject = obj;
      var cls = obj.GetClass();
      var prop = cls.FindPropertyByName(field);
      if (prop != null) {
        bpSetField_rec(AnyPtr.fromUObject(obj), prop, value, path);
        return;
      }
    }

    var old = Reflect.getProperty(obj, field);
    var ptr:VariantPtr = old;
    if (!ptr.isObject() || Std.is(old, Wrapper)) {
      throw 'Cannot set non-uproperty struct field for $field ' + (path == null ? '' : '($path)');
    }

    Reflect.setProperty(obj, field, value);
  }

  private static function bpSetField_rec(obj:AnyPtr, prop:UProperty, value:Dynamic, path:String) {
    if (prop.ArrayDim > 1) {
#if debug
      throw 'Property (${prop.GetName()}) with array dimensions more than 1 is not supported (for $path)';
#else
      throw 'Property (${prop.GetName()}) with array dimensions more than 1 is not supported';
#end
    }

    var objOffset = obj + prop.GetOffset_ReplaceWith_ContainerPtrToValuePtr();
    if (Std.is(prop, UNumericProperty)) {
      var np:UNumericProperty = cast prop;
      var i64:Int64 = 0;
      if (Std.is(value, Int)) {
        i64 = cast haxe.Int64.ofInt(value);
      } else if (Std.is(value, Float)) {
        i64 = cast haxe.Int64.ofInt(Std.int(value));
      } else {
        i64 = value;
      }
      if (np.IsFloatingPoint()) {
        np.SetFloatingPointPropertyValue(objOffset, cast value);
      } else if (Std.is(prop, UInt64Property)) {
        np.SetIntPropertyValue(objOffset, i64);
      } else if (Std.is(prop, UUInt64Property)) {
        np.SetUIntPropertyValue(objOffset, i64);
      } else if (Std.is(prop, UUInt32Property)) {
        np.SetUIntPropertyValue(objOffset, i64);
      } else {
        var e = np.GetIntPropertyEnum();
        if (e != null) {
          i64 = cast haxe.Int64.ofInt(getEnumInt(value));
        }
        np.SetIntPropertyValue(objOffset, i64);
      }
    } else if (Std.is(prop, UBoolProperty)) {
      var prop:UBoolProperty = cast prop;
      prop.SetPropertyValue(objOffset, value == true);
    } else if (Std.is(prop, UObjectPropertyBase)) {
      var prop:UObjectPropertyBase = cast prop;
      prop.SetObjectPropertyValue(objOffset, value);
    } else if (Std.is(prop, UNameProperty)) {
      var val:AnyPtr = 0;
      if (Std.is(value, String)) {
        val = AnyPtr.fromStruct(FName.fromString(value));
      } else {
        val = AnyPtr.fromStruct(value);
      }
      prop.CopyCompleteValue(objOffset, val);
    } else if (Std.is(prop, UStrProperty)) {
      var val:AnyPtr = 0;
      if (Std.is(value, String)) {
        val = AnyPtr.fromStruct(FString.fromString(value));
      } else {
        val = AnyPtr.fromStruct(value);
      }
      prop.CopyCompleteValue(objOffset, val);
    } else if (Std.is(prop, UTextProperty)) {
      var val:AnyPtr = 0;
      if (Std.is(value, String)) {
        val = AnyPtr.fromStruct(FText.fromString(value));
      } else {
        val = AnyPtr.fromStruct(value);
      }
      prop.CopyCompleteValue(objOffset, val);
    } else if (Std.is(prop, UArrayProperty)) {
      var prop:UArrayProperty = cast prop,
          inner = prop.Inner;
      var arr:FScriptArray = cast objOffset.getStruct(0);
      if (Std.is(value, Array)) {
        var value:Array<Dynamic> = value;
        var elementSize = inner.ElementSize;
        arr.Empty(value.length, elementSize);
        arr.AddZeroed(value.length, elementSize);
        var data = arr.GetData();
        for (i in 0...value.length) {
          var newPath =
#if debug
            path + '[$i]';
#else
            null;
#end
          bpSetField_rec(data, inner, value[i], newPath);
          data += inner.ElementSize;
        }
      } else {
        var value:FScriptArray = cast value.getStruct(0);
        prop.CopyCompleteValue(objOffset, AnyPtr.fromStruct(value));
      }
    } else if (Std.is(prop, UStructProperty)) {
      var prop:UStructProperty = cast prop,
          struct = prop.Struct;
      if (Type.getClass(value) == null && value != null && !Reflect.isEnumValue(value) && Reflect.isObject(value)) {
        // set objects
        for (field in Reflect.fields(value)) {
          var newPath =
#if debug
            path + '.$field';
#else
            null;
#end
          var prop = struct.FindPropertyByName(field);
          if (prop == null) {
            prop = struct.PropertyLink;
            while (prop != null) {
              // strangely, blueprint-only structs have some weird names
              if (prop.GetName().toString().startsWith(field + '_')) {
                break;
              }
              prop = prop.PropertyLinkNext;
            }
          }
          if (prop == null) {
            throw 'Field `$field` does not exist on ${struct.GetDesc()}' #if debug + ' ($path)' #end;
          }
          bpSetField_rec(objOffset, prop, Reflect.field(value, field), newPath);
        }
      } else {
        throw 'Struct set not supported: ${struct.GetDesc()}';
      }
    } else {
      throw 'Property not supported: $prop';
    }
  }

  private static function getEnumInt(value:Dynamic):Int {
    // convert to ue enum value
    var etype = Type.getEnum(value);
    if (etype != null) {
      var ret = Type.enumIndex(value);
      var name = Type.getEnumName(etype);
      // check for _EnumConv
      var conv:Dynamic = Type.resolveClass(name + '_EnumConv');
      if (conv != null) {
        return conv.haxeToUe(ret + 1);
      } else {
        return ret;
      }
    } else {
      return value;
    }
  }

  public static function bpGetField(obj:unreal.IInterface, field:String):Dynamic {
    var obj:UObject = cast obj;
    var cls = obj.GetClass();
    var prop = cls.FindPropertyByName(field);
    if (prop == null) {
      throw 'Class ${cls.GetDesc()} does not exist!';
    }

    var objPtr = AnyPtr.fromUObject(obj) + prop.GetOffset_ReplaceWith_ContainerPtrToValuePtr();
    if (Std.is(prop, UNumericProperty)) {
      var np:UNumericProperty = cast prop;
      if (np.IsFloatingPoint()) {
        return np.GetFloatingPointPropertyValue(objPtr);
      } else if (Std.is(prop, UInt64Property)) {
        return np.GetSignedIntPropertyValue(objPtr);
      } else if (Std.is(prop, UUInt64Property)) {
        return np.GetUnsignedIntPropertyValue(objPtr);
      } else if (Std.is(prop, UUInt32Property)) {
        return cast np.GetUnsignedIntPropertyValue(objPtr);
      } else {
        return np.GetSignedIntPropertyValue(objPtr);
      }
    } else if (Std.is(prop, UBoolProperty)) {
      var prop:UBoolProperty = cast prop;
      return prop.GetPropertyValue(objPtr);
    } else if (Std.is(prop, UObjectPropertyBase)) {
      var prop:UObjectPropertyBase = cast prop;
      return prop.GetObjectPropertyValue(objPtr);
    } else if (Std.is(prop, UNameProperty)) {
      var value:FName = "";
      prop.CopyCompleteValue(AnyPtr.fromStruct(value),objPtr);
      return value;
    } else if (Std.is(prop, UStrProperty)) {
      var value:FString = "";
      prop.CopyCompleteValue(AnyPtr.fromStruct(value),objPtr);
      return value;
    } else if (Std.is(prop, UTextProperty)) {
      var value:FText = "";
      prop.CopyCompleteValue(AnyPtr.fromStruct(value),objPtr);
      return value;
    } else {
      throw 'Property not supported: $prop (for field $field)';
    }
    return null;
  }

  public static function getBlueprintClass(path:String):UClass {
    // make sure that the package is loaded already
    var pack = UObject.FindPackage(null, path);
    if (pack == null) {
      pack = UObject.LoadPackage(null, path, 0);
    }
    if (pack == null) {
      trace('Warning', 'Package for path $path could not be loaded!');
    } else {
      pack.FullyLoad();

      var arr = TArray.create(new TypeParam<UObject>());
      UObject.GetObjectsWithOuter(pack, arr, true, RF_NoFlags);
      for (val in arr) {
        if (Std.is(val, UBlueprint)) {
          return (cast val : UBlueprint).GeneratedClass;
        } else if (Std.is(val, UClass)) {
          return cast val;
        }
      }
    }

    var obj = UObject.LoadObject(new TypeParam<UBlueprint>(), null, path, null, 0, null);
    if (obj == null) {
      trace('Warning', 'The blueprint path $path does not exist!');
      return null;
    }
    return obj.GeneratedClass;
  }
#end
}
