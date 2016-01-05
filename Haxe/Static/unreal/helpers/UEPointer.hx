package unreal.helpers;

/**
  This is the base (abstract) class to abstract any ownership model used.
  Shared pointers, weak pointers, pointers that are owned by Unreal and pointers that are
  owned by Hxcpp will all derive from this implementation and add the appropriate destructors when needed
 **/
@:include("UEPointer.h") extern class UEPointer
{
  /**
    Gets the underlying pointer to the referenced element.
    This should always be the pointer to the actual object - not to any wrapper.
    For example, in the case of TSharedPointer<T>, getPointer will return the actual raw T*
   **/
  public function getPointer():cpp.RawPointer<cpp.Void>;
  public function toSharedPtr():cpp.RawPointer<UEPointer>;
  public function toSharedPtrTS():cpp.RawPointer<UEPointer>;
  public function toSharedRef():cpp.RawPointer<UEPointer>;
  public function toSharedRefTS():cpp.RawPointer<UEPointer>;
  public function toWeakPtr():cpp.RawPointer<UEPointer>;
  public function toWeakPtrTS():cpp.RawPointer<UEPointer>;
}
