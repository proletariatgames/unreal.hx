package unreal.helpers;
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
    var ptr = unreal.helpers.ClassMap.wrap(nativePtr);
    ret = unreal.helpers.HaxeHelpers.pointerToDynamic(ptr);
    ret.serialNumber = serial;
    ret.internalIndex = index;
    wrappers[index] = ret;
    wrapperArray[index] = ret;
    indexes[nIndex++] = index;
    return ret;
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
    return unreal.helpers.HaxeHelpers.pointerToDynamic( unreal.helpers.ClassMap.wrap(nativePtr) );
#end
  }
#end
}
