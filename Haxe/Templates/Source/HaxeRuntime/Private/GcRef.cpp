#include "HaxeRuntime.h"
#include "CoreMinimal.h"
#include "IntPtr.h"
#include "HaxeInit.h"
#include "uhx/GcRef.h"
#include "CoreGlobals.h"

::uhx::GcRef::GcRef() {
  if (!GIsRetrievingVTablePtr) {
    check_hx_init();
    this->ref = ::uhx::expose::GcRefStatic::init();
  } else {
    this->ref = 0;
  }
}

::uhx::GcRef::~GcRef() {
  if (this->ref != 0) {
    ::uhx::expose::GcRefStatic::destruct(this->ref);
  }
}

::uhx::GcRef::GcRef(const GcRef& rhs) {
  if (rhs.ref != 0) {
    this->ref = ::uhx::expose::GcRefStatic::init();
    this->set(const_cast<GcRef&>(rhs).get());
  } else {
    this->ref = 0;
  }
}

void ::uhx::GcRef::set(unreal::UIntPtr val) {
  if (this->ref == 0) {
    check_hx_init();
    this->ref = ::uhx::expose::GcRefStatic::init();
  }
  ::uhx::expose::GcRefStatic::set(this->ref, val);
}

unreal::UIntPtr uhx::GcRef::get() const {
  if (this->ref == 0) {
    return 0;
  }
  return ::uhx::expose::GcRefStatic::get(this->ref);
}
