#pragma once
#include "IntPtr.h"

namespace uhx {

enum EStructFlags {
  UHX_None = 0,
  UHX_Templated = 1,
  UHX_POD = 2,
  UHX_CUSTOM = 3, // was created through a UProperty / UScriptStruct type
};

struct StructInfo;

typedef void (*IntrinsicFunction)(const StructInfo *, unreal::UIntPtr);
typedef bool (*EqFunction)(const StructInfo *, unreal::UIntPtr, unreal::UIntPtr);
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
   * The alignment size of the type
   **/
  unreal::UIntPtr alignment;

  /**
   * Calls the destructor on the target pointer. If the struct is a POD structure, or if it doesn't need
   * a destructor, this might be null
   **/
  IntrinsicFunction destruct;

  /**
   * Calls the operator equals for the target pointer type
   **/
  EqFunction equals;

  /**
   * If the type is templated, will point to a null-terminated array where each element represents a StructInfo of its implementation
   **/
  const StructInfo **genericParams;

  /**
   * If the type is templated, this will contain a pointer to a type that decodes the templated implementations through a series of virtual functions
   **/
  void *genericImplementation;

  /**
   * If this StructInfo was created by a UProperty or UScriptStruct, the original UProperty pointer can be found here
   **/
  void *contextObject;
};

#ifndef UHX_NO_UOBJECT
/**
 * Creates a StructInfo given a UScriptStruct
 **/
StructInfo infoFromUScriptStruct(void *inUScriptStruct);
#endif

}
