#pragma once

#include <type_traits>
#ifndef HAXERUNTIME_API
  #define HAXERUNTIME_API
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

//////////////////////////////////
// Forward declarations
template<typename T> struct HAXERUNTIME_API PtrHelper_Stack;
template<typename T> struct HAXERUNTIME_API PtrHelper_Ptr;
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
