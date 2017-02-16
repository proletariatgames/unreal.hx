package unreal;
import cpp.Pointer;
import cpp.RawPointer;
import unreal.WrapperFlags;
import unreal.helpers.StructInfo;

@:keep class Wrapper {

  public function getPointer():UIntPtr {
    throw 'Not Implemented';
  }

  public function dispose():Void {
  }

  public function isDisposed():Bool {
    return false; // for types that don't need disposing, this will return false even if `dispose` was indeed called
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
  inline static hx::ObjectPtr< InlinePodWrapper_obj > create(int extraSize, unreal::UIntPtr info) {
    int size = (int) ((extraSize + sizeof(void*) - 1) & ~(sizeof(void*) - 1));
    InlinePodWrapper_obj *result = new (size) InlinePodWrapper_obj;
    result->init();
    result->m_info = cpp::Pointer_obj::fromPointer( (uhx::StructInfo *) info );
    return result;
  }
')
#else
@:headerClassCode('
  inline static hx::ObjectPtr< InlinePodWrapper_obj > create(int extraSize, unreal::UIntPtr info) {
    int size = (int) ((extraSize + sizeof(void*) - 1) & ~(sizeof(void*) - 1));
    InlinePodWrapper_obj *result = new (size) InlinePodWrapper_obj;
    result->init();
    return result;
  }
')
#end
@:keep class InlinePodWrapper extends Wrapper {
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

  public static function getOffset():UIntPtr {
    return untyped __cpp__('(unreal::UIntPtr) (sizeof(unreal::InlinePodWrapper_obj))');
  }
}

/**
 **/
@:headerClassCode('
  inline static hx::ObjectPtr< InlineWrapper_obj > create(int extraSize, unreal::UIntPtr info) {
    int size =  (int) ((extraSize + sizeof(void *) - 1) & ~(sizeof(void*) - 1));
    InlineWrapper_obj *result = new (size) InlineWrapper_obj;
    result->m_info = cpp::Pointer_obj::fromPointer( (uhx::StructInfo *) info );
    result->init();
    return result;
  }
')
@:keep class InlineWrapper extends Wrapper {
  var m_flags:WrapperFlags;
  var m_info:Pointer<StructInfo>;

  @:final @:nonVirtual private function init() {
    if (m_info.ptr.destruct != untyped __cpp__('0')) {
      m_flags = NeedsDestructor;
      cpp.vm.Gc.setFinalizer(this, cpp.Callable.fromStaticFunction( finalize ));
    }
  }

  @:analyzer(no_fusion)
  private static function finalize(self:InlineWrapper) {
    if (self.m_flags.hasAny(NeedsDestructor)) {
      var fn = (cast self.m_info.ptr.destruct : cpp.Function<UIntPtr->Void, cpp.abi.Abi>);
      fn.call(self.getPointer());
      self.m_flags = Disposed;
    }
  }

  override public function getPointer():UIntPtr {
    return untyped __cpp__('(unreal::UIntPtr) (this + 1)');
  }

  override public function isDisposed() {
    return m_flags.hasAny(Disposed);
  }

  override public function dispose():Void {
    if (m_flags & (Disposed | NeedsDestructor) == NeedsDestructor) {
      cpp.vm.Gc.setFinalizer(this, untyped __cpp__('0'));
      var fn = (cast this.m_info.ptr.destruct : cpp.Function<UIntPtr->Void, cpp.abi.Abi>);
      fn.call(this.getPointer());
      m_flags = (m_flags & ~NeedsDestructor) | Disposed;
    } else if (m_flags.hasAny(Disposed)) {
      throw 'Cannot dispose $this: It was already disposed';
    } else {
      m_flags |= Disposed;
    }
  }

  @:extern public static function create(extraSize:Int, info:UIntPtr):InlineWrapper { return null; }

  override public function toString():String {
    var name = m_info.ptr.name.toString();
    return '[Inline Wrapper ($name) @ ${getPointer()}]';
  }

  public static function getOffset():UIntPtr {
    return untyped __cpp__('(unreal::UIntPtr) (sizeof(unreal::InlineWrapper_obj))');
  }
}

/**
  Represents a special aligned wrapper
 **/
@:headerClassCode('
  inline static hx::ObjectPtr< AlignedInlineWrapper_obj > create(int extraSize, unreal::UIntPtr rawInfo) {
    uhx::StructInfo *info = (uhx::StructInfo *) rawInfo;
    // make sure extraSize is big enough to hold the alignment
    unreal::UIntPtr align = info->alignment;
    unreal::UIntPtr dif = align - 2; // the pointer is at least aligned in the power of two
    // align the final result to (void*) - should be already, but why not
    extraSize = (extraSize + dif + ( sizeof(void*) - 1 )) & ~( sizeof(void*) - 1 );
    AlignedInlineWrapper_obj *result = new ((int) extraSize) AlignedInlineWrapper_obj;
    result->m_info = cpp::Pointer_obj::fromPointer( info );
    result->init();
    return result;
  }
')
@:keep class AlignedInlineWrapper extends InlineWrapper {
  @:extern public static function create(extraSize:Int, info:UIntPtr):InlineWrapper { return null; }

  override public function getPointer():UIntPtr {
    var align = m_info.ptr.alignment - 1;
    return untyped __cpp__(' ( (((unreal::UIntPtr) (this + 1)) + {0}) & ~((unreal::UIntPtr) {0}))', align);
  }
}

@:keep class TemplateWrapper extends Wrapper {
  public var info(default, null):Pointer<StructInfo>;
  public var pointer(default, null):UIntPtr;

  inline override public function getPointer():UIntPtr {
    return pointer;
  }

  override public function toString():String {
    var name = info.ptr.name.toString();
    return '[Template Wrapper ($name) @ ${getPointer()}]';
  }

  public static function getOffset():UIntPtr {
    return untyped __cpp__('(unreal::UIntPtr) offsetof(unreal::TemplateWrapper_obj, pointer)');
  }
}

@:keep class PointerTemplateWrapper extends TemplateWrapper {
  public function new(ptr, info:UIntPtr) {
    this.pointer = ptr;
    this.info =  untyped __cpp__('(uhx::StructInfo *) {0}', info);
  }
}

@:headerClassCode('
  inline static hx::ObjectPtr< InlineTemplateWrapper_obj > create(int extraSize, unreal::UIntPtr rawInfo) {
    uhx::StructInfo *info = (uhx::StructInfo *) rawInfo;
    unreal::UIntPtr align = info->alignment;
    // make sure extraSize is big enough to hold the alignment
    unreal::UIntPtr dif = align - 2; // the pointer is at least aligned in the power of two
    // align the final result to (void*) - should be already, but why not
    extraSize = (extraSize + dif + ( sizeof(void*) - 1 )) & ~( sizeof(void*) - 1 );
    InlineTemplateWrapper_obj *result = new ((int) extraSize) InlineTemplateWrapper_obj;
    result->info = cpp::Pointer_obj::fromPointer( (uhx::StructInfo *) info );
    result->pointer = ( ((unreal::UIntPtr) (result + 1)) + align - 1 ) & ~(align -1);
    result->init();
    return result;
  }
')
@:keep class InlineTemplateWrapper extends TemplateWrapper {
  var m_flags:WrapperFlags;

  @:final @:nonVirtual private function init() {
    if (info.ptr.destruct != untyped __cpp__('0')) {
      m_flags = NeedsDestructor;
      cpp.vm.Gc.setFinalizer(this, cpp.Callable.fromStaticFunction( finalize ));
    }
  }

  @:analyzer(no_fusion)
  private static function finalize(self:InlineTemplateWrapper) {
    if (self.m_flags.hasAny(NeedsDestructor)) {
      var fn = (cast self.info.ptr.destruct : cpp.Function<UIntPtr->Void, cpp.abi.Abi>);
      fn.call(self.pointer);
      self.m_flags = Disposed;
    }
  }

  override public function isDisposed() {
    return m_flags.hasAny(Disposed);
  }

  override public function dispose():Void {
    if (m_flags & (Disposed | NeedsDestructor) == NeedsDestructor) {
      cpp.vm.Gc.setFinalizer(this, untyped __cpp__('0'));
      var fn = (cast this.info.ptr.destruct : cpp.Function<UIntPtr->Void, cpp.abi.Abi>);
      fn.call(this.pointer);
      m_flags = (m_flags & ~NeedsDestructor) | Disposed;
    } else if (m_flags.hasAny(Disposed)) {
      throw 'Cannot dispose $this: It was already disposed';
    } else {
      m_flags |= Disposed;
    }
  }

  @:extern public static function create(extraSize:Int, info:UIntPtr):InlineTemplateWrapper { return null; }
}
