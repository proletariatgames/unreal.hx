package unreal;
using StringTools;

class ReflectAPI {
  /**
    Sets the `obj` `field` to `value`.
    Additionally from the basic types supported by Haxe, the following type transformations are made:
     * if `value` is an `Array<>` and `field` denotes an external `TArray<>`, the `TArray` will be populated from the array contents
     * if `value` is an anonymous object and `field` denotes an external C++ struct, the struct's fields will be populated from the anonymous' object fields
     * if `value` is a `String` and `field` denotes an external `FString`, `FText` or `FName`, the `String` will be converted to the target type
    This function works recursively and is only guaranteed to work with external fields (the ones that are either defined in extern code, or are `@:uproperty` or `@:uexpose` fields)

    Remarks:
     * `unreal.PPtr`, `unreal.PRef`, `unreal.TSharedPtr/TWeakPtr` are not supported for automatic anonymous types / Array automatic conversion
     * Array of anonymous types to TArray of structs is supported, but the default constructor will not be called in this case. So make sure the struct used supports that
     * Blueprint-only classes are partially supported. See `bpSetField`
   **/
  public static function extSetField(obj:haxe.extern.EitherType<unreal.Wrapper, unreal.IInterface>, field:String, value:Dynamic) {
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

//   private static function handleInplaceStruct(from:Dynamic, to:Dynamic, path:String):Bool {
//     var cls = to == null ? null : Type.getClass(to);
//     if (cls == null && to != null && !Reflect.isEnumValue(to) && Reflect.isObject(to)) {
//       if (Std.is(from, Wrapper)) {
//         for (field in Reflect.fields(to)) {
//           var newPath =
// #if debug
//             path + '.$field';
// #else
//             null;
// #end
//           extSetField_rec(from, field, Reflect.field(to, field), newPath);
//         }
//         return true;
//       }
//     } else if (cls == Array) {
//       if (Std.is(from, TArrayImpl)) {
//         var arr:Array<Dynamic> = to,
//             from:TArray<Dynamic> = from;
//         from.Empty();
//         from.AddZeroed(arr.length);
//         for (i in 0...arr.length) {
//           var old = from[i];
//           var newPath =
// #if debug
//             path + '[$i]';
// #else
//             null;
// #end
//           var val = arr[i];
//           if (old == null || !handleInplaceStruct(old, val, newPath)) {
//             from[i] = changeType(old, val, newPath);
//           }
//         }
//         return true;
//       }
//     }
//     return false;
//   }

  private static function handleInplaceStruct(from:Dynamic, to:Dynamic, path:String):Bool {
    return false; // FIXME
  }

  private static function changeType(from:Dynamic, to:Dynamic, path:String):Dynamic {
    // if (Std.is(to, String)) {
    //   if (Std.is(from, FStringImpl)) {
    //     return new FString(to);
    //   } else if (Std.is(from, FNameImpl)) {
    //     return new FName(to);
    //   } else if (Std.is(from, FTextImpl)) {
    //     return new FText(to);
    //   }
    // }
    // return to;
    return to; // FIXME
  }

  private static function extSetField_rec(obj:Dynamic, field:String, value:Dynamic, path:String) {
    var cls = value == null ? null : Type.getClass(value);
    var old = Reflect.getProperty(obj, field);
    if (old == null || !handleInplaceStruct(old, value, path)) {
      try {
        Reflect.setProperty(obj, field, changeType(old, value, path));
      } catch (e:Dynamic) {
        if (StringTools.startsWith(Std.string(e), 'Invalid field:')) {
          if (Std.is(obj, UObject)) {
            var obj:UObject = obj;
            var cls = obj.GetClass();
            if (!cls.HasAllClassFlags(EClassFlags.CLASS_Native)) {
              var prop = cls.FindPropertyByName(field);
              if (prop != null) {
                bpSetField_rec(AnyPtr.fromUObject(obj), prop, value, path);
                return;
              }
            }
          }
        }
#if debug
        throw 'Cannot set field for path `$path` on object of type `${Type.getClassName(Type.getClass(obj))}`: $e';
#else
        throw 'Cannot set field on object of type `${Type.getClassName(Type.getClass(obj))}`: $e';
#end
      }
    }
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
      if (np.IsFloatingPoint()) {
        np.SetFloatingPointPropertyValue(objOffset, cast value);
      } else if (Std.is(prop, UInt64Property)) {
        np.SetIntPropertyValue(objOffset, value);
      } else if (Std.is(prop, UUInt64Property)) {
        np.SetUIntPropertyValue(objOffset, value);
      } else if (Std.is(prop, UUInt32Property)) {
        np.SetUIntPropertyValue(objOffset, value);
      } else {
        np.SetIntPropertyValue(objOffset, cast value);
      }
    } else if (Std.is(prop, UBoolProperty)) {
      var prop:UBoolProperty = cast prop;
      prop.SetPropertyValue(objOffset, value == true);
    } else if (Std.is(prop, UObjectPropertyBase)) {
      var prop:UObjectPropertyBase = cast prop;
      prop.SetObjectPropertyValue(objOffset, value);
    } else if (Std.is(prop, UNameProperty)) {
      if (Std.is(value, String)) {
        value = (cast(value, String) : FName);
      }
      var myObj = AnyPtr.fromStruct(value);
      prop.CopyCompleteValue(objOffset, myObj);
    } else if (Std.is(prop, UStrProperty)) {
      if (Std.is(value, String)) {
        value = (cast(value,String) : FString);
      }
      var myObj = AnyPtr.fromStruct(value);
      prop.CopyCompleteValue(objOffset, myObj);
    } else if (Std.is(prop, UTextProperty)) {
      if (Std.is(value, String)) {
        value = (cast(value,String) : FText);
      }
      var myObj = AnyPtr.fromStruct(value);
      prop.CopyCompleteValue(objOffset, myObj);
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
}
