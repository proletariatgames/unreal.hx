#pragma once
#ifndef UHX_NO_UOBJECT

#include "Engine.h"
#include "UObjectBase.h"
#include "HaxeInit.h"
#include "uhx/Version.h"

#if UE_VER >= 416
#define DECLARE_UHX_DYNAMIC_UCLASS_PACK(Class) \
  virtual const TCHAR* ClassPackage() const override;

#define DEFINE_UHX_DYNAMIC_UCLASS_PACK(Class) \
  const TCHAR* TClassCompiledInDefer<Class>::ClassPackage() const { \
    return Class::StaticPackage(); \
  }

#else
#define DECLARE_UHX_DYNAMIC_UCLASS_PACK(Class)
#define DEFINE_UHX_DYNAMIC_UCLASS_PACK(Class)
#endif

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
    DECLARE_UHX_DYNAMIC_UCLASS_PACK(Class) \
  }

#define DEFINE_UHX_DYNAMIC_UCLASS(Class) \
UClass* TClassCompiledInDefer<Class>::Register() const { \
  UClass *ret = Class::StaticClass(); \
  ::uhx::DynamicClassHelper::getDynamicsMap().Add(FName(#Class), ret); \
  return ret; \
} \
DEFINE_UHX_DYNAMIC_UCLASS_PACK(Class)

namespace uhx {

class HAXERUNTIME_API DynamicClassHelper {
public:
  static TMap<FName, uint32>& getCrcMap();

  static TMap<FName, UClass *>& getDynamicsMap();

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
