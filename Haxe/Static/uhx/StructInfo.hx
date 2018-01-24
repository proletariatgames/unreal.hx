package uhx;
import cpp.ConstCharStar;
import unreal.*;

/**
  This is the base (abstract) class to abstract any ownership model used.
  Shared pointers, weak pointers, pointers that are owned by Unreal and pointers that are
  owned by Hxcpp will all derive from this implementation and add the appropriate destructors when needed
 **/
@:include("uhx/StructInfo.h") @:native("uhx.StructInfo") extern class StructInfo
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
    The aligment of the type
   **/
  public var alignment:UIntPtr;

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
   * Calls the operator equals for the target pointer type
   **/
  public var equals:VoidPtr;

  /**
   * If the type is templated, will point to a null-terminated array where each element represents a StructInfo of its implementation
   **/
  public var genericParams:cpp.RawPointer<cpp.RawConstPointer<StructInfo>>;

  /**
   * If the type is templated, this will contain a pointer to a type that decodes the templated implementations through a series of virtual functions
   **/
  public var genericImplementation:VoidPtr;

  /**
   * If this StructInfo was created by a UProperty, the original UProperty pointer can be found here
   **/
  public var contextObject:VoidPtr;
}
