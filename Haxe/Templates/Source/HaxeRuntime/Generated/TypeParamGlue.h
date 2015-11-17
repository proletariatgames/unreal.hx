#pragma once
#define TypeParamGlue_h_included__

#ifndef HAXERUNTIME_API
  #define HAXERUNTIME_API
#endif
#include <cstdio>
#include <utility>

#if __cplusplus > 199711L
  // This is unecessary on the Haxe side
  #include <type_traits>
#endif

// PtrHelper for objects that are stored on the stack
template<typename T>
struct HAXERUNTIME_API PtrHelper_Stack {
  T val;
  PtrHelper_Stack(const T& inVal) : val(inVal) {
  }
#if __cplusplus > 199711L // disable during Haxe compilation
  PtrHelper_Stack(PtrHelper_Stack&& mv) : val(std::move(mv.val)) {
  }
#endif
  PtrHelper_Stack(const PtrHelper_Stack& rhs) : val(rhs.val) {
  }


  T* getPointer() {
    return &val;
  }
};

// PtrHelper for objects that are stored by reference
template<typename T>
struct HAXERUNTIME_API PtrHelper_Ptr {
  T* ptr;
  PtrHelper_Ptr(T* inPtr) : ptr(inPtr) {
  }

#if __cplusplus > 199711L // disable during Haxe compilation
  PtrHelper_Ptr(PtrHelper_Ptr&& mv) : ptr(mv.ptr) {
  }
#endif

  PtrHelper_Ptr(const PtrHelper_Ptr& rhs) : ptr(rhs.ptr) {
  }

  T* getPointer() {
    return ptr;
  }
};

// Default PtrMaker assumes pass-by-ref
template<typename T, typename=void>
struct PtrMaker {
  typedef PtrHelper_Ptr<T> Type;
};

// Pointers always passed by-val
template<typename T>
struct PtrMaker<T*> {
  typedef PtrHelper_Stack<T*> Type;
};

#if __cplusplus > 199711L // disable during Haxe compilation
  // Enums always passed by-val
  template<typename T>
  struct PtrMaker<T, typename std::enable_if<std::is_enum<T>::value>::type> {
    typedef PtrHelper_Stack<T> Type;
  };

  // forward declarations for smart pointers
  enum class ESPMode;
  template<class ObjectType, ESPMode Mode> class TSharedRef;
  template<class ObjectType, ESPMode Mode> class TSharedPtr;
  template<class T, class TWeakObjectPtrBase> struct TWeakObjectPtr;
  template<class T> class TAutoWeakObjectPtr;
  template<class TClass> class TSubclassOf;

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
#endif // !hxcpp

// Basic types are passed by-val
#define BASIC_TYPE(TYPE) \
  template<> \
  struct PtrMaker<TYPE> { \
    typedef PtrHelper_Stack<TYPE> Type; \
  }

BASIC_TYPE(bool);
BASIC_TYPE(::cpp::UInt32);
BASIC_TYPE(::cpp::UInt64);
BASIC_TYPE(::cpp::Int64);
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
