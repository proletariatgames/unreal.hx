#pragma once
// basic includes
#include <type_traits>

// uhx includes
#include "IntPtr.h"
#include "uhx/StructInfo.h"
#include "uhx/TypeTraits.h"

// unreal includes
#include "Core.h"

#ifndef UHX_NO_UOBJECT
#include "Engine.h"
#include "UObject/Class.h"
#endif

#ifdef _MSC_VER
#define UHX_ALIGNOF(TYPE) _alignof(TYPE)
#else
#define UHX_ALIGNOF(TYPE) alignof(TYPE)
#endif

enum class ESPMode;
template<class T, class TWeakObjectPtrBase> struct TWeakObjectPtr;
template<class T> class TAutoWeakObjectPtr;
template<class TClass> class TSubclassOf;

namespace uhx {


template<typename T, bool isAbstract = std::is_abstract<T>::value>
struct Alignment {
  inline static size_t get();
};

template<typename T>
struct Alignment<T, true> {
  inline static size_t get() {
    return sizeof(void*);
  }
};

template<typename T>
struct Alignment<T, false> {
  inline static size_t get() {
    return UHX_ALIGNOF(T);
  }
};

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

/**
 * The same as TStructData, however does not implement some troublesome features like `destruct`, which
 * can't be conditionally compiled (see the note on TypeTraits::TDestructExists
 **/
template<class T, bool isPod = TIsPODType<T>::Value>
struct TSimpleStructData {
  static const StructInfo *getInfo();
};

template<class T>
struct TTemplatedData {
  static const StructInfo *getInfo();
};

#ifndef UHX_NO_UOBJECT

template<class T, bool isObject = TIsCastable<T>::Value>
struct TAnyData {
  FORCEINLINE static const StructInfo *getInfo();
};

#else

template<class T, bool isObject = false>
struct TAnyData {
  FORCEINLINE static const StructInfo *getInfo();
};

#endif

template<class T, bool destructible = uhx::TypeTraits::TDestructExists<T>::Value>
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

////// Equals
enum EEqualKind {
  CppEquals,
  StructEquals,
  NoEquals,
};

#ifdef UHX_NO_UOBJECT
template<typename T>
struct TEqualsKind { enum { Value = uhx::NoEquals }; };

#else
template<typename T>
struct TEqualsKind { enum { Value = TStructOpsTypeTraits<T>::WithIdentical || TStructOpsTypeTraits<T>::WithIdenticalViaEquality ? uhx::StructEquals : uhx::NoEquals }; };

#endif

#define SET_CPP_EQ(TYPE) \
  template<> struct TEqualsKind<TYPE> { enum { Value = uhx::CppEquals }; }; 
SET_CPP_EQ(FName);
SET_CPP_EQ(FString);
SET_CPP_EQ(FText);

#undef SET_CPP_EQ

/**
 * A more conservative approach to equals functions - it only is available if unreal's `WithIdentical` or
 * `WithIdenticalViaEquality` is defined
 **/
template<typename T, int kind = TEqualsKind<T>::Value>
struct TUnrealEquals {
  inline static bool isEq(T const& t1, T const& t2);
};

template<typename T>
struct TUnrealEquals<T, uhx::StructEquals> {
  inline static bool isEq(T const& t1, T const& t2) {
    bool result = false;
    IdenticalOrNot(&t1, &t2, 0, result);
    return result;
  }
};

template<typename T>
struct TUnrealEquals<T, uhx::NoEquals> {
  inline static bool isEq(T const& t1, T const& t2) {
    return &t1 == &t2;
  }
};

template<typename T>
struct TUnrealEquals<T, uhx::CppEquals> {
  inline static bool isEq(T const& t1, T const& t2) {
    return uhx::TypeTraits::Equals<T>::isEq(t1,t2);
  }
};

// POD types
template<class T>
struct TStructData<T, true> {
  typedef TStructData<T, true> TSelf;

  FORCEINLINE static const StructInfo *getInfo() {
    static StructInfo info = {
      /* .name = */ TypeName<T>::Get(),
      /* .flags = */ UHX_POD,
      /* .size = */ (unreal::UIntPtr) sizeof(T),
      /* .alignment = */ (unreal::UIntPtr) Alignment<T>::get(),
      /* .destruct = */ nullptr,
      /* .equals = */ (uhx::TEqualsKind<T>::Value != uhx::NoEquals) ? &doEquals : nullptr,
      /* .genericParams = */ nullptr,
      /* .genericImplementation = */ nullptr
    };
    return &info;
  }

  static bool doEquals(unreal::UIntPtr t1, unreal::UIntPtr t2) {
    return t1 == t2 || uhx::TUnrealEquals<T>::isEq( *(reinterpret_cast<T*>(t1)), *(reinterpret_cast<T*>(t2)));
  }
};

// Normal types
template<class T>
struct TStructData<T, false> {
#ifdef UHX_NO_UOBJECT
  #define CHECK_DESTRUCTOR(T) (std::is_trivially_destructible<T>::value)
#else
  #define CHECK_DESTRUCTOR(T) (TStructOpsTypeTraits<T>::WithNoDestructor || std::is_trivially_destructible<T>::value)
#endif
  typedef TStructData<T, false> TSelf;

  FORCEINLINE static const StructInfo *getInfo() {
    static StructInfo info = {
      /* .name = */ TypeName<T>::Get(),
      /* .flags = */ UHX_None,
      /* .size = */ (unreal::UIntPtr) sizeof(T),
      /* .alignment = */ (unreal::UIntPtr) Alignment<T>::get(),
      /* .destruct = */ (CHECK_DESTRUCTOR(T) ? nullptr : &TSelf::destruct),
      /* .equals = */ (uhx::TEqualsKind<T>::Value != uhx::NoEquals) ? &doEquals : nullptr,
      /* .genericParams = */ nullptr,
      /* .genericImplementation = */ nullptr
    };
    return &info;
  }
private:

  static void destruct(unreal::UIntPtr ptr) {
    TDestruct<T>::doDestruct(ptr);
  }

  static bool doEquals(unreal::UIntPtr t1, unreal::UIntPtr t2) {
    return t1 == t2 || uhx::TUnrealEquals<T>::isEq( *(reinterpret_cast<T*>(t1)), *(reinterpret_cast<T*>(t2)));
  }

#undef CHECK_DESTRUCTOR
};

template<class T>
struct TAnyData<T, true> {
  FORCEINLINE static const StructInfo *getInfo() {
    return nullptr;
  }
};

// POD types
template<class T>
struct TSimpleStructData<T, true> {
  FORCEINLINE static const StructInfo *getInfo() {
    return TStructData<T, true>::getInfo();
  }
};

// Normal types
template<class T>
struct TSimpleStructData<T, false> {
  FORCEINLINE static const StructInfo *getInfo() {
    static StructInfo info = {
      /* .name = */ TypeName<T>::Get(),
      /* .flags = */ UHX_None,
      /* .size = */ (unreal::UIntPtr) sizeof(T),
      /* .alignment = */ (unreal::UIntPtr) Alignment<T>::get(),
      /* .destruct = */ nullptr,
      /* .equals = */ (uhx::TEqualsKind<T>::Value != uhx::NoEquals) ? &doEquals : nullptr,
      /* .genericParams = */ nullptr,
      /* .genericImplementation = */ nullptr
    };
    return &info;
  }
private:

  static bool doEquals(unreal::UIntPtr t1, unreal::UIntPtr t2) {
    return t1 == t2 || uhx::TUnrealEquals<T>::isEq( *(reinterpret_cast<T*>(t1)), *(reinterpret_cast<T*>(t2)));
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
    return TSimpleStructData<T>::getInfo();
  }
};


}
