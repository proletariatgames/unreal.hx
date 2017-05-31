#include "HaxeRuntime.h"
#include "IntPtr.h"
#include "HaxeInit.h"
#include <uhx/GcRef.h>

::uhx::GcRef::GcRef() {
  check_hx_init();
  this->ref = ::uhx::expose::GcRefStatic::init();
}

::uhx::GcRef::~GcRef() {
  ::uhx::expose::GcRefStatic::destruct(this->ref);
}

::uhx::GcRef::GcRef(const GcRef& rhs) {
  this->ref = ::uhx::expose::GcRefStatic::init();
  this->set(const_cast<GcRef&>(rhs).get());
}

void ::uhx::GcRef::set(unreal::UIntPtr val) {
  ::uhx::expose::GcRefStatic::set(this->ref, val);
}

unreal::UIntPtr uhx::GcRef::get() const {
  return ::uhx::expose::GcRefStatic::get(this->ref);
}
