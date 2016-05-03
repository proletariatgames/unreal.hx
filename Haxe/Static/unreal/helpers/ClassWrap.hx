package unreal.helpers;
import cpp.RawPointer;
import cpp.Function;
import unreal.*;

@:access(unreal.UObject)
class ClassWrap {
#if !UHX_WRAP_OBJECTS
  static var wrappers:Map<Int, UObject>;
  static var indexes:Array<Int>;
  static var delegateHandle:FDelegateHandle;
  static var nIndex:Int = 0;

  public static function wrap(nativePtr:UIntPtr):UObject {
    if (nativePtr == null) {
      return null;
    }

    if (wrappers == null) {
      wrappers = new Map();
      indexes = [];
      delegateHandle = FCoreUObjectDelegates.PostGarbageCollect.AddLambda(onGC);
    }
    var index = ObjectArrayHelper_Glue.objectToIndex(nativePtr);
    var ret = wrappers[index];
    var serial = ObjectArrayHelper_Glue.indexToSerial(index);
    if (ret != null) {
      if (ret.serialNumber == serial) {
#if debug
        if (ret.wrapped != nativePtr) {
          throw 'assert: ${cpp.Pointer.fromRaw(cast ret.wrapped)} != ${nativePtr}';
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
    ret = unreal.helpers.HaxeHelpers.pointerToDynamic( unreal.helpers.ClassMap.wrap(nativePtr) );
    ret.serialNumber = serial;
    wrappers[index] = ret;
    indexes[nIndex++] = index;
    return ret;
  }

  static function onGC() {
    var wrappers = wrappers,
        inds = indexes,
        len = nIndex;
    var nidx = 0;
    for (i in 0...len) {
      var index = inds[i],
          obj = wrappers[index];
      var ptr = ObjectArrayHelper_Glue.indexToObject(index);
      if (obj != null && ptr == obj.wrapped && ObjectArrayHelper_Glue.indexToSerial(index) == obj.serialNumber) {
        inds[nidx++] = index;
      } else {
        if (obj != null) {
          obj.invalidate();
        }
        wrappers.remove(index);
      }
    }
    nIndex = nidx;
  }

#else
  inline public static function wrap(nativePtr:UIntPtr):UObject {
    return unreal.helpers.HaxeHelpers.pointerToDynamic( unreal.helpers.ClassMap.wrap(nativePtr.rawCast()) );
  }
#end
}
