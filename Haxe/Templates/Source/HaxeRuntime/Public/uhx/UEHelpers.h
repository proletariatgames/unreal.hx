#pragma once

#include "IntPtr.h"
#include "uhx/GcRef.h"
#include "uhx/expose/HxcppRuntime.h"
#include "HaxeInit.h"
#include "UObject/ScriptInterface.h"
#include "Core.h"
#include "uhx/ue/ClassMap.h"
#include "UObject/UnrealType.h"
#include "UObject/Class.h"

typedef unreal::UIntPtr (*CreateHaxeFn)(unreal::UIntPtr);

namespace uhx {

struct UEHelpers {

FORCEINLINE static TSet<FName>& getHaxeGeneratedSet() {
  static TSet<FName> set;
  return set;
}

static FName setIsHaxeGenerated(const FName& inName) {
  getHaxeGeneratedSet().Add(inName);
  return inName;
}

FORCEINLINE static bool isHaxeGenerated(const FName& inName) {
  return getHaxeGeneratedSet().Contains(inName);
}

static void createWrapperIfNeeded(const FName& className, UClass *curClass, uhx::GcRef& haxeGcRef, UObject *self, CreateHaxeFn createHaxeWrapper) {
  HaxeWrap *customCtor = nullptr;
  while (!curClass->HasAllClassFlags(CLASS_Native) || !isHaxeGenerated(curClass->GetFName())) {
    if (customCtor == nullptr) {
      customCtor = uhx::ue::ClassMap_obj::getCustomCtor((unreal::UIntPtr)curClass);
    }
    curClass = curClass->GetSuperClass();
  }
  if (curClass->GetFName() == className) {
    if (customCtor != nullptr) {
      createHaxeWrapper = *customCtor;
    }
    haxeGcRef.set(createHaxeWrapper( (unreal::UIntPtr) self ));
  }
}

template<class InterfaceType>
static TScriptInterface<InterfaceType> createScriptInterface(InterfaceType *iface) {
  TScriptInterface<InterfaceType> ret;
  ret.SetInterface(iface);
  ret.SetObject(Cast<UObject>(iface));
  return ret;
}

#if WITH_EDITOR
static void createDynamicWrapperIfNeeded(const FName& className, UClass *curClass, uhx::GcRef& haxeGcRef, UObject *self, CreateHaxeFn createHaxeWrapper) {
  if (GIsDuplicatingClassForReinstancing) {
    return;
  }
  FString hxClassName;
  FName currentName;
  HaxeWrap *customCtor = nullptr;
  while (true) {
    hxClassName = curClass->GetMetaData(TEXT("HaxeDynamicClass"));
    if (!hxClassName.IsEmpty()) {
      // this is a dynamic class. Its dynamic properties are however already set by its class constructor `dynamicConstruct`
      haxeGcRef.set(uhx::expose::HxcppRuntime::createDynamicHelper( (unreal::UIntPtr) self, TCHAR_TO_UTF8(*hxClassName) ));
      return;
    }
    if (curClass->HasAllClassFlags(CLASS_Native) && isHaxeGenerated( curClass->GetFName() )) {
      break;
    }
    if (customCtor == nullptr) {
      customCtor = uhx::ue::ClassMap_obj::getCustomCtor((unreal::UIntPtr)curClass);
    }
    curClass = curClass->GetSuperClass();
  }
  if (curClass->GetFName() == className) {
    initializeDynamicProperties(curClass, self);
    if (customCtor != nullptr) {
      createHaxeWrapper = *customCtor;
    }
    unreal::UIntPtr created = createHaxeWrapper( (unreal::UIntPtr) self );
    if (created == 0) {
      self->MarkPendingKill();
    }
    haxeGcRef.set(created);
  }
}

static void initializeDynamicProperties(UClass *curClass, UObject *self) {
  uint8 *objPtr = (uint8*) self;
  auto childClass = curClass;
  while(childClass != nullptr && childClass->HasMetaData(TEXT("HaxeGenerated"))) {
    auto child = childClass->PropertyLink;
    while(child != nullptr) {
      if (child->HasMetaData(TEXT("HaxeGenerated"))) {
        child->InitializeValue( (void *) (objPtr + child->GetOffset_ReplaceWith_ContainerPtrToValuePtr()) );
      }
      child = child->PropertyLinkNext;
    }
    childClass = childClass->GetSuperClass();
  }
}
#endif

};

}
