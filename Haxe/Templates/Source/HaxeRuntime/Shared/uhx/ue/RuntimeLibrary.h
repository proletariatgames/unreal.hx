#pragma once
#ifndef UHX_NO_UOBJECT

#include "IntPtr.h"
#include "VariantPtr.h"

#ifdef _MSC_VER
  #include <malloc.h>
#else
  #include <alloca.h>
#endif
#include <string.h>

#ifndef HX_ALLOCA
  #ifdef _MSC_VER
    #define HX_ALLOCA(v) (v == 0 ? (unreal::UIntPtr) 0 : (unreal::UIntPtr) _alloca(v))
  #else
    #define HX_ALLOCA(v) (v == 0 ? (unreal::UIntPtr) 0 : (unreal::UIntPtr) alloca(v))
  #endif
#endif

#ifndef HX_ALLOCA_ZEROED
  #define HX_ALLOCA_ZEROED(v) uhx::ue::RuntimeLibrary_obj::setZero(HX_ALLOCA(v), v)
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
   * Ensures that the code is called from the main thread
   **/
  static void ensureMainThread();

  /**
   * Gets the GcRef size
   **/
  static int getGcRefSize();

  /**
   * Sets up the class constructor
   **/
  static void setupClassConstructor(unreal::UIntPtr inDynamicClass);

  /**
   * Creates an empty VariantPtr object from a ScriptStruct object
   **/
  static unreal::VariantPtr createDynamicWrapperFromStruct(unreal::UIntPtr inStruct);

  /**
   * Enables/disables additional debugging information on the uhx::StructInfo struct
   **/
  inline static void setReflectionDebugMode(bool value) {
    getReflectionDebugMode() = value;
  }

  inline static bool& getReflectionDebugMode() {
    static bool ret = false;
    return ret;
  }

  /**
   * Sets up the class constructor as the super class' constructor
   **/
  static void setSuperClassConstructor(unreal::UIntPtr inDynamicClass);

  static unreal::UIntPtr setZero(unreal::UIntPtr inPtr, int inSize)
  {
    if (inSize != 0)
    {
      memset((void*) inPtr, 0, inSize);
    }
    return inPtr;
  }

  inline static void dummyCall() {
    // this is just here to ensure that this header is included
  }
};

}
}

#endif
