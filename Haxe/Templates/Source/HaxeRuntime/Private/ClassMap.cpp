#include "HaxeRuntime.h"
#ifndef UHX_NO_UOBJECT

#include "IntPtr.h"
#include "uhx/ue/ClassMap.h"
#include "CoreUObject.h"
#include "Core.h"
#include "uhx/expose/HxcppRuntime.h"

static TMap<UClass *,HaxeWrap>& getClassMap() {
  // lazy instantiation
  static TMap<UClass *,HaxeWrap> classMap;
  return classMap;
}

static TArray<CppInit>& getInits() {
  static TArray<CppInit> inits;
  return inits;
}

bool ::uhx::ue::ClassMap_obj::addWrapper(unreal::UIntPtr inUClass, HaxeWrap inWrapper) {
  getClassMap().Emplace((UClass *)inUClass, inWrapper);
  return true;
}

unreal::UIntPtr uhx::ue::ClassMap_obj::wrap(unreal::UIntPtr inUObject) {
  if (inUObject == 0) return 0;
  UObject *obj = (UObject *) inUObject;
  UClass *cls = obj->GetClass();
  auto& map = getClassMap();
  while (cls != nullptr) {
    if (cls->HasAllClassFlags(CLASS_Native)) {
      auto it = map.Find(cls);
      if (it != nullptr) {
        return (*it)(inUObject);
      }
    }
    cls = cls->GetSuperClass();
  }
#if !WITH_EDITOR
  UE_LOG(LogTemp,Fatal,TEXT("No haxe wrapper was found for the uobject from class %s nor from any of its superclasses"), *obj->GetClass()->GetName());
#endif
  // we might get here on
  return 0;
}

void uhx::ue::ClassMap_obj::addCppInit(CppInit inInit) {
  getInits().Push(inInit);
}

void uhx::ue::ClassMap_obj::runInits() {
  TArray<CppInit> curInits = MoveTemp(getInits());
  for (const CppInit& init : curInits) {
    init();
  }
}

static TMap<UClass*, FString>& getCppiaWrapperMap() {
  static TMap<UClass*, FString> ret;
  return ret;
}

static unreal::UIntPtr cppiaWrapper(unreal::UIntPtr inUObject) {
  UObject *obj = (UObject*) inUObject;
  UClass *cls = obj->GetClass();

  auto& map = getCppiaWrapperMap();
  while (cls != nullptr) {
    auto it = map.Find(cls);
    if (it != nullptr) {
      FString& hxClass = *it;
      return uhx::expose::HxcppRuntime::createDynamicHelper(inUObject, TCHAR_TO_UTF8(*hxClass));
    }
    cls = cls->GetSuperClass();
  }

#if !WITH_EDITOR
  UE_LOG(LogTemp,Fatal,TEXT("No cppia wrapper was found for the uobject from class %s nor from any of its superclasses"), *obj->GetClass()->GetName());
#endif
  return 0;
}

void uhx::ue::ClassMap_obj::addCppiaExternWrapper(const char *inUClass, const char *inHxClass) {
  UClass *cls = Cast<UClass>(StaticFindObjectFast(UClass::StaticClass(), nullptr, FName(UTF8_TO_TCHAR(inUClass)), false, true, RF_NoFlags));
  getCppiaWrapperMap().Emplace(cls, FString(UTF8_TO_TCHAR(inHxClass)));
  addWrapper((unreal::UIntPtr) cls, &cppiaWrapper);
}

static TMap<UClass*, HaxeWrap>& getCustomCtors() {
  static TMap<UClass*, HaxeWrap> ret;
  return ret;
}

bool uhx::ue::ClassMap_obj::hasCustomCtor = false;

void uhx::ue::ClassMap_obj::addCustomCtor(unreal::UIntPtr inUClass, HaxeWrap inCtor) {
  hasCustomCtor = true;
  getCustomCtors().Emplace((UClass*)inUClass, inCtor);
}

void uhx::ue::ClassMap_obj::addCppiaCustomCtor(const char *inUClass, const char *inHxClass) {
  UClass *cls = Cast<UClass>(StaticFindObjectFast(UClass::StaticClass(), nullptr, FName(UTF8_TO_TCHAR(inUClass)), false, true, RF_NoFlags));
  getCppiaWrapperMap().Emplace(cls, FString(UTF8_TO_TCHAR(inHxClass)));
  addCustomCtor((unreal::UIntPtr) cls, &cppiaWrapper);
}

HaxeWrap *uhx::ue::ClassMap_obj::getCustomCtorImpl(unreal::UIntPtr inUClass) {
  return getCustomCtors().Find((UClass*)inUClass);
}
#endif
