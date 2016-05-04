#pragma once
#include "IntPtr.h"

namespace uhx {

enum EStructFlags {
  UHXS_Templated = 1,
  UHXS_POD = 2,
  UHXS_SharedPointer = 4,
};

typedef void (*IntrinsicFunction)(unreal::UIntPtr);
typedef void (*AnyFunction)();

/**
 * A small data type that contains information of each non-uobject type that is known to Haxe
 * Because it is so simple, this information can be seen by both hxcpp and Unreal
 **/
struct StructInfo {
  /**
   * The name of the struct owned by the info
   **/
  const char *name;

  /**
   * If it's a special pointer type (e.g. TSharedPtr, TSharedRef, etc),
   * tells the name of that pointer kind. Otherwise, will be null
   **/
  const char *pointerKind;

  /**
   * Special flags
   **/
  EStructFlags flags;

  /**
   * The total size of the type
   **/
  unreal::UIntPtr size;

  /**
   * Calls placement new on the target pointer. If the struct is a POD structure, or if it doesn't need
   * a constructor, this might be null
   **/
  IntrinsicFunction initialize;

  /**
   * Calls the destructor on the target pointer. If the struct is a POD structure, or if it doesn't need
   * a destructor, this might be null
   **/
  IntrinsicFunction destruct;

  /**
   * Deletes target pointer. It's different from `destruct` as it only works with pointers that were created with `new`,
   * and it frees the underlying pointer as well. Same as `delete ptr`
   **/
  IntrinsicFunction del;

  // TODO: copy (see Class.h@CopyOrNot)

  /**
   * If the type is templated, will point to a null-terminated array where each element represents a StructInfo of its implementation
   **/
  const StructInfo *genericParams;

  /**
   * If the type is templated, this will contain a pointer to a type that decodes the templated implementations through a series of virtual functions
   **/
  void *genericImplementation;
};

// template<typename T>

}
