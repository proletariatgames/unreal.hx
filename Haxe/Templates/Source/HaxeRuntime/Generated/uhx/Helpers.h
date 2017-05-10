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

};
}
