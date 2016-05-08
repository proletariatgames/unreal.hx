#pragma once

#include <type_traits>
#include "unreal/helpers/HxcppRuntime.h"
#include "Engine.h"

// This file is only included during Unreal Engine compilation - it specifies how various UE types are
// passed around: by-ref or by-val. Behavior for basic types are specified in TypeParamGlue.h

enum class ESPMode;
template<class ObjectType, ESPMode Mode> class TSharedRef;
template<class ObjectType, ESPMode Mode> class TSharedPtr;
template<class T, class TWeakObjectPtrBase> struct TWeakObjectPtr;
template<class T> class TAutoWeakObjectPtr;
template<class TClass> class TSubclassOf;

namespace uhx {

enum EImplementationKind {
  OtherType = 0,

  EnumType = 1,

  ObjectType = 2,
};

/**
 * Trait to determine what implementation of TStructData we need
 **/
template<class T> struct TImplementationKind {
  enum { Value = std::is_enum<T>::value ? EnumType : (TIsCastable<T>::Value ? ObjectType : OtherType) };
};

template<class T> struct TImplementationKind<T*> { enum { Value = TImplementationKind<T>::Value }; };
template<class T> struct TImplementationKind<T&> { enum { Value = TImplementationKind<T>::Value }; };

// Main defintions
template<typename T, typename=void> struct PtrMaker;

template<typename T, int Kind = TImplementationKind<T>::Value>
struct TypeParamGlue {
  static T haxeToUe(unreal::UIntPtr haxe);
  static unreal::UIntPtr ueToHaxe(T ue);
};

template<typename T, int Kind = TImplementationKind<T>::Value>
struct TypeParamGluePtr {
  static typename PtrMaker<T>::Type haxeToUePtr(unreal::UIntPtr haxe);

  inline static unreal::UIntPtr ueToHaxeRef(T& ue) {
    return TypeParamGlue<T, Kind>::ueToHaxe(ue);
  }
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

template<typename T, int Kind>
struct TypeParamGlue<T&, Kind> {
  static T& haxeToUe(unreal::UIntPtr haxe);
  static unreal::UIntPtr ueToHaxe(T& ue);
};

template<typename T, int Kind>
struct TypeParamGlue<const T&, Kind> {
  static const T& haxeToUe(unreal::UIntPtr haxe);
  static unreal::UIntPtr ueToHaxe(const T& ue);
};

template<typename T, int Kind>
struct TypeParamGlue<const T*, Kind> {
  static const T* haxeToUe(unreal::UIntPtr haxe);
  static unreal::UIntPtr ueToHaxe(const T* ue);
};

template<typename T, int Kind>
struct TypeParamGlue<const T, Kind> {
  static const T haxeToUe(unreal::UIntPtr haxe);
  static unreal::UIntPtr ueToHaxe(const T ue);
};

template<typename T, int Kind>
struct TypeParamGluePtr<const T, Kind> {
  static typename PtrMaker<const T>::Type haxeToUe(unreal::UIntPtr haxe);
  static unreal::UIntPtr ueToHaxeRef(const T& ue);
};



//////////////////////////////////

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

//////////////////////////////////
// Implementations
//////////////////////////////////

// basic types
#define BASIC_TYPE(TYPE,name) \
  template<> struct TypeParamGlue<TYPE, OtherType> { \
    inline static TYPE haxeToUe(unreal::UIntPtr haxe) { \
      return (TYPE) unreal::helpers::HxcppRuntime::box##name(haxe); \
    } \
    inline static unreal::UIntPtr ueToHaxe(TYPE ue) { \
      return unreal::helpers::HxcppRuntime::unbox##name(ue); \
    } \
  }; \
  template<> struct PtrMaker< TYPE > { typedef PtrHelper_Stack< TYPE > Type; }; \
  template<> struct TypeParamGluePtr<TYPE, OtherType> { \
    inline static typename PtrMaker<TYPE>::Type haxeToUePtr(unreal::UIntPtr haxe) { \
      return typename PtrMaker<TYPE>::Type(TypeParamGlue<TYPE, OtherType>::haxeToUe(haxe)); \
    } \
    inline static unreal::UIntPtr ueToHaxeRef(TYPE& ue) { \
      return TypeParamGlue<TYPE, OtherType>::ueToHaxe(ue); \
    } \
  }

BASIC_TYPE(bool, Bool);
BASIC_TYPE(uint64, Int64);
BASIC_TYPE(uint32, Int);
BASIC_TYPE(uint16, Int);
BASIC_TYPE(uint8, Int);
BASIC_TYPE(int64, Int64);
BASIC_TYPE(int32, Int);
BASIC_TYPE(int16, Int);
BASIC_TYPE(int8, Int);
BASIC_TYPE(char, Int);
BASIC_TYPE(float, Float);
BASIC_TYPE(double, Float);

#undef BASIC_TYPE

// special types: TWeakObjectPtr, TAutoWeakObjectPtr, TSubclassOf
template<typename T, int Kind>
struct TypeParamGlue<TWeakObjectPtr<T>, Kind> {
  inline static TWeakObjectPtr<T> haxeToUe(unreal::UIntPtr haxe) {
    return (TWeakObjectPtr<T>) TypeParamGlue<T*>::haxeToUe(haxe);
  }

  inline static unreal::UIntPtr ueToHaxe(TWeakObjectPtr<T> ue) {
    return TypeParamGlue<T*>::ueToHaxe( (T*) ue );
  }
};

template<typename T, int Kind>
struct TypeParamGlue<TAutoWeakObjectPtr<T>, Kind> {
  inline static TAutoWeakObjectPtr<T> haxeToUe(unreal::UIntPtr haxe) {
    return (TAutoWeakObjectPtr<T>) TypeParamGlue<T*>::haxeToUe(haxe);
  }

  inline static unreal::UIntPtr ueToHaxe(TAutoWeakObjectPtr<T> ue) {
    return TypeParamGlue<T*>::ueToHaxe( (T*) ue );
  }
};

template<typename T, int Kind>
struct TypeParamGlue<TSubclassOf<T>, Kind> {
  inline static TSubclassOf<T> haxeToUe(unreal::UIntPtr haxe) {
    return (TSubclassOf<T>) TypeParamGlue<UClass *>::haxeToUe(haxe);
  }

  inline static unreal::UIntPtr ueToHaxe(TSubclassOf<T> ue) {
    return TypeParamGlue<UClass *>::ueToHaxe( (UClass *) ue );
  }
};

// enum types
template<typename T>

// uobject-derived types
// interface types (see Casts.h -> TIsIInterface)
// struct types
// templated types

}

template<typename T, int Kind>
T& uhx::TypeParamGlue<T&, Kind>::haxeToUe(unreal::UIntPtr haxe) {
  // warning: this WILL FAIL with basic types (like int*, float, double) and enums
  // This will only be used like that on delegates - so these kinds of delegates are forbidden to be declared
  return *uhx::TypeParamGluePtr<T, Kind>::haxeToUePtr(haxe).ptr;
}

template<typename T, int Kind>
unreal::UIntPtr uhx::TypeParamGlue<T&, Kind>::ueToHaxe(T& ue) {
  return uhx::TypeParamGluePtr<T, Kind>::ueToHaxeRef(ue);
}

template<typename T, int Kind>
const T& uhx::TypeParamGlue<const T&, Kind>::haxeToUe(unreal::UIntPtr haxe) {
  // warning: this WILL FAIL with basic types (like int*, float, double) and enums
  // This will only be used like that on delegates - so these kinds of delegates are forbidden to be declared
  return *uhx::TypeParamGluePtr<T, Kind>::haxeToUePtr(haxe).ptr;
}

template<typename T, int Kind>
unreal::UIntPtr uhx::TypeParamGlue<const T&, Kind>::ueToHaxe(const T& ue) {
  return uhx::TypeParamGluePtr<T, Kind>::ueToHaxeRef(const_cast<T&>(ue));
}

template<typename T, int Kind>
const T* uhx::TypeParamGlue<const T*, Kind>::haxeToUe(unreal::UIntPtr haxe) {
  return uhx::TypeParamGlue<T*, Kind>::haxeToUe(haxe);
}

template<typename T, int Kind>
unreal::UIntPtr uhx::TypeParamGlue<const T*, Kind>::ueToHaxe(const T* ue) {
  return uhx::TypeParamGlue<T*, Kind>::ueToHaxe(const_cast<T*>(ue));
}

template<typename T, int Kind>
const T uhx::TypeParamGlue<const T, Kind>::haxeToUe(unreal::UIntPtr haxe) {
  return uhx::TypeParamGlue<T, Kind>::haxeToUe(haxe);
}

template<typename T, int Kind>
unreal::UIntPtr uhx::TypeParamGlue<const T, Kind>::ueToHaxe(const T ue) {
  return uhx::TypeParamGlue<T, Kind>::ueToHaxe(const_cast<T>(ue));
}

template<typename T, int Kind>
typename uhx::PtrMaker<const T>::Type uhx::TypeParamGluePtr<const T, Kind>::haxeToUe(unreal::UIntPtr haxe) {
  return const_cast<typename uhx::PtrMaker<T>::Type>(uhx::TypeParamGluePtr<T, Kind>::haxeToUe(haxe));
}

template<typename T, int Kind>
unreal::UIntPtr uhx::TypeParamGluePtr<const T, Kind>::ueToHaxeRef(const T& ue) {
  return uhx::TypeParamGluePtr<T, Kind>::ueToHaxeRef(const_cast<T&>(ue));
}
