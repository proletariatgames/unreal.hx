#pragma once
#ifndef HXCPP_H
#include <hxcpp.h>
#endif
#include <uhx/expose/GcRefStatic.h>
#include "IntPtr.h"

namespace uhx {

class HXCPP_CLASS_ATTRIBUTES GcRef {
public:

  GcRef();
  ~GcRef();
  GcRef(const GcRef& rhs);
  void set(unreal::UIntPtr val);
  unreal::UIntPtr get() const;

private:
  unreal::UIntPtr ref;
};

}