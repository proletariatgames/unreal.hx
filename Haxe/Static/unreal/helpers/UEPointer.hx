package unreal.helpers;

/**
  This is the base (abstract) class to abstract any ownership model used.
  Shared pointers, weak pointers, pointers that are owned by Unreal and pointers that are
  owned by Hxcpp will all derive from this implementation and add the appropriate destructors when needed
 **/
@:headerClassCode('\n\t\tvirtual ~UEPointer() {}\n')
@:uexpose class UEPointer
{
  public static var NULL_PTR(get,never):cpp.RawPointer<UEPointer>;

  inline private static function get_NULL_PTR():cpp.RawPointer<UEPointer>
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
