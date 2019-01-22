package uhx;
import uhx.internal.ObjectArrayHelper;
import uhx.internal.ObjectArrayHelper_Glue;
import cpp.Function;
import unreal.*;

@:access(unreal.UObject)
@:keep class ClassWrap {
#if (!UHX_WRAP_OBJECTS && !UHX_NO_UOBJECT)
  static var wrapperArray:Array<UObject>;
  static var indexes:Array<Int>;
  static var delegateHandles:Array<FDelegateHandle>;
  static var nIndex:Int = 0;

  static var constructingObjects:Array<unreal.UObject> = [];

  static var purgingObjects:Bool;

  public static function wrap(nativePtr:UIntPtr):UObject {
    if (nativePtr == 0) {
      return null;
    }

    if (wrapperArray == null) {
      wrapperArray = [];
      indexes = [];
      delegateHandles = [];
#if (UE_VER < 4.19)
      delegateHandles.push(FCoreUObjectDelegates.PostGarbageCollect.AddLambda(onGC));
#else
      delegateHandles.push(FCoreUObjectDelegates.GetPostGarbageCollect().AddLambda(onGC));
#end
#if (UE_VER >= 4.21)
      delegateHandles.push(FCoreUObjectDelegates.PreGarbageCollectConditionalBeginDestroy.AddLambda(function() {
        purgingObjects = true;
      }));
      delegateHandles.push(FCoreUObjectDelegates.PostGarbageCollectConditionalBeginDestroy.AddLambda(function() {
        purgingObjects = false;
      }));
#end
    }

    var index = ObjectArrayHelper_Glue.objectToIndex(nativePtr);
    var ret = wrapperArray[index];
    var serial = ObjectArrayHelper_Glue.indexToSerialChecked(index, nativePtr);
    if (serial == -1 && ObjectArrayHelper_Glue.indexToSerial(index) != -1)
    {
      trace('Warning', 'Trying to wrap an invalid/unreachable pointer', {obj:ret, serial:serial, index:index, ptr:nativePtr});
      return null;
    }
    if (ret != null) {
      if (ret.serialNumber == serial) {
#if debug
        if (ret.wrapped != nativePtr) {
          throw 'assert: ${ret.wrapped} != ${nativePtr} (index=$index serial=$serial)';
        }
#end
        return ret;
      } else {
        throw 'The object at index $index ($ret) had incompatible serial numbers: ${ret.serialNumber} != $serial';
      }
    }

    if (serial == 0) {
      serial = ObjectArrayHelper_Glue.allocateSerialNumber(index);
    }
    var ptr = uhx.ue.ClassMap.wrap(nativePtr);
    ret = uhx.internal.HaxeHelpers.pointerToDynamic(ptr);
    if (ret == null) {
      for (obj in constructingObjects) {
        if (obj.wrapped == nativePtr) {
          ret = obj;
          break;
        }
      }
      if (ret == null) {
        throw 'Could not find a suitable Haxe wrapper for object';
      }
    }
    ret.serialNumber = serial;
    ret.internalIndex = index;
    // if this object is no longer reachable, it must be set accordingly
    // this can happen if the object was never referenced in Unreal.hx code - only after it was already unreachable
    if (ObjectArrayHelper_Glue.indexToSerialReachable(index, nativePtr) != serial)
    {
      // if we are doing a GC, add this as a normal object and don't immediately set its wrapped as null, as we will set it
      // in the end of this GC. We may have objects that hit this point and call into Haxe code - this can happen if you
      // override BeginDestroy in Unreal.hx
      var inGc = UObject.IsGarbageCollecting();
      if (!inGc && !purgingObjects && !UObject.GExitPurge)
      {
        ret.wrapped = 0;
        // do not add the object to the array - it shouldn't be there!
        return ret;
      }
    }
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

  public static function isConstructing(obj:UObject) {
    for (cur in constructingObjects) {
      if (cur == obj) {
        return true;
      }
    }
    return false;
  }

  static function onGC() {
    var wrapperArray = wrapperArray,
        inds = indexes,
        len = nIndex;
    var nidx = 0;
    for (i in 0...len) {
      var index = inds[i],
          obj = wrapperArray[index];
      if (obj != null && obj.serialNumber != 0 && ObjectArrayHelper_Glue.indexToSerialReachable(index, obj.wrapped) == obj.serialNumber) {
        inds[nidx++] = index;
      } else {
        if (obj != null) {
          obj.invalidate();
        }
        wrapperArray[index] = null;
      }
    }
    nIndex = nidx + 1;
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
