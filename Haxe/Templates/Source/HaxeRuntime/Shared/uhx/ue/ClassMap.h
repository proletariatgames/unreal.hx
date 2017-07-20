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
     * Adds a custom create function so that given `inUClass` the function `inCreate` will be called to create it
     **/
    static void addCustomCtor(unreal::UIntPtr inUClass, HaxeWrap inCtor);

    /**
     * Given `inUObject`, find the best wrapper and return the Haxe wrapper to it
     **/
    static unreal::UIntPtr wrap(unreal::UIntPtr inUObject);

    static void addCppInit(CppInit inInit);

    static void runInits();

    /**
     * Creates a dynamic wrapper which binds `inHxClass` to the extern class `inUClass`.
     * Note that this is only called for @:uextern classes that were not compiled into the latest binary
     **/
    static void addCppiaExternWrapper(const char *inUClass, const char *inHxClass);
    static void addCppiaCustomCtor(const char *inUClass, const char *inHxClass);

    /**
     * Attempts to create a custom create function. If no create function was found, 0 is returned
     **/
    inline static HaxeWrap *getCustomCtor(unreal::UIntPtr inUClass) {
      if (!hasCustomCtor) {
        return 0;
      } else {
        return getCustomCtorImpl(inUClass);
      }
    }

  private:
    static bool hasCustomCtor;
    static HaxeWrap *getCustomCtorImpl(unreal::UIntPtr inUClass);
  };

  class InitAdd {
  public:
    InitAdd(CppInit inInit) {
      uhx::ue::ClassMap_obj::addCppInit(inInit);
    }
  };
}
}
