package unreal;

class ReflectAPI {
  /**
    Sets the `obj` `field` to `value`.
    Additionally from the basic types supported by Haxe, the following type transformations are made:
     * if `value` is an `Array<>` and `field` denotes an external `TArray<>`, the `TArray` will be populated from the array contents
     * if `value` is an anonymous object and `field` denotes an external C++ struct, the struct's fields will be populated from the anonymous' object fields
     * if `value` is a `String` and `field` denotes an external `FString`, `FText` or `FName`, the `String` will be converted to the target type
    This function works recursively and is only guaranteed to work with external fields (the ones that are either defined in extern code, or are `@:uproperty` or `@:uexpose` fields)

    Remarks:
     * `unreal.PExternal`, `unreal.PRef`, `unreal.TSharedPtr/TWeakPtr` are not supported for automatic anonymous types / Array automatic conversion
     * Array of anonymous types to TArray of structs is supported, but the default constructor will not be called in this case. So make sure the struct used supports that
   **/
  public static function extSetField(obj:haxe.extern.EitherType<unreal.Wrapper, unreal.IInterface>, field:String, value:Dynamic) {
    extSetField_rec(obj, field, value, field);
  }

  private static function handleInplaceStruct(from:Dynamic, to:Dynamic, path:String):Bool {
    var cls = to == null ? null : Type.getClass(to);
    if (cls == null && to != null && !Reflect.isEnumValue(to) && Reflect.isObject(to)) {
      if (Std.is(from, Wrapper)) {
        for (field in Reflect.fields(to)) {
          var newPath =
#if debug
            path + '.$field';
#else
            null;
#end
          extSetField_rec(from, field, Reflect.field(to, field), newPath);
        }
        return true;
      }
    } else if (cls == Array) {
      if (Std.is(from, TArrayImpl)) {
        var arr:Array<Dynamic> = to,
            from:TArray<Dynamic> = from;
        from.Empty();
        from.AddZeroed(arr.length);
        for (i in 0...arr.length) {
          var old = from[i];
          var newPath =
#if debug
            path + '[$i]';
#else
            null;
#end
          var val = arr[i];
          if (old == null || !handleInplaceStruct(old, val, newPath)) {
            from[i] = changeType(old, val, newPath);
          }
        }
        return true;
      }
    }
    return false;
  }

  private static function changeType(from:Dynamic, to:Dynamic, path:String):Dynamic {
    if (Std.is(to, String)) {
      if (Std.is(from, FStringImpl)) {
        return new FString(to);
      } else if (Std.is(from, FNameImpl)) {
        return new FName(to);
      } else if (Std.is(from, FTextImpl)) {
        return new FText(to);
      }
    }
    return to;
  }

  private static function extSetField_rec(obj:Dynamic, field:String, value:Dynamic, path:String) {
    var cls = value == null ? null : Type.getClass(value);
    var old = Reflect.getProperty(obj, field);
    if (old == null || !handleInplaceStruct(old, value, path)) {
#if debug
      try {
#end
      Reflect.setProperty(obj, field, changeType(old, value, path));
#if debug
      } catch (e:Dynamic) {
        throw 'Cannot set field for path `$path` on object of type `${Type.getClassName(Type.getClass(obj))}`: $e';
      }
#end
    }
  }
}
