#pragma once
#include <hxcpp.h>
#include "IntPtr.h"
#include "VariantPtr.h"
#include "StructInfo.h"
#include "StructInfo_UE.h"
#include "unreal/helpers/HxcppRuntime.h"
#include <utility>

namespace uhx {

template<typename T, int Kind=TImplementationKind<T>::Value>
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

template<int Kind>
struct PointerOffset {
  static unreal::UIntPtr getVariantOffset();
};

template<>
struct PointerOffset<uhx::NormalType> {
  inline static unreal::UIntPtr getVariantOffset() {
    static unreal::IntPtr offset = unreal::helpers::HxcppRuntime::getInlineWrapperOffset();
    return offset;
  }
};

template<>
struct PointerOffset<uhx::PODType> {
  inline static unreal::UIntPtr getVariantOffset() {
    static unreal::IntPtr offset = unreal::helpers::HxcppRuntime::getInlinePodWrapperOffset();
    return offset;
  }
};

template<typename T>
struct StructHelper<T, uhx::NormalType> {
  inline static T *getPointer(unreal::VariantPtr inPtr) {
    return (inPtr.raw & 1) == 1 ? ((T *) (inPtr.raw - 1)) : ((T *) (inPtr.raw + PointerOffset<uhx::NormalType>::getVariantOffset()));
  }

  inline static unreal::VariantPtr fromStruct(const T& inOrigin) {
    unreal::VariantPtr ret = unreal::helpers::HxcppRuntime::createInlineWrapper((int) sizeof(T), (unreal::UIntPtr) TStructData<T>::getInfo());
    T *ptr = (T*) (ret.raw + PointerOffset<uhx::NormalType>::getVariantOffset());
    new(ptr) T(inOrigin);
    // *ptr = inOrigin;
    return ret;
  }

  inline static unreal::VariantPtr fromStruct(T&& inOrigin) {
    unreal::VariantPtr ret = unreal::helpers::HxcppRuntime::createInlineWrapper((int) sizeof(T), (unreal::UIntPtr) TStructData<T>::getInfo());
    T *ptr = (T*) (ret.raw + PointerOffset<uhx::NormalType>::getVariantOffset());
    new(ptr) T(inOrigin);
    // *ptr = inOrigin;
    return ret;
  }

  inline static unreal::VariantPtr fromPointer(T *inOrigin) {
    // TODO - check inOrigin & 1 == 0
    return unreal::VariantPtr(inOrigin);
  }
};

template<typename T>
struct StructHelper<T, uhx::PODType> {
  inline static T *getPointer(unreal::VariantPtr inPtr) {
    return (inPtr.raw & 1) == 1 ? ((T *) (inPtr.raw - 1)) : ((T *) (inPtr.raw + PointerOffset<uhx::PODType>::getVariantOffset()));
  }

  inline static unreal::VariantPtr fromStruct(const T& inOrigin) {
    unreal::VariantPtr ret = unreal::helpers::HxcppRuntime::createInlinePodWrapper((int) sizeof(T), (unreal::UIntPtr) TStructData<T>::getInfo());
    T *ptr = (T*) (ret.raw + PointerOffset<uhx::PODType>::getVariantOffset());
    new(ptr) T(inOrigin);
    // *ptr = inOrigin;
    return ret;
  }

  inline static unreal::VariantPtr fromStruct(T&& inOrigin) {
    unreal::VariantPtr ret = unreal::helpers::HxcppRuntime::createInlinePodWrapper((int) sizeof(T), (unreal::UIntPtr) TStructData<T>::getInfo());
    T *ptr = (T*) (ret.raw + PointerOffset<uhx::PODType>::getVariantOffset());
    new(ptr) T(inOrigin);
    // *ptr = inOrigin;
    return ret;
  }

  inline static unreal::VariantPtr fromPointer(T *inOrigin) {
    // TODO - check inOrigin & 1 == 0
    return unreal::VariantPtr(inOrigin);
  }
};

template<typename T>
struct StructHelper<T, uhx::Templated> {
  inline static T *getPointer(unreal::VariantPtr inPtr) {
    if ((inPtr.raw & 1) == 0) {
      static unreal::UIntPtr offset = unreal::helpers::HxcppRuntime::getTemplateOffset();
      T **ret = (T **) inPtr.raw + offset;
      return *ret;
    } else {
      unreal::helpers::HxcppRuntime::throwString("Invalid templated pointer");
      return nullptr;
    }
  }

  inline static unreal::VariantPtr fromStruct(const T& inOrigin) {
    unreal::VariantPtr ret = unreal::helpers::HxcppRuntime::createInlineTemplateWrapper((int) sizeof(T), (unreal::UIntPtr) TStructData<T>::getInfo());
    T *ptr = (T*) (ret.raw + PointerOffset<uhx::Templated>::getVariantOffset());
    new(ptr) T(inOrigin);
    // *ptr = inOrigin;
    return ret;
  }

  inline static unreal::VariantPtr fromStruct(T&& inOrigin) {
    unreal::VariantPtr ret = unreal::helpers::HxcppRuntime::createInlineTemplateWrapper((int) sizeof(T), (unreal::UIntPtr) TStructData<T>::getInfo());
    T *ptr = (T*) (ret.raw + PointerOffset<uhx::Templated>::getVariantOffset());
    new(ptr) T(inOrigin);
    // *ptr = inOrigin;
    return ret;
  }

  inline static unreal::VariantPtr fromPointer(T *inOrigin) {
    return unreal::helpers::HxcppRuntime::createPointerTemplateWrapper((unreal::UIntPtr) inOrigin, (unreal::UIntPtr) TStructData<T>::getInfo());
  }
};

}
