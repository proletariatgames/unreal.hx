#pragma once
#include <hxcpp.h>
#include "IntPtr.h"
#include "VariantPtr.h"

#include "uhx/StructInfo.h"
#include "uhx/StructInfo_UE.h"
#include "unreal/helpers/HxcppRuntime.h"

// #include "Containers/ContainerAllocationPolicies.h"
#include "HAL/Platform.h"

#include <type_traits>
#include <utility>

namespace uhx {

enum StructKind {
  SKNormal,
  SKPOD,
  SKAligned
};

template<class T, bool isAbstract = std::is_abstract<T>::value>
struct TStructKind { enum { Value = uhx::SKNormal }; };

template<class T>
struct TStructKind<T, true> { enum { Value = TIsPODType<T>::Value ? uhx::SKPOD : uhx::SKNormal }; };

template<class T>
struct TStructKind<T, false> { enum { Value = UHX_ALIGNOF(T) > sizeof(void*) ? uhx::SKAligned : (TIsPODType<T>::Value ? uhx::SKPOD : uhx::SKNormal) }; };

}

namespace uhx {

template<class T, int kind = TStructKind<T>::Value>
struct StructHelper {
  /**
   * Gets the actual pointer, given a VariantPtr
   **/
  static T *getPointer(unreal::VariantPtr inPtr);

  /**
   * Creates a Haxe wrapper object that contains a copy of the original value
   **/
  static unreal::VariantPtr fromStruct(const T& inOrigin);

  /**
   * Creates a Haxe wrapper object that moves the original value
   **/
  static unreal::VariantPtr fromStruct(T&& inOrigin);

  /**
   * Creates a Haxe wrapper object from the constructor
   **/
  template<typename... Args>
  static unreal::VariantPtr create(Args... params);

  /**
   * Creates a pointer wrapper from the original pointer
   **/
  static unreal::VariantPtr fromPointer(T *inOrigin);
};

template<typename T>
struct TemplateHelper {
  inline static T *getPointer(unreal::VariantPtr inPtr) {
    if ((inPtr.raw & 1) == 0) {
      if (inPtr.raw == 0) {
        return nullptr;
      }

      static unreal::UIntPtr offset = unreal::helpers::HxcppRuntime::getTemplateOffset();
      T **ret = (T **) (inPtr.raw + offset);
      return *ret;
    } else {
      unreal::helpers::HxcppRuntime::throwString("Invalid templated pointer");
      return nullptr;
    }
  }

  inline static unreal::VariantPtr fromStruct(const T& inOrigin) {
    static unreal::UIntPtr offset = unreal::helpers::HxcppRuntime::getTemplateOffset();
    unreal::VariantPtr ret = unreal::helpers::HxcppRuntime::createInlineTemplateWrapper((int) sizeof(T), (unreal::UIntPtr) TTemplatedData<T>::getInfo());
    T *ptr = *((T**) (ret.raw + offset));
    new(ptr) T(inOrigin);
    return ret;
  }

  inline static unreal::VariantPtr fromStruct(T&& inOrigin) {
    static unreal::UIntPtr offset = unreal::helpers::HxcppRuntime::getTemplateOffset();
    unreal::VariantPtr ret = unreal::helpers::HxcppRuntime::createInlineTemplateWrapper((int) sizeof(T), (unreal::UIntPtr) TTemplatedData<T>::getInfo());
    T *ptr = *((T**) (ret.raw + offset));
    new(ptr) T(inOrigin);
    return ret;
  }

  template<typename... Args>
  inline static unreal::VariantPtr create(Args... params) {
    static unreal::UIntPtr offset = unreal::helpers::HxcppRuntime::getTemplateOffset();
    unreal::VariantPtr ret = unreal::helpers::HxcppRuntime::createInlineTemplateWrapper((int) sizeof(T), (unreal::UIntPtr) TTemplatedData<T>::getInfo());
    void *ptr = *((void**) (ret.raw + offset));
    new(ptr) T(params...);
    return ret;
  }

  inline static unreal::VariantPtr fromPointer(T *inOrigin) {
    return unreal::helpers::HxcppRuntime::createPointerTemplateWrapper((unreal::UIntPtr) inOrigin, (unreal::UIntPtr) TTemplatedData<T>::getInfo(), 0);
  }
};

template<bool isPod>
struct PointerOffset {
  static unreal::UIntPtr getVariantOffset();
};

template<>
struct PointerOffset<false> {
  inline static unreal::UIntPtr getVariantOffset() {
    static unreal::IntPtr offset = unreal::helpers::HxcppRuntime::getInlineWrapperOffset();
    return offset;
  }
};

template<>
struct PointerOffset<true> {
  inline static unreal::UIntPtr getVariantOffset() {
    static unreal::IntPtr offset = unreal::helpers::HxcppRuntime::getInlinePodWrapperOffset();
    return offset;
  }
};

template<typename T>
struct StructHelper<T, uhx::SKNormal> {
  inline static T *getPointer(unreal::VariantPtr inPtr) {
    return (inPtr.raw & 1) == 1 ? ((T *) (inPtr.raw - 1)) : ((inPtr.raw == 0) ? nullptr : (T *) (inPtr.raw + PointerOffset<false>::getVariantOffset()));
  }

  inline static unreal::VariantPtr fromStruct(const T& inOrigin) {
    unreal::VariantPtr ret = unreal::helpers::HxcppRuntime::createInlineWrapper((int) sizeof(T), (unreal::UIntPtr) TStructData<T>::getInfo());
    T *ptr = (T*) (ret.raw + PointerOffset<false>::getVariantOffset());
    new(ptr) T(inOrigin);
    return ret;
  }

  inline static unreal::VariantPtr fromStruct(T&& inOrigin) {
    unreal::VariantPtr ret = unreal::helpers::HxcppRuntime::createInlineWrapper((int) sizeof(T), (unreal::UIntPtr) TStructData<T>::getInfo());
    T *ptr = (T*) (ret.raw + PointerOffset<false>::getVariantOffset());
    new(ptr) T(inOrigin);
    return ret;
  }

  template<typename... Args>
  inline static unreal::VariantPtr create(Args... params) {
    unreal::VariantPtr ret = unreal::helpers::HxcppRuntime::createInlineWrapper((int) sizeof(T), (unreal::UIntPtr) TStructData<T>::getInfo());
    void *ptr = (void*) (ret.raw + PointerOffset<false>::getVariantOffset());
    new(ptr) T(params...);
    return ret;
  }

  inline static unreal::VariantPtr fromPointer(T *inOrigin) {
    // TODO - check inOrigin & 1 == 0
    return unreal::VariantPtr(inOrigin);
  }
};

template<typename T>
struct StructHelper<T, uhx::SKPOD> {
  inline static T *getPointer(unreal::VariantPtr inPtr) {
    return (inPtr.raw & 1) == 1 ? ((T *) (inPtr.raw - 1)) : ((inPtr.raw == 0) ? nullptr : (T *) (inPtr.raw + PointerOffset<true>::getVariantOffset()));
  }

  inline static unreal::VariantPtr fromStruct(const T& inOrigin) {
    unreal::VariantPtr ret = unreal::helpers::HxcppRuntime::createInlinePodWrapper((int) sizeof(T), (unreal::UIntPtr) TStructData<T>::getInfo());
    T *ptr = (T*) (ret.raw + PointerOffset<true>::getVariantOffset());
    new(ptr) T(inOrigin);
    return ret;
  }

  inline static unreal::VariantPtr fromStruct(T&& inOrigin) {
    unreal::VariantPtr ret = unreal::helpers::HxcppRuntime::createInlinePodWrapper((int) sizeof(T), (unreal::UIntPtr) TStructData<T>::getInfo());
    T *ptr = (T*) (ret.raw + PointerOffset<true>::getVariantOffset());
    new(ptr) T(inOrigin);
    return ret;
  }

  template<typename... Args>
  inline static unreal::VariantPtr create(Args... params) {
    unreal::VariantPtr ret = unreal::helpers::HxcppRuntime::createInlinePodWrapper((int) sizeof(T), (unreal::UIntPtr) TStructData<T>::getInfo());
    void *ptr = (void*) (ret.raw + PointerOffset<true>::getVariantOffset());
    new(ptr) T(params...);
    return ret;
  }

  inline static unreal::VariantPtr fromPointer(T *inOrigin) {
    // TODO - check inOrigin & 1 == 0
    return unreal::VariantPtr(inOrigin);
  }
};

template<typename T>
struct StructHelper<T, uhx::SKAligned> {
  inline static T *getPointer(unreal::VariantPtr inPtr) {
    return (inPtr.raw & 1) == 1 ? ((T *) (inPtr.raw - 1)) : ((inPtr.raw == 0) ? nullptr : (T *) ( align(inPtr.raw + getOffset()) ));
  }

  inline static unreal::VariantPtr fromStruct(const T& inOrigin) {
    unreal::VariantPtr ret = unreal::helpers::HxcppRuntime::createAlignedInlineWrapper((int) sizeof(T), (unreal::UIntPtr) TStructData<T>::getInfo());
    T *ptr = (T*) align(ret.raw + getOffset());
    new(ptr) T(inOrigin);
    return ret;
  }

  inline static unreal::VariantPtr fromStruct(T&& inOrigin) {
    unreal::VariantPtr ret = unreal::helpers::HxcppRuntime::createAlignedInlineWrapper((int) sizeof(T), (unreal::UIntPtr) TStructData<T>::getInfo());
    T *ptr = (T*) align(ret.raw + getOffset());
    new(ptr) T(inOrigin);
    return ret;
  }

  template<typename... Args>
  inline static unreal::VariantPtr create(Args... params) {
    unreal::VariantPtr ret = unreal::helpers::HxcppRuntime::createAlignedInlineWrapper((int) sizeof(T), (unreal::UIntPtr) TStructData<T>::getInfo());
    void *ptr = (void*) align(ret.raw + getOffset());
    new(ptr) T(params...);
    return ret;
  }

  inline static unreal::VariantPtr fromPointer(T *inOrigin) {
    // TODO - check inOrigin & 1 == 0
    return unreal::VariantPtr(inOrigin);
  }
private:

  inline static unreal::UIntPtr align(unreal::UIntPtr ptr) {
    return (ptr + (UHX_ALIGNOF(T) - 1)) & (~(UHX_ALIGNOF(T) - 1));
  }

  inline static unreal::UIntPtr getOffset() {
    static unreal::IntPtr offset = unreal::helpers::HxcppRuntime::getInlineWrapperOffset();
    return offset;
  }

};

}
