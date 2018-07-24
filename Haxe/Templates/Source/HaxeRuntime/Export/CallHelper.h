#pragma once
#include "CoreMinimal.h"
#include "UObject/Object.h"
#include "UObject/Stack.h"
#include "uhx/expose/HxcppRuntime.h"
#include "IntPtr.h"
#include "CallHelper.generated.h"

UCLASS(Meta=(UHX_Internal=true))
class HAXERUNTIME_API UCallHelper : public UObject {
public:
  GENERATED_BODY()
  static void uhx_callFunctionOther(UObject* Context, FFrame& Stack, RESULT_DECL ) {
    ::uhx::expose::HxcppRuntime::callHaxeFunctionOther(unreal::VariantPtr::fromExternalPointer(&Stack), (unreal::UIntPtr) RESULT_PARAM);
  }

  static void setupFunction(void *cls, void *fn) {
    UFunction *realFn = ((UFunction*)fn);
    FNativeFuncPtr native = (FNativeFuncPtr)&UCallHelper::uhx_callFunctionOther;
    ((UClass *) cls)->AddNativeFunction(*realFn->GetName(), native);
    ((UFunction*) fn)->SetNativeFunc(native);
  }
};
