package unreal;
import unreal.Wrapper;
import unreal.EPropertyFlags.*;
import unreal.EPropertyFlags;
import unreal.EInternalObjectFlags;
using StringTools;

class ReflectAPI {
#if !UHX_NO_UOBJECT
  static var emptyArray:Array<Dynamic> = [];

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

  public static function getUPropertyFromClass(cls:UClass, name:String):UProperty {
    var prop = cls.FindPropertyByName(name);
    if (prop == null) {
      var c = cls.Children;
      while(c != null) {
        c = c.Next;
      }
      throw 'Field "$name" does not exist on ${cls.GetName()}';
    }
    return prop;
  }

  public static function getUFunctionFromClass(cls:UClass, name:String):UFunction {
    var func = cls.FindFunction(name);
    if (func == null) {
      var c = cls.Children;
      while(c != null) {
        c = c.Next;
      }
      throw 'Field "$name" does not exist on ${cls.GetName()}';
    }
    return func;
  }

  public static function setProperty(obj:UObject, prop:UProperty, value:Dynamic):Void {
// #if debug
//     if (prop.GetOuter() != obj.GetClass()) {
//       throw 'Property ${prop.GetName()} does not belong to uclass ${prop.GetOuter()}';
//     }
// #end
    bpSetField_rec(AnyPtr.fromUObject(obj), prop, value, #if debug prop.GetName().toString() #else null #end);
  }

  public static function getProperty(obj:UObject, prop:UProperty):Dynamic {
    return bpGetData(AnyPtr.fromUObject(obj), prop);
  }

  public static function callMethod(obj:UObject, funcName:String, args:Array<Dynamic>):Dynamic {
    var func = obj.FindFunction(funcName);
    return callUFunction(obj, func, args);
  }

  public static function callUFunction(obj:UObject, func:UFunction, args:Array<Dynamic>):Dynamic {
    if (!obj.isValid() && !uhx.ClassWrap.isConstructing(obj)) {
      var msg = 'Cannot call ${func.GetName()} in $obj: Object is invalid';
      trace('Warning', msg);
      throw msg;
    }
    if (args == null) {
      args = emptyArray;
    }

    var objIndex = @:privateAccess obj.internalIndex;
    var flags = objIndex == -1 ? None : uhx.internal.ObjectArrayHelper.getObjectFlags(objIndex);

    var restoreFlags = false;
    if (flags.hasAny(Unreachable | PendingKill)) {
      // unfortunately, Unreal reflection checks if the object is pending kill before calling it
      // this can lead to a lot of unexpected behaviour when calling an object's function that is referenced by another object,
      // since objects can still be reachable but pending kill regardless. So instead of having to add yet another
      // level of complexity of making everything be checked if it's pending kill before calling, or allowing unreal.hx to
      // fail silently, we'll reset the pending kill bit, and then set it back to what it was after the call is made
      if (!uhx.internal.ObjectArrayHelper.clearObjectFlags(objIndex, Unreachable | PendingKill)) {
        throw 'Object array item for index $objIndex (object $obj) was not found';
      }
      if (obj.IsPendingKill()) {
        throw 'This is still pending kill';
      }
      if (obj.IsUnreachable()) {
        throw 'This is still unreachable';
      }

      restoreFlags = true;
    }

    if (!restoreFlags) {
      return callUFunction_pvt(obj, func, args);
    } else {
      var ret = null;
      try {
        ret = callUFunction_pvt(obj, func, args);
      }
      catch(e:Dynamic) {
        if (!uhx.internal.ObjectArrayHelper.setObjectFlags(objIndex, flags & (Unreachable | PendingKill) )) {
          trace('Error', 'Cannot reset pending kill flag for object at index $objIndex ($obj)');
        }
        cpp.Lib.rethrow(e);
      }

        if (!uhx.internal.ObjectArrayHelper.setObjectFlags(objIndex, flags & (Unreachable | PendingKill) )) {
        trace('Error', 'Cannot reset pending kill flag for object at index $objIndex ($obj)');
      }
      return ret;
    }
  }

  private static function callUFunction_pvt(obj:UObject, func:UFunction, args:Array<Dynamic>):Dynamic {
    var cur:UField = func.Children,
        maxAlignment:Int = 0;
    while (cur != null) {
      var prop:UProperty = cast cur;
      if (prop == null) {
        throw 'Unexpected ${Type.getClassName(Type.getClass(cur))} in function\'s type';
      }
      var align = prop.GetMinAlignment();
      if (align > maxAlignment) {
        maxAlignment = align;
      }
      cur = cur.Next;
    }
    var params:AnyPtr = 0;
    // if (func.ParmsSize > 0) {
      var paramsData = Wrapper.InlinePodWrapper.create(func.ParmsSize + maxAlignment, 0);
      params = paramsData.getPointer();
      // re-align it
      params = untyped __cpp__ ("(unreal::UIntPtr) (({0} + {1} - 1) & ~({1} -1))", params, maxAlignment);
      FMemory.Memzero(params, func.ParmsSize);
    // }
    var defaultExportFlags = EPropertyPortFlags.PPF_Localized,
        i = 0;
    cur = func.Children;
    while(cur != null) {
      var prop:UProperty = cast cur;
      cur = cur.Next;
      if (prop.PropertyFlags & (CPF_Parm|CPF_ReturnParm) != CPF_Parm) {
        continue;
      }

      if (args == null || i > args.length) {
        // check default value
        var defaultProperty = "CPP_Default_" + prop.GetName();
        var defaultValue = func.GetMetaData(defaultProperty);
        if (!defaultValue.IsEmpty()) {
          var result = prop.ImportText(
              defaultValue.toString(),
              params + prop.GetOffset_ReplaceWith_ContainerPtrToValuePtr(),
              defaultExportFlags, null, FOutputDevice.GWarn);
          if (result != null) {
            continue;
          }

          throw 'Failed to import default cpp property ${prop.GetName()}';
        } else {
          throw 'Insufficient number of arguments: Supplied ${args.length}';
        }
      }

      bpSetField_rec(params, prop, args[i++], #if debug '${func.GetName()}.${prop.GetName()}' #else null #end);
    }

    obj.ProcessEvent(func, params);
    var prop:UProperty = cast cur;
    if (prop != null) {
      if (prop.PropertyFlags.hasAny(CPF_ReturnParm)) {
        throw 'Bad property flags for return property: ${prop.PropertyFlags}';
      }
      return bpGetData(params, prop);
    }

    return null;
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
      var i64:Int64 = value;
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
        // var value:FScriptArray = cast value.getStruct(0);
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
      } else if (Std.is(value, unreal.Wrapper)) {
        var wrapperValue:unreal.Wrapper = value;
        prop.CopyCompleteValue(objOffset, value.getPointer());
      } else {
        var variant:VariantPtr = value;
        if (!variant.isObject()) {
          prop.CopyCompleteValue(objOffset, variant.getUIntPtr() - 1);
        } else {
          throw 'Struct set not supported: ${struct.GetDesc()} for object $value' #if debug + ' ($path)' #end;
        }
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

    return bpGetData(AnyPtr.fromUObject(obj), prop);
  }

  private static function bpGetData(obj:AnyPtr, prop:UProperty):Dynamic {
    var objPtr:AnyPtr = obj + prop.GetOffset_ReplaceWith_ContainerPtrToValuePtr();
    if (Std.is(prop, UNumericProperty)) {
      var np:UNumericProperty = cast prop;
      var e = np.GetIntPropertyEnum();
      if (e != null) {
        var array = uhx.EnumMap.get(e.CppType.toString());

        if (array == null) {
          var arrCreate:Dynamic = Type.resolveClass('uhx.enums.${e.CppType}_ArrCreate');
          if (arrCreate == null) {
            throw 'Cannot find enum implementation of ${e.CppType} (${e.GetName()})';
          }

          array = arrCreate.get_arr();
          if (array == null) {
            throw 'Cannot find enum implementation function of ${e.CppType} (${e.GetName()})';
          }
          uhx.EnumMap.set(e.CppType.toString(), array);
        }
        var ret = array[np.GetSignedIntPropertyValue(objPtr)];
        if (ret == null) {
          throw 'Cannot find enum of position ${np.GetSignedIntPropertyValue(objPtr)} (${e.GetName()})';
        }
        return ret;
      }

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
    } else if (Std.is(prop, UStructProperty)) {
      // structs are always just pointers, so we can just return them
      return objPtr.getStruct(0);
    } else if (Std.is(prop, UArrayProperty)) {
      return uhx.ue.RuntimeLibrary.wrapProperty(@:privateAccess prop.wrapped, objPtr);
    } else {
      throw 'Property not supported: $prop (for field ${prop.GetName()})';
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

  public static function callHaxeFunction(obj:UObject, stack:FFrame, result:AnyPtr) {
    var ufunc = stack.CurrentNativeFunction,
        stackData = stack.Locals.asAnyPtr();
    var name = ufunc.HasMetaData('HaxeName') ? ufunc.GetMetaData('HaxeName').toString() : ufunc.GetName().toString();
    var fn = Reflect.field(obj, name),
        args = [];
    if (fn == null) {
      throw 'Trying to call function $name (from ufunction ${ufunc.GetName()}), but it was not found on object ${Type.getClassName(Type.getClass(obj))}';
    }
    var arg = ufunc.Children,
        retProp = null;
    while (arg != null) {
      var prop:UProperty = cast arg;
      if (prop == null) {
        throw 'Expected a UProperty, but found ${prop} on ${prop.GetName()}';
      }
      arg = arg.Next;
      if (prop.PropertyFlags.hasAll(CPF_ReturnParm)) {
        retProp = prop;
        continue;
      }

      args.push(bpGetData(stackData, prop));
    }

    var ret = Reflect.callMethod(obj, fn, args);
    if (retProp != null) {
      bpSetField_rec(stackData, retProp, ret, #if debug '${ufunc.GetName()}.ReturnVal' #else null #end);
    }

    if (ufunc.HasAnyFunctionFlags(FUNC_HasOutParms)) {
      var out = stack.OutParms,
          i = -1;
      arg = ufunc.Children;
      while(arg != null && out != null) {
        i++;
        var param:UProperty = cast arg;
        if (param.PropertyFlags & (CPF_ConstParm | CPF_OutParm) == CPF_OutParm) {
          var prop = out.Property;
          if (prop != null) {
            var addr = stackData + param.GetOffset_ReplaceWith_ContainerPtrToValuePtr();
            FMemory.Memcpy(out.PropAddr.asAnyPtr(), addr, prop.ArrayDim * prop.ElementSize);
          }
        }
        if (param.PropertyFlags.hasAny(CPF_OutParm)) {
          out = out.NextOutParm;
        }
        arg = arg.Next;
      }
    }
  }
#end
}
