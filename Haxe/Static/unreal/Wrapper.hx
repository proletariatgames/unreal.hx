package unreal;
import cpp.Pointer;
import unreal.helpers.StructInfo;

class Wrapper {
  public var flags:WrapperFlags;

  public function getPointer():UIntPtr {
    throw 'Not Implemented';
  }

  public function dispose():Void {
  }
}

/**
  Represents a pure-old-data inline wrapper
 **/
@:headerClassCode('
  inline void *operator new( size_t inSize, Int inExtra ) {
    return hx::Object::operator new( (size_t) inSize + inExtra, false, "unreal.InlinePodWrapper" );
  }

  inline static InlinePodWrapper create(Int extraSize) {
    InlinePodWrapper_obj *result = new (extraSize) InlinePodWrapper_obj;
    result->init();
    return result;
  }
')
class InlinePodWrapper extends Wrapper {
#if UHX_EXTRA_DEBUG
  var m_info:Pointer<StructInfo>;
#end

  @:final @:nonVirtual private function init() {
    var offset:UIntPtr = untyped __cpp__('sizeof (*this)');
    this.flags = WrapperFlags.fromOffset( offset );
  }

  override public function getPointer():UIntPtr {
    return untyped __cpp__('(unreal::UIntPtr) (this + 1)');
  }

  @:extern public static function create(extraSize:Int):InlinePodWrapper { return null; }
}

/**
 **/
@:headerClassCode('
  inline void *operator new( size_t inSize, Int inExtra ) {
    return hx::Object::operator new( (size_t) inSize + inExtra, false, "unreal.InlineWrapper" );
  }

  inline static InlineWrapper create(Int extraSize) {
    InlineWrapper_obj *result = new (extraSize) InlineWrapper_obj;
    result->init();
    return result;
  }
')
class InlineWrapper extends Wrapper {
  var m_info:Pointer<StructInfo>;

  @:final @:nonVirtual private function init() {
    var offset:UIntPtr = untyped __cpp__('sizeof (*this)');
    this.flags = WrapperFlags.fromOffset( offset ) | NeedsFinalizer;
  }

#if !cppia
  inline
#end
  override public function getPointer():UIntPtr {
    return untyped __cpp__('(unreal::UIntPtr) (this + 1)');
  }

  override public function dispose():Void {
    if (m_finalizer != null) {
      m_finalizer.call(getPointer());
    }
  }

  @:extern public static function create(extraSize:Int):InlineWrapper { return null; }

  public function toString() {
    var name = m_info.ptr.name.toString();
    return 'Inline Wrapper ($name) @ ${getPointer()}';
  }
}

/**
 **/
class PointerWrapper extends Wrapper {
  // var m_info:Pointer<StructInfo>;

  public function new(ptr) {
    // this.uePointer = ptr;
  }

#if !cppia
  inline
#end
  override public function getPointer():UIntPtr {
    // return uePointer.ptr.getPointer();
  }

  override public function dispose():Void {
    // if (m_finalizer != null) {
    //   m_finalizer.call(getPointer());
    // }
  }
}

/**
  With this wrapper, we can keep a live reference to a shared pointer,
  while still being able to access their underlying pointer directly
 **/
class SharedPointerWrapper extends Wrapper {
  var m_sharedWrapper:Wrapper;
}
