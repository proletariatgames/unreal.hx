#pragma once
#ifndef UHX_NO_UOBJECT

#include "IntPtr.h"
#include "VariantPtr.h"

namespace uhx {
namespace ue {

class RuntimeLibrary_obj {
public:
  /**
   * Creates a dynamic wrapper (unreal.Wrapper) that is empty but compatible with `inProp UProperty`
   **/
  static unreal::VariantPtr wrapProperty(unreal::UIntPtr inProp, unreal::UIntPtr pointerIfAny);

  /**
   * Gets the FHaxeGcRef offset to the actual GcRef object
   **/
  static int getHaxeGcRefOffset();

  /**
   * Sets up the class constructor
   **/
  static void setupClassConstructor(unreal::UIntPtr inDynamicClass, unreal::UIntPtr inParent, bool parentHxGenerated);
};

}
}

#endif
