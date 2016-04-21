package unreal;
import unreal.helpers.UEPointer;
import unreal.helpers.ClassMap;

/**
  This is the base wrapper class for all non-UObject wrappers
 **/
class Wrapper implements ue4hx.internal.NeedsGlue {
  public var disposed(default,null):Bool;
  private var wrapped:cpp.Pointer<UEPointer>;
  private var parent:Dynamic;

  private function new(wrapped:cpp.Pointer<UEPointer>, typeID:Int=0, ?parent:Dynamic) {
    this.wrapped = wrapped;
    this.parent = parent;
    setFinalizer(typeID);
  }

  private function setFinalizer(typeID:Int) {
    if (this.parent == null && typeID != 0) {
      ClassMap.registerWrapper(this.wrapped.ptr.getPointer(), unreal.helpers.HaxeHelpers.dynamicToPointer(this), typeID);
    }
    cpp.vm.Gc.setFinalizer(this, cpp.Callable.fromStaticFunction(disposeUEPointer));
  }

  public function checkPointer() {
    if (this.disposed) {
      var msg = 'Trying to use an already disposed object (${Type.getClassName(Type.getClass(this))})';
#if !UE4_POINTER_TESTING
      trace('Error',msg);
#end
      throw msg;
    }
  }

  @:extern inline private function getWrapped():cpp.Pointer<UEPointer> {
    return this == null ? null : this.wrapped;
  }

  public function rewrap(wrapped:cpp.Pointer<UEPointer>):Wrapper {
    return new Wrapper(wrapped);
  }

  inline public static function copy<T:Wrapper>(obj:T):PHaxeCreated<T> {
    return cast obj._copy();
  }

  inline public static function copyStruct<T:Wrapper>(obj:T):PHaxeCreated<T> {
    return cast obj._copyStruct();
  }

  private function _equals(other:Wrapper) : Bool {
    throw ('The type ${Type.getClassName(Type.getClass(this))} does not support equals');
  }

  private function _copy():Wrapper {
    throw 'The type ${Type.getClassName(Type.getClass(this))} does not support copy constructors';
  }

  private function _copyStruct():Wrapper {
    throw 'The type ${Type.getClassName(Type.getClass(this))} does not support copy constructors';
  }

  /**
    Releases the wrapped pointer. Call this if the object will not be used anymore
    in order to avoid the finalizer call overhead
   **/
  public function dispose() {
    if (this.disposed) {
      var msg = 'Trying to dispose an already disposed object (${Type.getClassName(Type.getClass(this))})';
#if !UE4_POINTER_TESTING
      trace('Error',msg);
#end
      throw msg;
    }

    // cancel the finalizer
    cpp.vm.Gc.setFinalizer(this, untyped __cpp__('0'));
    disposeUEPointer(this);
    this.disposed = true;
    this.wrapped = null;
  }

  @:void @:unreflective static function disposeUEPointer(wrapper:Wrapper):Void {
    if (!wrapper.disposed) {
      if (wrapper.parent == null) {
        ClassMap.unregisterWrapper(wrapper.wrapped.ptr.getPointer());
      }
      wrapper.wrapped.destroy();
    }
  }
}
