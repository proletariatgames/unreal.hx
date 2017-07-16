#pragma once
#include "uhx/GcRef.h"
#include "IntPtr.h"

#include "HaxeGcRef.generated.h"

USTRUCT(Meta=(UHX_Internal=true))
struct HAXERUNTIME_API FHaxeGcRef {
  GENERATED_BODY()

  ::uhx::GcRef ref;
};
