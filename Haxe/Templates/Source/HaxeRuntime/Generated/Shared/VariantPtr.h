#pragma once

#include "IntPtr.h"

#ifndef __UNREAL__
#include <hxcpp.h>
#include <cpp/Pointer.h>
#endif


namespace unreal {

class VariantPtr {
public:
  UIntPtr raw;

  inline VariantPtr() : raw(0) { }
  inline VariantPtr(const void *inRHS) : raw(((UIntPtr) inRHS) + 1) { }
  inline VariantPtr(void *inRHS) : raw(((UIntPtr) inRHS) + 1) { }
  inline VariantPtr(IntPtr inRHS) : raw((UIntPtr) inRHS) { }
  inline VariantPtr(UIntPtr inRHS) : raw(inRHS) { }
#ifndef __UNREAL__
  inline VariantPtr(const Dynamic& inRHS) : raw((UIntPtr) inRHS.mPtr) { }
  inline VariantPtr(const cpp::Variant& inRHS) : raw((UIntPtr) Dynamic(inRHS).mPtr) { }
  inline VariantPtr(const null& inRHS) : raw(0) { }

  inline operator Dynamic() {
    if ((raw & 1) == 0) {
      return Dynamic((hx::Object *)raw);
    } else {
      return cpp::Pointer<void>((void *) (raw - 1));
    }
  }

  // inline operator cpp::Variant() {
  //   return cpp::Variant(this->getDynamic());
  // }

  inline Dynamic getDynamic() {
    if ((raw & 1) == 0) {
      return Dynamic((hx::Object *)raw);
    } else {
      return cpp::Pointer<void>((void *) (raw - 1));
    }
  }
#endif

  // Allow '->' syntax
  inline VariantPtr *operator->() { return this; }

  inline IntPtr getIntPtr() { return (IntPtr) raw; }
  inline UIntPtr getUIntPtr() { return (UIntPtr) raw; }

  inline bool isObject() { return (raw & 1) == 0; }

  // inline operator UIntPtr() { return raw; }

  inline void *toPointer() {
    return ((raw & 1) == 1) ? ( (void *) (raw - 1) ) : haxeObjToPointer(raw);
  }

  static void *haxeObjToPointer(UIntPtr raw) {
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
}
#endif
