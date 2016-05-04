package unreal.helpers;
import cpp.ConstCharStar;

/**
  This is the base (abstract) class to abstract any ownership model used.
  Shared pointers, weak pointers, pointers that are owned by Unreal and pointers that are
  owned by Hxcpp will all derive from this implementation and add the appropriate destructors when needed
 **/
@:include("StructInfo.h") @:native("uhx.StructInfo") extern class StructInfo
{
  /**
   * The name of the struct owned by the info
   **/
  public var name:ConstCharStar;

  /**
   * If it's a special pointer type (e.g. TSharedPtr, TSharedRef, etc),
   * tells the name of that pointer kind. Otherwise, will be null
   **/
  public var pointerKind:ConstCharStar;

  /**
   * Special flags
   **/
  public var flags:EStructFlags;

  /**
   * The total size of the type
   **/
  public var size:UIntPtr;

  /**
   * Calls placement new on the target pointer. If the struct is a POD structure, or if it doesn't need
   * a constructor, this might be null
   **/
  public var initialize:VoidPtr;

  /**
   * Calls the destructor on the target pointer. If the struct is a POD structure, or if it doesn't need
   * a destructor, this might be null
   **/
  public var destruct:VoidPtr;

  /**
   * Deletes target pointer. It's different from `destruct` as it only works with pointers that were created with `new`,
   * and it frees the underlying pointer as well. Same as `delete ptr`
   **/
  public var del:VoidPtr;

  /**
   * If the type is templated, will point to a null-terminated array where each element represents a StructInfo of its implementation
   **/
  public var genericImplementations:VoidPtr;

  /**
   * If the type is templated, this will contain a null-terminated specialized function array
   **/
  public var memberTable:cpp.RawPointer<VoidPtr>;
}
