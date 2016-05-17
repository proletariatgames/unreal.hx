#pragma once
#ifndef HXCPP_H
#include <hxcpp.h>
#endif
#include <unreal/helpers/GcRefStatic.h>
#include "IntPtr.h"

namespace unreal {
namespace helpers {

class HXCPP_CLASS_ATTRIBUTES GcRef {
public:

  GcRef();
  ~GcRef();
  GcRef(const GcRef& rhs);
  void set(unreal::UIntPtr val);
  unreal::UIntPtr get();

private:
  unreal::UIntPtr ref;
};

}
}

