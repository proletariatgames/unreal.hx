#pragma once

#include "IntPtr.h"

#ifndef __UNREAL__
#ifndef HXCPP_H
#include <hxcpp.h>
#endif
#include <cpp/Pointer.h>
// #include <hx/LessThanEq.h>
#endif


namespace unreal {

class VariantPtr {
public:
  UIntPtr raw;

  inline VariantPtr() : raw(0) { }
  inline VariantPtr(const void *inRHS) : raw( inRHS == 0 ? 0 : (((UIntPtr) inRHS) + 1) ) { }
  inline VariantPtr(void *inRHS) : raw( inRHS == 0 ? 0 : (((UIntPtr) inRHS) + 1) ) { }
  inline VariantPtr(IntPtr inRHS) : raw((UIntPtr) inRHS) { }
  inline VariantPtr(UIntPtr inRHS) : raw(inRHS) { }
  inline VariantPtr(int inRHS) : raw((UIntPtr) inRHS) { }
#ifndef __UNREAL__
  inline VariantPtr(const Dynamic& inRHS) {
    if (inRHS.mPtr == 0) {
      this->raw = 0;
    } else {
      void *hnd = inRHS->__GetHandle();
      if (hnd != 0) {
        this->raw = ((UIntPtr) hnd) + 1;
      } else {
        this->raw = (UIntPtr) inRHS.mPtr;
      }
    }
  }

  inline VariantPtr(const cpp::Variant& inVariant) {
    Dynamic inRHS = Dynamic(inVariant);
    if (inRHS.mPtr == 0) {
      this->raw = 0;
    } else {
      void *hnd = inRHS->__GetHandle();
      if (hnd != 0) {
        this->raw = ((UIntPtr) hnd) + 1;
      } else {
        this->raw = (UIntPtr) inRHS.mPtr;
      }
    }
  }

  inline VariantPtr(const null& inRHS) : raw(0) { }

  inline operator Dynamic() const {
    return this->getDynamic();
  }

  inline bool operator ==(const VariantPtr &other) const {
    return this->raw == other.raw;
  }

  inline bool operator ==(const null &other) const {
    return this->raw == 0;
  }

  inline Dynamic getDynamic() const {
    if ((raw & 1) == 0) {
      return Dynamic((hx::Object *)raw);
    } else {
      return cpp::Pointer<void>((void *) (raw - 1));
    }
  }
#else
  inline VariantPtr(const std::nullptr_t& inRHS) : raw(0) { }
#endif

  // Allow '->' syntax
  inline VariantPtr *operator->() { return this; }

  inline IntPtr getIntPtr() const { return (IntPtr) raw; }
  inline UIntPtr getUIntPtr() const { return (UIntPtr) raw; }

  inline bool isObject() const { return (raw & 1) == 0; }

  // inline operator UIntPtr() { return raw; }

  inline void *toPointer() const {
    return ((raw & 1) == 1) ? ( (void *) (raw - 1) ) : haxeObjToPointer(raw);
  }

  static void *haxeObjToPointer(UIntPtr inRaw) {
    return 0;
  }
};

class VariantPtr_obj {
public:
  inline static VariantPtr fromIntPtr(IntPtr inPtr) { return VariantPtr(inPtr); }
  inline static VariantPtr fromUIntPtr(UIntPtr inPtr) { return VariantPtr(inPtr); }
  inline static VariantPtr fromRawPtr(void *inPtr) { return VariantPtr( (void *) inPtr ); }
  inline static VariantPtr fromRawPtr(const void *inPtr) { return VariantPtr( (void *) inPtr ); }
  template<typename T>
  inline static VariantPtr fromRawPtr(T *inPtr) { return VariantPtr( (void *) inPtr ); }
  template<typename T>
  inline static VariantPtr fromRawPtr(const T *inPtr) { return VariantPtr( (void *) inPtr ); }
#ifndef __UNREAL__
  template<typename T>
  inline static VariantPtr fromPointer(cpp::Pointer<T> inPtr) { return VariantPtr( (void *) inPtr ); }

  inline static VariantPtr fromDynamic(Dynamic inDyn) { return VariantPtr( inDyn ); }
#endif
};

}

#ifndef __UNREAL__
namespace hx {
template<> inline void MarkMember< unreal::VariantPtr >(unreal::VariantPtr &outT,hx::MarkContext *__inCtx)
{
  if ((outT.raw & 1) == 0) {
    HX_MARK_OBJECT((hx::Object *) outT.raw);
  }
}

template <> 
struct CompareTraits<unreal::VariantPtr>
{
   enum { type = (int)CompareAsInt64 };

   inline static int toInt(unreal::VariantPtr inValue) { return (int) inValue.raw; }
   inline static double toDouble(unreal::VariantPtr inValue) { return (double) inValue.raw; }
   inline static cpp::Int64 toInt64(unreal::VariantPtr inValue) { return (cpp::Int64) inValue.raw; }
   inline static String toString(unreal::VariantPtr inValue) { return inValue.getDynamic(); }
   inline static hx::Object *toObject(unreal::VariantPtr inValue) { return inValue.getDynamic().mPtr; }

   inline static int getDynamicCompareType(unreal::VariantPtr) { return type; }
   inline static bool isNull(const unreal::VariantPtr &inValue) { return inValue.raw == 0; }
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

#endif
