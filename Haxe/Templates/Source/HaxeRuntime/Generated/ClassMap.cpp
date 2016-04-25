#include "HaxeRuntime.h"
#include <CoreUObject.h>
#include <unordered_map>
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

static void* s_lastNativeLookup = nullptr;
static void* s_lastWrappedLookup = nullptr;
static int32 s_lastWrappedTypeID = -1;

void* ::unreal::helpers::ClassMap_obj::findWrapper(void* inNative, int32 typeID) {
  check(IsInGameThread());
  if (s_lastNativeLookup == inNative && s_lastWrappedTypeID == typeID && s_lastWrappedLookup) {
    if (typeID == 1210865730) {
      UE_LOG(LogTemp, Warning, TEXT("RETC %x %x"), inNative, s_lastWrappedLookup);
    }
    return s_lastWrappedLookup;
  }
  
  auto& wrappers = getWrapperMap();
  auto it = wrappers.find(inNative);
  if (it != wrappers.end() && it->second.typeID == typeID) {
    s_lastNativeLookup = inNative;
    s_lastWrappedTypeID = it->second.typeID;
    s_lastWrappedLookup = it->second.wrapper;
    if (typeID == 1210865730) {
      UE_LOG(LogTemp, Warning, TEXT("RETL %x %x"), inNative, s_lastWrappedLookup);
    }
    return s_lastWrappedLookup;
  }
  
  if (typeID == 1210865730) {
    UE_LOG(LogTemp, Warning, TEXT("NORET %x"), inNative);
  }
  return nullptr;
}

void ::unreal::helpers::ClassMap_obj::registerWrapper(void* inNative, void* inWrapper, int32 typeID) {
  check(IsInGameThread());
  if (typeID == 1210865730) {
    UE_LOG(LogTemp, Warning, TEXT("REGISTER %x %x"), inNative, inWrapper);
  }
  
  getWrapperMap()[inNative] = {typeID, inWrapper};
  s_lastNativeLookup = inNative;
  s_lastWrappedLookup = inWrapper;
  s_lastWrappedTypeID = typeID;
}

void ::unreal::helpers::ClassMap_obj::unregisterWrapper(void* inNative) {
  auto& wrappers = getWrapperMap();
  auto it = wrappers.find(inNative);
  if (it != wrappers.end() && it->second.typeID == 1210865730) {
    UE_LOG(LogTemp, Warning, TEXT("UNREGISTER %x %x"), inNative);
  }

  check(IsInGameThread());
  getWrapperMap().erase(inNative);
  if (s_lastNativeLookup == inNative) {
    s_lastNativeLookup = nullptr;
    s_lastWrappedLookup = nullptr;
    s_lastWrappedTypeID = -1;
  }
}