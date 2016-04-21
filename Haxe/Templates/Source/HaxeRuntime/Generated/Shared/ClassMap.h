#pragma once
#include <hxcpp.h>
typedef void *(*HaxeWrap)(void *);

namespace unreal {
namespace helpers {

  class HXCPP_CLASS_ATTRIBUTES ClassMap_obj {
  public:
    /**
     * Adds a wrapper so that given `inUClass`, the function `wrapper` will be called to wrap it
     **/
    static bool addWrapper(void *inUClass, HaxeWrap inWrapper);

    /**
     * Given `inUObject`, find the best wrapper and return the Haxe wrapper to it
     **/
    static void *wrap(void *inUObject);
    
    static void* findWrapper(void* inNative);
    static void registerWrapper(void* inNative, void* inWrapper);
    static void unregisterWrapper(void* inNative, void* inWrapper);
  };

}
}
