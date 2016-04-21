#include "HaxeRuntime.h"
#include <CoreUObject.h>
#include <unordered_map>
#include "ClassMap.h"

static std::unordered_map<UClass *,HaxeWrap>& getClassMap() {
  // lazy instantiation
  static std::unordered_map<UClass *,HaxeWrap> classMap;
  return classMap;
}

static std::unordered_map<void*, void*>& getWrapperMap() {
  static std::unordered_map<void*, void*> wrapperMap;
  return wrapperMap;
}

bool ::unreal::helpers::ClassMap_obj::addWrapper(void *inUClass, HaxeWrap inWrapper) {
  getClassMap()[(UClass *)inUClass] = inWrapper;
  return true;
}

void *::unreal::helpers::ClassMap_obj::wrap(void *inUObject) {
  if (inUObject == nullptr) return nullptr;  
  UObject *obj = (UObject *) inUObject;
  UClass *cls = obj->GetClass();
  auto& map = getClassMap();
  while (cls != nullptr) {
    if (cls->HasAllClassFlags(CLASS_Native)) {
      auto it = map.find(cls);
      if (it != map.end()) {
        return (it->second)(inUObject);
      }
    }
    cls = cls->GetSuperClass();
  }
  UE_LOG(LogTemp,Fatal,TEXT("No haxe wrapper was found for the uobject from class %s nor from any of its superclasses"), *obj->GetClass()->GetName());
  // won't get here
  return nullptr;
}

void* ::unreal::helpers::ClassMap_obj::findWrapper(void* inNative) {
  auto& wrappers = getWrapperMap();
  auto it = wrappers.find(inNative);
  if (it != wrappers.end()) {
    return it->second;
  }
  return nullptr;
}

void ::unreal::helpers::ClassMap_obj::registerWrapper(void* inNative, void* inWrapper) {
  getWrapperMap()[inNative] = inWrapper;
}

void ::unreal::helpers::ClassMap_obj::unregisterWrapper(void* inNative, void* inWrapper) {
  getWrapperMap().erase(inNative);
}