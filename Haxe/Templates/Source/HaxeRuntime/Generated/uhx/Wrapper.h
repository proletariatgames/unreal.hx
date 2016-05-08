#pragma once
#include <hxcpp.h>
#include "IntPtr.h"
#include "VariantPtr.h"
#include "uhx/StructInfo.h"
#include "uhx/StructInfo_UE.h"
#include "unreal/helpers/HxcppRuntime.h"
#include <utility>

namespace uhx {

template<class T, bool isPod = TIsPODType<T>::Value>
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
   * Creates a pointer wrapper from the original pointer
   **/
  static unreal::VariantPtr fromPointer(T *inOrigin);
};

template<typename T>
struct TemplateHelper {
  inline static T *getPointer(unreal::VariantPtr inPtr) {
    if ((inPtr.raw & 1) == 0) {
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
    T *ptr = (T*) (ret.raw + offset);
    new(ptr) T(inOrigin);
    return ret;
  }

  inline static unreal::VariantPtr fromStruct(T&& inOrigin) {
    static unreal::UIntPtr offset = unreal::helpers::HxcppRuntime::getTemplateOffset();
    unreal::VariantPtr ret = unreal::helpers::HxcppRuntime::createInlineTemplateWrapper((int) sizeof(T), (unreal::UIntPtr) TTemplatedData<T>::getInfo());
    T *ptr = (T*) (ret.raw + offset);
    new(ptr) T(inOrigin);
    return ret;
  }

  inline static unreal::VariantPtr fromPointer(T *inOrigin) {
    return unreal::helpers::HxcppRuntime::createPointerTemplateWrapper((unreal::UIntPtr) inOrigin, (unreal::UIntPtr) TTemplatedData<T>::getInfo());
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
struct StructHelper<T, false> {
  inline static T *getPointer(unreal::VariantPtr inPtr) {
    return (inPtr.raw & 1) == 1 ? ((T *) (inPtr.raw - 1)) : ((T *) (inPtr.raw + PointerOffset<false>::getVariantOffset()));
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

  inline static unreal::VariantPtr fromPointer(T *inOrigin) {
    // TODO - check inOrigin & 1 == 0
    return unreal::VariantPtr(inOrigin);
  }
};

template<typename T>
struct StructHelper<T, true> {
  inline static T *getPointer(unreal::VariantPtr inPtr) {
    return (inPtr.raw & 1) == 1 ? ((T *) (inPtr.raw - 1)) : ((T *) (inPtr.raw + PointerOffset<true>::getVariantOffset()));
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

  inline static unreal::VariantPtr fromPointer(T *inOrigin) {
    // TODO - check inOrigin & 1 == 0
    return unreal::VariantPtr(inOrigin);
  }
};

}
