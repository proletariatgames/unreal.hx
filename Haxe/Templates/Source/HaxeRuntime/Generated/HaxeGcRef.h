#pragma once
#include "GcRef.h"
#include "IntPtr.h"

#include "HaxeGcRef.generated.h"

USTRUCT()
struct HAXERUNTIME_API FHaxeGcRef {
  GENERATED_BODY()

  ::unreal::helpers::GcRef ref;
};
