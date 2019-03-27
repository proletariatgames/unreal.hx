package uhx.expose;
import unreal.Wrapper;
import unreal.*;
import uhx.EnumMap;
import uhx.HaxeCodeDispatcher;
import uhx.internal.HaxeHelpers;
import uhx.internal.Helpers;

@:headerClassCode('
  inline static unreal::UIntPtr callFunction(unreal::UIntPtr ptr) { return callFunction0(ptr); }
  inline static unreal::UIntPtr callFunction(unreal::UIntPtr ptr, unreal::UIntPtr arg0) { return callFunction1(ptr, arg0); }
  inline static unreal::UIntPtr callFunction(unreal::UIntPtr ptr, unreal::UIntPtr arg0, unreal::UIntPtr arg1) { return callFunction2(ptr, arg0, arg1); }
  inline static unreal::UIntPtr callFunction(unreal::UIntPtr ptr, unreal::UIntPtr arg0, unreal::UIntPtr arg1, unreal::UIntPtr arg2) { return callFunction3(ptr, arg0, arg1, arg2); }
  inline static unreal::UIntPtr callFunction(unreal::UIntPtr ptr, unreal::UIntPtr arg0, unreal::UIntPtr arg1, unreal::UIntPtr arg2, unreal::UIntPtr arg3) { return callFunction4(ptr, arg0, arg1, arg2, arg3); }
  inline static unreal::UIntPtr callFunction(unreal::UIntPtr ptr, unreal::UIntPtr arg0, unreal::UIntPtr arg1, unreal::UIntPtr arg2, unreal::UIntPtr arg3, unreal::UIntPtr arg4) { return callFunction5(ptr, arg0, arg1, arg2, arg3, arg4); }
  inline static unreal::UIntPtr callFunction(unreal::UIntPtr ptr, unreal::UIntPtr arg0, unreal::UIntPtr arg1, unreal::UIntPtr arg2, unreal::UIntPtr arg3, unreal::UIntPtr arg4, unreal::UIntPtr arg5) { return callFunction6(ptr, arg0, arg1, arg2, arg3, arg4, arg5); }
  inline static unreal::UIntPtr callFunction(unreal::UIntPtr ptr, unreal::UIntPtr arg0, unreal::UIntPtr arg1, unreal::UIntPtr arg2, unreal::UIntPtr arg3, unreal::UIntPtr arg4, unreal::UIntPtr arg5, unreal::UIntPtr arg6) { return callFunction7(ptr, arg0, arg1, arg2, arg3, arg4, arg5, arg6); }
  inline static unreal::UIntPtr callFunction(unreal::UIntPtr ptr, unreal::UIntPtr arg0, unreal::UIntPtr arg1, unreal::UIntPtr arg2, unreal::UIntPtr arg3, unreal::UIntPtr arg4, unreal::UIntPtr arg5, unreal::UIntPtr arg6, unreal::UIntPtr arg7) { return callFunction8(ptr, arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7); }
')
@:uexpose @:keep class HxcppRuntime
{
  @:extern static inline function toDyn(ptr:UIntPtr) return HaxeHelpers.pointerToDynamic(ptr);
  @:extern static inline function toPtr(dyn:Dynamic) return HaxeHelpers.dynamicToPointer(dyn);

  public static function constCharToString(str:cpp.ConstCharStar) : UIntPtr {
    return toPtr(str.toString());
  }
  public static function stringToConstChar(ptr:UIntPtr) : cpp.ConstCharStar {
    return cpp.ConstCharStar.fromString( toDyn(ptr) );
  }

  @:void public static function throwString(str:cpp.ConstCharStar) : Void {
    throw str.toString();
  }


  public static function uobjectWrap(uobj:UIntPtr) : UIntPtr {
#if !UHX_NO_UOBJECT
    return HaxeHelpers.dynamicToPointer(UObject.wrap(uobj));
#else
    return throw 'Cannot access uobjects on UE programs';
#end
  }

  public static function uobjectUnwrap(uobj:UIntPtr) : UIntPtr {
#if !UHX_NO_UOBJECT
    var uobj = (HaxeHelpers.pointerToDynamic(uobj) : UObject);
    return uobj != null ? @:privateAccess uobj.wrapped : 0;
#else
    return throw 'Cannot access uobjects on UE programs';
#end
  }

  public static function arrayIndex(array:UIntPtr, index:Int) : UIntPtr {
    var arr:Dynamic = HaxeHelpers.pointerToDynamic(array);
    return HaxeHelpers.dynamicToPointer(arr[index]);
  }

  public static function hxEnumToCppInt(value:UIntPtr) : Int {
    #if !UHX_NO_UOBJECT
    return @:privateAccess unreal.ReflectAPI.hxEnumToCppInt(HaxeHelpers.pointerToDynamic(value));
    #else
    return throw "Cannot access uobjects on UE programs";
    #end
  }

  public static function cppIntToHxEnum(cppType:cpp.ConstCharStar, value:Int) : UIntPtr {
    #if !UHX_NO_UOBJECT
    return HaxeHelpers.dynamicToPointer(@:privateAccess unreal.ReflectAPI.cppIntToHxEnum(cppType.toString(), value));
    #else
    return throw "Cannot access uobjects on UE programs";
    #end
  }

  public static function enumIndex(e:UIntPtr) : Int {
    return Type.enumIndex( HaxeHelpers.pointerToDynamic(e) );
  }

  public static function getEnumArray(name:cpp.ConstCharStar) : UIntPtr {
    return HaxeHelpers.dynamicToPointer(EnumMap.get(name.toString()));
  }


  public static function boxBool(b:Bool):UIntPtr {
    return HaxeHelpers.dynamicToPointer(b);
  }

  public static function boxInt(i:Int):UIntPtr {
    return HaxeHelpers.dynamicToPointer(i);
  }

  public static function boxFloat(f:cpp.Float64):UIntPtr {
    return HaxeHelpers.dynamicToPointer(f);
  }

  public static function boxInt64(i:cpp.Int64):UIntPtr {
    return HaxeHelpers.dynamicToPointer(i);
  }

  public static function unboxBool(ptr:UIntPtr):Bool {
    return HaxeHelpers.pointerToDynamic(ptr);
  }

  public static function unboxInt(ptr:UIntPtr):Int {
    return HaxeHelpers.pointerToDynamic(ptr);
  }

  public static function unboxFloat(ptr:UIntPtr):cpp.Float64 {
    return HaxeHelpers.pointerToDynamic(ptr);
  }

  public static function unboxInt64(ptr:UIntPtr):cpp.Int64 {
    return HaxeHelpers.pointerToDynamic(ptr);
  }

  public static function boxVariantPtr(ptr:VariantPtr):UIntPtr {
    var dyn:Dynamic = ptr;
    return HaxeHelpers.dynamicToPointer(dyn);
  }

  public static function unboxVariantPtr(ptr:UIntPtr):VariantPtr {
    return HaxeHelpers.pointerToDynamic(ptr);
  }

  public static function enterGCFreeZone() {
    cpp.vm.Gc.enterGCFreeZone();
  }

  public static function exitGCFreeZone() {
    cpp.vm.Gc.exitGCFreeZone();
  }

  public static function createInlinePodWrapper(size:Int, info:UIntPtr) : VariantPtr {
    var ret = VariantPtr.fromDynamic( InlinePodWrapper.create(size, info) );
#if debug
    if (ret.isExternalPointer()) {
      throw 'Assertion failed: Hxcpp allocated invalid pointer $ret';
    }
#end
    return ret;
  }

  public static function createInlineWrapper(size:Int, info:UIntPtr) : VariantPtr {
    var ret = VariantPtr.fromDynamic( InlineWrapper.create(size, info) );
#if debug
    if (ret.isExternalPointer()) {
      throw 'Assertion failed: Hxcpp allocated invalid pointer $ret';
    }
#end
    return ret;
  }

  public static function createAlignedInlineWrapper(size:Int, info:UIntPtr) : VariantPtr {
    var ret = VariantPtr.fromDynamic( AlignedInlineWrapper.create(size, info) );
#if debug
    if (ret.isExternalPointer()) {
      throw 'Assertion failed: Hxcpp allocated invalid pointer $ret';
    }
#end
    return ret;
  }

  public static function createInlineTemplateWrapper(size:Int, info:UIntPtr) : VariantPtr {
    var ret = VariantPtr.fromDynamic( InlineTemplateWrapper.create(size, info) );
#if debug
    if (ret.isExternalPointer()) {
      throw 'Assertion failed: Hxcpp allocated invalid pointer $ret';
    }
#end
    return ret;
  }

  public static function createPointerTemplateWrapper(pointer:UIntPtr, info:UIntPtr, extraSize:Int) : VariantPtr {
    var ret = VariantPtr.fromDynamic( PointerTemplateWrapper.create(pointer, info, extraSize) );
#if debug
    if (ret.isExternalPointer()) {
      throw 'Assertion failed: Hxcpp allocated invalid pointer $ret';
    }
#end
    return ret;
  }


  public static function getTemplateOffset() : UIntPtr {
    return unreal.Wrapper.TemplateWrapper.getOffset();
  }

  public static function getTemplatePointerSize() : UIntPtr {
    return unreal.Wrapper.PointerTemplateWrapper.getSize();
  }

  public static function getTemplateSize() : UIntPtr {
    return unreal.Wrapper.TemplateWrapper.getSize();
  }

  public static function getAlignedInlineWrapperSize() : UIntPtr {
    return unreal.Wrapper.AlignedInlineWrapper.getSize();
  }

  public static function getInlineWrapperOffset() : UIntPtr {
    return unreal.Wrapper.InlineWrapper.getOffset();
  }

  public static function getInlinePodWrapperOffset() : UIntPtr {
    return unreal.Wrapper.InlinePodWrapper.getOffset();
  }

  public static function setWrapperStructInfo(wrapper : UIntPtr, info : UIntPtr) : Void {
    var wrapper:Wrapper = toDyn(wrapper);
    wrapper.setInfo(info);
  }


  public static function callFunction0(ptr:UIntPtr) : UIntPtr {
    return toPtr( HaxeCodeDispatcher.runWithValue( function() return toDyn(ptr)() ));
  }
  public static function callFunction1(ptr:UIntPtr, arg0:UIntPtr) : UIntPtr {
    return toPtr( HaxeCodeDispatcher.runWithValue( function() return (toDyn(ptr))(toDyn(arg0)) ));
  }
  public static function callFunction2(ptr:UIntPtr, arg0:UIntPtr, arg1:UIntPtr) : UIntPtr {
    return toPtr( HaxeCodeDispatcher.runWithValue( function() return (toDyn(ptr))(toDyn(arg0), toDyn(arg1)) ));
  }
  public static function callFunction3(ptr:UIntPtr, arg0:UIntPtr, arg1:UIntPtr, arg2:UIntPtr) : UIntPtr {
    return toPtr( HaxeCodeDispatcher.runWithValue( function() return (toDyn(ptr))(toDyn(arg0), toDyn(arg1), toDyn(arg2)) ));
  }
  public static function callFunction4(ptr:UIntPtr, arg0:UIntPtr, arg1:UIntPtr, arg2:UIntPtr, arg3:UIntPtr) : UIntPtr {
    return toPtr( HaxeCodeDispatcher.runWithValue( function() return (toDyn(ptr))(toDyn(arg0), toDyn(arg1), toDyn(arg2), toDyn(arg3)) ));
  }
  public static function callFunction5(ptr:UIntPtr, arg0:UIntPtr, arg1:UIntPtr, arg2:UIntPtr, arg3:UIntPtr, arg4:UIntPtr) : UIntPtr {
    return toPtr( HaxeCodeDispatcher.runWithValue( function() return (toDyn(ptr))(toDyn(arg0), toDyn(arg1), toDyn(arg2), toDyn(arg3), toDyn(arg4)) ));
  }
  public static function callFunction6(ptr:UIntPtr, arg0:UIntPtr, arg1:UIntPtr, arg2:UIntPtr, arg3:UIntPtr, arg4:UIntPtr, arg5:UIntPtr) : UIntPtr {
    return toPtr( HaxeCodeDispatcher.runWithValue( function() return (toDyn(ptr))(toDyn(arg0), toDyn(arg1), toDyn(arg2), toDyn(arg3), toDyn(arg4), toDyn(arg5)) ));
  }
  public static function callFunction7(ptr:UIntPtr, arg0:UIntPtr, arg1:UIntPtr, arg2:UIntPtr, arg3:UIntPtr, arg4:UIntPtr, arg5:UIntPtr, arg6:UIntPtr) : UIntPtr {
    return toPtr( HaxeCodeDispatcher.runWithValue( function() return (toDyn(ptr))(toDyn(arg0), toDyn(arg1), toDyn(arg2), toDyn(arg3), toDyn(arg4), toDyn(arg5), toDyn(arg6)) ));
  }
  public static function callFunction8(ptr:UIntPtr, arg0:UIntPtr, arg1:UIntPtr, arg2:UIntPtr, arg3:UIntPtr, arg4:UIntPtr, arg5:UIntPtr, arg6:UIntPtr, arg7:UIntPtr) : UIntPtr {
    return toPtr( HaxeCodeDispatcher.runWithValue( function() return (toDyn(ptr))(toDyn(arg0), toDyn(arg1), toDyn(arg2), toDyn(arg3), toDyn(arg4), toDyn(arg5), toDyn(arg6), toDyn(arg7)) ));
  }

  public static function setDynamicNative(struct:UIntPtr, name:cpp.ConstCharStar) {
#if (WITH_CPPIA && !NO_DYNAMIC_UCLASS && !UHX_NO_UOBJECT)
    HaxeCodeDispatcher.runVoid( function() {
      var struct:UClass = cast @:privateAccess unreal.UObject.wrap(struct);
      uhx.runtime.UReflectionGenerator.setDynamicNative(struct, name.toString());
    });
#end
  }

  public static function setNativeTypes() {
#if (WITH_CPPIA && !NO_DYNAMIC_UCLASS && !UHX_NO_UOBJECT)
    HaxeCodeDispatcher.runVoid( function() {
      uhx.runtime.UReflectionGenerator.setNativeTypes();
    });
#end
  }

  public static function addDynamicProperties(struct:UIntPtr, name:cpp.ConstCharStar) {
#if (WITH_CPPIA && !NO_DYNAMIC_UCLASS && !UHX_NO_UOBJECT)
    HaxeCodeDispatcher.runVoid( function() {
      trace('Add Dynamic Properties $name');
      var struct:UStruct = cast @:privateAccess unreal.UObject.wrap(struct);
      uhx.runtime.UReflectionGenerator.updateClass(struct, name.toString());
      uhx.runtime.UReflectionGenerator.addFunctions(cast struct, name.toString(), true);
      uhx.runtime.UReflectionGenerator.addProperties(struct, name.toString(), true);
    });
#else
    trace('Warning', 'Trying to add properties for $name but dynamic class support was disabled');
#end
  }

  public static function startLoadingDynamic() {
#if (WITH_CPPIA && !NO_DYNAMIC_UCLASS && !UHX_NO_UOBJECT)
    HaxeCodeDispatcher.runVoid( function() uhx.runtime.UReflectionGenerator.startLoadingDynamic() );
#else
    trace('Warning', 'Trying to start loading Dynamic but dynamic class support was disabled');
#end
  }

  public static function endLoadingDynamic() {
#if (WITH_CPPIA && !NO_DYNAMIC_UCLASS && !UHX_NO_UOBJECT)
    HaxeCodeDispatcher.runVoid( function() uhx.runtime.UReflectionGenerator.endLoadingDynamic() );
#else
    trace('Warning', 'Trying to end loading Dynamic but dynamic class support was disabled');
#end
  }

  public static function createDynamicHelper(self:UIntPtr, name:cpp.ConstCharStar):UIntPtr {
#if (WITH_CPPIA && !UHX_NO_UOBJECT)
    var hxType = Type.resolveClass(name.toString());
    if (hxType == null) {
      trace('Error', 'Could not find type ${name.toString()}');
      return 0;
    }
    var ret = Type.createInstance(hxType, [self]);
    return HaxeCodeDispatcher.runWithValue( function() return HaxeHelpers.dynamicToPointer(ret) );
#else
    trace('Error', 'Trying to create a dynamic helper for ${name.toString()}, but dynamic class support was disabled');
    return 0;
#end
  }

  public static function callHaxeFunction(contextObj:UIntPtr, stack:VariantPtr, result:UIntPtr):Void {
#if (WITH_CPPIA && !NO_DYNAMIC_UCLASS && !UHX_NO_UOBJECT)
    HaxeCodeDispatcher.runVoid( function() ReflectAPI.callHaxeFunction(cast UObject.wrap(contextObj), cast stack, result) );
#else
    trace('Warning', 'Trying to call haxe function but dynamic class support was disabled');
#end
  }

  public static function callHaxeFunctionOther(stack:VariantPtr, result:UIntPtr):Void {
#if (WITH_CPPIA && !NO_DYNAMIC_UCLASS && !UHX_NO_UOBJECT)
    var stack:FFrame = cast stack;
    HaxeCodeDispatcher.runVoid( function() ReflectAPI.callHaxeFunction(stack.Object, stack, result) );
#else
    trace('Warning', 'Trying to call haxe function but dynamic class support was disabled');
#end
  }

  public static function setLifetimeProperties(uclass:UIntPtr, uname:cpp.ConstCharStar, out:VariantPtr) {
#if (WITH_CPPIA && !NO_DYNAMIC_UCLASS && !UHX_NO_UOBJECT)
    HaxeCodeDispatcher.runVoid( function() uhx.runtime.UReflectionGenerator.setLifetimeProperties(cast UObject.wrap(uclass), uname.toString(), cast out) );
#else
    trace('Warning', 'Trying to end loading Dynamic but dynamic class support was disabled');
#end
  }

  public static function instancePreReplication(obj:UIntPtr, changedPropertyTracker:VariantPtr) {
#if (WITH_CPPIA && !NO_DYNAMIC_UCLASS && !UHX_NO_UOBJECT)
    HaxeCodeDispatcher.runVoid( function() uhx.runtime.UReflectionGenerator.instancePreReplication(cast UObject.wrap(obj), cast changedPropertyTracker) );
#else
    trace('Warning', 'Trying to end loading Dynamic but dynamic class support was disabled');
#end
  }

  public static function addHaxeBlueprintOverrides(hxClassName:cpp.ConstCharStar, uclass:UIntPtr):Bool {
#if !UHX_NO_UOBJECT
    uhx.runtime.UReflectionGenerator.addHaxeBlueprintOverrides(hxClassName.toString(), @:privateAccess new unreal.UClass(uclass));
#end
    return true;
  }

  public static function printCallStack():Void {
    unreal.Log.trace(haxe.CallStack.toString(haxe.CallStack.callStack()));
  }

  public static function printExceptionStack():Void {
    unreal.Log.trace(haxe.CallStack.toString(haxe.CallStack.exceptionStack()));
  }
}
