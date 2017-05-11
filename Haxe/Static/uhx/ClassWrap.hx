package uhx;
import uhx.internal.ObjectArrayHelper;
import uhx.internal.ObjectArrayHelper_Glue;
import cpp.Function;
import unreal.*;

@:access(unreal.UObject)
@:keep class ClassWrap {
#if (!UHX_WRAP_OBJECTS && !UHX_NO_UOBJECT)
  static var wrappers:Map<Int, UObject>;
  static var wrapperArray:Array<UObject>;
  static var indexes:Array<Int>;
  static var delegateHandle:FDelegateHandle;
  static var nIndex:Int = 0;

  static var constructingObjects:Array<unreal.UObject> = [];

  public static function wrap(nativePtr:UIntPtr):UObject {
    if (nativePtr == 0) {
      return null;
    }

    if (wrappers == null) {
      wrappers = new Map();
      wrapperArray = [];
      indexes = [];
      delegateHandle = FCoreUObjectDelegates.PostGarbageCollect.AddLambda(onGC);
    }
    var index = ObjectArrayHelper_Glue.objectToIndex(nativePtr);
    var ret = wrapperArray[index];
    var serial = ObjectArrayHelper_Glue.indexToSerial(index);
    if (ret != null) {
      if (ret.serialNumber == serial) {
#if debug
        if (ret.wrapped != nativePtr) {
          throw 'assert: ${ret.wrapped} != ${nativePtr}';
        }
#end
        return ret;
      } else {
        ret.invalidate();
      }
    }

    if (serial == 0) {
      serial = ObjectArrayHelper_Glue.allocateSerialNumber(index);
    }
    var ptr = uhx.ue.ClassMap.wrap(nativePtr);
#if (WITH_CPPIA && !NO_DYNAMIC_UCLASS)
    if (ptr == 0) {
      ptr = getDynamicClass(nativePtr);
    }
#end
    ret = uhx.internal.HaxeHelpers.pointerToDynamic(ptr);
    if (ret == null) {
      for (obj in constructingObjects) {
        if (obj.wrapped == nativePtr) {
          ret = obj;
          break;
        }
      }
      if (ret == null) {
        throw 'Could not find ';
      }
    }
    ret.serialNumber = serial;
    ret.internalIndex = index;
    wrappers[index] = ret;
    wrapperArray[index] = ret;
    indexes[nIndex++] = index;
    return ret;
  }

  public static function pushCtor(obj:UObject) {
    if (obj == null) {
      throw 'Pushing a null constructed object';
    }
    constructingObjects.push(obj);
  }

  public static function popCtor(obj:UObject) {
    var last = constructingObjects.pop();
    if (last == null) {
      throw 'Popping a constructor past the last';
    }
    if (obj != null && last != obj) {
      throw 'Current constructed object $obj is different from last: $last';
    }
  }

#if (WITH_CPPIA && !NO_DYNAMIC_UCLASS)
  static var dynamicClassesOffsets = new Map<Int, Int>();
  static var gcRef:FName = new FName("haxeGcRef");

  private static function getDynamicClass(nativePtr:UIntPtr) {
    var uclass = uhx.glues.UObject_Glue.GetClass(nativePtr);
    var unique = uhx.glues.UClass_Glue.get_ClassUnique(uclass);
    var offset = dynamicClassesOffsets[unique];
    if (offset == null) {
      var prop = uhx.glues.UStruct_Glue.FindPropertyByName( uclass, gcRef );
      if (prop == 0) {
        var className:FString = cast uhx.glues.UObject_Glue.GetName(uclass);
        throw 'Cannot find a wrapper for ${className}';
      }
      var ofs = uhx.glues.UProperty_Glue.GetOffset_ReplaceWith_ContainerPtrToValuePtr(prop);
      ofs += uhx.ue.RuntimeLibrary.getHaxeGcRefOffset();
      offset = ofs;
      dynamicClassesOffsets[unique] = ofs;
    }
    var offset:UIntPtr = offset; // making it a non-nullable type
    var ptr:cpp.Pointer<GcRef> = cpp.Pointer.fromRaw(VariantPtr.fromUIntPtr(nativePtr + offset).toPointer()).reinterpret();
    return ptr.ptr.get();
  }

  @:keep private static function keepFunctions() {
    var obj:UObject = null;
    var c = obj.GetClass();
    var unique = c.ClassUnique;
    var prop = c.FindPropertyByName(null);
    prop.GetOffset_ReplaceWith_ContainerPtrToValuePtr();
  }
#end

  public static function isConstructing(obj:UObject) {
    for (cur in constructingObjects) {
      if (cur == obj) {
        return true;
      }
    }
    return false;
  }

  static function onGC() {
    var wrappers = wrappers,
        wrapperArray = wrapperArray,
        inds = indexes,
        len = nIndex;
    var nidx = 0;
    for (i in 0...len) {
      var index = inds[i],
          obj = wrapperArray[index];
      var ptr = ObjectArrayHelper_Glue.indexToObject(index);
      if (obj != null && ptr == obj.wrapped && ObjectArrayHelper_Glue.indexToSerialPendingKill(index) == obj.serialNumber) {
        inds[nidx++] = index;
      } else {
        if (obj != null) {
          obj.invalidate();
        }
        wrappers.remove(index);
        wrapperArray[index] = null;
      }
    }
    nIndex = nidx;
  }

#else

  inline public static function wrap(nativePtr:UIntPtr):UObject {
#if UHX_NO_UOBJECT
    return throw 'Cannot access uobject-derived types inside UE programs';
#else
    return uhx.internal.HaxeHelpers.pointerToDynamic( uhx.ue.ClassMap.wrap(nativePtr) );
#end
  }
#end
}
