#include "HaxeRuntime.h"
#ifndef UHX_NO_UOBJECT

#include "uhx/ue/ClassMap.h"
#include "uhx/TArrayReflect.h"
#include "uhx/StructInfo.h"
#include "uhx/ue/RuntimeLibrary.h"
#include "uhx/expose/HxcppRuntime.h"
#include "Engine.h"
#include "HaxeGcRef.h"
#include "HaxeInit.h"
#include "uhx/UEHelpers.h"
#include <unordered_map>
// #include "Templates/UnrealTemplate.h" // For STRUCT_OFFSET

#define GET_UPROP() (Cast<UProperty>((UObject *) this->m_propertyType))
#define GET_ARRAY_HELPER(self) (getArrayHelper((UProperty *) m_propertyType, self))


static inline FScriptArrayHelper getArrayHelper(UProperty *inProp, unreal::VariantPtr inSelf) {
  return FScriptArrayHelper::CreateHelperFormInnerProperty(inProp, (void *) uhx::expose::HxcppRuntime::getWrapperPointer(inSelf));
}

void uhx::TArrayReflect_obj::init() {
  check(m_propertyType);
  UProperty *prop = Cast<UProperty>((UObject *) m_propertyType);
  check(prop->IsA<UProperty>());
}

static bool valEquals(const uhx::StructInfo *info, unreal::UIntPtr t1, unreal::UIntPtr t2) {
  if (t1 == t2) {
    return true;
  }
  UProperty *prop = Cast<UProperty>((UObject *) info->upropertyObject);
  check(prop);
  return prop->Identical((void*)t1, (void*)t2);
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
  ret.equals = &valEquals;
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
    extraSize += sizeof(void*) * 2; // genericParams array
    extraSize += sizeof(uhx::StructInfo); // genericParams info
    if (pointerIfAny) {
      ret = uhx::expose::HxcppRuntime::createPointerTemplateWrapper((unreal::UIntPtr) pointerIfAny, (unreal::UIntPtr) &info, extraSize).raw;
      static int offset = uhx::expose::HxcppRuntime::getTemplatePointerSize();
      startOffset = offset;
    } else {
      ret = uhx::expose::HxcppRuntime::createInlineTemplateWrapper((unreal::UIntPtr) pointerIfAny, (unreal::UIntPtr) &info).raw;
      static int offset = uhx::expose::HxcppRuntime::getTemplateSize();
      startOffset = offset;
    }

    int align = info.alignment;
    if (align < sizeof(void*)) {
      align = sizeof(void*);
    }
    align--;
    unreal::UIntPtr objOffset = ret + startOffset;
    // re-align
    objOffset = (objOffset + align) & ~align;

    unreal::UIntPtr reflectPtr = objOffset + info.size;
    // re-align
    reflectPtr = (unreal::UIntPtr) ((reflectPtr + sizeof(void*) - 1) & ~(sizeof(void*) -1));
    reflectPtr += sizeof(uhx::StructInfo); // this is where the main info will be at

    uhx::StructInfo * genericParamPtr = ((uhx::StructInfo*) reflectPtr);
    *genericParamPtr = uhx::infoFromUProperty(prop->Inner);
    reflectPtr += sizeof(uhx::StructInfo);

    info.genericParams = (const uhx::StructInfo **) reflectPtr;
    info.genericParams[0] = genericParamPtr;
    reflectPtr += sizeof(void*);
    info.genericParams[1] = nullptr;
    reflectPtr += sizeof(void*);

    // re-align
    reflectPtr = (unreal::UIntPtr) ((reflectPtr + sizeof(void*) - 1) & ~(sizeof(void*) -1));
    char *reflectBuf = (char *) reflectPtr;

    uhx::TArrayReflect_obj *reflectHelper = new (reflectBuf) uhx::TArrayReflect_obj((unreal::UIntPtr) prop->Inner);
    info.genericImplementation = reflectHelper;
  } else if (pointerIfAny) {
    return unreal::VariantPtr(pointerIfAny); // we don't need wrappers
  } else if (info.alignment > sizeof(void*)) {
    extraSize += sizeof(void*); // alignment
    extraSize += sizeof(uhx::StructInfo); // genericParams info
    ret = uhx::expose::HxcppRuntime::createAlignedInlineWrapper(extraSize, (unreal::UIntPtr) &info).raw;
    startOffset = uhx::expose::HxcppRuntime::getAlignedInlineWrapperSize();
  } else if (info.flags == uhx::UHX_POD) {
    extraSize += sizeof(void*); // alignment
    extraSize += sizeof(uhx::StructInfo); // genericParams info
    ret = uhx::expose::HxcppRuntime::createInlinePodWrapper(extraSize, (unreal::UIntPtr) &info).raw;
    startOffset = uhx::expose::HxcppRuntime::getInlinePodWrapperOffset();
  } else {
    extraSize += sizeof(void*); // alignment
    extraSize += sizeof(uhx::StructInfo); // genericParams info
    // ret = uhx::expose::HxcppRuntime::createInlineWrapper(extraSize, (unreal::UIntPtr) &info).raw;
    // startOffset = uhx::expose::HxcppRuntime::getInlineWrapperOffset();
    // Dynamically created wrappers have more strict alignment needs than statically created (because we are using Unreal's reflection API)
    // so we always create an aligned inline wrapper
    ret = uhx::expose::HxcppRuntime::createAlignedInlineWrapper(extraSize, (unreal::UIntPtr) &info).raw;
    startOffset = uhx::expose::HxcppRuntime::getAlignedInlineWrapperSize();
  }

  int align = info.alignment;
  if (align < sizeof(void*)) {
    align = sizeof(void*);
  }
  align--;
  unreal::UIntPtr objOffset = ret + startOffset;
  // re-align
  objOffset = (objOffset + align) & ~align;
  unreal::UIntPtr infoOffset = objOffset + info.size;
  // re-align
  infoOffset = (unreal::UIntPtr) ((infoOffset + sizeof(void*) - 1) & ~(sizeof(void*) -1));
  // set the info inside the allocated space, so it can be reclaimed once the object is garbage collected
  *((uhx::StructInfo *) infoOffset) = info;
  // re-set the info on the wrapper
  uhx::expose::HxcppRuntime::setWrapperStructInfo(ret, infoOffset);
  return ret;
}

static unreal::UIntPtr getValueWithProperty(UProperty *inProp, void *inPointer) {
  if (inProp->IsA<UNumericProperty>()) {
    auto numeric = Cast<UNumericProperty>(inProp);
    UEnum *uenum = numeric->GetIntPropertyEnum();
    if (uenum != nullptr) {
      unreal::UIntPtr array = uhx::expose::HxcppRuntime::getEnumArray(TCHAR_TO_UTF8(*uenum->CppType));
      return uhx::expose::HxcppRuntime::arrayIndex(array, (int) numeric->GetSignedIntPropertyValue(inPointer));
    }
    if (numeric->IsFloatingPoint()) {
      return uhx::expose::HxcppRuntime::boxFloat(numeric->GetFloatingPointPropertyValue(inPointer));
    } else if (numeric->IsA<UInt64Property>() || numeric->IsA<UUInt64Property>()) {
      return uhx::expose::HxcppRuntime::boxInt64(numeric->GetSignedIntPropertyValue(inPointer));
    } else {
      return uhx::expose::HxcppRuntime::boxInt((int) numeric->GetSignedIntPropertyValue(inPointer));
    }
  } else if (inProp->IsA<UObjectProperty>()) {
    // auto objProp = Cast<UObjectProperty>(inProp);
    return uhx::expose::HxcppRuntime::uobjectWrap((unreal::UIntPtr) *((UObject **) inPointer) );
  } else if (inProp->IsA<UStructProperty>() || inProp->IsA<UDelegateProperty>() || inProp->IsA<UMulticastDelegateProperty>()) {
    return uhx::expose::HxcppRuntime::boxVariantPtr(inPointer);
  } else if (inProp->IsA<UBoolProperty>()) {
    auto prop = Cast<UBoolProperty>(inProp);
    return uhx::expose::HxcppRuntime::boxBool(prop->GetPropertyValue(inPointer));
  } else if (inProp->IsA<UNameProperty>() || inProp->IsA<UStrProperty>() || inProp->IsA<UTextProperty>()) {
    return uhx::expose::HxcppRuntime::boxVariantPtr(inPointer);
  } else if (inProp->IsA<UArrayProperty>()) {
    return uhx::expose::HxcppRuntime::boxVariantPtr(createWrapper(inProp, inPointer));
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
      numeric->SetIntPropertyValue(dest, (int64) uhx::expose::HxcppRuntime::enumIndex(value));
    }
    if (numeric->IsFloatingPoint()) {
      numeric->SetFloatingPointPropertyValue(dest, uhx::expose::HxcppRuntime::unboxFloat(value));
    } else if (numeric->IsA<UInt64Property>() || numeric->IsA<UUInt64Property>()) {
      numeric->SetIntPropertyValue(dest, (int64) uhx::expose::HxcppRuntime::unboxInt64(value));
    } else {
      numeric->SetIntPropertyValue(dest, (int64) uhx::expose::HxcppRuntime::unboxInt((int64) value));
    }
  } else if (inProp->IsA<UObjectProperty>()) {
    *((UObject **)dest) = (UObject *) uhx::expose::HxcppRuntime::uobjectUnwrap(value);
  } else if (inProp->IsA<UStructProperty>() || inProp->IsA<UDelegateProperty>() || inProp->IsA<UMulticastDelegateProperty>()) {
    inProp->CopyCompleteValue(dest, (void *) uhx::expose::HxcppRuntime::getWrapperPointer(value));
  } else if (inProp->IsA<UBoolProperty>()) {
    auto prop = Cast<UBoolProperty>(inProp);
    prop->SetPropertyValue(dest, uhx::expose::HxcppRuntime::unboxBool(value));
  } else if (inProp->IsA<UNameProperty>() || 
      inProp->IsA<UStrProperty>() ||
      inProp->IsA<UTextProperty>() ||
      inProp->IsA<UArrayProperty>()) {
    inProp->CopyCompleteValue(dest, (void *) uhx::expose::HxcppRuntime::getWrapperPointer(value));
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
  if (prop->IsA<UNumericProperty>() || prop->IsA<UBoolProperty>()) {
    ret = getValueWithProperty(prop, rawPtr);
  } else if (prop->IsA<UObjectProperty>()) {
    ret = (unreal::UIntPtr) *((UObject **) rawPtr);
  } else {
    ret = uhx::expose::HxcppRuntime::boxVariantPtr(createWrapper(prop, 0));
    unreal::UIntPtr retPtr = uhx::expose::HxcppRuntime::getWrapperPointer(ret);
    prop->InitializeValue((void *) retPtr);
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
  auto helper = GET_ARRAY_HELPER(self);
  int num = helper.Num();
  helper.InsertValues(index);
  setValueWithProperty( (UProperty *) m_propertyType, helper.GetRawPtr(index), item );
  return num;
}

void uhx::TArrayReflect_obj::RemoveAt(unreal::VariantPtr self, cpp::Int32 Index, cpp::Int32 Count, bool bAllowShrinking) {
  auto helper = GET_ARRAY_HELPER(self);
  helper.RemoveValues(Index, Count);
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

unreal::VariantPtr uhx::ue::RuntimeLibrary_obj::wrapProperty(unreal::UIntPtr inProp, unreal::UIntPtr pointerIfAny) {
  return createWrapper(Cast<UProperty>( (UObject *) inProp ), (void*) pointerIfAny);
}

int uhx::ue::RuntimeLibrary_obj::getHaxeGcRefOffset() {
  static int offset = (int) STRUCT_OFFSET(FHaxeGcRef, ref);
  return offset;
}

#if WITH_EDITOR
static void dynamicConstruct(const FObjectInitializer& init) {
  UObject *obj = init.GetObj();
  UClass *cls = init.GetClass();
  static FName HaxeDynamicClass(TEXT("HaxeDynamicClass"));
  FString hxClass = cls->GetMetaData(HaxeDynamicClass);
  while (hxClass.IsEmpty()) {
    cls = cls->GetSuperClass();
    hxClass = cls->GetMetaData(HaxeDynamicClass);
  }

  // super()
  auto superClass = cls->GetSuperClass();
  while (superClass->HasMetaData(HaxeDynamicClass)) {
    superClass = superClass->GetSuperClass();
  }
  superClass->ClassConstructor(init);

  static FName haxeGcRefName(TEXT("haxeGcRef"));
  UProperty *gcRefProp = cls->FindPropertyByName(haxeGcRefName);
  if (gcRefProp == nullptr) {
    UE_LOG(HaxeLog, Error, TEXT("Cannot find the gcRef property for %s"), *cls->GetName());
    return;
  }

  uint8 *objPtr = (uint8*) obj;
  uhx::UEHelpers::initializeDynamicProperties(cls, obj);

  objPtr += gcRefProp->GetOffset_ReplaceWith_ContainerPtrToValuePtr();
  FHaxeGcRef *gcRef = (FHaxeGcRef*) objPtr;
  gcRef->ref.set(uhx::expose::HxcppRuntime::createDynamicHelper((unreal::UIntPtr) obj, TCHAR_TO_UTF8(*hxClass)));
}

static unreal::UIntPtr dynamicWrapper(unreal::UIntPtr inObj) {
  static std::unordered_map<UClass *,int> offsets;
  UObject* obj = (UObject*) inObj;
  UClass* cls = obj->GetClass();
  auto it = offsets.find(cls);
  int offset = 0;
  if (it != offsets.end()) {
    offset = it->second;
  } else {
    UProperty *gcRefProp = cls->FindPropertyByName(TEXT("haxeGcRef"));
    if (gcRefProp == nullptr) {
      UE_LOG(HaxeLog, Error, TEXT("Cannot find the gcRef property for %s"), *cls->GetName());
      return 0;
    }

    offset = gcRefProp->GetOffset_ReplaceWith_ContainerPtrToValuePtr();
    offsets[cls] = offset;
  }

  FHaxeGcRef *gcRef = (FHaxeGcRef*) (inObj + offset);
  return gcRef->ref.get();
}

static void superConstruct(const FObjectInitializer& init) {
  UClass *cls = init.GetClass();
  char *name = TCHAR_TO_UTF8(*cls->GetName());

  auto superClass = cls->GetSuperClass();
  auto firstDynamicClass = superClass;
  static FName HaxeDynamicClassName(TEXT("HaxeDynamicClass"));
  while (superClass->HasMetaData(HaxeDynamicClassName)) {
    firstDynamicClass = superClass;
    superClass = superClass->GetSuperClass();
  }

  static FName HaxeGeneratedName(TEXT("HaxeGenerated"));
  bool bSuperIsHaxeGenerated = superClass->HasMetaData(HaxeGeneratedName);
  if (bSuperIsHaxeGenerated) {
    superClass->ClassConstructor(init);
  } else {
    firstDynamicClass->ClassConstructor(init);
  }
}
#endif

void uhx::ue::RuntimeLibrary_obj::setSuperClassConstructor(unreal::UIntPtr inDynamicClass) {
#if WITH_EDITOR
  UClass *cls = (UClass *)inDynamicClass;
  cls->ClassConstructor = &superConstruct;
#endif
}

void uhx::ue::RuntimeLibrary_obj::setupClassConstructor(unreal::UIntPtr inDynamicClass) {
#if WITH_EDITOR
  UClass *inClass = (UClass *)inDynamicClass;
  uhx::ue::ClassMap_obj::addWrapper((unreal::UIntPtr) inClass, &dynamicWrapper);
  inClass->ClassConstructor = &dynamicConstruct;
#endif
}

#undef GET_UPROP
#undef GET_ARRAY_HELPER

#endif
