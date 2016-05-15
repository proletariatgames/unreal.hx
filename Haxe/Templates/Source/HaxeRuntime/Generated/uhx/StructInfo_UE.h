#pragma once
// basic includes
#include <type_traits>

// uhx includes
#include "IntPtr.h"
#include "uhx/StructInfo.h"
#include "uhx/TypeTraits.h"

// unreal includes
#include "Engine.h"
#include "UObject/Class.h"
enum class ESPMode;
template<class T, class TWeakObjectPtrBase> struct TWeakObjectPtr;
template<class T> class TAutoWeakObjectPtr;
template<class TClass> class TSubclassOf;

namespace uhx {

// default implementation of getting type names. Not very pretty on gcc, but still nice for debugging
// use ENABLE_DEBUG_TYPENAME to add more readable implementations
template<class T>
struct TypeName
{
  FORCEINLINE static const char* Get()
  {
    // unfortunately we can't use this, because unreal compiles with -fno-rtti
    // return typeid(T).name();
    return nullptr;
  }
};

// a specialization for each type of those you want to support
#define ENABLE_DEBUG_TYPENAME(A) namespace uhx { template<> struct TypeName<A> { FORCEINLINE static const char *Get() { return #A; }}; }

/**
 * General definition of TStructData, which allows getting a StructInfo type of each type
 **/
template<class T, bool isPod = TIsPODType<T>::Value>
struct TStructData {
  static const StructInfo *getInfo();
};

template<class T>
struct TTemplatedData {
  static const StructInfo *getInfo();
};

template<class T, bool isObject = TIsCastable<T>::Value>
struct TAnyData {
  FORCEINLINE static const StructInfo *getInfo();
};

template<class T, bool destructible = std::is_destructible<T>::value>
struct TDestruct {
  FORCEINLINE static void doDestruct(unreal::UIntPtr ptr);
};

template<class T>
struct TDestruct<T, true> {
  FORCEINLINE static void doDestruct(unreal::UIntPtr ptr) { 
    ((T*)ptr)->~T();
  }
};

template<class T>
struct TDestruct<T, false> {
  FORCEINLINE static void doDestruct(unreal::UIntPtr ptr) { 
    // we cannot destruct this type
    check(false);
  }
};

// POD types
template<class T>
struct TStructData<T, true> {
  typedef TStructOpsTypeTraits<T> TTraits;
  typedef TStructData<T, true> TSelf;

  FORCEINLINE static const StructInfo *getInfo() {
    static StructInfo info = {
      .name = TypeName<T>::Get(),
      .flags = UHX_POD,
      .size = (unreal::UIntPtr) sizeof(T),
      .alignment = (unreal::UIntPtr) alignof(T),
      .destruct = nullptr,
      .equals = (TTraits::WithIdentical || TTraits::WithIdenticalViaEquality) ? &doEquals : nullptr,
      .genericParams = nullptr,
      .genericImplementation = nullptr
    };
    return &info;
  }

  static bool doEquals(unreal::UIntPtr t1, unreal::UIntPtr t2) {
    return t1 == t2 || uhx::TypeTraits::Equals<T>::isEq( *((T*) t1), *((T*) t2) );
  }
};

// Normal types
template<class T>
struct TStructData<T, false> {
  typedef TStructOpsTypeTraits<T> TTraits;
  typedef TStructData<T, false> TSelf;

  FORCEINLINE static const StructInfo *getInfo() {
    static StructInfo info = {
      .name = TypeName<T>::Get(),
      .flags = UHX_None,
      .size = (unreal::UIntPtr) sizeof(T),
      .alignment = (unreal::UIntPtr) alignof(T),
      .destruct = (TTraits::WithNoDestructor || std::is_trivially_destructible<T>::value ? nullptr : &TSelf::destruct),
      .equals = (TTraits::WithIdentical || TTraits::WithIdenticalViaEquality) ? &doEquals : nullptr,
      .genericParams = nullptr,
      .genericImplementation = nullptr
    };
    return &info;
  }
private:

  static void destruct(unreal::UIntPtr ptr) {
    TDestruct<T>::doDestruct(ptr);
  }

  static bool doEquals(unreal::UIntPtr t1, unreal::UIntPtr t2) {
    return t1 == t2 || uhx::TypeTraits::Equals<T>::isEq( *((T*) t1), *((T*) t2) );
  }
};

template<class T>
struct TAnyData<T, true> {
  FORCEINLINE static const StructInfo *getInfo() {
    return nullptr;
  }
};

template<class T>
struct TAnyData<TWeakObjectPtr<T>, false> { FORCEINLINE static const StructInfo *getInfo() { return nullptr; } };
template<class T>
struct TAnyData<TAutoWeakObjectPtr<T>, false> { FORCEINLINE static const StructInfo *getInfo() { return nullptr; } };
template<class T>
struct TAnyData<TSubclassOf<T>, false> { FORCEINLINE static const StructInfo *getInfo() { return nullptr; } };

template<template<typename, typename...> class T, typename First, typename... Values> 
struct TAnyData<T<First, Values...>, false> {
  FORCEINLINE static const StructInfo *getInfo() {
    return TTemplatedData<T<First, Values...>>::getInfo();
  }
};

template<ESPMode Mode, template<typename, ESPMode> class T, typename First> 
struct TAnyData<T<First, Mode>, false> {
  FORCEINLINE static const StructInfo *getInfo() {
    return TTemplatedData<T<First, Mode>>::getInfo();
  }
};

template<class T> 
struct TAnyData<T, false> {
  FORCEINLINE static const StructInfo *getInfo() {
    return TStructData<T>::getInfo();
  }
};


}
