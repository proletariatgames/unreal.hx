#pragma once
#include <hxcpp.h>
#include <unreal/helpers/HxcppRuntimeStatic.h>

namespace unreal {
namespace helpers {

class HXCPP_CLASS_ATTRIBUTES HxcppRuntime {
public:

  static void *constCharToString(const char *str) {
    return ::unreal::helpers::HxcppRuntimeStatic::constCharToString(str);
  }

  static const char *stringToConstChar(void *ptr) {
    return ::unreal::helpers::HxcppRuntimeStatic::stringToConstChar(ptr);
  }

  static void throwString(const char *str) {
    ::unreal::helpers::HxcppRuntimeStatic::throwString(str);
  }

  static void *getWrapped(void *ptr) {
    return ::unreal::helpers::HxcppRuntimeStatic::getWrapped(ptr);
  }

  static void *getWrappedRef(void *ptr) {
    return ::unreal::helpers::HxcppRuntimeStatic::getWrappedRef(ptr);
  }

  static void *callFunction(void *ptr) {
    return ::unreal::helpers::HxcppRuntimeStatic::callFunction(ptr);
  }

  static void *callFunction(void *ptr, void *arg0) {
    return ::unreal::helpers::HxcppRuntimeStatic::callFunction(ptr, arg0);
  }

  static void *callFunction(void *ptr, void *arg0, void *arg1) {
    return ::unreal::helpers::HxcppRuntimeStatic::callFunction(ptr, arg0, arg1);
  }

  static void *callFunction(void *ptr, void *arg0, void *arg1, void *arg2) {
    return ::unreal::helpers::HxcppRuntimeStatic::callFunction(ptr, arg0, arg1, arg2);
  }

  static void *callFunction(void *ptr, void *arg0, void *arg1, void *arg2, void *arg3) {
    return ::unreal::helpers::HxcppRuntimeStatic::callFunction(ptr, arg0, arg1, arg2, arg3);
  }

  static void *callFunction(void *ptr, void *arg0, void *arg1, void *arg2, void *arg3, void *arg4) {
    return ::unreal::helpers::HxcppRuntimeStatic::callFunction(ptr, arg0, arg1, arg2, arg3, arg4);
  }

  static void *callFunction(void *ptr, void *arg0, void *arg1, void *arg2, void *arg3, void *arg4, void *arg5) {
    return ::unreal::helpers::HxcppRuntimeStatic::callFunction(ptr, arg0, arg1, arg2, arg3, arg4, arg5);
  }

  static void *callFunction(void *ptr, void *arg0, void *arg1, void *arg2, void *arg3, void *arg4, void *arg5, void *arg6) {
    return ::unreal::helpers::HxcppRuntimeStatic::callFunction(ptr, arg0, arg1, arg2, arg3, arg4, arg5, arg6);
  }

  static void *callFunction(void *ptr, void *arg0, void *arg1, void *arg2, void *arg3, void *arg4, void *arg5, void *arg6, void *arg7) {
    return ::unreal::helpers::HxcppRuntimeStatic::callFunction(ptr, arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7);
  }
};

}
}
