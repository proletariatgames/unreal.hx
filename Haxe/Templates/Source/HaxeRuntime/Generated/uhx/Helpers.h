#pragma once

#include "IntPtr.h"
#include "GcRef.h"
#include "unreal/helpers/HxcppRuntime.h"

typedef unreal::UIntPtr (*CreateHaxeFn)(unreal::UIntPtr);

namespace uhx {
struct Helpers {

static void createWrapperIfNeeded(const FName& className, UClass *curClass, unreal::helpers::GcRef& haxeGcRef, UObject *self, CreateHaxeFn createHaxeWrapper) {
  while (!curClass->HasAllClassFlags(CLASS_Native)) {
    curClass = curClass->GetSuperClass();
  }
  if (curClass->GetFName() == className) {
    haxeGcRef.set(createHaxeWrapper( (unreal::UIntPtr) self ));
  }
}

static void createDynamicWrapperIfNeeded(const FName& className, UClass *curClass, unreal::helpers::GcRef& haxeGcRef, UObject *self, CreateHaxeFn createHaxeWrapper) {
  FString hxClassName;
  while (true) {
    hxClassName = curClass->GetMetaData(TEXT("HaxeClass"));
    if (!hxClassName.IsEmpty()) {
      // this is a dynamic class. So before we continue, we must initialize all properties
      haxeGcRef.set(unreal::helpers::HxcppRuntime::createDynamicHelper( (unreal::UIntPtr) self, TCHAR_TO_UTF8(*hxClassName) ));
      return;
    }
    if (curClass->HasAllClassFlags(CLASS_Native)) {
      break;
    }
    curClass = curClass->GetSuperClass();
  }
  if (curClass->GetFName() == className) {
    haxeGcRef.set(createHaxeWrapper( (unreal::UIntPtr) self ));
  }
}

static void initializeDynamicProperties(UClass *curClass, UObject *self) {
  uint8 *objPtr = (uint8*) self;
  auto childClass = curClass;
  while(childClass != nullptr && childClass->HasMetaData(TEXT("HaxeGenerated"))) {
    auto child = childClass->PropertyLink;
    while(child != nullptr) {
      child->InitializeValue( (void *) (objPtr + child->GetOffset_ReplaceWith_ContainerPtrToValuePtr()) );
      child = child->PropertyLinkNext;
    }
    childClass = childClass->GetSuperClass();
  }
}

};
}
