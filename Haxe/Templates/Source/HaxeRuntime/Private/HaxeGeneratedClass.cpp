#include "HaxeRuntime.h"
#ifndef UHX_NO_UOBJECT
#include "HaxeGeneratedClass.h"
#include "uhx/glues/TArrayImpl_Glue_UE.h"
#include "IntPtr.h"
#include "VariantPtr.h"
#include "uhx/Wrapper.h"
#include "uhx/expose/HxcppRuntime.h"

void UHaxeGeneratedClass::GetLifetimeBlueprintReplicationList(TArray<class FLifetimeProperty>& OutLifetimeProps) const {
  uhx::expose::HxcppRuntime::setLifetimeProperties(
      (unreal::UIntPtr) this,
      TCHAR_TO_UTF8(*(this->GetPrefixCPP() + this->GetName())),
      uhx::TemplateHelper<TArray<class FLifetimeProperty>>::fromPointer(&OutLifetimeProps));
}

/** called prior to replication of an instance of this BP class */
void UHaxeGeneratedClass::InstancePreReplication(UObject* Obj, class IRepChangedPropertyTracker& ChangedPropertyTracker) const {
  uhx::expose::HxcppRuntime::instancePreReplication(
      (unreal::UIntPtr) Obj,
      unreal::VariantPtr::fromExternalPointer(&ChangedPropertyTracker));
}

void UHaxeGeneratedClass::cdoInit() {
  for (FRawObjectIterator it(false); it; ++it) {
    if (UHaxeGeneratedClass* cls = Cast<UHaxeGeneratedClass>((UObject*)(it->Object))) {
      if (cls->HasAnyFlags(RF_ClassDefaultObject)) {
        cls->ClassAddReferencedObjects = &UBlueprintGeneratedClass::AddReferencedObjects;
      }
    }
  }
}
#endif