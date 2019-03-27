#pragma once
#ifndef UHX_NO_UOBJECT

#include "IntPtr.h"
#include "VariantPtr.h"
#include <uhx/glues/TArrayImpl_Glue.h>
#include <uhx/glues/TMap_Glue.h>
#include <uhx/glues/TSet_Glue.h>

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
  void Empty(unreal::VariantPtr self, cpp::Int32 NewSize = 0) override;
  void Reset(unreal::VariantPtr self, cpp::Int32 NewSize = 0) override;
  void Swap(unreal::VariantPtr self, int first, int second) override;
  unreal::UIntPtr GetData(unreal::VariantPtr self) override;
  unreal::VariantPtr copyNew(unreal::VariantPtr self) override;
  unreal::VariantPtr copy(unreal::VariantPtr self) override;

  void assign(unreal::VariantPtr self, unreal::VariantPtr to) override;

protected:
  void *m_propertyType;
  // bool m_isWrapper;
  bool m_isValueType;
  void init();
};

class TMapReflect_obj : uhx::glues::TMap_Glue_obj {
public:
  TMapReflect_obj(unreal::UIntPtr inUPropertyType) :
    m_propertyType( (void *) inUPropertyType )
  {
    init();
  }

  virtual void Add(unreal::VariantPtr self, unreal::UIntPtr InKey, unreal::UIntPtr InValue) override;
  virtual unreal::UIntPtr FindOrAdd(unreal::VariantPtr self, unreal::UIntPtr Key) override;
  virtual void set_Item(unreal::VariantPtr self, unreal::UIntPtr key, unreal::UIntPtr val) override;
  virtual bool Contains(unreal::VariantPtr self, unreal::UIntPtr InKey) override;
  virtual unreal::UIntPtr FindChecked(unreal::VariantPtr self, unreal::UIntPtr InKey) override;
  virtual int Remove(unreal::VariantPtr self, unreal::UIntPtr InKey) override;
  virtual void Empty(unreal::VariantPtr self, int ExpectedElements) override;
  virtual unreal::VariantPtr GenerateKeyArray(unreal::VariantPtr self) override;
  virtual unreal::VariantPtr GenerateValueArray(unreal::VariantPtr self) override;
  virtual unreal::VariantPtr copyNew(unreal::VariantPtr self) override;
  virtual unreal::VariantPtr copy(unreal::VariantPtr self) override;
  virtual void assign(unreal::VariantPtr self, unreal::VariantPtr val) override;

protected:
  void *m_propertyType;
  void init();
};

class TSetReflect_obj : uhx::glues::TSet_Glue_obj {
public:
  TSetReflect_obj(unreal::UIntPtr inUPropertyType) :
    m_propertyType( (void *) inUPropertyType )
  {
    init();
  }

  virtual void Empty(unreal::VariantPtr self, int ExpectedNumElements) override;
  virtual void Shrink(unreal::VariantPtr self) override;
  virtual void Reset(unreal::VariantPtr self) override;
  virtual void Compact(unreal::VariantPtr self) override;
  virtual void Reserve(unreal::VariantPtr self, int Number) override;
  virtual cpp::UInt32 GetAllocatedSize(unreal::VariantPtr self) override;
  virtual int Num(unreal::VariantPtr self) override;
  virtual unreal::VariantPtr Add(unreal::VariantPtr self, unreal::UIntPtr InElement) override;
  virtual void Remove(unreal::VariantPtr self, unreal::VariantPtr ElementId) override;
  virtual unreal::VariantPtr FindId(unreal::VariantPtr self, unreal::UIntPtr Element) override;
  virtual unreal::VariantPtr copyNew(unreal::VariantPtr self) override;
  virtual unreal::VariantPtr copy(unreal::VariantPtr self) override;
  virtual void assign(unreal::VariantPtr self, unreal::VariantPtr val) override;

protected:
  void *m_propertyType;
  void init();
};

}

#endif
