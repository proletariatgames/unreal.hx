#include "HaxeRuntime.h"
#ifndef UHX_NO_UOBJECT

#include "IntPtr.h"
#include "ClassMap.h"
#include <CoreUObject.h>
#include <unordered_map>

static std::unordered_map<UClass *,HaxeWrap>& getClassMap() {
  // lazy instantiation
  static std::unordered_map<UClass *,HaxeWrap> classMap;
  return classMap;
}

bool ::unreal::helpers::ClassMap_obj::addWrapper(unreal::UIntPtr inUClass, HaxeWrap inWrapper) {
  getClassMap()[(UClass *)inUClass] = inWrapper;
  return true;
}

unreal::UIntPtr unreal::helpers::ClassMap_obj::wrap(unreal::UIntPtr inUObject) {
  if (inUObject == 0) return 0;  
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
  return 0;
}

#endif
