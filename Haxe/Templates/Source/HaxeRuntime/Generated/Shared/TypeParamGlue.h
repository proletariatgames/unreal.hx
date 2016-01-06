#pragma once
#define TypeParamGlue_h_included__

#ifndef HAXERUNTIME_API
  #define HAXERUNTIME_API
#endif
#include <cstdio>
#include <utility>

#if __cplusplus > 199711L || __UNREAL__
  #define SUPPORTS_C11
#endif

#include "hxcpp.h"

template<typename T, typename=void> struct PtrMaker;

#ifdef SUPPORTS_C11
  #include "TypeParamGlue_UE.h"
#endif

// Wrapper for objects that are passed by-value.
template<typename T>
struct HAXERUNTIME_API PtrHelper_Stack {
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
struct HAXERUNTIME_API PtrHelper_Ptr {
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
struct HAXERUNTIME_API PtrMaker {
  typedef PtrHelper_Ptr<T> Type;
};

// Pointers always passed by-val
template<typename T>
struct HAXERUNTIME_API PtrMaker<T*> {
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
class HAXERUNTIME_API TypeParamGlue {
public:
  static T haxeToUe(void *haxe);
  static void *ueToHaxe(T ue);
};

template<typename T>
class HAXERUNTIME_API TypeParamGluePtr {
public:
  static typename PtrMaker<T>::Type haxeToUePtr(void *haxe);
  static void *ueToHaxeRef(T& ue);
};

template<typename T>
class HAXERUNTIME_API TypeParamGlue<T&> {
public:
  static T& haxeToUe(void *haxe);
  static void *ueToHaxe(T& ue);
};

template<typename T>
class HAXERUNTIME_API TypeParamGlue<const T&> {
public:
  static const T& haxeToUe(void *haxe);
  static void *ueToHaxe(const T& ue);
};

template<typename T>
class HAXERUNTIME_API TypeParamGlue<const T*> {
public:
  static const T* haxeToUe(void *haxe);
  static void *ueToHaxe(const T* ue);
};

template<typename T>
class HAXERUNTIME_API TypeParamGlue<const T> {
public:
  static const T haxeToUe(void *haxe);
  static void *ueToHaxe(const T ue);
};

template<typename T>
class HAXERUNTIME_API TypeParamGluePtr<const T> {
public:
  static typename PtrMaker<const T>::Type haxeToUe(void* haxe);
  static void* ueToHaxeRef(const T& ue);
};

template<typename T>
T& TypeParamGlue<T&>::haxeToUe(void *haxe) {
  // warning: this WILL FAIL with basic types (like int*, float, double) and enums
  // This will only be used like that on delegates - so these kinds of delegates are forbidden to be declared
  return *TypeParamGluePtr<T>::haxeToUePtr(haxe).ptr;
}

template<typename T>
void *TypeParamGlue<T&>::ueToHaxe(T& ue) {
  return TypeParamGluePtr<T>::ueToHaxeRef(ue);
}

template<typename T>
const T& TypeParamGlue<const T&>::haxeToUe(void *haxe) {
  // warning: this WILL FAIL with basic types (like int*, float, double) and enums
  // This will only be used like that on delegates - so these kinds of delegates are forbidden to be declared
  return *TypeParamGluePtr<T>::haxeToUePtr(haxe).ptr;
}

template<typename T>
void *TypeParamGlue<const T&>::ueToHaxe(const T& ue) {
  return TypeParamGluePtr<T>::ueToHaxeRef(const_cast<T&>(ue));
}

template<typename T>
const T* TypeParamGlue<const T*>::haxeToUe(void *haxe) {
  return TypeParamGlue<T*>::haxeToUe(haxe);
}

template<typename T>
void *TypeParamGlue<const T*>::ueToHaxe(const T* ue) {
  return TypeParamGlue<T*>::ueToHaxe(const_cast<T*>(ue));
}

template<typename T>
const T TypeParamGlue<const T>::haxeToUe(void *haxe) {
  return TypeParamGlue<T>::haxeToUe(haxe);
}

template<typename T>
void *TypeParamGlue<const T>::ueToHaxe(const T ue) {
  return TypeParamGlue<T>::ueToHaxe(const_cast<T>(ue));
}

template<typename T>
typename PtrMaker<const T>::Type TypeParamGluePtr<const T>::haxeToUe(void* haxe) {
  return const_cast<typename PtrMaker<const T>::Type>(TypeParamGluePtr<T>::haxeToUe(haxe));
}

template<typename T>
void* TypeParamGluePtr<const T>::ueToHaxeRef(const T& ue) {
  return TypeParamGluePtr<T>::ueToHaxeRef(const_cast<T&>(ue));
}
