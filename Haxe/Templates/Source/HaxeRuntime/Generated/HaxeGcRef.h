#pragma once
#include "uhx/GcRef.h"
#include "IntPtr.h"

#include "HaxeGcRef.generated.h"

USTRUCT()
struct HAXERUNTIME_API FHaxeGcRef {
  GENERATED_BODY()

  ::uhx::GcRef ref;
};
