#pragma once
#include "IntPtr.h"
#ifndef HXCPP_H
#include <hxcpp.h>
#endif
typedef unreal::UIntPtr (*HaxeWrap)(unreal::UIntPtr);
typedef void (*CppInit)();

namespace uhx {
namespace ue {

  class HXCPP_CLASS_ATTRIBUTES ClassMap_obj {
  public:
    /**
     * Adds a wrapper so that given `inUClass`, the function `wrapper` will be called to wrap it
     **/
    static bool addWrapper(unreal::UIntPtr inUClass, HaxeWrap inWrapper);

    /**
     * Given `inUObject`, find the best wrapper and return the Haxe wrapper to it
     **/
    static unreal::UIntPtr wrap(unreal::UIntPtr inUObject);

    static void addCppInit(CppInit inInit);

    static void runInits();
  };

  class InitAdd {
  public:
    InitAdd(CppInit inInit) {
      uhx::ue::ClassMap_obj::addCppInit(inInit);
    }
  };
}
}
