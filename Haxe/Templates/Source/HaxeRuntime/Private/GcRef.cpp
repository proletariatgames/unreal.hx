#include "HaxeRuntime.h"
#include "CoreMinimal.h"
#include "IntPtr.h"
#include "uhx/AutoHaxeInit.h"
#include "uhx/GcRef.h"
#include "CoreGlobals.h"

namespace hx {
  class Object;

  // Create/Remove a root.
  // All statics are explicitly registered - this saves adding the whole data segment
  //  to the collection list.
  // It takes a pointer-pointer so it can move the contents, and the caller can change the contents
  void GCAddRoot(hx::Object **inRoot);
  void GCRemoveRoot(hx::Object **inRoot);
}

unreal::UIntPtr uhx::GcRef::createRoot()
{
  hx::Object ** result = new hx::Object *();
  hx::GCAddRoot(result);
  return (unreal::UIntPtr) result;
}

void uhx::GcRef::deleteRoot(unreal::UIntPtr ptr)
{
  if (ptr)
  {
    hx::Object** obj = (hx::Object**) ptr;
    hx::GCRemoveRoot(obj);
    delete obj;
  }
}

::uhx::GcRef::GcRef() {
  this->ref = 0;
}

::uhx::GcRef::~GcRef() {
  // we crash if we are trying to attach a thread after our module has been abandoned - so check against that
  if (this->ref && !GIsRequestingExit && !GExitPurge) {
    AutoHaxeInit uhx_init;
    uhx::GcRef::deleteRoot(this->ref);
    this->ref = 0;
  }
}

::uhx::GcRef::GcRef(const GcRef& rhs) {
  if (rhs.ref) {
    AutoHaxeInit uhx_init;
    this->ref = uhx::GcRef::createRoot();
    this->set(const_cast<GcRef&>(rhs).get());
  } else {
    this->ref = 0;
  }
}

void ::uhx::GcRef::set(unreal::UIntPtr val) {
  AutoHaxeInit uhx_init;
  if (this->ref == 0) {
    this->ref = uhx::GcRef::createRoot();
  }
  *((hx::Object**) this->ref) = (hx::Object*) val;
}

unreal::UIntPtr uhx::GcRef::get() const {
  if (this->ref == 0) {
    return 0;
  }
  return *((unreal::UIntPtr*) this->ref);
}
