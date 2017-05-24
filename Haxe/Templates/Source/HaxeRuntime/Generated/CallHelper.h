#pragma once
#include "Engine.h"
#include "UObject/Stack.h"
#include "uhx/expose/HxcppRuntime.h"
#include "IntPtr.h"
#include "CallHelper.generated.h"

UCLASS()
class HAXERUNTIME_API UCallHelper : public UObject {
public:
  GENERATED_BODY()
  void uhx_callFunctionOther( FFrame& Stack, RESULT_DECL ) {
    ::uhx::expose::HxcppRuntime::callHaxeFunctionOther(unreal::VariantPtr(&Stack), (unreal::UIntPtr) RESULT_PARAM);
  }

  static void setupFunction(void *cls, void *fn) {
    UFunction *realFn = ((UFunction*)fn);
    Native native = (Native)&UCallHelper::uhx_callFunctionOther;
    ((UClass *) cls)->AddNativeFunction(*realFn->GetName(), native);
    ((UFunction*) fn)->SetNativeFunc(native);
  }
};
