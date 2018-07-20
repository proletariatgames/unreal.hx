#pragma once
#ifndef UHX_NO_UOBJECT

#include "CoreMinimal.h"
#include "UObjectBase.h"
#include "HaxeInit.h"
#include "UObject/Class.h"

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

#if UE_VER >= 417
typedef EClassFlags UHX_ClassFlags;
#else
typedef uint32 UHX_ClassFlags;
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

#ifdef GetPrivateStaticClassBody
#undef GetPrivateStaticClassBody
#endif

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

  static void getPrivateDynamicStaticClassBody(
      const TCHAR* PackageName,
      const TCHAR* Name,
      UClass*& ReturnClass,
      void(*RegisterNativeFunc)(),
      uint32 InSize,
      UHX_ClassFlags InClassFlags,
      EClassCastFlags InClassCastFlags,
      const TCHAR* InConfigName,
      UClass::ClassConstructorType InClassConstructor,
      UClass::ClassVTableHelperCtorCallerType InClassVTableHelperCtorCaller,
      UClass::ClassAddReferencedObjectsType InClassAddReferencedObjects,
      UClass::StaticClassFunctionType InSuperClassFn,
      UClass::StaticClassFunctionType InWithinClassFn,
      bool bIsDynamic = false) {

    if (GIsHotReload)
    {
      UPackage* Package = FindPackage(NULL, PackageName);
      if (Package)
      {
        ReturnClass = FindObject<UClass>((UObject *)Package, Name);
        if (ReturnClass && ReturnClass->HasMetaData(TEXT("UHX_PropSignature")))
        {
          // this is a dynamic uclass, so the reported C++ size is not correctly set.
          // We know for a fact that this class hasn't changed, otherwise FindObject would have failed
          // at this point. So we're just going to make sure that the reported size is the same as
          // the dynamic class
          InSize = ReturnClass->PropertiesSize;
        }
      }
    }

    ::GetPrivateStaticClassBody(
        PackageName,
        Name,
        ReturnClass,
        RegisterNativeFunc,
        InSize,
        InClassFlags,
        InClassCastFlags,
        InConfigName,
        InClassConstructor,
        InClassVTableHelperCtorCaller,
        InClassAddReferencedObjects,
        InSuperClassFn,
        InWithinClassFn,
        bIsDynamic);
  }
};


}

#define GetPrivateStaticClassBody uhx::DynamicClassHelper::getPrivateDynamicStaticClassBody

#endif
