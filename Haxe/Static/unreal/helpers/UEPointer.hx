package unreal.helpers;

/**
  This is the base (abstract) class to abstract any ownership model used.
  Shared pointers, weak pointers, pointers that are owned by Unreal and pointers that are
  owned by Hxcpp will all derive from this implementation and add the appropriate destructors when needed
 **/
@:headerClassCode('\n\t\tvirtual ~UEPointer() {}\n};\n\n

class HXCPP_CLASS_ATTRIBUTES UEProxyPointer : public UEPointer {
\tpublic:
\t\tUEPointer *proxy;
\t\tvoid *ptr;
\t\tUEProxyPointer(UEPointer *p) : proxy(p), ptr(p->getPointer()) { }
\t\t~UEProxyPointer() {
\t\t\tdelete proxy;
\t\t}
\t\tvoid *getPointer() { return this->ptr; }
\t\tUEPointer *toSharedPtr() { return rewrap(this->proxy->toSharedPtr()); }
\t\tUEPointer *toSharedRef() { return rewrap(this->proxy->toSharedRef()); }
\t\tUEPointer *toWeakPtr() { return rewrap(this->proxy->toWeakPtr()); }
\t\tvirtual UEProxyPointer *rewrap(UEPointer *inPtr) { return new UEProxyPointer(inPtr); }
')
@:uexpose class UEPointer
{
  public static var NULL_PTR(get,never):cpp.RawPointer<UEPointer>;

  @:extern inline private static function get_NULL_PTR():cpp.RawPointer<UEPointer>
    return untyped __cpp__('((::unreal::helpers::UEPointer *) 0)');

  /**
    Gets the underlying pointer to the referenced element.
    This should always be the pointer to the actual object - not to any wrapper.
    For example, in the case of TSharedPointer<T>, getPointer will return the actual raw T*
   **/
  public function getPointer():cpp.RawPointer<cpp.Void> {
    return untyped __cpp__('0');
  }

  public function toSharedPtr():cpp.RawPointer<UEPointer> {
    return NULL_PTR;
  }

  public function toSharedRef():cpp.RawPointer<UEPointer> {
    return NULL_PTR;
  }

  public function toWeakPtr():cpp.RawPointer<UEPointer> {
    return NULL_PTR;
  }
}
