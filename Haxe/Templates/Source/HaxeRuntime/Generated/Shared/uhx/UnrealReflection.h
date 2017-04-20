#pragma once
#ifndef UHX_NO_UOBJECT

#include "IntPtr.h"
#include "VariantPtr.h"

namespace unreal {
namespace helpers {

class UnrealReflection_obj {
public:
  /**
   * Creates a dynamic wrapper (unreal.Wrapper) that is empty but compatible with `inProp UProperty`
   **/
  static unreal::VariantPtr wrapProperty(unreal::UIntPtr inProp, unreal::UIntPtr pointerIfAny);
};

}
}

#endif
