#pragma once

#include <type_traits>
#include "unreal/helpers/HxcppRuntime.h"
#include "uhx/StructInfo_UE.h"
#include "uhx/EnumGlue.h"
#include "uhx/Wrapper.h"
#include "VariantPtr.h"

#ifndef UHX_NO_UOBJECT
#include "Engine.h"

#endif

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

  InterfaceType = 3
};

/**
 * Trait to determine what implementation of TStructData we need
 **/
#ifndef UHX_NO_UOBJECT
template<class T> struct TImplementationKind {
  enum { Value = std::is_enum<T>::value ? EnumType : (TIsCastable<T>::Value ? (TPointerIsConvertibleFromTo<T, const volatile UObject>::Value ? ObjectType : InterfaceType) : OtherType) };
};

#else
template<class T> struct TImplementationKind {
  enum { Value = std::is_enum<T>::value ? EnumType : OtherType };
};

#endif

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
  inline static typename PtrMaker<T>::Type haxeToUePtr(unreal::UIntPtr haxe) {
    return typename PtrMaker<T>::Type(TypeParamGlue<T, Kind>::haxeToUe(haxe));
  }

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

template<typename T>
struct TypeParamGlue<T&, OtherType> {
  static T& haxeToUe(unreal::UIntPtr haxe);
  static unreal::UIntPtr ueToHaxe(T& ue);
};
template<typename T>
struct TypeParamGlue<T&, EnumType> {
  static T& haxeToUe(unreal::UIntPtr haxe);
  static unreal::UIntPtr ueToHaxe(T& ue);
};

template<typename T>
struct TypeParamGlue<const T&, OtherType> {
  static const T& haxeToUe(unreal::UIntPtr haxe);
  static unreal::UIntPtr ueToHaxe(const T& ue);
};
template<typename T>
struct TypeParamGlue<const T&, EnumType> {
  static const T& haxeToUe(unreal::UIntPtr haxe);
  static unreal::UIntPtr ueToHaxe(const T& ue);
};

template<typename T>
struct TypeParamGlue<const T*, OtherType> {
  static const T* haxeToUe(unreal::UIntPtr haxe);
  static unreal::UIntPtr ueToHaxe(const T* ue);
};
template<typename T>
struct TypeParamGlue<const T*, EnumType> {
  static const T* haxeToUe(unreal::UIntPtr haxe);
  static unreal::UIntPtr ueToHaxe(const T* ue);
};

template<typename T>
struct TypeParamGlue<const T, OtherType> {
  static const T haxeToUe(unreal::UIntPtr haxe);
  static unreal::UIntPtr ueToHaxe(const T ue);
};
template<typename T>
struct TypeParamGlue<const T, EnumType> {
  static const T haxeToUe(unreal::UIntPtr haxe);
  static unreal::UIntPtr ueToHaxe(const T ue);
};
template<typename T>
struct TypeParamGlue<const T, ObjectType> {
  static const T haxeToUe(unreal::UIntPtr haxe);
  static unreal::UIntPtr ueToHaxe(const T ue);
};
template<typename T>
struct TypeParamGlue<const T, InterfaceType> {
  static const T haxeToUe(unreal::UIntPtr haxe);
  static unreal::UIntPtr ueToHaxe(const T ue);
};

template<typename T>
struct TypeParamGluePtr<const T, OtherType> {
  static typename PtrMaker<const T>::Type haxeToUe(unreal::UIntPtr haxe);
  static unreal::UIntPtr ueToHaxeRef(const T& ue);
};
template<typename T>
struct TypeParamGluePtr<const T, EnumType> {
  static typename PtrMaker<const T>::Type haxeToUe(unreal::UIntPtr haxe);
  static unreal::UIntPtr ueToHaxeRef(const T& ue);
};
template<typename T>
struct TypeParamGluePtr<const T, ObjectType> {
  static typename PtrMaker<const T>::Type haxeToUe(unreal::UIntPtr haxe);
  static unreal::UIntPtr ueToHaxeRef(const T& ue);
};
template<typename T>
struct TypeParamGluePtr<const T, InterfaceType> {
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
      return (TYPE) unreal::helpers::HxcppRuntime::unbox##name(haxe); \
    } \
    inline static unreal::UIntPtr ueToHaxe(TYPE ue) { \
      return unreal::helpers::HxcppRuntime::box##name(ue); \
    } \
  }; \
  template<> struct PtrMaker< TYPE > { typedef PtrHelper_Stack< TYPE > Type; }; \
  template<> struct TypeParamGluePtr< TYPE > { \
    inline static PtrMaker< TYPE >::Type haxeToUePtr(unreal::UIntPtr haxe) { \
      return PtrMaker< TYPE >::Type(TypeParamGlue< TYPE , OtherType>::haxeToUe(haxe)); \
    } \
    inline static unreal::UIntPtr ueToHaxeRef( TYPE & ue) { \
      return TypeParamGlue< TYPE , OtherType>::ueToHaxe(ue); \
    } \
  }

BASIC_TYPE(bool, Bool);
BASIC_TYPE(cpp::UInt64, Int64);
BASIC_TYPE(cpp::UInt32, Int);
BASIC_TYPE(cpp::UInt16, Int);
BASIC_TYPE(cpp::UInt8, Int);
BASIC_TYPE(cpp::Int64, Int64);
BASIC_TYPE(Int, Int);
BASIC_TYPE(cpp::Int16, Int);
BASIC_TYPE(cpp::Int8, Int);
BASIC_TYPE(cpp::Char, Int);
BASIC_TYPE(float, Float);
BASIC_TYPE(double, Float);

#undef BASIC_TYPE

// enum types
template<typename T>
struct TypeParamGlue<T, EnumType> {
  inline static T haxeToUe(unreal::UIntPtr haxe) {
    return uhx::EnumGlue<T>::haxeToUe(haxe);
  }

  inline static unreal::UIntPtr ueToHaxe(T ue) {
    return uhx::EnumGlue<T>::ueToHaxe(ue);
  }
};

// uobject-derived types
template<typename T>
struct TypeParamGlue<T, ObjectType> {
  inline static T haxeToUe(unreal::UIntPtr haxe) {
    // uobject-derived types are never passed by value - this is probably a bad overload selection
    check(false);
  }

  inline static unreal::UIntPtr ueToHaxe(T ue) {
    // uobject-derived types are never passed by value - this is probably a bad overload selection
    check(false);
  }
};
template<typename T>
struct TypeParamGlue<T, InterfaceType> {
  inline static T haxeToUe(unreal::UIntPtr haxe) {
    // uobject-derived types are never passed by value - this is probably a bad overload selection
    check(false);
  }

  inline static unreal::UIntPtr ueToHaxe(T ue) {
    // uobject-derived types are never passed by value - this is probably a bad overload selection
    check(false);
  }
};


template<typename T>
struct TypeParamGlue<T*, ObjectType> {
  inline static T* haxeToUe(unreal::UIntPtr haxe) {
    return (T *) unreal::helpers::HxcppRuntime::uobjectUnwrap(haxe);
  }

  inline static unreal::UIntPtr ueToHaxe(T* ue) {
    return unreal::helpers::HxcppRuntime::uobjectWrap((unreal::UIntPtr) ue);
  }
};
template<typename T>
struct TypeParamGlue<T*, InterfaceType> {
  inline static T* haxeToUe(unreal::UIntPtr haxe) {
    return Cast<T>((UObject *) unreal::helpers::HxcppRuntime::uobjectUnwrap(haxe));
  }

  inline static unreal::UIntPtr ueToHaxe(T* ue) {
    return unreal::helpers::HxcppRuntime::uobjectWrap((unreal::UIntPtr) Cast<UObject>(ue));
  }
};

template<typename T>
struct TypeParamGlue<T&, ObjectType> {
  inline static T& haxeToUe(unreal::UIntPtr haxe) {
    return *((UObject *) unreal::helpers::HxcppRuntime::uobjectUnwrap(haxe));
  }

  inline static unreal::UIntPtr ueToHaxe(T& ue) {
    return unreal::helpers::HxcppRuntime::uobjectWrap((unreal::UIntPtr) &ue);
  }
};
template<typename T>
struct TypeParamGlue<T&, InterfaceType> {
  inline static T& haxeToUe(unreal::UIntPtr haxe) {
    return *Cast<T>((UObject *) unreal::helpers::HxcppRuntime::uobjectUnwrap(haxe));
  }

  inline static unreal::UIntPtr ueToHaxe(T& ue) {
    return unreal::helpers::HxcppRuntime::uobjectWrap((unreal::UIntPtr) Cast<UObject>(&ue));
  }
};

#ifndef UHX_NO_UOBJECT
// special types: TWeakObjectPtr, TAutoWeakObjectPtr, TSubclassOf
template<typename T>
struct TypeParamGlue<TWeakObjectPtr<T>, OtherType> {
  inline static TWeakObjectPtr<T> haxeToUe(unreal::UIntPtr haxe) {
    return (TWeakObjectPtr<T>) TypeParamGlue<T*>::haxeToUe(haxe);
  }

  inline static unreal::UIntPtr ueToHaxe(TWeakObjectPtr<T> ue) {
    return TypeParamGlue<T*>::ueToHaxe( (T*) ue.Get() );
  }
};
template<typename T>
struct TypeParamGluePtr<TWeakObjectPtr<T>, OtherType> {
  inline static typename PtrMaker<TWeakObjectPtr<T>>::Type haxeToUePtr(unreal::UIntPtr haxe) {
    return typename PtrMaker<TWeakObjectPtr<T>>::Type(TypeParamGlue<TWeakObjectPtr<T>, OtherType>::haxeToUe(haxe));
  }

  inline static unreal::UIntPtr ueToHaxeRef(TWeakObjectPtr<T>& ue) {
    return TypeParamGlue<T*>::ueToHaxe( (T*) ue.Get() );
  }
};

template<typename T>
struct TypeParamGlue<TAutoWeakObjectPtr<T>, OtherType> {
  inline static TAutoWeakObjectPtr<T> haxeToUe(unreal::UIntPtr haxe) {
    return (TAutoWeakObjectPtr<T>) TypeParamGlue<T*>::haxeToUe(haxe);
  }

  inline static unreal::UIntPtr ueToHaxe(TAutoWeakObjectPtr<T> ue) {
    return TypeParamGlue<T*>::ueToHaxe( (T*) ue.Get() );
  }
};
template<typename T>
struct TypeParamGluePtr<TAutoWeakObjectPtr<T>, OtherType> {
  inline static typename PtrMaker<TAutoWeakObjectPtr<T>>::Type haxeToUePtr(unreal::UIntPtr haxe) {
    return typename PtrMaker<TAutoWeakObjectPtr<T>>::Type(TypeParamGlue<TAutoWeakObjectPtr<T>, OtherType>::haxeToUe(haxe));
  }

  inline static unreal::UIntPtr ueToHaxeRef(TAutoWeakObjectPtr<T>& ue) {
    return TypeParamGlue<T*>::ueToHaxe( (T*) ue.Get() );
  }
};

template<typename T>
struct TypeParamGlue<TSubclassOf<T>, OtherType> {
  inline static TSubclassOf<T> haxeToUe(unreal::UIntPtr haxe) {
    return (TSubclassOf<T>) TypeParamGlue<UClass *>::haxeToUe(haxe);
  }

  inline static unreal::UIntPtr ueToHaxe(TSubclassOf<T> ue) {
    return TypeParamGlue<UClass *>::ueToHaxe( (UClass *) ue );
  }
};
template<typename T>
struct TypeParamGluePtr<TSubclassOf<T>, OtherType> {
  inline static typename PtrMaker<TSubclassOf<T>>::Type haxeToUePtr(unreal::UIntPtr haxe) {
    return typename PtrMaker<TSubclassOf<T>>::Type(TypeParamGlue<TSubclassOf<T>, OtherType>::haxeToUe(haxe));
  }

  inline static unreal::UIntPtr ueToHaxeRef(TSubclassOf<T>& ue) {
    return TypeParamGlue<UClass *>::ueToHaxe( *ue );
  }
};

#endif

// templated types
template<template<typename, typename...> class T, typename First, typename... Values> 
struct TTemplatedData<T<First, Values...>> {
  static const StructInfo *getInfo();
};

template<template<typename, typename...> class T, typename First, typename... Values> 
struct TypeParamGlue<T<First, Values...>, OtherType> {
  inline static T<First, Values...> haxeToUe(unreal::UIntPtr haxe) {
    return *TemplateHelper<T<First, Values...>>::getPointer(unreal::VariantPtr(haxe));
  }

  inline static unreal::UIntPtr ueToHaxe(T<First, Values...> ue) {
    return TemplateHelper<T<First, Values...>>::fromStruct(ue).raw;
  }
};
template<template<typename, typename...> class T, typename First, typename... Values> 
struct TypeParamGluePtr<T<First, Values...>, OtherType> {
  inline static typename PtrMaker<T<First, Values...>>::Type haxeToUePtr(unreal::UIntPtr haxe) {
    return typename PtrMaker<T<First, Values...>>::Type( TemplateHelper<T<First, Values...>>::getPointer(haxe) );
  }

  inline static unreal::UIntPtr ueToHaxeRef(T<First, Values...>& ue) {
    return TemplateHelper<T<First, Values...>>::fromStruct(ue).raw;
  }
};

// special case for the types that have constant values. Right now we only need this for shared pointers
template<ESPMode Mode, template<typename, ESPMode> class T, typename First> 
struct TTemplatedData<T<First, Mode>> {
  static const StructInfo *getInfo();
};

template<ESPMode Mode, template<typename, ESPMode> class T, typename First> 
struct TypeParamGlue<T<First, Mode>, OtherType> {
  inline static T<First, Mode> haxeToUe(unreal::UIntPtr haxe) {
    return *TemplateHelper<T<First, Mode>>::getPointer(unreal::VariantPtr(haxe));
  }

  inline static unreal::UIntPtr ueToHaxe(T<First, Mode> ue) {
    return TemplateHelper<T<First, Mode>>::fromStruct(ue).raw;
  }
};
template<ESPMode Mode, template<typename, ESPMode> class T, typename First> 
struct TypeParamGluePtr<T<First, Mode>, OtherType> {
  inline static typename PtrMaker<T<First, Mode>>::Type haxeToUePtr(unreal::UIntPtr haxe) {
    return typename PtrMaker<T<First, Mode>>::Type( TemplateHelper<T<First, Mode>>::getPointer(haxe) );
  }

  inline static unreal::UIntPtr ueToHaxeRef(T<First, Mode>& ue) {
    return TemplateHelper<T<First, Mode>>::fromStruct(ue).raw;
  }
};

// struct types
template<typename T>
struct TypeParamGlue<T, OtherType> {
  inline static T haxeToUe(unreal::UIntPtr haxe) {
    return *StructHelper<T>::getPointer(unreal::VariantPtr(haxe));
  }

  inline static unreal::UIntPtr ueToHaxe(T ue) {
    return StructHelper<T>::fromStruct(ue).raw;
  }
};
template<typename T>
struct TypeParamGluePtr<T, OtherType> {
  inline static typename PtrMaker<T>::Type haxeToUePtr(unreal::UIntPtr haxe) {
    return typename PtrMaker<T>::Type( StructHelper<T>::getPointer(haxe) );
  }

  inline static unreal::UIntPtr ueToHaxeRef(T& ue) {
    return unreal::helpers::HxcppRuntime::boxVariantPtr(StructHelper<T>::fromPointer(&ue));
  }
};

template<typename T>
struct TypeParamGlue<T*, OtherType> {
  inline static T* haxeToUe(unreal::UIntPtr haxe) {
    return StructHelper<T>::getPointer(unreal::VariantPtr(haxe));
  }

  inline static unreal::UIntPtr ueToHaxe(T* ue) {
    return unreal::helpers::HxcppRuntime::boxVariantPtr(unreal::VariantPtr(ue));
  }
};

}

template<typename T>
T& uhx::TypeParamGlue< T&, uhx::EnumType >::haxeToUe(unreal::UIntPtr haxe) {
  // warning: this WILL FAIL with basic types (like int*, float, double) and enums
  // This will only be used like that on delegates - so these kinds of delegates are forbidden to be declared
  return *uhx::TypeParamGluePtr< T >::haxeToUePtr(haxe).ptr;
}

template<typename T>
T& uhx::TypeParamGlue< T&, uhx::OtherType >::haxeToUe(unreal::UIntPtr haxe) {
  // warning: this WILL FAIL with basic types (like int*, float, double) and enums
  // This will only be used like that on delegates - so these kinds of delegates are forbidden to be declared
  return *uhx::TypeParamGluePtr<T>::haxeToUePtr(haxe).ptr;
}

template<typename T>
unreal::UIntPtr uhx::TypeParamGlue<T&, uhx::EnumType>::ueToHaxe(T& ue) {
  return uhx::TypeParamGluePtr<T>::ueToHaxeRef(ue);
}
template<typename T>
unreal::UIntPtr uhx::TypeParamGlue<T&, uhx::OtherType>::ueToHaxe(T& ue) {
  return uhx::TypeParamGluePtr<T>::ueToHaxeRef(ue);
}

template<typename T>
const T& uhx::TypeParamGlue<const T&, uhx::EnumType>::haxeToUe(unreal::UIntPtr haxe) {
  // warning: this WILL FAIL with basic types (like int*, float, double) and enums
  // This will only be used like that on delegates - so these kinds of delegates are forbidden to be declared
  return *uhx::TypeParamGluePtr<T>::haxeToUePtr(haxe).ptr;
}
template<typename T>
const T& uhx::TypeParamGlue<const T&, uhx::OtherType>::haxeToUe(unreal::UIntPtr haxe) {
  // warning: this WILL FAIL with basic types (like int*, float, double) and enums
  // This will only be used like that on delegates - so these kinds of delegates are forbidden to be declared
  return *uhx::TypeParamGluePtr<T>::haxeToUePtr(haxe).ptr;
}

template<typename T>
unreal::UIntPtr uhx::TypeParamGlue<const T&, uhx::EnumType>::ueToHaxe(const T& ue) {
  return uhx::TypeParamGluePtr<T>::ueToHaxeRef(const_cast<T&>(ue));
}
template<typename T>
unreal::UIntPtr uhx::TypeParamGlue<const T&, uhx::OtherType>::ueToHaxe(const T& ue) {
  return uhx::TypeParamGluePtr<T>::ueToHaxeRef(const_cast<T&>(ue));
}

template<typename T>
const T* uhx::TypeParamGlue<const T*, uhx::EnumType>::haxeToUe(unreal::UIntPtr haxe) {
  return uhx::TypeParamGlue<T*>::haxeToUe(haxe);
}
template<typename T>
const T* uhx::TypeParamGlue<const T*, uhx::OtherType>::haxeToUe(unreal::UIntPtr haxe) {
  return uhx::TypeParamGlue<T*>::haxeToUe(haxe);
}

template<typename T>
unreal::UIntPtr uhx::TypeParamGlue<const T*, uhx::EnumType>::ueToHaxe(const T* ue) {
  return uhx::TypeParamGlue<T*>::ueToHaxe(const_cast<T*>(ue));
}
template<typename T>
unreal::UIntPtr uhx::TypeParamGlue<const T*, uhx::OtherType>::ueToHaxe(const T* ue) {
  return uhx::TypeParamGlue<T*>::ueToHaxe(const_cast<T*>(ue));
}

template<typename T>
const T uhx::TypeParamGlue<const T, uhx::EnumType>::haxeToUe(unreal::UIntPtr haxe) {
  return uhx::TypeParamGlue<T>::haxeToUe(haxe);
}
template<typename T>
const T uhx::TypeParamGlue<const T, uhx::OtherType>::haxeToUe(unreal::UIntPtr haxe) {
  return uhx::TypeParamGlue<T>::haxeToUe(haxe);
}
template<typename T>
const T uhx::TypeParamGlue<const T, uhx::ObjectType>::haxeToUe(unreal::UIntPtr haxe) {
  return uhx::TypeParamGlue<T>::haxeToUe(haxe);
}
template<typename T>
const T uhx::TypeParamGlue<const T, uhx::InterfaceType>::haxeToUe(unreal::UIntPtr haxe) {
  return uhx::TypeParamGlue<T>::haxeToUe(haxe);
}

template<typename T>
unreal::UIntPtr uhx::TypeParamGlue<const T, uhx::EnumType>::ueToHaxe(const T ue) {
  return uhx::TypeParamGlue<T>::ueToHaxe(const_cast<T>(ue));
}
template<typename T>
unreal::UIntPtr uhx::TypeParamGlue<const T, uhx::OtherType>::ueToHaxe(const T ue) {
  return uhx::TypeParamGlue<T>::ueToHaxe(const_cast<T>(ue));
}
template<typename T>
unreal::UIntPtr uhx::TypeParamGlue<const T, uhx::ObjectType>::ueToHaxe(const T ue) {
  return uhx::TypeParamGlue<T>::ueToHaxe(const_cast<T>(ue));
}
template<typename T>
unreal::UIntPtr uhx::TypeParamGlue<const T, uhx::InterfaceType>::ueToHaxe(const T ue) {
  return uhx::TypeParamGlue<T>::ueToHaxe(const_cast<T>(ue));
}

template<typename T>
typename uhx::PtrMaker<const T>::Type uhx::TypeParamGluePtr<const T, uhx::EnumType>::haxeToUe(unreal::UIntPtr haxe) {
  return const_cast<typename uhx::PtrMaker<T>::Type>(uhx::TypeParamGluePtr<T, uhx::EnumType>::haxeToUe(haxe));
}
template<typename T>
typename uhx::PtrMaker<const T>::Type uhx::TypeParamGluePtr<const T, uhx::OtherType>::haxeToUe(unreal::UIntPtr haxe) {
  return const_cast<typename uhx::PtrMaker<T>::Type>(uhx::TypeParamGluePtr<T, uhx::OtherType>::haxeToUe(haxe));
}
template<typename T>
typename uhx::PtrMaker<const T>::Type uhx::TypeParamGluePtr<const T, uhx::ObjectType>::haxeToUe(unreal::UIntPtr haxe) {
  return const_cast<typename uhx::PtrMaker<T>::Type>(uhx::TypeParamGluePtr<T, uhx::ObjectType>::haxeToUe(haxe));
}
template<typename T>
typename uhx::PtrMaker<const T>::Type uhx::TypeParamGluePtr<const T, uhx::InterfaceType>::haxeToUe(unreal::UIntPtr haxe) {
  return const_cast<typename uhx::PtrMaker<T>::Type>(uhx::TypeParamGluePtr<T, uhx::InterfaceType>::haxeToUe(haxe));
}

template<typename T>
unreal::UIntPtr uhx::TypeParamGluePtr<const T, uhx::EnumType>::ueToHaxeRef(const T& ue) {
  return uhx::TypeParamGluePtr<T>::ueToHaxeRef(const_cast<T&>(ue));
}
template<typename T>
unreal::UIntPtr uhx::TypeParamGluePtr<const T, uhx::OtherType>::ueToHaxeRef(const T& ue) {
  return uhx::TypeParamGluePtr<T>::ueToHaxeRef(const_cast<T&>(ue));
}
template<typename T>
unreal::UIntPtr uhx::TypeParamGluePtr<const T, uhx::ObjectType>::ueToHaxeRef(const T& ue) {
  return uhx::TypeParamGluePtr<T>::ueToHaxeRef(const_cast<T&>(ue));
}
template<typename T>
unreal::UIntPtr uhx::TypeParamGluePtr<const T, uhx::InterfaceType>::ueToHaxeRef(const T& ue) {
  return uhx::TypeParamGluePtr<T>::ueToHaxeRef(const_cast<T&>(ue));
}
