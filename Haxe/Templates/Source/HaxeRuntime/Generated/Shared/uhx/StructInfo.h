#pragma once
#include "IntPtr.h"

namespace uhx {

enum EStructFlags {
  UHX_None = 0,
  UHX_Templated = 1,
  UHX_POD = 2,
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
   * Special flags
   **/
  EStructFlags flags;

  /**
   * The total size of the type
   **/
  unreal::UIntPtr size;

  /**
   * Calls the destructor on the target pointer. If the struct is a POD structure, or if it doesn't need
   * a destructor, this might be null
   **/
  IntrinsicFunction destruct;

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
