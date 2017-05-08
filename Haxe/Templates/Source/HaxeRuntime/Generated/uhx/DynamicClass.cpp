#include "HaxeRuntime.h"
#include "DynamicClass.h"

#include "Misc/Paths.h"

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

#endif
