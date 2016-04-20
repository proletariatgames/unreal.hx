package unreal.helpers;
import cpp.RawPointer;
import cpp.Pointer;
import cpp.Function;
import unreal.*;

@:access(unreal.UObject)
class ClassWrap {
#if !UHX_WRAP_OBJECTS
  static var wrappers:Map<Int, UObject>;
  static var indexes:Array<Int>;
  static var objArray:FUObjectArray;
  static var delegateHandle:FDelegateHandle;
  static var nIndex:Int = 0;

  public static function wrap(nativePtr:Pointer<Dynamic>):UObject {
    if (nativePtr == null) {
      return null;
    }

    if (wrappers == null) {
      wrappers = new Map();
      indexes = [];
      objArray = FUObjectArray.GUObjectArray;
      delegateHandle = FCoreUObjectDelegates.PostGarbageCollect.AddLambda(onGC);
    }
    var index = __pvt._hx_unreal.FUObjectArray_Glue.ObjectToIndex(@:privateAccess objArray.getWrapped().get_raw(), nativePtr.rawCast());
    var ret = wrappers[index];
    var serial = ObjectArrayHelper_Glue.indexToSerial(index);
    if (ret != null) {
      if (ret.serialNumber == serial) {
        return ret;
      } else {
        ret.invalidate();
      }
    }

    ret = unreal.helpers.HaxeHelpers.pointerToDynamic( unreal.helpers.ClassMap.wrap(nativePtr.rawCast()) );
    ret.serialNumber = serial;
    wrappers[index] = ret;
    indexes[nIndex++] = index;
    return ret;
  }

  static function onGC() {
    trace('GC: '+ nIndex);
    var wrappers = wrappers,
        inds = indexes,
        len = nIndex;
    var nidx = 0;
    for (i in 0...len) {
      var index = inds[i],
          obj = wrappers[index];
      var ptr = ObjectArrayHelper_Glue.indexToObject(index);
      trace(obj);
      if (ptr == obj.wrapped && ObjectArrayHelper_Glue.indexToSerial(index) == obj.serialNumber) {
        trace('object ok');
        inds[nidx++] = index;
      } else {
        trace('Invalidating object');
        obj.invalidate();
        wrappers.remove(index);
      }
    }
    trace('GC done');
    nIndex = nidx;
  }

#else
  inline public static function wrap(nativePtr:Pointer<Dynamic>):UObject {
    return unreal.helpers.HaxeHelpers.pointerToDynamic( unreal.helpers.ClassMap.wrap(nativePtr.rawCast()) );
  }
#end
}
