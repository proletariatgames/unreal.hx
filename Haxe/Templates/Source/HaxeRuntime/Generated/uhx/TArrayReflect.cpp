#include "HaxeRuntime.h"
#ifndef UHX_NO_UOBJECT

#include "uhx/TArrayReflect.h"
#include "uhx/StructInfo.h"
#include "uhx/UnrealReflection.h"
#include "unreal/helpers/HxcppRuntime.h"
#include "Engine.h"

#define GET_UPROP() (Cast<UProperty>((UObject *) this->m_propertyType))
#define GET_ARRAY_HELPER(self) (getArrayHelper((UProperty *) m_propertyType, self))


static inline FScriptArrayHelper getArrayHelper(UProperty *inProp, unreal::VariantPtr inSelf) {
  return FScriptArrayHelper::CreateHelperFormInnerProperty(inProp, (void *) unreal::helpers::HxcppRuntime::getWrapperPointer(inSelf));
}

void uhx::TArrayReflect_obj::init() {
  check(m_propertyType);
  UProperty *prop = Cast<UProperty>((UObject *) m_propertyType);
  check(prop->IsA<UProperty>());
}

uhx::StructInfo uhx::infoFromUProperty(void *inUPropertyObject) {
  UProperty *prop = Cast<UProperty>((UObject *) inUPropertyObject);
  check(prop->IsA<UProperty>());
  uhx::StructInfo ret;
  FMemory::Memzero(&ret, sizeof(ret));
  if (prop->PropertyFlags & CPF_IsPlainOldData) {
    ret.flags = uhx::UHX_POD;
  } else {
    ret.flags = uhx::UHX_UPROP;
  }
  ret.size = (unreal::UIntPtr) prop->ElementSize;
  ret.alignment = (unreal::UIntPtr) prop->GetMinAlignment();
  ret.upropertyObject = inUPropertyObject;
  return ret;
}

static unreal::VariantPtr createWrapper(UProperty *inProp, void *pointerIfAny) {
  check(inProp);
  uhx::StructInfo info = uhx::infoFromUProperty(inProp);
  size_t extraSize = sizeof(info);
  extraSize += sizeof(void*); // alignment

  int startOffset = 0;
  unreal::UIntPtr ret = 0;
  if (inProp->IsA<UArrayProperty>()) {
    auto prop = Cast<UArrayProperty>(inProp);
    extraSize += sizeof(uhx::TArrayReflect_obj);
    extraSize += sizeof(void*); // alignment
    if (pointerIfAny) {
      ret = unreal::helpers::HxcppRuntime::createPointerTemplateWrapper((unreal::UIntPtr) pointerIfAny, (unreal::UIntPtr) &info, extraSize).raw;
      static int offset = unreal::helpers::HxcppRuntime::getTemplatePointerSize();
      startOffset = offset;
    } else {
      ret = unreal::helpers::HxcppRuntime::createInlineTemplateWrapper((unreal::UIntPtr) pointerIfAny, (unreal::UIntPtr) &info).raw;
      static int offset = unreal::helpers::HxcppRuntime::getTemplateSize();
      startOffset = offset;
    }

    unreal::UIntPtr reflectOffset = ret + startOffset + info.size;
    // re-align
    reflectOffset = (unreal::UIntPtr) ((reflectOffset + sizeof(void*) - 1) & ~(sizeof(void*) -1));
    reflectOffset += sizeof(uhx::StructInfo);
    // re-align
    reflectOffset = (unreal::UIntPtr) ((reflectOffset + sizeof(void*) - 1) & ~(sizeof(void*) -1));
    char *reflectBuf = (char *) reflectOffset;

    uhx::TArrayReflect_obj *reflectHelper = new (reflectBuf) uhx::TArrayReflect_obj((unreal::UIntPtr) prop->Inner);
    info.genericImplementation = reflectHelper;
  } else if (pointerIfAny) {
    return unreal::VariantPtr(pointerIfAny); // we don't need wrappers
  } else if (info.alignment > sizeof(void*)) {
    ret = unreal::helpers::HxcppRuntime::createAlignedInlineWrapper(extraSize, (unreal::UIntPtr) &info).raw;
    startOffset = unreal::helpers::HxcppRuntime::getAlignedInlineWrapperSize();
  } else if (info.flags == uhx::UHX_POD) {
    ret = unreal::helpers::HxcppRuntime::createInlinePodWrapper(extraSize, (unreal::UIntPtr) &info).raw;
    startOffset = unreal::helpers::HxcppRuntime::getInlinePodWrapperOffset();
  } else {
    ret = unreal::helpers::HxcppRuntime::createInlineWrapper(extraSize, (unreal::UIntPtr) &info).raw;
    startOffset = unreal::helpers::HxcppRuntime::getInlineWrapperOffset();
  }

  unreal::UIntPtr infoOffset = ret + startOffset + info.size;
  // re-align
  infoOffset = (unreal::UIntPtr) ((infoOffset + sizeof(void*) - 1) & ~(sizeof(void*) -1));
  // set the info inside the allocated space, so it can be reclaimed once the object is garbage collected
  *((uhx::StructInfo *) infoOffset) = info;
  // re-set the info on the wrapper
  unreal::helpers::HxcppRuntime::setWrapperStructInfo(ret, infoOffset);
  return ret;
}

static unreal::UIntPtr getValueWithProperty(UProperty *inProp, void *inPointer) {
  if (inProp->IsA<UNumericProperty>()) {
    auto numeric = Cast<UNumericProperty>(inProp);
    UEnum *uenum = numeric->GetIntPropertyEnum();
    if (uenum != nullptr) {
      unreal::UIntPtr array = unreal::helpers::HxcppRuntime::getEnumArray(TCHAR_TO_UTF8(*uenum->CppType));
      return unreal::helpers::HxcppRuntime::arrayIndex(array, (int) numeric->GetSignedIntPropertyValue(inPointer));
    }
    if (numeric->IsFloatingPoint()) {
      return unreal::helpers::HxcppRuntime::boxFloat(numeric->GetFloatingPointPropertyValue(inPointer));
    } else if (numeric->IsA<UInt64Property>() || numeric->IsA<UUInt64Property>()) {
      return unreal::helpers::HxcppRuntime::boxInt64(numeric->GetSignedIntPropertyValue(inPointer));
    } else {
      return unreal::helpers::HxcppRuntime::boxInt((int) numeric->GetSignedIntPropertyValue(inPointer));
    }
  } else if (inProp->IsA<UObjectProperty>()) {
    // auto objProp = Cast<UObjectProperty>(inProp);
    return unreal::helpers::HxcppRuntime::uobjectWrap((unreal::UIntPtr) *((UObject **) inPointer) );
  } else if (inProp->IsA<UStructProperty>()) {
    return unreal::helpers::HxcppRuntime::boxVariantPtr(inPointer);
  } else if (inProp->IsA<UBoolProperty>()) {
    auto prop = Cast<UBoolProperty>(inProp);
    return unreal::helpers::HxcppRuntime::boxBool(prop->GetPropertyValue(inPointer));
  } else if (inProp->IsA<UNameProperty>() || inProp->IsA<UStrProperty>() || inProp->IsA<UTextProperty>()) {
    return unreal::helpers::HxcppRuntime::boxVariantPtr(inPointer);
  } else if (inProp->IsA<UArrayProperty>()) {
    return unreal::helpers::HxcppRuntime::boxVariantPtr(createWrapper(inProp, inPointer));
  }

  // TODO: delegates, map, and set
  check(false);
  return 0;
}

static void setValueWithProperty(UProperty *inProp, void *dest, unreal::UIntPtr value) {
  if (inProp->IsA<UNumericProperty>()) {
    auto numeric = Cast<UNumericProperty>(inProp);
    UEnum *uenum = numeric->GetIntPropertyEnum();
    if (uenum != nullptr) {
      numeric->SetIntPropertyValue(dest, (int64) unreal::helpers::HxcppRuntime::enumIndex(value));
    }
    if (numeric->IsFloatingPoint()) {
      numeric->SetFloatingPointPropertyValue(dest, unreal::helpers::HxcppRuntime::unboxFloat(value));
    } else if (numeric->IsA<UInt64Property>() || numeric->IsA<UUInt64Property>()) {
      numeric->SetIntPropertyValue(dest, unreal::helpers::HxcppRuntime::unboxInt64(value));
    } else {
      numeric->SetIntPropertyValue(dest, (int64) unreal::helpers::HxcppRuntime::unboxInt((int64) value));
    }
  } else if (inProp->IsA<UObjectProperty>()) {
    *((UObject **)dest) = (UObject *) unreal::helpers::HxcppRuntime::uobjectUnwrap(value);
  } else if (inProp->IsA<UStructProperty>()) {
    auto prop = Cast<UStructProperty>(inProp);
    prop->CopyCompleteValue(dest, (void *) unreal::helpers::HxcppRuntime::getWrapperPointer(value));
  } else if (inProp->IsA<UBoolProperty>()) {
    auto prop = Cast<UBoolProperty>(inProp);
    prop->SetPropertyValue(dest, unreal::helpers::HxcppRuntime::unboxBool(value));
  } else if (inProp->IsA<UNameProperty>() || 
      inProp->IsA<UStrProperty>() ||
      inProp->IsA<UTextProperty>() ||
      inProp->IsA<UArrayProperty>()) {
    inProp->CopyCompleteValue(dest, (void *) unreal::helpers::HxcppRuntime::getWrapperPointer(value));
  } else {
    // TODO: delegates, map, and set
    check(false);
  }
}

unreal::UIntPtr uhx::TArrayReflect_obj::get_Item(unreal::VariantPtr self, int index) {
  return getValueWithProperty((UProperty *) m_propertyType, (void *) GET_ARRAY_HELPER(self).GetRawPtr(index));
}

void uhx::TArrayReflect_obj::set_Item(unreal::VariantPtr self, int index, unreal::UIntPtr val) {
  setValueWithProperty((UProperty *) m_propertyType, (void *) GET_ARRAY_HELPER(self).GetRawPtr(index), val);
}

unreal::UIntPtr uhx::TArrayReflect_obj::Pop(unreal::VariantPtr self, bool allowShrinking) {
  UProperty *prop = (UProperty *) m_propertyType;
  FScriptArrayHelper helper = GET_ARRAY_HELPER(self);

  unreal::UIntPtr ret = 0;
  int num = helper.Num();
  check(num > 0);
  uint8 *rawPtr = helper.GetRawPtr(num - 1);
  if (prop->IsA<UNumericProperty>()) {
    ret = getValueWithProperty(prop, rawPtr);
  } else if (prop->IsA<UObjectProperty>()) {
    ret = (unreal::UIntPtr) *((UObject **) rawPtr);
  } else {
    ret = unreal::helpers::HxcppRuntime::boxVariantPtr(createWrapper(prop, 0));
    unreal::UIntPtr retPtr = unreal::helpers::HxcppRuntime::getWrapperPointer(ret);
    prop->CopyCompleteValue((void *) retPtr, (void *) rawPtr);
  }
  helper.Resize(num - 1);
  return ret;
}

void uhx::TArrayReflect_obj::Push(unreal::VariantPtr self, unreal::UIntPtr obj) {
  FScriptArrayHelper helper = GET_ARRAY_HELPER(self);
  int num = helper.Num();
  helper.Resize(num + 1);
  setValueWithProperty((UProperty *) m_propertyType, helper.GetRawPtr(num), obj);
}

cpp::Int32 uhx::TArrayReflect_obj::AddZeroed(unreal::VariantPtr self, cpp::Int32 Count) {
  FScriptArrayHelper helper = GET_ARRAY_HELPER(self);
  int num = helper.Num();
  helper.Resize(num + Count);
  return num;
}

void uhx::TArrayReflect_obj::SetNumUninitialized(unreal::VariantPtr self, int arraySize) {
  GET_ARRAY_HELPER(self).Resize(arraySize);
}

int uhx::TArrayReflect_obj::Insert(unreal::VariantPtr self, unreal::UIntPtr item, int index) {
  //TODO
  check(false);
  return 0;
}

void uhx::TArrayReflect_obj::RemoveAt(unreal::VariantPtr self, cpp::Int32 Index, cpp::Int32 Count, bool bAllowShrinking) {
  // TODO
  check(false);
  return;
}
int uhx::TArrayReflect_obj::Num(unreal::VariantPtr self) {
  return GET_ARRAY_HELPER(self).Num();
}

void uhx::TArrayReflect_obj::Empty(unreal::VariantPtr self) {
  GET_ARRAY_HELPER(self).Resize(0);
}

void uhx::TArrayReflect_obj::Reset(unreal::VariantPtr self) {
  GET_ARRAY_HELPER(self).Resize(0);
}

void uhx::TArrayReflect_obj::Swap(unreal::VariantPtr self, int first, int second) {
  GET_ARRAY_HELPER(self).SwapValues(first, second);
}

unreal::UIntPtr uhx::TArrayReflect_obj::GetData(unreal::VariantPtr self) {
  return (unreal::UIntPtr) GET_ARRAY_HELPER(self).GetRawPtr();
}

unreal::VariantPtr uhx::TArrayReflect_obj::copyNew(unreal::VariantPtr self) {
  // TODO
  return 0;
}

unreal::VariantPtr uhx::TArrayReflect_obj::copy(unreal::VariantPtr self) {
  // TODO
  return 0;
}

unreal::VariantPtr unreal::helpers::UnrealReflection_obj::wrapProperty(unreal::UIntPtr inProp, unreal::UIntPtr pointerIfAny) {
  return createWrapper(Cast<UProperty>( (UObject *) inProp ), (void*) pointerIfAny);
}

#undef GET_UPROP
#undef GET_ARRAY_HELPER

#endif
