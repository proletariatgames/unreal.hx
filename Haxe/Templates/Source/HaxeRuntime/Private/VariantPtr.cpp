#include "HaxeRuntime.h"
#include "VariantPtr.h"
#include "CoreMinimal.h"
#include "HaxeInit.h"

void unreal::VariantPtr::badAlignmentAssert(UIntPtr value)
{
  UE_LOG(HaxeLog, Fatal, TEXT("The pointer %llx was not aligned and is not supported by Unreal.hx"), value);
}