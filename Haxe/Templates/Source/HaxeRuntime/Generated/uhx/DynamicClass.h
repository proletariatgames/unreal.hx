#pragma once
#ifndef UHX_NO_UOBJECT

#include "Engine.h"
#include "UObjectBase.h"
#include "HaxeInit.h"
#include "unreal/helpers/HxcppRuntime.h"

#define DECLARE_UHX_DYNAMIC_UCLASS(Class) \
  class Class; \
  template<> \
  struct TClassCompiledInDefer<Class> : public FFieldCompiledInInfo \
  { \
    TClassCompiledInDefer(const TCHAR* InName, SIZE_T InClassSize, uint32 InCrc) \
      : FFieldCompiledInInfo(InClassSize, InCrc) \
    { \
      static FName className = FName(#Class); \
      uint32 crc = ::uhx::DynamicClassHelper::getCrc(className); \
      this->Crc = crc; \
      UClassCompiledInDefer(this, InName, InClassSize, crc); \
    } \
    virtual UClass* Register() const override; \
  }

#define DEFINE_UHX_DYNAMIC_UCLASS(Class) \
UClass* TClassCompiledInDefer<Class>::Register() const \
{ \
  check_hx_init(); \
  UClass * ret = Class::StaticClass(); \
  unreal::helpers::HxcppRuntime::addDynamicProperties((unreal::UIntPtr) ret, #Class); \
  return ret; \
}

namespace uhx {

class HAXERUNTIME_API DynamicClassHelper {
public:
  static TMap<FName, uint32>& getCrcMap();

  static uint32 getCrc(FName& className) {
    auto ret = getCrcMap().Find(className);
    if (ret == nullptr) {
      UE_LOG(HaxeLog,Error,TEXT("Could not find CRC for class %s"), *className.ToString());
      return 0;
    }
    return *ret;
  }
};

}

#endif
