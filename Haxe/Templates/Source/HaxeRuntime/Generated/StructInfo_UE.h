#pragma once
// basic includes
#include <type_traits>

// uhx includes
#include "IntPtr.h"
#include "StructInfo.h"

// unreal includes
#include "Engine.h"
#include "UObject/Class.h"

namespace uhx {

enum EImplementationKind {
  /**
   * The type's StructInfo can be determined by a template
   **/
  NormalType = 0,

  /**
   * The type's StructInfo can be determined by a template, and it is a plain old data type
   **/
  PODType = 1,

  BasicType = 2,

  EnumType = 3,
  
  Templated = 4,

  UObjectDerived = 5,
};

/**
 * Trait to determine what implementation of TStructData we need
 **/
template<class T> struct TImplementationKind {
  enum { Value = TIsPODType<T>::Value ? (std::is_enum<T>::value ? EnumType : PODType) : NormalType };
};

// Basic types
#define BASICTYPE(name) template<> struct TImplementationKind<name> { enum { Value = BasicType }; };
BASICTYPE(float);
BASICTYPE(double);
BASICTYPE(uint8);
BASICTYPE(uint16);
BASICTYPE(uint32);
BASICTYPE(uint64);
BASICTYPE(int8);
BASICTYPE(int16);
BASICTYPE(int32);
BASICTYPE(int64);
BASICTYPE(bool);

#undef BASICTYPE

// default implementation of getting type names. Not very pretty on gcc, but still nice for debugging
// use ENABLE_DEBUG_TYPENAME to add more readable implementations
template<class T>
struct TypeName
{
  inline static const char* Get()
  {
    // unfortunately we can't use this, because unreal compiles with -fno-rtti
    // return typeid(T).name();
    return nullptr;
  }
};

// a specialization for each type of those you want to support
#define ENABLE_DEBUG_TYPENAME(A) namespace uhx { template<> struct TypeName<A> { inline static const char *Get() { return #A; }}; }

/**
 * General definition of TStructData, which allows getting a StructInfo type of each type
 **/
template<class T, bool isPod = TIsPODType<T>::Value>
struct TStructData {
  static const StructInfo *getInfo();
};

// POD types
template<class T>
struct TStructData<T, true> {
  typedef TStructData<T, true> TSelf;

  inline static const StructInfo *getInfo() {
    static StructInfo info = {
      .name = TypeName<T>::Get(),
      .flags = UHX_POD,
      .size = (unreal::UIntPtr) sizeof(T),
      .destruct = nullptr,
      .genericParams = nullptr,
      .genericImplementation = nullptr
    };
    return &info;
  }
};

// Normal types
template<class T>
struct TStructData<T, false> {
  typedef TStructOpsTypeTraits<T> TTraits;
  typedef TStructData<T, false> TSelf;

  inline static const StructInfo *getInfo() {
    static StructInfo info = {
      .name = TypeName<T>::Get(),
      .flags = UHX_None,
      .size = (unreal::UIntPtr) sizeof(T),
      .destruct = (TTraits::WithNoDestructor || std::is_trivially_destructible<T>::value ? nullptr : &TSelf::doDestruct),
      .genericParams = nullptr,
      .genericImplementation = nullptr
    };
    return &info;
  }
private:
  static void doDestruct(unreal::UIntPtr ptr) {
    ((T*)ptr)->~T();
  }
};

template<class T>
struct TTemplatedData {
  static const StructInfo *getInfo();
};

}
