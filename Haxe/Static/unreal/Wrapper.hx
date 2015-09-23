package unreal;
import unreal.helpers.UEPointer;

/**
  This is the base wrapper class for all non-UObject wrappers
 **/
class Wrapper implements ue4hx.internal.NeedsGlue {
  @:unreflective private var wrapped(get,null):cpp.RawPointer<UEPointer>;
  public var destroyed(default,null):Bool;

  private function new(wrapped:cpp.Pointer<UEPointer>) {
    this.wrapped = wrapped.get_raw();
    this.destroyed = false;
    cpp.vm.Gc.setFinalizer(this, cpp.Callable.fromStaticFunction(destroyUEPointer));
  }

  @:extern inline private function get_wrapped():cpp.RawPointer<UEPointer> {
#if UE4_CHECK_POINTER
    if (this.destroyed) {
      var msg = 'Trying to use an already destroyed object (${Type.getClassName(Type.getClass(this))})';
      trace('Error',msg);
      throw msg;
    }
#end
    return this.wrapped;
  }

  /**
    Releases the wrapped pointer. Call this if the object will not be used anymore
    in order to avoid the finalizer call overhead
   **/
  public function destroy() {
    if (this.destroyed) {
      var msg = 'Trying to destroy an already destroyed object (${Type.getClassName(Type.getClass(this))})';
      trace('Error', msg);
      throw msg;
    }
    this.destroyed = true;

    // cancel the finalizer
    cpp.vm.Gc.setFinalizer(this, untyped __cpp__('0'));
    // make sure we'll crash with a null reference if trying to use this object
    this.wrapped = untyped __cpp__('0');
  }

  @:void @:unreflective static function destroyUEPointer(wrapper:Wrapper):Void {
    cpp.Pointer.fromRaw(wrapper.wrapped).destroy();
  }
}
