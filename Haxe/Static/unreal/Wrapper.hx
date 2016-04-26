package unreal;

class Wrapper {
  public var flags:WrapperFlags;

  public function getPointer():UIntPtr {
    throw 'Not Implemented';
  }

  public function dispose():Void {
  }
}

@:headerClassCode('
  inline void *operator new( size_t inSize, Int inExtra ) {
    return hx::Object::operator new( (size_t) inSize + inExtra, false, "unreal.InlinePODWrapper" );
  }

  inline static InlinePODWrapper create(Int extraSize) {
    InlinePODWrapper_obj *result = new (extraSize) InlinePODWrapper_obj;
    result->init();
    return result;
  }
')
class InlinePODWrapper extends Wrapper {
  @:final @:nonVirtual private function init() {
    var offset:UIntPtr = untyped __cpp__(' ( (unreal::UIntPtr) (this + 1) ) - ( (unreal::UIntPtr) this ) ');
    this.flags = WrapperFlags.fromOffset( offset );
  }

  override public function getPointer():UIntPtr {
    return untyped __cpp__('(unreal::UIntPtr) (this + 1)');
  }

  @:extern public static function create(extraSize:Int):InlinePODWrapper { return null; }
}

@:headerClassCode('
  inline void *operator new( size_t inSize, Int inExtra ) {
    return hx::Object::operator new( (size_t) inSize + inExtra, false, "unreal.InlinePODWrapper" );
  }

  inline static InlinePODWrapper create(Int extraSize) {
    InlinePODWrapper_obj *result = new (extraSize) InlinePODWrapper_obj;
    result->init();
    return result;
  }
')
class InlineWrapper extends Wrapper {
  @:final @:nonVirtual private function init() {
    var offset:UIntPtr = untyped __cpp__(' ( (unreal::UIntPtr) (this + 1) ) - ( (unreal::UIntPtr) this ) ');
    this.flags = WrapperFlags.fromOffset( offset ) | NeedsFinalizer;
  }

  override public function getPointer():UIntPtr {
    return untyped __cpp__('(unreal::UIntPtr) (this + 1)');
  }

  @:extern public static function create(extraSize:Int):InlinePODWrapper { return null; }
}
