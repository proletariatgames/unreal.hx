package unreal;
import unreal.helpers.UEPointer;

/**
  This is the base wrapper class for all non-UObject wrappers
 **/
class Wrapper implements ue4hx.internal.NeedsGlue {
  public var disposed(default,null):Bool;
  @:unreflective private var wrapped:cpp.RawPointer<UEPointer>;

  private function new(wrapped:cpp.Pointer<UEPointer>) {
    this.wrapped = wrapped.get_raw();
    this.disposed = false;
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
    this.disposed = true;

    // cancel the finalizer
    cpp.vm.Gc.setFinalizer(this, untyped __cpp__('0'));
    untyped __cpp__('delete {0}',this.wrapped);

    // make sure we'll crash with a null reference if trying to use this object
    this.wrapped = untyped __cpp__('0');
  }

  @:void @:unreflective inline static function disposeUEPointer(wrapper:Wrapper):Void {
    untyped __cpp__('delete {0}',wrapper.wrapped);
  }
}
