#pragma once
#include <hxcpp.h>
#include <unreal/helpers/GcRefStatic.h>
extern "C" HXCPP_CLASS_ATTRIBUTES void check_hx_init();

namespace unreal {
namespace helpers {

class HXCPP_CLASS_ATTRIBUTES GcRef {
public:

  GcRef() {
    check_hx_init();
    this->ref = ::unreal::helpers::GcRefStatic::init();
  }

  ~GcRef() {
    ::unreal::helpers::GcRefStatic::destruct(this->ref);
  }

  GcRef(const GcRef& rhs) {
    this->ref = ::unreal::helpers::GcRefStatic::init();
    this->set(const_cast<GcRef&>(rhs).get());
  }

  void set(void *val) {
    ::unreal::helpers::GcRefStatic::set(this->ref, val);
  }

  void *get() {
    return ::unreal::helpers::GcRefStatic::get(this->ref);
  }

private:
  void *ref;
};

}
}

