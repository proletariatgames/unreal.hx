package unreal;
import cpp.Pointer;
import cpp.RawPointer;
import unreal.WrapperFlags;
import unreal.helpers.StructInfo;

class Wrapper {

  public function getPointer():UIntPtr {
    throw 'Not Implemented';
  }

  public function dispose():Void {
  }

  public function toString():String {
    return '[Unknown Wrapper: ${getPointer()}]';
  }
}

/**
  Represents a pure-old-data inline wrapper
 **/
#if UHX_EXTRA_DEBUG
@:headerClassCode('
  inline void *operator new( size_t inSize, Int inExtra ) {
    return hx::Object::operator new( (size_t) inSize + inExtra, false, "unreal.InlinePodWrapper" );
  }

  inline static InlineWrapper create(Int extraSize, unreal::UIntPtr info) {
    InlinePodWrapper_obj *result = new (extraSize) InlinePodWrapper_obj;
    result->init();
    result->m_info = (struct StructInfo *) info;
    return result;
  }
')
#else
@:headerClassCode('
  inline void *operator new( size_t inSize, Int inExtra ) {
    return hx::Object::operator new( (size_t) inSize + inExtra, false, "unreal.InlinePodWrapper" );
  }

  inline static InlineWrapper create(Int extraSize, unreal::UIntPtr info) {
    InlinePodWrapper_obj *result = new (extraSize) InlinePodWrapper_obj;
    result->init();
    return result;
  }
')
#end
class InlinePodWrapper extends Wrapper {
#if UHX_EXTRA_DEBUG
  var m_info:Pointer<StructInfo>;
#end

  @:final @:nonVirtual private function init() {
  }

  override public function getPointer():UIntPtr {
    return untyped __cpp__('(unreal::UIntPtr) (this + 1)');
  }

  @:extern public static function create(extraSize:Int, info:UIntPtr):InlinePodWrapper { return null; }

  override public function toString():String {
#if UHX_EXTRA_DEBUG
    return '[Inline POD Wrapper ($name) @ ${getPointer()}]';
#else
    return '[Unknown POD wrapper: ${getPointer()}]';
#end
  }
}

/**
 **/
@:headerClassCode('
  inline void *operator new( size_t inSize, Int inExtra ) {
    return hx::Object::operator new( (size_t) inSize + inExtra, false, "unreal.InlineWrapper" );
  }

  inline static InlineWrapper create(Int extraSize, unreal::UIntPtr info) {
    InlineWrapper_obj *result = new (extraSize) InlineWrapper_obj;
    result->m_info = (struct StructInfo *) info;
    result->init();
    return result;
  }
')
class InlineWrapper extends Wrapper {
  var m_flags:WrapperFlags;
  var m_info:Pointer<StructInfo>;

  @:final @:nonVirtual private function init() {
    if (m_info.ptr.destruct != untyped __cpp__('0')) {
      m_flags = NeedsDestructor;
      cpp.vm.Gc.setFinalizer(this, cpp.Callable.fromStaticFunction( finalize ));
    }
  }

  private static function finalize(self:InlineWrapper) {
    if (self.m_flags.hasAny(NeedsDestructor)) {
      var fn = (cast self.m_info.ptr.destruct : cpp.Function<UIntPtr->Void, cpp.abi.Abi>);
      fn.call( untyped __cpp__('(unreal::UIntPtr) (self.mPtr + 1)') );
      self.m_flags = Disposed;
    }
  }

  override public function getPointer():UIntPtr {
    return untyped __cpp__('(unreal::UIntPtr) (this + 1)');
  }

  override public function dispose():Void {
    if (m_flags & (Disposed | NeedsDestructor) == NeedsDestructor) {
      var fn = (cast this.m_info.ptr.destruct : cpp.Function<UIntPtr->Void, cpp.abi.Abi>);
      fn.call( untyped __cpp__('(unreal::UIntPtr) (this + 1)') );
      cpp.vm.Gc.setFinalizer(this, untyped __cpp__('0'));
      m_flags = (m_flags & ~NeedsDestructor) | Disposed;
    } else if (m_flags.hasAny(Disposed)) {
      throw 'Cannot dispose $this: It was already disposed';
    }
  }

  @:extern public static function create(extraSize:Int, info:UIntPtr):InlineWrapper { return null; }

  override public function toString():String {
    var name = m_info.ptr.name.toString();
    return '[Inline Wrapper ($name) @ ${getPointer()}]';
  }
}

class TemplateWrapper extends Wrapper {
  public var info(default, null):Pointer<StructInfo>;
}

class PointerTemplateWrapper extends TemplateWrapper {
  var m_pointer:UIntPtr;

  public function new(info, ptr) {
    this.info = info;
    m_pointer = ptr;
  }

  override public function getPointer():UIntPtr {
    return m_pointer;
  }
}

class InlineTemplateWrapper extends TemplateWrapper {
  var m_flags:WrapperFlags;

  @:final @:nonVirtual private function init() {
    if (info.ptr.destruct != untyped __cpp__('0')) {
      m_flags = NeedsDestructor;
      cpp.vm.Gc.setFinalizer(this, cpp.Callable.fromStaticFunction( finalize ));
    }
  }

  private static function finalize(self:InlineTemplateWrapper) {
    if (self.m_flags.hasAny(NeedsDestructor)) {
      var fn = (cast self.info.ptr.destruct : cpp.Function<UIntPtr->Void, cpp.abi.Abi>);
      fn.call( untyped __cpp__('(unreal::UIntPtr) (self.mPtr + 1)') );
      self.m_flags = Disposed;
    }
  }

  override public function getPointer():UIntPtr {
    return untyped __cpp__('(unreal::UIntPtr) (this + 1)');
  }

  override public function dispose():Void {
    if (m_flags & (Disposed | NeedsDestructor) == NeedsDestructor) {
      var fn = (cast this.info.ptr.destruct : cpp.Function<UIntPtr->Void, cpp.abi.Abi>);
      fn.call( untyped __cpp__('(unreal::UIntPtr) (this + 1)') );
      cpp.vm.Gc.setFinalizer(this, untyped __cpp__('0'));
      m_flags = (m_flags & ~NeedsDestructor) | Disposed;
    } else if (m_flags.hasAny(Disposed)) {
      throw 'Cannot dispose $this: It was already disposed';
    }
  }

  @:extern public static function create(extraSize:Int, info:UIntPtr):InlineTemplateWrapper { return null; }

  override public function toString():String {
    var name = info.ptr.name.toString();
    return '[Inline Wrapper ($name) @ ${getPointer()}]';
  }
}
