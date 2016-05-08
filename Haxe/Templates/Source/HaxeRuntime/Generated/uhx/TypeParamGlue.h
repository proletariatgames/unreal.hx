#pragma once

#include <type_traits>

// This file is only included during Unreal Engine compilation - it specifies how various UE types are
// passed around: by-ref or by-val. Behavior for basic types are specified in TypeParamGlue.h

enum class ESPMode;
template<class ObjectType, ESPMode Mode> class TSharedRef;
template<class ObjectType, ESPMode Mode> class TSharedPtr;
template<class T, class TWeakObjectPtrBase> struct TWeakObjectPtr;
template<class T> class TAutoWeakObjectPtr;
template<class TClass> class TSubclassOf;

namespace uhx {

// Main defintions
template<typename T, typename=void> struct PtrMaker;

template<typename T>
class TypeParamGlue {
public:
  static T haxeToUe(unreal::UIntPtr haxe);
  static unreal::UIntPtr ueToHaxe(T ue);
};

template<typename T>
class TypeParamGluePtr {
public:
  static typename PtrMaker<T>::Type haxeToUePtr(unreal::UIntPtr haxe);
  static unreal::UIntPtr ueToHaxeRef(T& ue);
};


// Wrapper for objects that are passed by-value.
template<typename T>
struct PtrHelper_Stack {
  T val;
  inline PtrHelper_Stack(const T& inVal) : val(inVal) {
  }
#ifdef SUPPORTS_C11
  inline PtrHelper_Stack(T&& inVal) : val(std::move(inVal)) {
  }
  inline PtrHelper_Stack(PtrHelper_Stack&& mv) : val(std::move(mv.val)) {
  }
#endif
  inline PtrHelper_Stack(const PtrHelper_Stack& rhs) : val(rhs.val) {
  }

  inline T* getPointer() {
    return &val;
  }
};

// Wrapper for objects that are passed by-reference.
template<typename T>
struct PtrHelper_Ptr {
  T* ptr;
  inline PtrHelper_Ptr(T* inPtr) : ptr(inPtr) {
  }

#ifdef SUPPORTS_C11
  inline PtrHelper_Ptr(PtrHelper_Ptr&& mv) : ptr(mv.ptr) {
  }
#endif

  inline PtrHelper_Ptr(const PtrHelper_Ptr& rhs) : ptr(rhs.ptr) {
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
BASIC_TYPE(uint32);
BASIC_TYPE(uint64);
BASIC_TYPE(int64);
BASIC_TYPE(float);
BASIC_TYPE(double);
BASIC_TYPE(int16);
BASIC_TYPE(int32);
BASIC_TYPE(int8);
BASIC_TYPE(uint16);
BASIC_TYPE(uint8);
BASIC_TYPE(char);

#undef BASIC_TYPE

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
  static typename PtrMaker<const T>::Type haxeToUe(unreal::UIntPtr haxe);
  static unreal::UIntPtr ueToHaxeRef(const T& ue);
};



//////////////////////////////////
// Forward declarations
template<typename T> struct PtrHelper_Stack;
template<typename T> struct PtrHelper_Ptr;
/////////////////////////////////

// Enums always passed by-val
template<typename T>
struct PtrMaker<T, typename std::enable_if<std::is_enum<T>::value>::type> {
  typedef PtrHelper_Stack<T> Type;
};

// Smart pointers are passed by-val
template<typename T, ESPMode Mode>
struct PtrMaker<TSharedPtr<T, Mode>> {
  typedef PtrHelper_Stack<TSharedPtr<T,Mode>> Type;
};
template<typename T, ESPMode Mode>
struct PtrMaker<TSharedRef<T, Mode>> {
  typedef PtrHelper_Stack<TSharedRef<T,Mode>> Type;
};
template<typename T, typename Base>
struct PtrMaker<TWeakObjectPtr<T,Base>> {
  typedef PtrHelper_Stack<TWeakObjectPtr<T,Base>> Type;
};
template<typename T>
struct PtrMaker<TAutoWeakObjectPtr<T>> {
  typedef PtrHelper_Stack<TAutoWeakObjectPtr<T>> Type;
};

// TSubclassOf passed by-val
template<class T>
struct PtrMaker<TSubclassOf<T>> {
  typedef PtrHelper_Stack<TSubclassOf<T>> Type;
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
