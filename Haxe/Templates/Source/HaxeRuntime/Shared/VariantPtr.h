#pragma once

#include "IntPtr.h"
#include "uhx/Defines.h"
#include "uhx/expose/BaseRuntime.h"

#ifndef __UNREAL__
#ifndef HXCPP_H
#include <hxcpp.h>
#endif
#include "cpp/Pointer.h"
// #include <hx/LessThanEq.h>
#endif

#ifndef __UNREAL__
#ifndef setFixed
#define setFixed(index, name, value) setFixed(index, name, uhx::ConvertHelper::maybeConvert(value))
#endif
#endif


namespace unreal {

class VariantPtr {
private:
  UIntPtr raw;
public:
  #if UHX_FAT_VARIANTPTR
  bool isExternal;

  inline VariantPtr() : raw(0), isExternal(false) { }
private:
  inline VariantPtr(UIntPtr inPtr, bool isExternal) : raw(inPtr), isExternal(isExternal) {}
public:
  #else
  inline VariantPtr() : raw(0) { }
private:
  inline VariantPtr(UIntPtr inPtr, bool isExternal) : raw(inPtr) {}
public:
  #endif

#ifndef __UNREAL__
  inline VariantPtr(const Dynamic& inRHS) {
    #if UHX_FAT_VARIANTPTR
    this->isExternal = false;
    #endif

    if (inRHS.mPtr == 0) {
      this->raw = 0;
    } else {
      void *hnd = inRHS->__GetHandle();
      if (hnd != 0) {
        #if UHX_FAT_VARIANTPTR
        this->isExternal = true;
        this->raw = ((UIntPtr) hnd);
        #else
        this->raw = ~((UIntPtr)hnd);
        #endif
      } else {
        this->raw = (UIntPtr) inRHS.mPtr;
      }
    }
  }

  inline VariantPtr(const cpp::Variant& inVariant) {
    Dynamic inRHS = Dynamic(inVariant);
    #if UHX_FAT_VARIANTPTR
    this->isExternal = false;
    #endif

    if (inRHS.mPtr == 0) {
      this->raw = 0;
    } else {
      void *hnd = inRHS->__GetHandle();
      if (hnd != 0) {
        #if UHX_FAT_VARIANTPTR
        this->isExternal = true;
        this->raw = ((UIntPtr) hnd);
        #else
        this->raw = ~((UIntPtr)hnd);
        #endif
      } else {
        this->raw = (UIntPtr) inRHS.mPtr;
      }
    }
  }

  #if UHX_FAT_VARIANTPTR
  inline VariantPtr(const null& inRHS) : raw(0), isExternal(false) { }
  #else
  inline VariantPtr(const null& inRHS) : raw(0) { }
  #endif

  inline operator Dynamic() const {
    return this->getDynamic();
  }

  inline bool operator ==(const null &other) const {
    return this->raw == 0;
  }

  inline Dynamic getDynamic() const {
    if (this->raw == 0)
    {
      return Dynamic((hx::Object *) nullptr);
    }

    UIntPtr ptr = this->getExternalPointer();
    if (ptr == 0)
    {
      return Dynamic((hx::Object *) raw);
    } else {
      return cpp::Pointer<void>((void *) (ptr));
    }
  }
#else
  #if UHX_FAT_VARIANTPTR
  inline VariantPtr(const std::nullptr_t& inRHS) : raw(0), isExternal(false) { }
  #else
  inline VariantPtr(const std::nullptr_t& inRHS) : raw(0) { }
  #endif


  inline bool operator ==(const std::nullptr_t &other) const {
    return this->raw == 0;
  }
#endif

  inline bool operator ==(const VariantPtr &other) const {
    return this->raw == other.raw;
  }

  // Allow '->' syntax
  inline VariantPtr *operator->() { return this; }

  inline bool isObject() const {
    return !this->isExternalPointer();
  }

  inline bool isExternalPointer() const {
    #if UHX_FAT_VARIANTPTR
    return this->isExternal;
    #else
    return (this->raw & (1LL << 63)) != 0;
    #endif
  }

  inline UIntPtr getExternalPointerUnchecked() const {
    #if UHX_FAT_VARIANTPTR
    return this->raw;
    #else
    return (this->raw == 0) ? 0 : ~this->raw;
    #endif
  }

  inline UIntPtr getGcPointerUnchecked() const {
    return this->raw;
  }

  inline bool isNull() const {
    return this->raw == 0;
  }

  /**
   * If it's an external pointer, returns the pointer itself
   * Otherwise, the Dynamic object is assyned to be an unreal.Wrapper type,
   * and `getPointer()` is called, so the underlying native pointer is returned
   **/
  inline UIntPtr getUnderlyingPointer() const {
    if (this->raw == 0)
    {
      return 0;
    }

    if (this->isExternalPointer())
    {
      return this->getExternalPointerUnchecked();
    } else {
      return uhx::expose::BaseRuntime::wrapperObjectToPointer(this->raw);
    }
  }

  /**
   * Returns the most efficient representation possible of `this` VariantPtr
   * to a UIntPtr. This may mean that in some platforms the result will need to be boxed
   **/
  inline UIntPtr getUIntPtrRepresentation() const {
    #if UHX_FAT_VARIANTPTR
    // By definition, we cannot get a full representation of a VariantPtr into an UIntPtr
    // when using fat variantptrs. So instead we're going to box it
    if (this->isExternalPointer())
    {
      return uhx::expose::BaseRuntime::boxPointer(this->raw);
    } else {
      return this->raw;
    }
    #else
    return this->raw;
    #endif
  }

  inline static VariantPtr fromUIntPtrRepresentation(UIntPtr inPtr)
  {
    #if UHX_FAT_VARIANTPTR
    UIntPtr handle = uhx::expose::BaseRuntime::getPointerHandle(inPtr);
    if (handle != 0)
    {
      return VariantPtr(handle, true);
    } else {
      return VariantPtr(inPtr, false);
    }
    #else
    VariantPtr ptr;
    ptr.raw = inPtr;
    return ptr;
    #endif
  }

  static void badPointerAssert(UIntPtr inPtr)
  {
    // if this happened, it means it's probably not safe to use the
    // most significant bit as an indicator of external pointers on this platform
    // If that's the case, make sure to define UHX_FAT_VARIANTPTR  for this platform
    // (see uhx/Defines.h)
    uhx::expose::BaseRuntime::throwBadPointer(inPtr);
  }

  inline UIntPtr getExternalPointer() const {
    #if UHX_FAT_VARIANTPTR
    return (this->isExternal) ? (this->raw) : 0;
    #else
    return ((this->raw & (1LL << 63)) != 0) ? ~this->raw : 0;
    #endif
  }

  inline static VariantPtr fromExternalPointer(const void *inPtr)
  {
    return fromExternalPointer((UIntPtr) inPtr);
  }

  inline static VariantPtr fromExternalPointer(UIntPtr inPtr)
  {
    if (inPtr == 0)
    {
      return VariantPtr(0, false);
    }
    #if UHX_FAT_VARIANTPTR
    return VariantPtr(inPtr, true);
    #else
    #if UHX_DEBUG
    if ((inPtr & (1LL << 63)) != 0)
    {
      badPointerAssert(inPtr);
    }
    #endif
    return VariantPtr(~inPtr, true);
    #endif
  }

  inline static VariantPtr fromGcPointer(UIntPtr inPtr)
  {
    return VariantPtr(inPtr, false);
  }
};

class VariantPtr_obj {
public:
  inline static VariantPtr fromExternalPointer(UIntPtr inPtr) { return VariantPtr::fromExternalPointer(inPtr); }
  template<typename T>
  inline static VariantPtr fromExternalRawPtr(T *inPtr) { return VariantPtr::fromExternalPointer( (UIntPtr) inPtr ); }
  template<typename T>
  inline static VariantPtr fromExternalRawPtr(const T *inPtr) { return VariantPtr::fromExternalPointer( (UIntPtr) inPtr ); }
#ifndef __UNREAL__
  template<typename T>
  inline static VariantPtr fromExternalHxcppPointer(cpp::Pointer<T> inPtr) { return VariantPtr::fromExternalPointer( (UIntPtr) inPtr ); }

  inline static VariantPtr fromDynamic(Dynamic inDyn) { return VariantPtr( inDyn ); }
#endif
};

}

#ifndef __UNREAL__
namespace hx {
template<> inline void MarkMember< unreal::VariantPtr >(unreal::VariantPtr &outT,hx::MarkContext *__inCtx)
{
  if (outT.isObject()) {
    HX_MARK_OBJECT((hx::Object *) outT.getGcPointerUnchecked());
  }
}

template <>
struct CompareTraits<unreal::VariantPtr>
{
   enum { type = (int)CompareAsInt64 };

   inline static int toInt(unreal::VariantPtr inValue) { return (int) inValue.getGcPointerUnchecked(); }
   inline static double toDouble(unreal::VariantPtr inValue) { return (double) inValue.getGcPointerUnchecked(); }
   inline static cpp::Int64 toInt64(unreal::VariantPtr inValue) { return (cpp::Int64) inValue.getGcPointerUnchecked(); }
   inline static String toString(unreal::VariantPtr inValue) { return inValue.getDynamic(); }
   inline static hx::Object *toObject(unreal::VariantPtr inValue) { return inValue.getDynamic().mPtr; }

   inline static int getDynamicCompareType(unreal::VariantPtr) { return type; }
   inline static bool isNull(const unreal::VariantPtr &inValue) { return inValue.isNull(); }
};

template<>
inline EnumBase_obj *EnumBase_obj::_hx_init(int inIndex,const unreal::VariantPtr &inValue)
{
   _hx_getFixed()[inIndex] = inValue.getDynamic();
   return this;
}
}

template<>
inline unreal::VariantPtr Dynamic::StaticCast() const
{
  // Simple reinterpret_cast
  return unreal::VariantPtr_obj::fromDynamic(*this);
}


#ifndef __UNREAL__

namespace uhx {

struct ConvertHelper {
  template<typename T>
  static inline T maybeConvert(T val) {
    return val;
  }

  static inline ::cpp::Variant maybeConvert(::unreal::VariantPtr v) {
    return ::cpp::Variant(v.getDynamic());
  }
};

}
#endif

#endif