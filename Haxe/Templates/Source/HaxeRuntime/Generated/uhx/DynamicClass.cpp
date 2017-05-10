#include "HaxeRuntime.h"
#include "DynamicClass.h"

#include "Misc/Paths.h"
#include "unreal/helpers/HxcppRuntime.h"

#ifndef UHX_NO_UOBJECT

static TMap<FName, uint32> getCrcMapPvt() {
  TMap<FName, uint32> map;
  FString path = FPaths::ConvertRelativePathToFull(FPaths::GameDir()) + TEXT("/Binaries/Haxe/gameCrcs.data");
  auto file = FPlatformFileManager::Get().GetPlatformFile().OpenRead(*path, false);
  if (file == nullptr) {
    return map;
  }

  uint8 classNameSize = 0;
  char className[257];
  uint32 crc = 0;
  bool success = true;

#define READ(destination, bytesToRead) if (!file->Read(destination, bytesToRead)) { success = false; break; }

  while(true) {
    READ(&classNameSize, 1);
    if (classNameSize == 0) {
      break;
    }

    READ((uint8 *) className, classNameSize);
    className[classNameSize] = 0;
    READ((uint8 *) &crc, 4);
    FName classFName = FName( UTF8_TO_TCHAR(className) );
    if (crc == 0) {
      UE_LOG(HaxeLog, Error, TEXT("Unreal.hx CRC for class %s was 0"), *classFName.ToString());
    }
    map.Add(classFName, crc);
  }

#undef READ

  if (!success) {
    UE_LOG(HaxeLog,Error,TEXT("Unreal.hx CRC data was corrupt"));
  }

  delete file;
  return map;
}

TMap<FName, uint32>& ::uhx::DynamicClassHelper::getCrcMap() {
  static TMap<FName, uint32> map = getCrcMapPvt();
  return map;
}

TMap<FName, UClass *>& ::uhx::DynamicClassHelper::getDynamicsMap() {
  static TMap<FName, UClass *> map;
  return map;
}


#endif

#if (WITH_EDITOR && !NO_DYNAMIC_UCLASS)

/**
 * In order to add cppia dynamic class support, we need to be able to call `addDynamicProperties` in a very precise location - which is
 * right before the CDO is created. We must call this before the class CDO is created because otherwise the CDO will have the wrong size,
 * and bad things will happen. This UHxBootstrap class implements an intrinsic class so we can have a callback right when the classes
 * are registering, which is the exact place where we should add the dynamic properties
 **/
class UHxBootstrap : public UObject {
#if WITH_HOT_RELOAD_CTORS
  DECLARE_CASTED_CLASS_INTRINSIC_NO_CTOR_NO_VTABLE_CTOR(UHxBootstrap, UObject, 0, TEXT("/Script/HaxeRuntime"), 0, HAXERUNTIME_API)

  UHxBootstrap(FVTableHelper& Helper) : UObject(Helper) {
  }
#else
  DECLARE_CASTED_CLASS_INTRINSIC_NO_CTOR(UHxBootstrap, UObject, 0, HaxeRuntime, 0, HAXERUNTIME_API)
#endif
  UHxBootstrap(const FObjectInitializer& ObjectInitializer = FObjectInitializer::Get()) : UObject(ObjectInitializer) {
    unreal::helpers::HxcppRuntime::endLoadingDynamic();
  }

};

IMPLEMENT_INTRINSIC_CLASS(UHxBootstrap, HAXERUNTIME_API, UObject, HAXERUNTIME_API,
{
  check_hx_init();
  unreal::helpers::HxcppRuntime::startLoadingDynamic();
  for (auto It = ::uhx::DynamicClassHelper::getDynamicsMap().CreateIterator(); It; ++It) {
    UClass *val = It.Value();
    unreal::helpers::HxcppRuntime::addDynamicProperties((unreal::UIntPtr) val, TCHAR_TO_UTF8(*It.Key().ToString()));
  }
});


#endif
