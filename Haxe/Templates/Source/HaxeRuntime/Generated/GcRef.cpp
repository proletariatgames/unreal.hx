#include "HaxeRuntime.h"
#include "IntPtr.h"
#include "HaxeInit.h"
#include <GcRef.h>

::unreal::helpers::GcRef::GcRef() {
  check_hx_init();
  this->ref = ::unreal::helpers::GcRefStatic::init();
}

::unreal::helpers::GcRef::~GcRef() {
  ::unreal::helpers::GcRefStatic::destruct(this->ref);
}

::unreal::helpers::GcRef::GcRef(const GcRef& rhs) {
  this->ref = ::unreal::helpers::GcRefStatic::init();
  this->set(const_cast<GcRef&>(rhs).get());
}

void ::unreal::helpers::GcRef::set(unreal::UIntPtr val) {
  ::unreal::helpers::GcRefStatic::set(this->ref, val);
}

unreal::UIntPtr ::unreal::helpers::GcRef::get() {
  return ::unreal::helpers::GcRefStatic::get(this->ref);
}
