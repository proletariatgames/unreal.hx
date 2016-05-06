#pragma once
#define TypeParamGlue_h_included__

#include "HaxeShared.h"
#include "IntPtr.h"
#include <cstdio>
#include <utility>

#if __cplusplus > 199711L || __UNREAL__
  #define SUPPORTS_C11
#endif

#include "hxcpp.h"

namespace uhx {
template<typename T, typename=void> struct PtrMaker;
}

#ifdef __UNREAL__
  #include "TypeParamGlue_UE.h"
#endif

namespace uhx {

// Wrapper for objects that are passed by-value.
template<typename T>
struct PtrHelper_Stack {
  T val;
  PtrHelper_Stack(const T& inVal) : val(inVal) {
  }
#ifdef SUPPORTS_C11
  PtrHelper_Stack(T&& inVal) : val(std::move(inVal)) {
  }
  PtrHelper_Stack(PtrHelper_Stack&& mv) : val(std::move(mv.val)) {
  }
#endif
  PtrHelper_Stack(const PtrHelper_Stack& rhs) : val(rhs.val) {
  }

  inline T* getPointer() {
    return &val;
  }
};

// Wrapper for objects that are passed by-reference.
template<typename T>
struct PtrHelper_Ptr {
  T* ptr;
  PtrHelper_Ptr(T* inPtr) : ptr(inPtr) {
  }

#ifdef SUPPORTS_C11
  PtrHelper_Ptr(PtrHelper_Ptr&& mv) : ptr(mv.ptr) {
  }
#endif

  PtrHelper_Ptr(const PtrHelper_Ptr& rhs) : ptr(rhs.ptr) {
  }

  inline T* getPointer() {
    return ptr;
  }
};

// Default PtrMaker assumes pass-by-ref
template<typename T, typename EnumEnabler>
struct PtrMaker {
  typedef PtrHelper_Ptr<T> Type;
};

// Pointers always passed by-val
template<typename T>
struct PtrMaker<T*> {
  typedef PtrHelper_Stack<T*> Type;
};

// Basic types are passed by-val
#define BASIC_TYPE(TYPE) \
  template<> \
  struct PtrMaker< TYPE > { \
    typedef PtrHelper_Stack< TYPE > Type; \
  }

BASIC_TYPE(bool);
BASIC_TYPE(::cpp::UInt32);
BASIC_TYPE(unsigned long long int);
BASIC_TYPE(long long int);
BASIC_TYPE(::cpp::Float32);
BASIC_TYPE(::cpp::Float64);
BASIC_TYPE(::cpp::Int16);
BASIC_TYPE(::cpp::Int32);
BASIC_TYPE(::cpp::Int8);
BASIC_TYPE(::cpp::UInt16);
BASIC_TYPE(::cpp::UInt8);
BASIC_TYPE(::cpp::Char);

#undef BASIC_TYPE

template<typename T>
class MAY_EXPORT_SYMBOL TypeParamGlue {
public:
  static T haxeToUe(unreal::UIntPtr haxe);
  static unreal::UIntPtr ueToHaxe(T ue);
};

template<typename T>
class MAY_EXPORT_SYMBOL TypeParamGluePtr {
public:
  static typename uhx::PtrMaker<T>::Type haxeToUePtr(unreal::UIntPtr haxe);
  static unreal::UIntPtr ueToHaxeRef(T& ue);
};

template<typename T>
class TypeParamGlue<T&> {
public:
  static T& haxeToUe(unreal::UIntPtr haxe);
  static unreal::UIntPtr ueToHaxe(T& ue);
};

template<typename T>
class TypeParamGlue<const T&> {
public:
  static const T& haxeToUe(unreal::UIntPtr haxe);
  static unreal::UIntPtr ueToHaxe(const T& ue);
};

template<typename T>
class TypeParamGlue<const T*> {
public:
  static const T* haxeToUe(unreal::UIntPtr haxe);
  static unreal::UIntPtr ueToHaxe(const T* ue);
};

template<typename T>
class TypeParamGlue<const T> {
public:
  static const T haxeToUe(unreal::UIntPtr haxe);
  static unreal::UIntPtr ueToHaxe(const T ue);
};

template<typename T>
class TypeParamGluePtr<const T> {
public:
  static typename uhx::PtrMaker<const T>::Type haxeToUe(unreal::UIntPtr haxe);
  static unreal::UIntPtr ueToHaxeRef(const T& ue);
};

}

template<typename T>
T& uhx::TypeParamGlue<T&>::haxeToUe(unreal::UIntPtr haxe) {
  // warning: this WILL FAIL with basic types (like int*, float, double) and enums
  // This will only be used like that on delegates - so these kinds of delegates are forbidden to be declared
  return *uhx::TypeParamGluePtr<T>::haxeToUePtr(haxe).ptr;
}

template<typename T>
unreal::UIntPtr uhx::TypeParamGlue<T&>::ueToHaxe(T& ue) {
  return uhx::TypeParamGluePtr<T>::ueToHaxeRef(ue);
}

template<typename T>
const T& uhx::TypeParamGlue<const T&>::haxeToUe(unreal::UIntPtr haxe) {
  // warning: this WILL FAIL with basic types (like int*, float, double) and enums
  // This will only be used like that on delegates - so these kinds of delegates are forbidden to be declared
  return *uhx::TypeParamGluePtr<T>::haxeToUePtr(haxe).ptr;
}

template<typename T>
unreal::UIntPtr uhx::TypeParamGlue<const T&>::ueToHaxe(const T& ue) {
  return uhx::TypeParamGluePtr<T>::ueToHaxeRef(const_cast<T&>(ue));
}

template<typename T>
const T* uhx::TypeParamGlue<const T*>::haxeToUe(unreal::UIntPtr haxe) {
  return uhx::TypeParamGlue<T*>::haxeToUe(haxe);
}

template<typename T>
unreal::UIntPtr uhx::TypeParamGlue<const T*>::ueToHaxe(const T* ue) {
  return uhx::TypeParamGlue<T*>::ueToHaxe(const_cast<T*>(ue));
}

template<typename T>
const T uhx::TypeParamGlue<const T>::haxeToUe(unreal::UIntPtr haxe) {
  return uhx::TypeParamGlue<T>::haxeToUe(haxe);
}

template<typename T>
unreal::UIntPtr uhx::TypeParamGlue<const T>::ueToHaxe(const T ue) {
  return uhx::TypeParamGlue<T>::ueToHaxe(const_cast<T>(ue));
}

template<typename T>
typename uhx::PtrMaker<const T>::Type uhx::TypeParamGluePtr<const T>::haxeToUe(unreal::UIntPtr haxe) {
  return const_cast<typename uhx::PtrMaker<const T>::Type>(uhx::TypeParamGluePtr<T>::haxeToUe(haxe));
}

template<typename T>
unreal::UIntPtr uhx::TypeParamGluePtr<const T>::ueToHaxeRef(const T& ue) {
  return uhx::TypeParamGluePtr<T>::ueToHaxeRef(const_cast<T&>(ue));
}
