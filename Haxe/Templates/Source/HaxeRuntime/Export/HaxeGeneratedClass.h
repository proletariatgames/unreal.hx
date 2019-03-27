#pragma once
#include "CoreMinimal.h"
#include "UObject/Object.h"
#include "Engine/BlueprintGeneratedClass.h"
#include "UnrealNetwork.h"
#include "HaxeGeneratedClass.generated.h"

UCLASS(Meta=(UHX_Internal=true))
class HAXERUNTIME_API UHaxeGeneratedClass : public UBlueprintGeneratedClass {
public:
  GENERATED_BODY()

  /** called to gather blueprint replicated properties */
  virtual void GetLifetimeBlueprintReplicationList(TArray<class FLifetimeProperty>& OutLifetimeProps) const override;
  /** called prior to replication of an instance of this BP class */
  virtual void InstancePreReplication(UObject* Obj, class IRepChangedPropertyTracker& ChangedPropertyTracker) const override;
  static void cdoInit();
};

