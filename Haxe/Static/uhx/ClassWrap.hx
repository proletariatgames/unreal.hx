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

#if UHX_MULTI_THREADED
  static var constructingObjects:uhx.threading.Tls<Array<unreal.UObject>> = new uhx.threading.Tls();
  static var mutex:cpp.vm.Mutex;
#else
  static var constructingObjects:Array<unreal.UObject> = [];
#end

  static var purgingObjects:Bool;

  public static function wrap(nativePtr:UIntPtr):UObject {
    if (nativePtr == 0) {
      return null;
    }

    if (indexes == null) {
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
#if UHX_MULTI_THREADED
      mutex = new cpp.vm.Mutex();
#end
    }

    var wrapperArray = wrapperArray;
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
#if UHX_MULTI_THREADED
      var constructingObjects = constructingObjects.value;
#else
      var constructingObjects = constructingObjects;
#end
      if (constructingObjects != null) {
        for (obj in constructingObjects) {
          if (obj.wrapped == nativePtr) {
            ret = obj;
            break;
          }
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
    if (ObjectArrayHelper_Glue.indexToSerialReachable(index, nativePtr) != serial) {
      // if we are doing a GC, add this as a normal object and don't immediately set its wrapped as null, as we will set it
      // in the end of this GC. We may have objects that hit this point and call into Haxe code - this can happen if you
      // override BeginDestroy in Unreal.hx
      var inGc = UObject.IsGarbageCollecting();
      if (!inGc && !purgingObjects && !UObject.GExitPurge) {
        ret.wrapped = 0;
        // do not add the object to the array - it shouldn't be there!
        return ret;
      }
    }
#if UHX_MULTI_THREADED
    // we need to write in the wrapper array - so we need to acquire this mutex
    mutex.acquire();
    wrapperArray = ClassWrap.wrapperArray;
    var cur = wrapperArray[index];
    if (cur != null) {
      // another competing thread has already set this
      mutex.release();
      return cur;
    }
    if (index >= wrapperArray.length) {
      // if we need to grow the array, we must create a new one so that the threads that are only reading can safely keep reading from the old array
      var newArray = cpp.NativeArray.create(index * 2 + 1);
      cpp.NativeArray.blit(newArray, 0, wrapperArray, 0, wrapperArray.length);
      wrapperArray = ClassWrap.wrapperArray = newArray;
    }
    // we already made the bounds check
    // cpp.NativeArray.unsafeSet(wrapperArray, index, ret);
    wrapperArray[index] = ret;
    indexes[nIndex++] = index;
    mutex.release();
#else
    wrapperArray[index] = ret;
    indexes[nIndex++] = index;
#end
    return ret;
  }

  public static function pushCtor(obj:UObject) {
    if (obj == null) {
      throw 'Pushing a null constructed object';
    }
#if UHX_MULTI_THREADED
      var arr = constructingObjects.value;
      if (arr == null) {
        constructingObjects.value = arr = [];
      }
      arr.push(obj);
#else
      constructingObjects.push(obj);
#end
  }

  public static function popCtor(obj:UObject) {
#if UHX_MULTI_THREADED
    if (constructingObjects.value == null) {
      throw 'Popping a constructor in a new thread';
    }
    var last = constructingObjects.value.pop();
#else
    var last = constructingObjects.pop();
#end
    if (last == null) {
      throw 'Popping a constructor past the last';
    }
    if (obj != null && last != obj) {
      throw 'Current constructed object $obj is different from last: $last';
    }
  }

  public static function isConstructing(obj:UObject) {
#if UHX_MULTI_THREADED
    var constructingObjects = constructingObjects.value;
    if (constructingObjects == null) {
      return false;
    }
#end
    for (cur in constructingObjects) {
      if (cur == obj) {
        return true;
      }
    }
    return false;
  }

  static function onGC() {
#if UHX_MULTI_THREADED
    mutex.acquire();
#end
    var wrapperArray = wrapperArray,
        inds = indexes,
        len = nIndex;
    var nidx = 0;
    for (i in 0...len) {
      var index = cpp.NativeArray.unsafeGet(inds, i); // we are sure this is inside the bounds, since we are looping through them
#if debug
      // only perform bounds check in debug
      if (index >= wrapperArray.length) {
        throw 'assert: Index $index out of bounds for wrapperArray (${wrapperArray.length})';
      }
#end
      var obj = cpp.NativeArray.unsafeGet(wrapperArray, index);
      if (obj != null && obj.serialNumber != 0 && ObjectArrayHelper_Glue.indexToSerialReachable(index, obj.wrapped) == obj.serialNumber) {
        inds[nidx++] = index;
      } else {
        if (obj != null) {
          obj.invalidate();
          cpp.NativeArray.unsafeSet(wrapperArray, index, null);
        }
      }
    }
    nIndex = nidx + 1;
#if UHX_MULTI_THREADED
    mutex.release();
#end
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
