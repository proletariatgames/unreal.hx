#pragma once

#include "IntPtr.h"
#include "VariantPtr.h"
#include "uhx/expose/HxcppRuntime.h"
#include "uhx/GcRef.h"

#ifdef _MSC_VER
  #include <malloc.h>
#elif defined(HX_LINUX)
  #include <alloca.h>
#else
  #include <stdlib.h>
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
private:
  #if defined(_MSC_VER)
  static _declspec( thread ) unreal::UIntPtr *tlsObj;
  #elif defined(__GNUC__)
  static thread_local unreal::UIntPtr *tlsObj;
  #endif

public:
  #if defined(_MSC_VER) || defined(__GNUC__)
  static inline unreal::UIntPtr getTlsObj()
  {
    unreal::UIntPtr *ret = tlsObj;
    if (!ret) {
      tlsObj = ret = (unreal::UIntPtr *) uhx::GcRef::createRoot();
      return *ret = uhx::expose::HxcppRuntime::createArray();
    }
    return *ret;
  }
  #else
  static unreal::UIntPtr getTlsObj();
  #endif

  static int allocTlsSlot();

#ifndef UHX_NO_UOBJECT
  /**
   * Creates a dynamic wrapper (unreal.Wrapper) that is empty but compatible with `inProp UProperty`
   **/
  static unreal::VariantPtr wrapProperty(unreal::UIntPtr inProp, unreal::UIntPtr pointerIfAny);

  /**
   * Gets the FHaxeGcRef offset to the actual GcRef object
   **/
  static int getHaxeGcRefOffset();

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
#endif

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

