#pragma once
#ifndef UHX_NO_UOBJECT

#include "IntPtr.h"
#include "VariantPtr.h"
#include <uhx/glues/TArrayImpl_Glue.h>

namespace uhx {

class TArrayReflect_obj : uhx::glues::TArrayImpl_Glue_obj {
public:
  TArrayReflect_obj(unreal::UIntPtr inUPropertyType) :
    m_propertyType( (void *) inUPropertyType )
  {
    init();
  }

  unreal::UIntPtr get_Item(unreal::VariantPtr self, int index) override;
  void set_Item(unreal::VariantPtr self, int index, unreal::UIntPtr val) override;
  unreal::UIntPtr Pop(unreal::VariantPtr self, bool allowShrinking) override;
  void Push(unreal::VariantPtr self, unreal::UIntPtr obj) override;
  cpp::Int32 AddZeroed(unreal::VariantPtr self, cpp::Int32 Count) override;
  void SetNumUninitialized(unreal::VariantPtr self, int arraySize) override;
  int Insert(unreal::VariantPtr self, unreal::UIntPtr item, int index) override;
  void RemoveAt(unreal::VariantPtr self, cpp::Int32 Index, cpp::Int32 Count, bool bAllowShrinking) override;
  int Num(unreal::VariantPtr self) override;
  void Empty(unreal::VariantPtr self) override;
  void Reset(unreal::VariantPtr self) override;
  void Swap(unreal::VariantPtr self, int first, int second) override;
  unreal::UIntPtr GetData(unreal::VariantPtr self) override;
  unreal::VariantPtr copyNew(unreal::VariantPtr self) override;
  unreal::VariantPtr copy(unreal::VariantPtr self) override;

protected:
  void *m_propertyType;
  // bool m_isWrapper;
  bool m_isValueType;
  void init();
};

}

#endif
