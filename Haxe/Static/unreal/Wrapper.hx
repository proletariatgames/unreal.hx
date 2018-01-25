package unreal;
import cpp.Pointer;
import cpp.RawPointer;
import unreal.WrapperFlags;
import uhx.StructInfo;

@:keep class Wrapper {

  public function getPointer():UIntPtr {
    throw 'Not Implemented';
  }

  public function dispose():Void {
  }

  public function isDisposed():Bool {
    return false; // for types that don't need disposing, this will return false even if `dispose` was indeed called
  }

  public function setInfo(info:UIntPtr):Void {
    // do nothing
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
    int size = (int) ((extraSize + 4 - 1) & ~(4 - 1));
    size += sizeof(void*);
    InlinePodWrapper_obj *result = new (size) InlinePodWrapper_obj;
    result->init();
    result->setSize(size);
    result->m_info = cpp::Pointer_obj::fromPointer( (uhx::StructInfo *) info );
    return result;
  }
')
#else
@:headerClassCode('
  inline static hx::ObjectPtr< InlinePodWrapper_obj > create(int extraSize, unreal::UIntPtr info) {
    int size = (int) ((extraSize + 4 - 1) & ~(4 - 1));
    size += sizeof(void*);
    InlinePodWrapper_obj *result = new (size) InlinePodWrapper_obj;
    result->init();
    result->setSize(size);
    return result;
  }
')
#end
@:keep class InlinePodWrapper extends Wrapper {
#if UHX_EXTRA_DEBUG
  var m_info:Pointer<StructInfo>;
#end
#if wrapper_debug
  var m_size:Int;
#end

  @:final @:nonVirtual private function init() {
  }

  @:final @:nonVirtual private function setSize(i:Int) {
#if wrapper_debug
    m_size = i;
#end
  }

  override public function getPointer():UIntPtr {
    return untyped __cpp__('(((unreal::UIntPtr) (this + 1)) + sizeof(void*) -1) & ~(sizeof(void*)-1)');
  }

  @:extern public static function create(extraSize:Int, info:UIntPtr):InlinePodWrapper { return null; }

  override public function toString():String {
#if UHX_EXTRA_DEBUG
    return '[Inline POD Wrapper ($name) @ ${getPointer()}]';
#else
    return '[Unknown POD wrapper: ${getPointer()}]';
#end
  }

#if UHX_EXTRA_DEBUG
  override public function setInfo(info:UIntPtr):Void {
    m_info = cpp.Pointer.fromPointer(untyped __cpp__('(uhx::StructInfo *) {0}', info));
  }
#end

  public static function getOffset():UIntPtr {
    return untyped __cpp__('(unreal::UIntPtr) (sizeof(unreal::InlinePodWrapper_obj))');
  }
}

/**
 **/
@:headerClassCode('
  inline static hx::ObjectPtr< InlineWrapper_obj > create(int extraSize, unreal::UIntPtr info) {
    int size = (int) ((extraSize + 4 - 1) & ~(4 - 1));
    size += sizeof(void*);
    InlineWrapper_obj *result = new (size) InlineWrapper_obj;
    result->m_info = cpp::Pointer_obj::fromPointer( (uhx::StructInfo *) info );
    result->setSize(size);
    result->init();
    return result;
  }
')
@:keep class InlineWrapper extends Wrapper {
  var m_flags:WrapperFlags;
  var m_info:Pointer<StructInfo>;
#if wrapper_debug
  var m_size:Int;
#end

  @:final @:nonVirtual private function setSize(i:Int) {
#if wrapper_debug
    m_size = i;
#end
  }

  @:final @:nonVirtual private function init() {
    var needsDestructor:Bool = untyped __cpp__("{0}->ptr->destruct != 0", m_info);
//     if (!needsDestructor && untyped __cpp__("{0}->ptr->upropertyObject != 0", m_info)) {
// #if !UHX_NO_UOBJECT
//       var flags:EPropertyFlags = uhx.glues.UProperty_Glue.get_PropertyFlags(untyped __cpp__("(unreal::UIntPtr) {0}->ptr->upropertyObject", m_info));
//       if (!flags.hasAny(EPropertyFlags.CPF_NoDestructor)) {
//         needsDestructor = true;
//       }
// #else
//       trace('Fatal', 'UProperty InlineWrapper is not supported on programs');
// #end
//     }
    if (needsDestructor) {
      m_flags = NeedsDestructor;
#if !cppia
      cpp.vm.Gc.setFinalizer(this, cpp.Callable.fromStaticFunction( finalize ));
#end
    }
  }

  @:analyzer(no_fusion)
  private static function finalize(self:InlineWrapper) {
    if (self.m_flags.hasAny(NeedsDestructor)) {
      if (untyped __cpp__("{0}->ptr->destruct != 0", self.m_info)) {
        var fn = (cast self.m_info.ptr.destruct : cpp.Function<cpp.RawConstPointer<StructInfo>->UIntPtr->Void, cpp.abi.Abi>);
        fn.call(self.m_info.raw, self.getPointer());
//       } else if (untyped __cpp__('{0}->ptr->upropertyObject != 0', self.m_info)) {
// #if !UHX_NO_UOBJECT
//         uhx.glues.UProperty_Glue.DestroyValue(untyped __cpp__('(unreal::UIntPtr) {0}->ptr->upropertyObject', self.m_info), self.getPointer());
// #else
//       trace('Fatal', 'UProperty InlineWrapper is not supported on programs');
// #end
      }
      self.m_flags = Disposed;
    }
  }

  override public function getPointer():UIntPtr {
    return untyped __cpp__('(((unreal::UIntPtr) (this + 1)) + sizeof(void*) -1) & ~(sizeof(void*)-1)');
  }

  override public function setInfo(info:UIntPtr):Void {
    m_info = cpp.Pointer.fromPointer(untyped __cpp__('(uhx::StructInfo *) {0}', info));
  }

  override public function isDisposed() {
    return m_flags.hasAny(Disposed);
  }

  override public function dispose():Void {
    if (m_flags & (Disposed | NeedsDestructor) == NeedsDestructor) {
#if !cppia
      cpp.vm.Gc.setFinalizer(this, untyped __cpp__('0'));
#end
      finalize(this);
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

  public static function getSize():UIntPtr {
    return untyped __cpp__('(unreal::UIntPtr) (sizeof(unreal::AlignedInlineWrapper_obj))');
  }
}

@:keep class TemplateWrapper extends Wrapper {
  public var info(default, null):Pointer<StructInfo>;
  public var pointer(default, null):UIntPtr;
#if wrapper_debug
  var m_size:Int;
#end

  @:final @:nonVirtual private function setSize(i:Int) {
#if wrapper_debug
    m_size = i;
#end
  }

  inline override public function getPointer():UIntPtr {
    return pointer;
  }

  override public function toString():String {
    var name = info.ptr.name.toString();
    return '[Template Wrapper ($name) @ ${getPointer()}]';
  }

  override public function setInfo(info:UIntPtr):Void {
    this.info = cpp.Pointer.fromPointer(untyped __cpp__('(uhx::StructInfo *) {0}', info));
  }

  public static function getOffset():UIntPtr {
    return untyped __cpp__('(unreal::UIntPtr) offsetof(unreal::TemplateWrapper_obj, pointer)');
  }

  public static function getSize():UIntPtr {
    return untyped __cpp__('(unreal::UIntPtr) (sizeof(unreal::TemplateWrapper_obj))');
  }
}

@:headerClassCode('
  inline static hx::ObjectPtr< PointerTemplateWrapper_obj > create(unreal::UIntPtr ptr, unreal::UIntPtr info, int extraSize) {
    int size = (int) ((extraSize + sizeof(void*) - 1) & ~(sizeof(void*) - 1));
    PointerTemplateWrapper_obj *result = new (size) PointerTemplateWrapper_obj;
    result->init();
    result->setSize(size);
    result->pointer = ptr;
    result->info = cpp::Pointer_obj::fromPointer( (uhx::StructInfo *) info );
    return result;
  }
')
@:keep class PointerTemplateWrapper extends TemplateWrapper {

  @:extern public static function create(ptr:UIntPtr, info:UIntPtr, extraSize:Int):PointerTemplateWrapper { return null; }
  // public function new(ptr, info:UIntPtr) {
  //   this.pointer = ptr;
  //   this.info =  untyped __cpp__('(uhx::StructInfo *) {0}', info);
  // }

  @:final @:nonVirtual private function init() {
  }

  public static function getSize():UIntPtr {
    return untyped __cpp__('(unreal::UIntPtr) (sizeof(unreal::PointerTemplateWrapper_obj))');
  }
}

@:headerClassCode('
  inline static hx::ObjectPtr< InlineTemplateWrapper_obj > create(int extraSize, unreal::UIntPtr rawInfo) {
    uhx::StructInfo *info = (uhx::StructInfo *) rawInfo;
    unreal::UIntPtr align = info->alignment;
    // make sure extraSize is big enough to hold the alignment
    // align the final result to (void*) - should be already, but why not
    extraSize += align;
    extraSize = (extraSize + ( sizeof(void*) - 1 )) & ~( sizeof(void*) - 1 );
    InlineTemplateWrapper_obj *result = new ((int) extraSize) InlineTemplateWrapper_obj;
    result->info = cpp::Pointer_obj::fromPointer( (uhx::StructInfo *) info );
    result->pointer = ( ((unreal::UIntPtr) (result + 1)) + align - 1 ) & ~(align -1);
    result->init();
    result->setSize(extraSize);
    return result;
  }
')
@:keep class InlineTemplateWrapper extends TemplateWrapper {
  var m_flags:WrapperFlags;

  @:final @:nonVirtual private function init() {
    if (untyped __cpp__("{0}->ptr->destruct != 0", info) || info.ptr.flags == UHXS_CUSTOM) {
      m_flags = NeedsDestructor;
#if !cppia
      cpp.vm.Gc.setFinalizer(this, cpp.Callable.fromStaticFunction( finalize ));
#end
    }
  }

  @:analyzer(no_fusion)
  private static function finalize(self:InlineTemplateWrapper) {
    if (self.m_flags.hasAny(NeedsDestructor)) {
      var fn = (cast self.info.ptr.destruct : cpp.Function<cpp.RawConstPointer<StructInfo>->UIntPtr->Void, cpp.abi.Abi>);
      fn.call(self.info.raw, self.pointer);
      self.m_flags = Disposed;
    }
  }

  override public function isDisposed() {
    return m_flags.hasAny(Disposed);
  }

  override public function dispose():Void {
    if (m_flags & (Disposed | NeedsDestructor) == NeedsDestructor) {
#if !cppia
      cpp.vm.Gc.setFinalizer(this, untyped __cpp__('0'));
#end
      var fn = (cast this.info.ptr.destruct : cpp.Function<cpp.RawConstPointer<StructInfo>->UIntPtr->Void, cpp.abi.Abi>);
      fn.call(this.info.raw, this.pointer);
      m_flags = (m_flags & ~NeedsDestructor) | Disposed;
    } else if (m_flags.hasAny(Disposed)) {
      throw 'Cannot dispose $this: It was already disposed';
    } else {
      m_flags |= Disposed;
    }
  }

  @:extern public static function create(extraSize:Int, info:UIntPtr):InlineTemplateWrapper { return null; }
}
