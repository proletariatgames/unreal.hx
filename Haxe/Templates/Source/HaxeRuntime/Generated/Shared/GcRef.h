#pragma once
#include <hxcpp.h>
#include <unreal/helpers/GcRefStatic.h>

namespace unreal {
namespace helpers {

class HXCPP_CLASS_ATTRIBUTES GcRef {
public:

  GcRef();
  ~GcRef();
  GcRef(const GcRef& rhs);
  void set(void *val);
  void *get();

private:
  void *ref;
};

}
}

