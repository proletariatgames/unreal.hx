#pragma once
#ifndef HXCPP_H
#include <hxcpp.h>
#endif
#include "IntPtr.h"

namespace uhx {

class HXCPP_CLASS_ATTRIBUTES GcRef {
public:
  static unreal::UIntPtr createRoot();
  static void deleteRoot(unreal::UIntPtr ptr);

  GcRef();
  ~GcRef();
  GcRef(const GcRef& rhs);
  void set(unreal::UIntPtr val);
  unreal::UIntPtr get() const;

private:
  unreal::UIntPtr ref;
};

}