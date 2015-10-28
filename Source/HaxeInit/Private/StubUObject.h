#pragma once
#include <Engine.h>
#include "StubUObject.generated.h"

// This class is only here to make sure we're visible to UHT.
// We need to be visible to UHT so that UE4HaxeExternGenerator works correctly
// (as any script generator must return a module name that is visible to UHT)
// see IScriptGeneratorPluginInterface::GetGeneratedCodeModuleName for the related code
UCLASS()
class HAXEINIT_API UObjectStub : public UObject {
  GENERATED_BODY()
};
