#pragma once

#include "IntPtr.h"
#include "uhx/GcRef.h"
#include "uhx/expose/HxcppRuntime.h"
#include "HaxeInit.h"

typedef unreal::UIntPtr (*CreateHaxeFn)(unreal::UIntPtr);

namespace uhx {

struct UEHelpers {

static void createWrapperIfNeeded(const FName& className, UClass *curClass, uhx::GcRef& haxeGcRef, UObject *self, CreateHaxeFn createHaxeWrapper) {
  while (!curClass->HasAllClassFlags(CLASS_Native)) {
    curClass = curClass->GetSuperClass();
  }
  if (curClass->GetFName() == className) {
    haxeGcRef.set(createHaxeWrapper( (unreal::UIntPtr) self ));
  }
}

static void createDynamicWrapperIfNeeded(const FName& className, UClass *curClass, uhx::GcRef& haxeGcRef, UObject *self, CreateHaxeFn createHaxeWrapper) {
  FString hxClassName;
  while (true) {
    hxClassName = curClass->GetMetaData(TEXT("HaxeDynamicClass"));
    if (!hxClassName.IsEmpty()) {
      // this is a dynamic class. Its dynamic properties are however already set by its class constructor `dynamicConstruct`
      haxeGcRef.set(uhx::expose::HxcppRuntime::createDynamicHelper( (unreal::UIntPtr) self, TCHAR_TO_UTF8(*hxClassName) ));
      return;
    }
    if (curClass->HasAllClassFlags(CLASS_Native)) {
      break;
    }
    curClass = curClass->GetSuperClass();
  }
  if (curClass->GetFName() == className) {
    initializeDynamicProperties(curClass, self);
    unreal::UIntPtr created = createHaxeWrapper( (unreal::UIntPtr) self );
    if (created == 0) {
      UE_LOG(HaxeLog, Error, TEXT("Error while creating class %s: It was not found. Perhaps the type was not compiled in the latest cppia compilation"), *className.ToString());
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

};

}
