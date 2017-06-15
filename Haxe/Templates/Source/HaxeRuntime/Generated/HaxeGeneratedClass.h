#pragma once
#include "Engine.h"
#include "IntPtr.h"
#include "VariantPtr.h"
#include "uhx/Wrapper.h"
#include "uhx/expose/HxcppRuntime.h"
#include "Engine/BlueprintGeneratedClass.h"
#include "UnrealNetwork.h"
#include "HaxeGeneratedClass.generated.h"

UCLASS()
class HAXERUNTIME_API UHaxeGeneratedClass : public UBlueprintGeneratedClass {
public:
  GENERATED_BODY()

  /** called to gather blueprint replicated properties */
  virtual void GetLifetimeBlueprintReplicationList(TArray<class FLifetimeProperty>& OutLifetimeProps) const override {
    uhx::expose::HxcppRuntime::setLifetimeProperties(
        (unreal::UIntPtr) this,
        TCHAR_TO_UTF8(*(this->GetPrefixCPP() + this->GetName())),
        uhx::TemplateHelper<TArray<class FLifetimeProperty>>::fromPointer(&OutLifetimeProps));
  }

  /** called prior to replication of an instance of this BP class */
  virtual void InstancePreReplication(UObject* Obj, class IRepChangedPropertyTracker& ChangedPropertyTracker) const override {
    uhx::expose::HxcppRuntime::instancePreReplication(
        (unreal::UIntPtr) Obj,
        unreal::VariantPtr(&ChangedPropertyTracker));
  }

  static void cdoInit() {
    for (FRawObjectIterator it(false); it; ++it) {
      if (UHaxeGeneratedClass* cls = Cast<UHaxeGeneratedClass>((UObject*)(it->Object))) {
        if (cls->HasAnyFlags(RF_ClassDefaultObject)) {
          cls->ClassAddReferencedObjects = &UBlueprintGeneratedClass::AddReferencedObjects;
        }
      }
    }
  }
};

