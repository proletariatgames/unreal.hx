#pragma once
#include <hxcpp.h>
#include "uhx/Defines.h"
#include "IntPtr.h"
#include "VariantPtr.h"

#include "uhx/StructInfo.h"
#include "uhx/StructInfo_UE.h"
#include "uhx/expose/HxcppRuntime.h"

// #include "Containers/ContainerAllocationPolicies.h"
#include "HAL/Platform.h"

#include <type_traits>
#include <utility>

// these are special cases for the FVector_NetQuantize* since they are subclasses of the POD type FVector
// C++ sees them as non-POD because they have a parent, but they don't have anything that would
// benefit from being a SKNormal class
struct FVector_NetQuantize;
struct FVector_NetQuantize10;
struct FVector_NetQuantize100;
struct FVector_NetQuantizeNormal;

namespace uhx {

enum StructKind {
  SKNormal,
  SKPOD,
  SKAligned
};

template<class T, bool isAbstract = std::is_abstract<T>::value>
struct TStructKind { enum { Value = uhx::SKNormal }; };

template<class T>
struct TStructKind<T, true> { enum { Value = (!UHX_IGNORE_POD && TIsPODType<T>::Value) ? uhx::SKPOD : uhx::SKNormal }; };

template<class T>
struct TStructKind<T, false> { enum { Value = UHX_ALIGNOF(T) > sizeof(void*) ? uhx::SKAligned : ((!UHX_IGNORE_POD && TIsPODType<T>::Value) ? uhx::SKPOD : uhx::SKNormal) }; };

#if !UHX_IGNORE_POD
#define OVERRIDE_KIND(T, Kind) \
  template<> \
  struct TStructKind<T, false> { enum { Value = Kind }; };

OVERRIDE_KIND(struct FVector_NetQuantize, uhx::SKPOD);
OVERRIDE_KIND(struct FVector_NetQuantize10, uhx::SKPOD);
OVERRIDE_KIND(struct FVector_NetQuantize100, uhx::SKPOD);
OVERRIDE_KIND(struct FVector_NetQuantizeNormal, uhx::SKPOD);

#undef OVERRIDE_KIND
#endif
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

  /**
   * Creates an empty wrapper
   **/
  static unreal::VariantPtr emptyWrapper();
};

template<typename T>
struct TemplateHelper {
  inline static T *getPointer(unreal::VariantPtr inPtr) {
    if (inPtr.isObject()) {
      if (inPtr.isNull()) {
        return nullptr;
      }

      static unreal::UIntPtr offset = uhx::expose::HxcppRuntime::getTemplateOffset();
      T **ret = (T **) (inPtr.getGcPointerUnchecked() + offset);
      return *ret;
    } else {
      uhx::expose::HxcppRuntime::throwString("Invalid templated pointer");
      return nullptr;
    }
  }

  inline static unreal::VariantPtr fromStruct(const T& inOrigin) {
    static unreal::UIntPtr offset = uhx::expose::HxcppRuntime::getTemplateOffset();
    unreal::VariantPtr ret = uhx::expose::HxcppRuntime::createInlineTemplateWrapper((int) sizeof(T), (unreal::UIntPtr) TTemplatedData<T>::getInfo());
    T *ptr = *((T**) (ret.getGcPointerUnchecked() + offset));
    new(ptr) T(inOrigin);
    return ret;
  }

  inline static unreal::VariantPtr fromStruct(T&& inOrigin) {
    static unreal::UIntPtr offset = uhx::expose::HxcppRuntime::getTemplateOffset();
    unreal::VariantPtr ret = uhx::expose::HxcppRuntime::createInlineTemplateWrapper((int) sizeof(T), (unreal::UIntPtr) TTemplatedData<T>::getInfo());
    T *ptr = *((T**) (ret.getGcPointerUnchecked() + offset));
    new(ptr) T(inOrigin);
    return ret;
  }

  template<typename... Args>
  inline static unreal::VariantPtr create(Args... params) {
    static unreal::UIntPtr offset = uhx::expose::HxcppRuntime::getTemplateOffset();
    unreal::VariantPtr ret = uhx::expose::HxcppRuntime::createInlineTemplateWrapper((int) sizeof(T), (unreal::UIntPtr) TTemplatedData<T>::getInfo());
    void *ptr = *((void**) (ret.getGcPointerUnchecked() + offset));
    new(ptr) T(params...);
    return ret;
  }

  inline static unreal::VariantPtr fromPointer(T *inOrigin) {
    return uhx::expose::HxcppRuntime::createPointerTemplateWrapper((unreal::UIntPtr) inOrigin, (unreal::UIntPtr) TTemplatedData<T>::getInfo(), 0);
  }

  inline static unreal::VariantPtr emptyWrapper() {
    return uhx::expose::HxcppRuntime::createInlineTemplateWrapper((int) sizeof(T), (unreal::UIntPtr) TTemplatedData<T>::getInfo());
  }
};

template<bool isPod>
struct PointerOffset {
  static unreal::UIntPtr getVariantOffset();
};

template<>
struct PointerOffset<false> {
  inline static unreal::UIntPtr getVariantOffset() {
    static unreal::IntPtr offset = uhx::expose::HxcppRuntime::getInlineWrapperOffset();
    return offset;
  }
};

template<>
struct PointerOffset<true> {
  inline static unreal::UIntPtr getVariantOffset() {
    static unreal::IntPtr offset = uhx::expose::HxcppRuntime::getInlinePodWrapperOffset();
    return offset;
  }
};

template<typename T>
struct StructHelper<T, uhx::SKNormal> {
  inline static T *getPointer(unreal::VariantPtr inPtr) {
    return (inPtr.isExternalPointer()) ? ((T *) inPtr.getExternalPointerUnchecked()) : (inPtr.isNull() ? nullptr : (T *) align(inPtr.getGcPointerUnchecked() + PointerOffset<false>::getVariantOffset()) );
  }

  inline static unreal::VariantPtr fromStruct(const T& inOrigin) {
    unreal::VariantPtr ret = uhx::expose::HxcppRuntime::createInlineWrapper((int) sizeof(T), (unreal::UIntPtr) TStructData<T>::getInfo());
    T *ptr = (T*) align(ret.getGcPointerUnchecked() + PointerOffset<false>::getVariantOffset());
    new(ptr) T(inOrigin);
    return ret;
  }

  inline static unreal::VariantPtr fromStruct(T&& inOrigin) {
    unreal::VariantPtr ret = uhx::expose::HxcppRuntime::createInlineWrapper((int) sizeof(T), (unreal::UIntPtr) TStructData<T>::getInfo());
    T *ptr = (T*) align(ret.getGcPointerUnchecked() + PointerOffset<false>::getVariantOffset());
    new(ptr) T(inOrigin);
    return ret;
  }

  template<typename... Args>
  inline static unreal::VariantPtr create(Args... params) {
    unreal::VariantPtr ret = uhx::expose::HxcppRuntime::createInlineWrapper((int) sizeof(T), (unreal::UIntPtr) TStructData<T>::getInfo());
    void *ptr = (void*) align(ret.getGcPointerUnchecked() + PointerOffset<false>::getVariantOffset());
    new(ptr) T(params...);
    return ret;
  }

  inline static unreal::VariantPtr fromPointer(T *inOrigin) {
    return unreal::VariantPtr::fromExternalPointer(inOrigin);
  }

  inline static unreal::VariantPtr emptyWrapper() {
    return uhx::expose::HxcppRuntime::createInlineWrapper((int) sizeof(T), (unreal::UIntPtr) TStructData<T>::getInfo());
  }

private:
  inline static unreal::UIntPtr align(unreal::UIntPtr ptr) {
    return (ptr + (sizeof(void*) - 1)) & (~(sizeof(void*) - 1));
  }
};

template<typename T>
struct StructHelper<T, uhx::SKPOD> {
  inline static T *getPointer(unreal::VariantPtr inPtr) {
    return (inPtr.isExternalPointer()) ? ((T *)inPtr.getExternalPointerUnchecked()) : (inPtr.isNull() ? nullptr : (T *) align(inPtr.getGcPointerUnchecked() + PointerOffset<true>::getVariantOffset()) );
  }

  inline static unreal::VariantPtr fromStruct(const T& inOrigin) {
    unreal::VariantPtr ret = uhx::expose::HxcppRuntime::createInlinePodWrapper((int) sizeof(T), (unreal::UIntPtr) TStructData<T>::getInfo());
    T *ptr = (T*) align(ret.getGcPointerUnchecked() + PointerOffset<true>::getVariantOffset());
    new(ptr) T(inOrigin);
    return ret;
  }

  inline static unreal::VariantPtr fromStruct(T&& inOrigin) {
    unreal::VariantPtr ret = uhx::expose::HxcppRuntime::createInlinePodWrapper((int) sizeof(T), (unreal::UIntPtr) TStructData<T>::getInfo());
    T *ptr = (T*) align(ret.getGcPointerUnchecked() + PointerOffset<true>::getVariantOffset());
    new(ptr) T(inOrigin);
    return ret;
  }

  template<typename... Args>
  inline static unreal::VariantPtr create(Args... params) {
    unreal::VariantPtr ret = uhx::expose::HxcppRuntime::createInlinePodWrapper((int) sizeof(T), (unreal::UIntPtr) TStructData<T>::getInfo());
    void *ptr = (void*) align(ret.getGcPointerUnchecked() + PointerOffset<true>::getVariantOffset());
    new(ptr) T(params...);
    return ret;
  }

  inline static unreal::VariantPtr fromPointer(T *inOrigin) {
    return unreal::VariantPtr::fromExternalPointer(inOrigin);
  }

  inline static unreal::VariantPtr emptyWrapper() {
    return uhx::expose::HxcppRuntime::createInlinePodWrapper((int) sizeof(T), (unreal::UIntPtr) TStructData<T>::getInfo());
  }

private:
  inline static unreal::UIntPtr align(unreal::UIntPtr ptr) {
    return (ptr + (sizeof(void*) - 1)) & (~(sizeof(void*) - 1));
  }
};

template<typename T>
struct StructHelper<T, uhx::SKAligned> {
  inline static T *getPointer(unreal::VariantPtr inPtr) {
    return (inPtr.isExternalPointer()) ? ((T *) inPtr.getExternalPointerUnchecked()) : (inPtr.isNull() ? nullptr : (T *) ( align(inPtr.getGcPointerUnchecked() + getOffset()) ) );
  }

  inline static unreal::VariantPtr fromStruct(const T& inOrigin) {
    unreal::VariantPtr ret = uhx::expose::HxcppRuntime::createAlignedInlineWrapper((int) sizeof(T), (unreal::UIntPtr) TStructData<T>::getInfo());
    T *ptr = (T*) align(ret.getGcPointerUnchecked() + getOffset());
    new(ptr) T(inOrigin);
    return ret;
  }

  inline static unreal::VariantPtr fromStruct(T&& inOrigin) {
    unreal::VariantPtr ret = uhx::expose::HxcppRuntime::createAlignedInlineWrapper((int) sizeof(T), (unreal::UIntPtr) TStructData<T>::getInfo());
    T *ptr = (T*) align(ret.getGcPointerUnchecked() + getOffset());
    new(ptr) T(inOrigin);
    return ret;
  }

  template<typename... Args>
  inline static unreal::VariantPtr create(Args... params) {
    unreal::VariantPtr ret = uhx::expose::HxcppRuntime::createAlignedInlineWrapper((int) sizeof(T), (unreal::UIntPtr) TStructData<T>::getInfo());
    void *ptr = (void*) align(ret.getGcPointerUnchecked() + getOffset());
    new(ptr) T(params...);
    return ret;
  }

  inline static unreal::VariantPtr fromPointer(T *inOrigin) {
    return unreal::VariantPtr::fromExternalPointer(inOrigin);
  }

  inline static unreal::VariantPtr emptyWrapper() {
    return uhx::expose::HxcppRuntime::createAlignedInlineWrapper((int) sizeof(T), (unreal::UIntPtr) TStructData<T>::getInfo());
  }
private:

  inline static unreal::UIntPtr align(unreal::UIntPtr ptr) {
    return (ptr + (UHX_ALIGNOF(T) - 1)) & (~(UHX_ALIGNOF(T) - 1));
  }

  inline static unreal::UIntPtr getOffset() {
    static unreal::IntPtr offset = uhx::expose::HxcppRuntime::getInlineWrapperOffset();
    return offset;
  }

};

}
