#pragma once
#ifndef UHX_NO_UOBJECT

#include "IntPtr.h"
#include "VariantPtr.h"

#ifdef _MSC_VER
  #include <malloc.h>
#else
  #include <alloca.h>
#endif

#ifndef HX_ALLOCA
  #ifdef _MSC_VER
    #define HX_ALLOCA(v) (v == 0 ? (unreal::UIntPtr) 0 : (unreal::UIntPtr) _alloca(v))
  #else
    #define HX_ALLOCA(v) (v == 0 ? (unreal::UIntPtr) 0 : (unreal::UIntPtr) alloca(v))
  #endif
#endif

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

  inline static void dummyCall() {
    // this is just here to ensure that this header is included
  }
};

}
}

#endif
