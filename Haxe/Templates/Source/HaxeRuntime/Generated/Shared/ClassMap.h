#pragma once
#include <hxcpp.h>
#include <functional>

typedef void *(*HaxeWrap)(void *);

namespace unreal {
namespace helpers {

  class UEPointer_obj;

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
    
    static void* checkWrapperCache(void* inNative, int typeID);
    static bool checkIsWrapper(void* inPtr, int typeID);
    static void registerWrapper(void* inNative, void* inWrapper, int typeID);
    static void unregisterWrapper(void* inNative);
  };

}
}
