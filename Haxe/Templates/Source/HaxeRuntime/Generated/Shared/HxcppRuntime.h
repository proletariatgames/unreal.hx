#pragma once
#include <hxcpp.h>
#include <unreal/helpers/HxcppRuntimeStatic.h>

namespace unreal {
namespace helpers {

class HXCPP_CLASS_ATTRIBUTES HxcppRuntime {
public:

  static void *constCharToString(const char *str);
  static const char *stringToConstChar(void *ptr);
  static void throwString(const char *str);
  static void *getWrapped(void *ptr);
  static void *getWrappedRef(void *ptr);
  static void *callFunction(void *ptr);
  static void *callFunction(void *ptr, void *arg0);
  static void *callFunction(void *ptr, void *arg0, void *arg1);
  static void *callFunction(void *ptr, void *arg0, void *arg1, void *arg2);
  static void *callFunction(void *ptr, void *arg0, void *arg1, void *arg2, void *arg3);
  static void *callFunction(void *ptr, void *arg0, void *arg1, void *arg2, void *arg3, void *arg4);
  static void *callFunction(void *ptr, void *arg0, void *arg1, void *arg2, void *arg3, void *arg4, void *arg5);
  static void *callFunction(void *ptr, void *arg0, void *arg1, void *arg2, void *arg3, void *arg4, void *arg5, void *arg6);
  static void *callFunction(void *ptr, void *arg0, void *arg1, void *arg2, void *arg3, void *arg4, void *arg5, void *arg6, void *arg7);
};

}
}
