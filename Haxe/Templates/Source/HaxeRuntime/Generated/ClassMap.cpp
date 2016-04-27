#include "HaxeRuntime.h"
#include <CoreUObject.h>
#include <unordered_map>
#include <vector>
#include "ClassMap.h"

struct WrapperCacheEntry {
  int32 typeID;
  void* wrapper;
};

static std::unordered_map<UClass *,HaxeWrap>& getClassMap() {
  // lazy instantiation
  static std::unordered_map<UClass *,HaxeWrap> classMap;
  return classMap;
}

static std::unordered_map<void*, WrapperCacheEntry>& getWrapperMap() {
  static std::unordered_map<void*, WrapperCacheEntry> wrapperMap;
  return wrapperMap;
}

static std::vector<WrapperCacheEntry>& getRequestedWrappers() {
  static std::vector<WrapperCacheEntry> requestedWrappers;
  return requestedWrappers;
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

void* ::unreal::helpers::ClassMap_obj::checkWrapperCache(void* inNative, int32 typeID) {
  check(IsInGameThread());
  
  auto& wrappers = getWrapperMap();
  auto it = wrappers.find(inNative);
  if (it != wrappers.end() && it->second.typeID == typeID) {
	  getRequestedWrappers().push_back(it->second);
	  return it->second.wrapper;
  }
  
  return nullptr;
}

bool ::unreal::helpers::ClassMap_obj::checkIsWrapper(void* inPtr, int32 typeID) {
	auto& requested = getRequestedWrappers();
  auto ln = requested.size();
  for (int i = 0; i != ln; ++i) {
    auto& entry = requested[i];
    if (entry.wrapper == inPtr && entry.typeID == typeID) {
      if (i != ln-1) {
        requested[i] = requested[ln-1];
      }
      requested.pop_back();
      return true;
    }
  }
  return false;
}

void ::unreal::helpers::ClassMap_obj::registerWrapper(void* inNative, void* inWrapper, int32 typeID) {
  check(IsInGameThread());
  getWrapperMap()[inNative] = {typeID, inWrapper};
}

void ::unreal::helpers::ClassMap_obj::unregisterWrapper(void* inNative) {
  check(IsInGameThread());
  getWrapperMap().erase(inNative);
}