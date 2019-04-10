#include "HaxeRuntime.h"
#ifndef UHX_NO_UOBJECT

#include "uhx/Defines.h"
#include "uhx/ue/ClassMap.h"
#include "uhx/ReflectTypes.h"
#include "uhx/StructInfo.h"
#include "uhx/ue/RuntimeLibrary.h"
#include "uhx/expose/HxcppRuntime.h"
#include "CoreMinimal.h"
#include "UObject/UnrealType.h"
#include "HaxeGcRef.h"
#include "HaxeInit.h"
#include "uhx/UEHelpers.h"
#include "uhx/GcRef.h"
#include <unordered_map>
#include <string.h>
#include "UObject/UObjectArray.h"
#include "HAL/PlatformTLS.h"
// #include "Templates/UnrealTemplate.h" // For STRUCT_OFFSET

#if WITH_EDITOR // debug mode
#define GET_UPROP() (Cast<UProperty>((UObject *) this->m_propertyType))
#define GET_MAP_UPROP() (Cast<UMapProperty>((UObject *) this->m_propertyType))

#else
#define GET_UPROP() ((UProperty *) this->m_propertyType)
#define GET_MAP_UPROP() ((UMapProperty *) this->m_propertyType)

#endif

#define GET_ARRAY_HELPER(self) (getArrayHelper(GET_UPROP(), self))
#define GET_MAP_HELPER(self) (getMapHelper(GET_MAP_UPROP(), self))
#define GET_SET_HELPER(self) (getSetHelper(GET_UPROP(), self))

namespace uhx {

enum WrapperKind {
  UHX_WRAPPER_NORMAL = 0,
  UHX_WRAPPER_ARRAY,
  UHX_WRAPPER_SET
};

struct InitialWrapperLayout {
  uhx::StructInfo mainInfo;
};

struct ArrayWrapperLayout : public InitialWrapperLayout {
  uhx::StructInfo paramInfo;
  uhx::StructInfo* paramArray[2];
  uhx::TArrayReflect_obj arrayReflect;

  ArrayWrapperLayout(unreal::UIntPtr innerProperty) :
    arrayReflect(uhx::TArrayReflect_obj(innerProperty))
  {
  }
};

struct SetWrapperLayout : public InitialWrapperLayout {
  uhx::StructInfo paramInfo;
  uhx::StructInfo* paramArray[2];
  uhx::TSetReflect_obj setReflect;

  SetWrapperLayout(unreal::UIntPtr innerProperty) :
    setReflect(uhx::TSetReflect_obj(innerProperty))
  {
  }
};

struct MapWrapperLayout : public InitialWrapperLayout {
  uhx::StructInfo paramInfos[2];
  uhx::StructInfo* paramArray[3];
  uhx::TMapReflect_obj mapReflect;

  MapWrapperLayout(unreal::UIntPtr innerProperty) :
    mapReflect(uhx::TMapReflect_obj(innerProperty))
  {
  }
};

}

static inline unreal::UIntPtr getUnderlyingFromUIntPtr(unreal::UIntPtr inPtr) {
  return unreal::VariantPtr::fromUIntPtrRepresentation(inPtr).getUnderlyingPointer();
}

static inline unreal::UIntPtr doAlign(unreal::UIntPtr offset, unreal::UIntPtr align) {
  if (align < sizeof(void*)) {
    align = sizeof(void*);
  }
  checkSlow((align & (sizeof(void*) - 1)) == 0);
  int alignMinusOne = align - 1;
  return (offset + alignMinusOne) & ~alignMinusOne;
}

static inline FScriptArrayHelper getArrayHelper(UProperty *inProp, unreal::VariantPtr inSelf) {
  return FScriptArrayHelper::CreateHelperFormInnerProperty(inProp, (void *) (inSelf.getUnderlyingPointer()));
}

static inline FScriptMapHelper getMapHelper(UMapProperty *inProp, unreal::VariantPtr inSelf) {
  return FScriptMapHelper(inProp, (void *) (inSelf.getUnderlyingPointer()));
}

static inline FScriptSetHelper getSetHelper(UProperty *inProp, unreal::VariantPtr inSelf) {
  return FScriptSetHelper::CreateHelperFormElementProperty(inProp, (void *) (inSelf.getUnderlyingPointer()));
}

void uhx::TArrayReflect_obj::init() {
  check(m_propertyType);
  UProperty *prop = Cast<UProperty>((UObject *) m_propertyType);
  check(prop->IsA<UProperty>());
}

void uhx::TMapReflect_obj::init() {
  check(m_propertyType);
  UMapProperty *prop = Cast<UMapProperty>((UObject *) m_propertyType);
  check(prop->IsA<UMapProperty>());
}

void uhx::TSetReflect_obj::init() {
  check(m_propertyType);
  UProperty *prop = Cast<UProperty>((UObject *) m_propertyType);
  check(prop->IsA<UProperty>());
}

static TMap<UObject*, int>& rootCount()
{
  static TMap<UObject*, int> ret;
  return ret;
}

static void incrRef(UObject *inObj)
{
  auto obj = GUObjectArray.ObjectToObjectItem(inObj);
  if (!obj->IsRootSet())
  {
    rootCount().Emplace(inObj, 1);
    obj->SetRootSet();
  } else {
    auto count = rootCount().Find(inObj);
    if (count == nullptr)
    {
      return;
    }
    *count += 1;
  }
}

static void decrRef(UObject *inObj)
{
  auto count = rootCount().Find(inObj);
  if (count != nullptr)
  {
    *count -= 1;
    if (*count == 0)
    {
      rootCount().Remove(inObj);
      inObj->RemoveFromRoot();
    }
  }
}

static bool valPropEquals(const uhx::StructInfo *info, unreal::UIntPtr t1, unreal::UIntPtr t2) {
  if (t1 == t2) {
    return true;
  }
  UProperty *prop = Cast<UProperty>((UObject *) info->contextObject);
  check(prop);
  return prop->Identical((void*)t1, (void*)t2);
}

static void valPropDestruct(const uhx::StructInfo *info, unreal::UIntPtr t1) {
  UProperty *prop = Cast<UProperty>((UObject *) info->contextObject);
  check(prop);
  prop->DestroyValue((void *) t1);
  decrRef(prop);
}

static bool valStructEquals(const uhx::StructInfo *info, unreal::UIntPtr t1, unreal::UIntPtr t2) {
  if (t1 == t2) {
    return true;
  }
  UScriptStruct *prop = Cast<UScriptStruct>((UObject *) info->contextObject);
  check(prop);
  bool result;
  return prop->GetCppStructOps()->Identical((void*)t1, (void*)t2, 0, result);
}

static void valStructDestruct(const uhx::StructInfo *info, unreal::UIntPtr t1) {
  UScriptStruct *prop = Cast<UScriptStruct>((UObject *) info->contextObject);
  check(prop);
  prop->DestroyStruct((void *) t1);
  decrRef(prop);
}

static void valArrayDestruct(const uhx::StructInfo *info, unreal::UIntPtr t1) {
  FScriptArrayHelper helper = FScriptArrayHelper::CreateHelperFormInnerProperty(Cast<UProperty>((UObject*)info->contextObject), (void *) t1);
  helper.EmptyValues();

  ((FScriptArray*)t1)->~FScriptArray();
  decrRef((UObject*) info->contextObject);
}

static void valSetDestruct(const uhx::StructInfo *info, unreal::UIntPtr t1) {
  FScriptSetHelper helper = FScriptSetHelper::CreateHelperFormElementProperty(Cast<UProperty>((UObject*)info->contextObject), (void *) t1);
  helper.EmptyElements();

  ((FScriptSet*)t1)->~FScriptSet();
  decrRef((UObject*) info->contextObject);
}

static uhx::StructInfo infoFromUProperty(void *inUPropertyObject, uhx::WrapperKind kind) {
  UProperty *prop = Cast<UProperty>((UObject *) inUPropertyObject);
  check(prop->IsA<UProperty>());
  uhx::StructInfo ret;
  FMemory::Memzero(&ret, sizeof(ret));
  if (!UHX_IGNORE_POD && kind == uhx::UHX_WRAPPER_NORMAL && prop->PropertyFlags & CPF_IsPlainOldData) {
    ret.flags = uhx::UHX_POD;
  } else {
    ret.flags = uhx::UHX_CUSTOM;
  }
  ret.contextObject = inUPropertyObject;

  if (kind == uhx::UHX_WRAPPER_ARRAY) {
    ret.name = "TArray";
    ret.size = (unreal::UIntPtr) sizeof(FScriptArray);
    ret.alignment = (unreal::UIntPtr) alignof(FScriptArray);
    ret.destruct = &valArrayDestruct;
    incrRef(prop);
  } else if (kind == uhx::UHX_WRAPPER_SET) {
    ret.name = "TSet";
    ret.size = (unreal::UIntPtr) sizeof(FScriptSet);
    ret.alignment = (unreal::UIntPtr) alignof(FScriptSet);
    ret.destruct = &valSetDestruct;
    incrRef(prop);
  } else {
    ret.size = (unreal::UIntPtr) prop->ElementSize;
    ret.alignment = (unreal::UIntPtr) prop->GetMinAlignment();
    if (ret.alignment < sizeof(void*)) {
      ret.alignment = sizeof(void*);
    }
    ret.destruct = (prop->PropertyFlags & CPF_NoDestructor) != 0 ? nullptr : &valPropDestruct;
    if (ret.destruct)
    {
      incrRef(prop);
      ret.equals = &valPropEquals;
    }

    if (prop->IsA<UArrayProperty>()) {
      ret.name = "TArray";
      check(sizeof(FScriptArray) == ret.size);
    } else if (prop->IsA<USetProperty>()) {
      ret.name = "TSet";
      check(sizeof(FScriptSet) == ret.size);
    } else if (prop->IsA<UMapProperty>()) {
      ret.name = "TMap";
      check(sizeof(FScriptMap) == ret.size);
    }
  }
  return ret;
}

uhx::StructInfo uhx::infoFromUScriptStruct(void *inUScriptStructObject) {
  UScriptStruct *s = Cast<UScriptStruct>((UObject *) inUScriptStructObject);
  check(s->IsA<UScriptStruct>());
  uhx::StructInfo ret;
  FMemory::Memzero(&ret, sizeof(ret));
  if (s->GetCppStructOps() == nullptr) {
    FString msg = TEXT("Struct ");
    msg += s->GetName() + TEXT(" does not have a CPP Struct ops object!");
    uhx::expose::HxcppRuntime::throwString(TCHAR_TO_UTF8(*msg));
  }

  auto structOps = s->GetCppStructOps();
  if (!UHX_IGNORE_POD && structOps->IsPlainOldData()) {
    ret.flags = uhx::UHX_POD;
  } else {
    ret.flags = uhx::UHX_CUSTOM;
  }
  ret.size = (unreal::UIntPtr) structOps->GetSize();
  ret.alignment = (unreal::UIntPtr) structOps->GetAlignment();
  if (ret.alignment < sizeof(void*)) {
    ret.alignment = sizeof(void*);
  }
  ret.contextObject = inUScriptStructObject;
  ret.destruct = (structOps->HasDestructor()) ? &valStructDestruct : nullptr;
  if (ret.destruct)
  {
    incrRef(s);
    ret.equals = &valStructEquals;
  }
  return ret;
}

unreal::VariantPtr uhx::ue::RuntimeLibrary_obj::createDynamicWrapperFromStruct(unreal::UIntPtr inStruct) {
  check(inStruct);
  UScriptStruct* scriptStruct = Cast<UScriptStruct>((UObject*) inStruct);

  uhx::StructInfo info = uhx::infoFromUScriptStruct(scriptStruct);
  size_t extraSize = 0;
  extraSize += info.size +
                info.alignment +
                sizeof(void*) +
                sizeof(info);

  int startOffset = 0;
  unreal::UIntPtr ret = 0;
  uhx::InitialWrapperLayout *infoLayout = nullptr;

  if (info.alignment > sizeof(void*)) {
    ret = uhx::expose::HxcppRuntime::createAlignedInlineWrapper(extraSize, (unreal::UIntPtr) &info).getGcPointerUnchecked();
    static int staticOffset = uhx::expose::HxcppRuntime::getAlignedInlineWrapperSize();
    startOffset = staticOffset;
  } else if (info.flags == uhx::UHX_POD) {
    ret = uhx::expose::HxcppRuntime::createInlinePodWrapper(extraSize, (unreal::UIntPtr) &info).getGcPointerUnchecked();
    static int staticOffset = uhx::expose::HxcppRuntime::getInlinePodWrapperOffset();
    startOffset = staticOffset;
  } else {
    // Dynamically created wrappers have more strict alignment needs than statically created (because we are using Unreal's reflection API)
    // so we always create an aligned inline wrapper
    ret = uhx::expose::HxcppRuntime::createInlineWrapper(extraSize, (unreal::UIntPtr) &info).getGcPointerUnchecked();
    static int staticOffset = uhx::expose::HxcppRuntime::getInlineWrapperOffset();
    startOffset = staticOffset;
  }
  unreal::UIntPtr objOffset = ret + startOffset;
  // align
  objOffset = doAlign(objOffset, info.alignment);
  unreal::UIntPtr infoOffset = objOffset + info.size;
  infoOffset = doAlign(infoOffset, sizeof(void*));
  infoLayout = (uhx::InitialWrapperLayout*) infoOffset;

  infoLayout->mainInfo = info;
  // re-set the info on the wrapper
  uhx::expose::HxcppRuntime::setWrapperStructInfo(ret, (unreal::UIntPtr) &infoLayout->mainInfo);
  check( ((unreal::UIntPtr)infoLayout) + sizeof(info) <= ret + startOffset + extraSize);
  return unreal::VariantPtr::fromGcPointer(ret);
}

static unreal::VariantPtr createWrapper(UProperty *inProp, void *pointerIfAny, uhx::WrapperKind wrapperKind = uhx::UHX_WRAPPER_NORMAL) {
  check(inProp);
  uhx::StructInfo info = infoFromUProperty(inProp, wrapperKind);
  size_t extraSize = 0;
  FString name;
  int startOffset = 0;
  unreal::UIntPtr ret = 0;
  uhx::InitialWrapperLayout *infoLayout = nullptr;
  if (uhx::ue::RuntimeLibrary_obj::getReflectionDebugMode())
  {
    name = inProp->GetClass()->GetName() + TEXT("-") + inProp->GetName() + TEXT("-") + inProp->GetOuter()->GetName();
    extraSize += strlen(TCHAR_TO_UTF8(*name)) + 1;
  }

  if (wrapperKind == uhx::UHX_WRAPPER_ARRAY || inProp->IsA<UArrayProperty>()) {
    UProperty *innerProperty = nullptr;
    if (wrapperKind == uhx::UHX_WRAPPER_ARRAY) {
      innerProperty = inProp;
    } else {
      innerProperty = Cast<UArrayProperty>(inProp)->Inner;
    }
    extraSize += sizeof(void*) + sizeof(uhx::ArrayWrapperLayout);
    if (pointerIfAny) {
      ret = uhx::expose::HxcppRuntime::createPointerTemplateWrapper((unreal::UIntPtr) pointerIfAny, (unreal::UIntPtr) &info, extraSize).getGcPointerUnchecked();
      static int offset = uhx::expose::HxcppRuntime::getTemplatePointerSize();
      startOffset = offset;
    } else {
      extraSize += sizeof(FScriptArray) + sizeof(void*);
      ret = uhx::expose::HxcppRuntime::createInlineTemplateWrapper(extraSize, (unreal::UIntPtr) &info).getGcPointerUnchecked();
      static int offset = uhx::expose::HxcppRuntime::getTemplateSize();
      startOffset = offset;
    }

    unreal::UIntPtr objOffset = ret + startOffset;
    // re-align
    objOffset = doAlign(objOffset, info.alignment);
    if (!pointerIfAny) {
      objOffset += sizeof(FScriptArray);
      // re-align
      objOffset = doAlign(objOffset, sizeof(void*));
    }

    unreal::UIntPtr reflectPtr = objOffset;

    uhx::ArrayWrapperLayout *layout = new ( (void*) reflectPtr) uhx::ArrayWrapperLayout((unreal::UIntPtr) innerProperty);
    infoLayout = layout;
    info.genericImplementation = &layout->arrayReflect;
    layout->paramInfo = infoFromUProperty(innerProperty, uhx::UHX_WRAPPER_NORMAL);
    layout->paramArray[0] = &layout->paramInfo;
    layout->paramArray[1] = nullptr;
    info.genericParams = (const uhx::StructInfo**) layout->paramArray;

    check(reflectPtr + (sizeof(uhx::ArrayWrapperLayout)) <= (ret + startOffset + extraSize));
  } else if (wrapperKind == uhx::UHX_WRAPPER_SET || inProp->IsA<USetProperty>()) {
    UProperty *innerProperty = nullptr;
    if (wrapperKind == uhx::UHX_WRAPPER_SET) {
      innerProperty = inProp;
    } else {
      innerProperty = Cast<USetProperty>(inProp)->ElementProp;
    }
    extraSize += sizeof(void*) + sizeof(uhx::SetWrapperLayout);
    if (pointerIfAny) {
      ret = uhx::expose::HxcppRuntime::createPointerTemplateWrapper((unreal::UIntPtr) pointerIfAny, (unreal::UIntPtr) &info, extraSize).getGcPointerUnchecked();
      static int offset = uhx::expose::HxcppRuntime::getTemplatePointerSize();
      startOffset = offset;
    } else {
      extraSize += sizeof(FScriptSet) + sizeof(void*);
      ret = uhx::expose::HxcppRuntime::createInlineTemplateWrapper(extraSize, (unreal::UIntPtr) &info).getGcPointerUnchecked();
      static int offset = uhx::expose::HxcppRuntime::getTemplateSize();
      startOffset = offset;
    }

    unreal::UIntPtr objOffset = ret + startOffset;
    // re-align
    objOffset = doAlign(objOffset, info.alignment);
    if (!pointerIfAny) {
      objOffset += sizeof(FScriptSet);
      // re-align
      objOffset = doAlign(objOffset, sizeof(void*));
    }

    unreal::UIntPtr reflectPtr = objOffset;

    uhx::SetWrapperLayout *layout = new ( (void*) reflectPtr) uhx::SetWrapperLayout((unreal::UIntPtr) innerProperty);
    infoLayout = layout;
    info.genericImplementation = &layout->setReflect;
    layout->paramInfo = infoFromUProperty(innerProperty, uhx::UHX_WRAPPER_NORMAL);
    layout->paramArray[0] = &layout->paramInfo;
    layout->paramArray[1] = nullptr;
    info.genericParams = (const uhx::StructInfo**) layout->paramArray;

    check(reflectPtr + (sizeof(uhx::SetWrapperLayout)) <= (ret + startOffset + extraSize));
  } else if (inProp->IsA<UMapProperty>()) {
    auto prop = Cast<UMapProperty>(inProp);
    extraSize += sizeof(void*) + sizeof(uhx::MapWrapperLayout);
    if (pointerIfAny) {
      ret = uhx::expose::HxcppRuntime::createPointerTemplateWrapper((unreal::UIntPtr) pointerIfAny, (unreal::UIntPtr) &info, extraSize).getGcPointerUnchecked();
      static int offset = uhx::expose::HxcppRuntime::getTemplatePointerSize();
      startOffset = offset;
    } else {
      extraSize += sizeof(FScriptMap) + sizeof(void*);
      ret = uhx::expose::HxcppRuntime::createInlineTemplateWrapper(extraSize, (unreal::UIntPtr) &info).getGcPointerUnchecked();
      static int offset = uhx::expose::HxcppRuntime::getTemplateSize();
      startOffset = offset;
    }

    unreal::UIntPtr objOffset = ret + startOffset;
    // re-align
    objOffset = doAlign(objOffset, info.alignment);
    if (!pointerIfAny) {
      objOffset += sizeof(FScriptMap);
      // re-align
      objOffset = doAlign(objOffset, sizeof(void*));
    }

    unreal::UIntPtr reflectPtr = objOffset;

    uhx::MapWrapperLayout *layout = new ( (void*) reflectPtr) uhx::MapWrapperLayout((unreal::UIntPtr) inProp);
    infoLayout = layout;
    info.genericImplementation = &layout->mapReflect;
    layout->paramInfos[0] = infoFromUProperty(prop->KeyProp, uhx::UHX_WRAPPER_NORMAL);
    layout->paramInfos[1] = infoFromUProperty(prop->ValueProp, uhx::UHX_WRAPPER_NORMAL);
    layout->paramArray[0] = &layout->paramInfos[0];
    layout->paramArray[1] = &layout->paramInfos[1];
    layout->paramArray[2] = nullptr;
    info.genericParams = (const uhx::StructInfo**) layout->paramArray;

    check(reflectPtr + (sizeof(uhx::MapWrapperLayout)) <= (ret + startOffset + extraSize));
  } else if (pointerIfAny) {
    return unreal::VariantPtr::fromExternalPointer(pointerIfAny); // we don't need wrappers
  } else {
    extraSize += info.size +
                 info.alignment +
                 sizeof(void*) +
                 sizeof(info);
    if (info.alignment > sizeof(void*)) {
      ret = uhx::expose::HxcppRuntime::createAlignedInlineWrapper(extraSize, (unreal::UIntPtr) &info).getGcPointerUnchecked();
      static int staticOffset = uhx::expose::HxcppRuntime::getAlignedInlineWrapperSize();
      startOffset = staticOffset;
    } else if (info.flags == uhx::UHX_POD) {
      ret = uhx::expose::HxcppRuntime::createInlinePodWrapper(extraSize, (unreal::UIntPtr) &info).getGcPointerUnchecked();
      static int staticOffset = uhx::expose::HxcppRuntime::getInlinePodWrapperOffset();
      startOffset = staticOffset;
    } else {
      // Dynamically created wrappers have more strict alignment needs than statically created (because we are using Unreal's reflection API)
      // so we always create an aligned inline wrapper
      // ret = uhx::expose::HxcppRuntime::createAlignedInlineWrapper(extraSize, (unreal::UIntPtr) &info).getGcPointerUnchecked();
      ret = uhx::expose::HxcppRuntime::createInlineWrapper(extraSize, (unreal::UIntPtr) &info).getGcPointerUnchecked();
      static int staticOffset = uhx::expose::HxcppRuntime::getInlineWrapperOffset();
      startOffset = staticOffset;
      // static int staticOffset = uhx::expose::HxcppRuntime::getAlignedInlineWrapperSize();
      // startOffset = staticOffset;
    }
    unreal::UIntPtr objOffset = ret + startOffset;
    // align
    objOffset = doAlign(objOffset, info.alignment);
    unreal::UIntPtr infoOffset = objOffset + info.size;
    infoOffset = doAlign(infoOffset, sizeof(void*));
    infoLayout = (uhx::InitialWrapperLayout*) infoOffset;
  }

  infoLayout->mainInfo = info;
  if (!name.IsEmpty())
  {
    char *utf = TCHAR_TO_UTF8(*name);
    int len = strlen(utf);

    unreal::UIntPtr strPtr = ret + startOffset + extraSize - len - 1;
    memcpy((void*) strPtr, utf, len);
    infoLayout->mainInfo.name = (char*) strPtr;
  }
  // re-set the info on the wrapper
  uhx::expose::HxcppRuntime::setWrapperStructInfo(ret, (unreal::UIntPtr) &infoLayout->mainInfo);
  check( ((unreal::UIntPtr)infoLayout) + sizeof(info) <= ret + startOffset + extraSize);
  return unreal::VariantPtr::fromGcPointer(ret);
}

static void *hxcppPointerToCppPointer(UProperty *inProp, unreal::UIntPtr hxcppPointer, uint64& stackSpace) {
  if (inProp->IsA<UNumericProperty>()) {
    auto numeric = Cast<UNumericProperty>(inProp);
    UEnum *uenum = numeric->GetIntPropertyEnum();
    if (uenum != nullptr) {
      stackSpace = (int64) uhx::expose::HxcppRuntime::hxEnumToCppInt(hxcppPointer);
    } else if (numeric->IsFloatingPoint()) {
      double *stack = (double *) &stackSpace;
      *stack = uhx::expose::HxcppRuntime::unboxFloat(hxcppPointer);
    } else if (numeric->IsA<UInt64Property>() || numeric->IsA<UUInt64Property>()) {
      stackSpace = (int64) uhx::expose::HxcppRuntime::unboxInt64(hxcppPointer);
    } else {
      stackSpace = (int64) uhx::expose::HxcppRuntime::unboxInt((int64) hxcppPointer);
    }
    return &stackSpace;
  } else if (inProp->IsA<UObjectPropertyBase>()) {
    UObject **ptr = (UObject**) &stackSpace;
    *ptr = (UObject *) uhx::expose::HxcppRuntime::uobjectUnwrap(hxcppPointer);
    return ptr;
  } else {
    #if (UE_VER >= 417)
    if (inProp->IsA<UEnumProperty>()) {
      auto prop = Cast<UEnumProperty>(inProp);
      UEnum *uenum = prop->GetEnum();
      stackSpace = (int64) uhx::expose::HxcppRuntime::hxEnumToCppInt(hxcppPointer);
      return &stackSpace;
    }
    #endif

    return (void *) (getUnderlyingFromUIntPtr(hxcppPointer));
  }

  check(false);
  return nullptr;
}

static unreal::UIntPtr getValueWithProperty(UProperty *inProp, void *inPointer) {
  if (inProp->IsA<UNumericProperty>()) {
    auto numeric = Cast<UNumericProperty>(inProp);
    UEnum *uenum = numeric->GetIntPropertyEnum();
    if (uenum != nullptr) {
      return uhx::expose::HxcppRuntime::cppIntToHxEnum(TCHAR_TO_UTF8(*uenum->CppType), (int) numeric->GetSignedIntPropertyValue(inPointer));
    } else if (numeric->IsFloatingPoint()) {
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
    return uhx::expose::HxcppRuntime::boxVariantPtr(unreal::VariantPtr::fromExternalPointer(inPointer));
  } else if (inProp->IsA<UBoolProperty>()) {
    auto prop = Cast<UBoolProperty>(inProp);
    return uhx::expose::HxcppRuntime::boxBool(prop->GetPropertyValue(inPointer));
  } else if (inProp->IsA<UNameProperty>() || inProp->IsA<UStrProperty>() || inProp->IsA<UTextProperty>()) {
    return uhx::expose::HxcppRuntime::boxVariantPtr(unreal::VariantPtr::fromExternalPointer(inPointer));
  } else if (inProp->IsA<UArrayProperty>() || inProp->IsA<UMapProperty>() || inProp->IsA<USetProperty>()) {
    return uhx::expose::HxcppRuntime::boxVariantPtr(createWrapper(inProp, inPointer));
  } else if (inProp->IsA<UObjectPropertyBase>()) {
    auto objProp = Cast<UObjectPropertyBase>(inProp);
    return uhx::expose::HxcppRuntime::uobjectWrap((unreal::UIntPtr)  objProp->GetObjectPropertyValue((void *) inPointer));
  }

  #if (UE_VER >= 417)
  if (inProp->IsA<UEnumProperty>()) {
    auto prop = Cast<UEnumProperty>(inProp);
    UEnum *uenum = prop->GetEnum();
    return uhx::expose::HxcppRuntime::cppIntToHxEnum(TCHAR_TO_UTF8(*uenum->CppType), (int) prop->GetUnderlyingProperty()->GetSignedIntPropertyValue(inPointer));
  }
  #endif

  // TODO: delegates, map, and set
  check(false);
  return 0;
}

static void setValueWithProperty(UProperty *inProp, void *dest, unreal::UIntPtr value) {
  if (inProp->IsA<UNumericProperty>()) {
    auto numeric = Cast<UNumericProperty>(inProp);
    UEnum *uenum = numeric->GetIntPropertyEnum();
    if (uenum != nullptr) {
      numeric->SetIntPropertyValue(dest, (int64) uhx::expose::HxcppRuntime::hxEnumToCppInt(value));
    } else if (numeric->IsFloatingPoint()) {
      numeric->SetFloatingPointPropertyValue(dest, uhx::expose::HxcppRuntime::unboxFloat(value));
    } else if (numeric->IsA<UInt64Property>() || numeric->IsA<UUInt64Property>()) {
      numeric->SetIntPropertyValue(dest, (int64) uhx::expose::HxcppRuntime::unboxInt64(value));
    } else {
      numeric->SetIntPropertyValue(dest, (int64) uhx::expose::HxcppRuntime::unboxInt((int64) value));
    }
  } else if (inProp->IsA<UObjectProperty>()) {
    *((UObject **)dest) = (UObject *) uhx::expose::HxcppRuntime::uobjectUnwrap(value);
  } else if (inProp->IsA<UStructProperty>() || inProp->IsA<UDelegateProperty>() || inProp->IsA<UMulticastDelegateProperty>()) {
    inProp->CopyCompleteValue(dest, (void *) (getUnderlyingFromUIntPtr(value)));
  } else if (inProp->IsA<UBoolProperty>()) {
    auto prop = Cast<UBoolProperty>(inProp);
    prop->SetPropertyValue(dest, uhx::expose::HxcppRuntime::unboxBool(value));
  } else if (inProp->IsA<UNameProperty>() ||
      inProp->IsA<UStrProperty>() ||
      inProp->IsA<UTextProperty>() ||
      inProp->IsA<UArrayProperty>() ||
      inProp->IsA<UMapProperty>() ||
      inProp->IsA<USetProperty>()) {
    inProp->CopyCompleteValue(dest, (void *) (getUnderlyingFromUIntPtr(value)));
  } else if (inProp->IsA<UObjectPropertyBase>()) {
    auto objProp = Cast<UObjectPropertyBase>(inProp);
    auto obj = (UObject *) uhx::expose::HxcppRuntime::uobjectUnwrap(value);
    objProp->SetObjectPropertyValue(dest, obj);
  } else {
    // TODO: delegates, map, and set
    check(false);
  }
}


// TArrayReflect implementation

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
    ret = uhx::expose::HxcppRuntime::uobjectWrap((unreal::UIntPtr) *((UObject **) rawPtr));
  } else if (prop->IsA<UObjectPropertyBase>()) {
    auto objProp = Cast<UObjectPropertyBase>(prop);
    ret = uhx::expose::HxcppRuntime::uobjectWrap((unreal::UIntPtr)  objProp->GetObjectPropertyValue((void *) rawPtr));
  } else {
    ret = uhx::expose::HxcppRuntime::boxVariantPtr(createWrapper(prop, 0));
    unreal::UIntPtr retPtr = (getUnderlyingFromUIntPtr(ret));
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

void uhx::TArrayReflect_obj::Empty(unreal::VariantPtr self, cpp::Int32 NewSize) {
  GET_ARRAY_HELPER(self).EmptyValues(NewSize);
}

void uhx::TArrayReflect_obj::Reset(unreal::VariantPtr self, cpp::Int32 NewSize) {
  GET_ARRAY_HELPER(self).EmptyValues(NewSize);
}

void uhx::TArrayReflect_obj::Swap(unreal::VariantPtr self, int first, int second) {
  GET_ARRAY_HELPER(self).SwapValues(first, second);
}

unreal::UIntPtr uhx::TArrayReflect_obj::GetData(unreal::VariantPtr self) {
  return (unreal::UIntPtr) GET_ARRAY_HELPER(self).GetRawPtr();
}

unreal::VariantPtr uhx::TArrayReflect_obj::copyNew(unreal::VariantPtr self) {
  // TODO
  uhx::expose::HxcppRuntime::throwString("TArray copyNew is not implemented");
  return 0;
}

unreal::VariantPtr uhx::TArrayReflect_obj::copy(unreal::VariantPtr self) {
  auto helper = GET_ARRAY_HELPER(self);
  auto prop = GET_UPROP();

  unreal::VariantPtr ret = createWrapper(prop, nullptr, uhx::UHX_WRAPPER_ARRAY);
  void *pointer = (void *) (ret.getUnderlyingPointer());
  new (pointer) FScriptArray();

  auto targetHelper = getArrayHelper(prop, ret);
  int num = helper.Num();

  if ( !(prop->PropertyFlags & CPF_IsPlainOldData) ) {
    targetHelper.EmptyAndAddValues(num);
  } else {
    targetHelper.EmptyAndAddUninitializedValues(num);
  }

  if (num > 0) {
    int size = prop->ElementSize;
    uint8* srcData = (uint8*) helper.GetRawPtr();
    uint8* destData = (uint8*) targetHelper.GetRawPtr();
    if ( !(prop->PropertyFlags & CPF_IsPlainOldData) ) {
      for ( int i = 0; i < num; i++ ) {
        prop->CopyCompleteValue(destData + i * size, srcData + i * size);
      }
    } else {
      FMemory::Memcpy(destData, srcData, num * size);
    }
  }

  return ret;
}

void uhx::TArrayReflect_obj::assign(unreal::VariantPtr self, unreal::VariantPtr val) {
  auto targetHelper = GET_ARRAY_HELPER(self);
  auto prop = GET_UPROP();
  auto srcHelper = getArrayHelper(prop, val);

  int num = srcHelper.Num();

  targetHelper.Resize(0);
  if ( !(prop->PropertyFlags & CPF_IsPlainOldData) ) {
    targetHelper.EmptyAndAddValues(num);
  } else {
    targetHelper.EmptyAndAddUninitializedValues(num);
  }

  if (num > 0) {
    int size = prop->ElementSize;
    uint8* srcData = (uint8*) srcHelper.GetRawPtr();
    uint8* destData = (uint8*) targetHelper.GetRawPtr();
    if ( !(prop->PropertyFlags & CPF_IsPlainOldData) ) {
      for ( int i = 0; i < num; i++ ) {
        prop->CopyCompleteValue(destData + i * size, srcData + i * size);
      }
    } else {
      FMemory::Memcpy(destData, srcData, num * size);
    }
  }
}


// TMapReflect implementation

void uhx::TMapReflect_obj::Add(unreal::VariantPtr self, unreal::UIntPtr InKey, unreal::UIntPtr InValue) {
  uint64 stackSpace1, stackSpace2;
  GET_MAP_HELPER(self).AddPair(
    hxcppPointerToCppPointer(GET_MAP_UPROP()->KeyProp, InKey, stackSpace1),
    hxcppPointerToCppPointer(GET_MAP_UPROP()->ValueProp, InValue, stackSpace2)
  );
}

unreal::UIntPtr uhx::TMapReflect_obj::FindOrAdd(unreal::VariantPtr self, unreal::UIntPtr Key) {
  uint64 stackSpace1;
  auto helper = GET_MAP_HELPER(self);
  UProperty* localKeyProp = GET_MAP_UPROP()->KeyProp;
  UProperty* localValueProp = GET_MAP_UPROP()->ValueProp;
  FScriptMapLayout& localMapLayout = helper.MapLayout;
  void *keyPtr = hxcppPointerToCppPointer(GET_MAP_UPROP()->KeyProp, Key, stackSpace1);
  void *result = (void *) helper.FindValueFromHash(keyPtr);
  if (!result) {
		helper.Map->Add(
			keyPtr,
			nullptr,
			helper.MapLayout,
			[localKeyProp](const void* ElementKey) { return localKeyProp->GetValueTypeHash(ElementKey); },
			[localKeyProp](const void* A, const void* B) { return localKeyProp->Identical(A, B); },
			[localKeyProp, keyPtr, localMapLayout](void* NewElementKey)
			{
				if (localKeyProp->PropertyFlags & CPF_ZeroConstructor)
				{
					FMemory::Memzero(NewElementKey, localKeyProp->GetSize());
				}
				else
				{
					localKeyProp->InitializeValue(NewElementKey);
				}

				localKeyProp->CopySingleValueToScriptVM(NewElementKey, keyPtr);
			},
			[localValueProp, result, localMapLayout](void* NewElementValue) mutable
			{
				if (localValueProp->PropertyFlags & CPF_ZeroConstructor)
				{
					FMemory::Memzero(NewElementValue, localValueProp->GetSize());
				}
				else
				{
					localValueProp->InitializeValue(NewElementValue);
				}

        result = NewElementValue;
			},
			[localValueProp, result](void* ExistingElementValue) mutable
			{
        result = ExistingElementValue;
			},
			[localKeyProp](void* ElementKey)
			{
				if (!(localKeyProp->PropertyFlags & (CPF_IsPlainOldData | CPF_NoDestructor)))
				{
					localKeyProp->DestroyValue(ElementKey);
				}
			},
			[localValueProp](void* ElementValue)
			{
				if (!(localValueProp->PropertyFlags & (CPF_IsPlainOldData | CPF_NoDestructor)))
				{
					localValueProp->DestroyValue(ElementValue);
				}
			}
		);
  }

  return result != nullptr ? getValueWithProperty(localValueProp, result) : 0;
}

void uhx::TMapReflect_obj::set_Item(unreal::VariantPtr self, unreal::UIntPtr key, unreal::UIntPtr val) {
  Add(self, key, val);
}

bool uhx::TMapReflect_obj::Contains(unreal::VariantPtr self, unreal::UIntPtr InKey) {
  uint64 stackSpace1;
  void *keyPtr = hxcppPointerToCppPointer(GET_MAP_UPROP()->KeyProp, InKey, stackSpace1);
  return GET_MAP_HELPER(self).FindValueFromHash(keyPtr) != nullptr;
}

unreal::UIntPtr uhx::TMapReflect_obj::FindChecked(unreal::VariantPtr self, unreal::UIntPtr InKey) {
  uint64 stackSpace1;
  void *keyPtr = hxcppPointerToCppPointer(GET_MAP_UPROP()->KeyProp, InKey, stackSpace1);
  void *result = (void *) GET_MAP_HELPER(self).FindValueFromHash(keyPtr);
  check(result != nullptr);
  return getValueWithProperty(GET_MAP_UPROP()->ValueProp, result);
}

int uhx::TMapReflect_obj::Remove(unreal::VariantPtr self, unreal::UIntPtr InKey) {
  uint64 stackSpace1;
  void *keyPtr = hxcppPointerToCppPointer(GET_MAP_UPROP()->KeyProp, InKey, stackSpace1);
  return GET_MAP_HELPER(self).RemovePair(keyPtr) ? 1 : 0;
}

void uhx::TMapReflect_obj::Empty(unreal::VariantPtr self, int ExpectedNumElements) {
  return GET_MAP_HELPER(self).EmptyValues(ExpectedNumElements);
}

unreal::VariantPtr uhx::TMapReflect_obj::GenerateKeyArray(unreal::VariantPtr self) {
  auto keyProp = GET_MAP_UPROP()->KeyProp;

  unreal::VariantPtr ret = createWrapper(keyProp, nullptr, uhx::UHX_WRAPPER_ARRAY);
  void *pointer = (void *) (ret.getUnderlyingPointer());
  // initialize
  new (pointer) FScriptArray();

  FScriptArrayHelper array = FScriptArrayHelper::CreateHelperFormInnerProperty(keyProp, pointer);
  FScriptMapHelper map = GET_MAP_HELPER(self);

  int32 size = map.Num();
  for (int32 i = 0; size; i++) {
    if (map.IsValidIndex(i)) {
      int32 lastIndex = array.AddValue();
      keyProp->CopySingleValueToScriptVM(array.GetRawPtr(lastIndex), map.GetKeyPtr(i));
      size--;
    }
  }

  return ret;
}

unreal::VariantPtr uhx::TMapReflect_obj::GenerateValueArray(unreal::VariantPtr self) {
  auto keyProp = GET_MAP_UPROP()->ValueProp;

  unreal::VariantPtr ret = createWrapper(keyProp, nullptr, uhx::UHX_WRAPPER_ARRAY);
  void *pointer = (void *) (ret.getUnderlyingPointer());
  // initialize
  new (pointer) FScriptArray();

  FScriptArrayHelper array = FScriptArrayHelper::CreateHelperFormInnerProperty(keyProp, pointer);
  FScriptMapHelper map = GET_MAP_HELPER(self);

  int32 size = map.Num();
  for (int32 i = 0; size; i++) {
    if (map.IsValidIndex(i)) {
      int32 lastIndex = array.AddValue();
      keyProp->CopySingleValueToScriptVM(array.GetRawPtr(lastIndex), map.GetValuePtr(i));
      size--;
    }
  }

  return ret;
}

unreal::VariantPtr uhx::TMapReflect_obj::copyNew(unreal::VariantPtr self) {
  uhx::expose::HxcppRuntime::throwString("TMap copyNew is not implemented");
  return 0;
}

unreal::VariantPtr uhx::TMapReflect_obj::copy(unreal::VariantPtr self) {
  auto uprop = GET_MAP_UPROP();
  auto ret = createWrapper(uprop, nullptr, uhx::UHX_WRAPPER_NORMAL);
  void *pointer = (void *) (ret.getUnderlyingPointer());
  // initialize
  uprop->InitializeValue(pointer);
  uprop->CopyCompleteValue(pointer, (void *) (self.getUnderlyingPointer()));

  return ret;
}

void uhx::TMapReflect_obj::assign(unreal::VariantPtr self, unreal::VariantPtr val) {
  auto uprop = GET_MAP_UPROP();
  uprop->CopyCompleteValue((void *) (self.getUnderlyingPointer()), (void *) (val.getUnderlyingPointer()));
}

unreal::VariantPtr uhx::ue::RuntimeLibrary_obj::wrapProperty(unreal::UIntPtr inProp, unreal::UIntPtr pointerIfAny) {
  return createWrapper(Cast<UProperty>( (UObject *) inProp ), (void*) pointerIfAny);
}


// TSetReflect implementation

void uhx::TSetReflect_obj::Empty(unreal::VariantPtr self, int ExpectedNumElements) {
  GET_SET_HELPER(self).EmptyElements(ExpectedNumElements);
}

void uhx::TSetReflect_obj::Shrink(unreal::VariantPtr self) {
  // let's just ignore this for now - it should be fine
}

void uhx::TSetReflect_obj::Reset(unreal::VariantPtr self) {
  GET_SET_HELPER(self).EmptyElements(0);
}

void uhx::TSetReflect_obj::Compact(unreal::VariantPtr self) {
  // ignore
}

void uhx::TSetReflect_obj::Reserve(unreal::VariantPtr self, int Number) {
  // ignore
}

cpp::UInt32 uhx::TSetReflect_obj::GetAllocatedSize(unreal::VariantPtr self) {
  return GET_SET_HELPER(self).Num();
}

int uhx::TSetReflect_obj::Num(unreal::VariantPtr self) {
  return GET_SET_HELPER(self).Num();
}

unreal::VariantPtr uhx::TSetReflect_obj::Add(unreal::VariantPtr self, unreal::UIntPtr InElement) {
  uint64 stackSpace;

  auto helper = GET_SET_HELPER(self);
  helper.AddElement(hxcppPointerToCppPointer(GET_UPROP(), InElement, stackSpace));

  return FindId(self, InElement);
}

void uhx::TSetReflect_obj::Remove(unreal::VariantPtr self, unreal::VariantPtr ElementId) {
  FSetElementId *pointer = (FSetElementId *) (ElementId.getUnderlyingPointer());
  GET_SET_HELPER(self).RemoveAt(pointer->AsInteger());
}

unreal::VariantPtr uhx::TSetReflect_obj::FindId(unreal::VariantPtr self, unreal::UIntPtr Element) {
  uint64 stackSpace;
  auto prop = GET_UPROP();

  int index = GET_SET_HELPER(self).FindElementIndex(hxcppPointerToCppPointer(GET_UPROP(), Element, stackSpace));
  if (index < 0) {
    return ::uhx::StructHelper<FSetElementId>::fromStruct(FSetElementId());
  } else {
    return ::uhx::StructHelper<FSetElementId>::fromStruct(FSetElementId::FromInteger(index));
  }
}

unreal::VariantPtr uhx::TSetReflect_obj::copyNew(unreal::VariantPtr self) {
  uhx::expose::HxcppRuntime::throwString("TSet copyNew is not implemented");
  return 0;
}

unreal::VariantPtr uhx::TSetReflect_obj::copy(unreal::VariantPtr self) {
  auto srcHelper = GET_SET_HELPER(self);
  auto prop = GET_UPROP();

  unreal::VariantPtr ret = createWrapper(prop, nullptr, uhx::UHX_WRAPPER_SET);
  void *pointer = (void *) (ret.getUnderlyingPointer());
  new (pointer) FScriptSet();

  auto targetHelper = getSetHelper(prop, ret);
  int num = srcHelper.Num();

  for (int srcIndex = 0; num; srcIndex++) {
    if (srcHelper.IsValidIndex(srcIndex)) {
      int destIndex = targetHelper.AddDefaultValue_Invalid_NeedsRehash();

      uint8* srcData = (uint8*) srcHelper.Set->GetData(srcIndex, srcHelper.SetLayout);
      uint8* destData = (uint8*) targetHelper.Set->GetData(destIndex, targetHelper.SetLayout);

      prop->CopyCompleteValue_InContainer(destData, srcData);
      num--;
    }
  }

  targetHelper.Rehash();

  return ret;
}

void uhx::TSetReflect_obj::assign(unreal::VariantPtr self, unreal::VariantPtr val) {
  auto targetHelper = GET_SET_HELPER(self);
  auto prop = GET_UPROP();

  auto srcHelper = getSetHelper(prop, val);
  int num = srcHelper.Num();

  for (int srcIndex = 0; num; srcIndex++) {
    if (srcHelper.IsValidIndex(srcIndex)) {
      int destIndex = targetHelper.AddDefaultValue_Invalid_NeedsRehash();

      uint8* srcData = (uint8*) srcHelper.Set->GetData(srcIndex, srcHelper.SetLayout);
      uint8* destData = (uint8*) targetHelper.Set->GetData(destIndex, targetHelper.SetLayout);

      prop->CopyCompleteValue_InContainer(destData, srcData);
      num--;
    }
  }

  targetHelper.Rehash();
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

int uhx::ue::RuntimeLibrary_obj::getGcRefSize() {
  return sizeof(uhx::GcRef);
}

#undef GET_UPROP
#undef GET_MAP_UPROP
#undef GET_ARRAY_HELPER

#endif
