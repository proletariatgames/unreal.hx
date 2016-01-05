#include "HaxeRuntime.h"
#include <HxcppRuntime.h>

void *::unreal::helpers::HxcppRuntime::constCharToString(const char *str) {
  return ::unreal::helpers::HxcppRuntimeStatic::constCharToString(str);
}

const char *::unreal::helpers::HxcppRuntime::stringToConstChar(void *ptr) {
  return ::unreal::helpers::HxcppRuntimeStatic::stringToConstChar(ptr);
}

void ::unreal::helpers::HxcppRuntime::throwString(const char *str) {
  ::unreal::helpers::HxcppRuntimeStatic::throwString(str);
}

void *::unreal::helpers::HxcppRuntime::getWrapped(void *ptr) {
  return ::unreal::helpers::HxcppRuntimeStatic::getWrapped(ptr);
}

void *::unreal::helpers::HxcppRuntime::getWrappedRef(void *ptr) {
  return ::unreal::helpers::HxcppRuntimeStatic::getWrappedRef(ptr);
}

void *::unreal::helpers::HxcppRuntime::callFunction(void *ptr) {
  return ::unreal::helpers::HxcppRuntimeStatic::callFunction(ptr);
}

void *::unreal::helpers::HxcppRuntime::callFunction(void *ptr, void *arg0) {
  return ::unreal::helpers::HxcppRuntimeStatic::callFunction(ptr, arg0);
}

void *::unreal::helpers::HxcppRuntime::callFunction(void *ptr, void *arg0, void *arg1) {
  return ::unreal::helpers::HxcppRuntimeStatic::callFunction(ptr, arg0, arg1);
}

void *::unreal::helpers::HxcppRuntime::callFunction(void *ptr, void *arg0, void *arg1, void *arg2) {
  return ::unreal::helpers::HxcppRuntimeStatic::callFunction(ptr, arg0, arg1, arg2);
}

void *::unreal::helpers::HxcppRuntime::callFunction(void *ptr, void *arg0, void *arg1, void *arg2, void *arg3) {
  return ::unreal::helpers::HxcppRuntimeStatic::callFunction(ptr, arg0, arg1, arg2, arg3);
}

void *::unreal::helpers::HxcppRuntime::callFunction(void *ptr, void *arg0, void *arg1, void *arg2, void *arg3, void *arg4) {
  return ::unreal::helpers::HxcppRuntimeStatic::callFunction(ptr, arg0, arg1, arg2, arg3, arg4);
}

void *::unreal::helpers::HxcppRuntime::callFunction(void *ptr, void *arg0, void *arg1, void *arg2, void *arg3, void *arg4, void *arg5) {
  return ::unreal::helpers::HxcppRuntimeStatic::callFunction(ptr, arg0, arg1, arg2, arg3, arg4, arg5);
}

void *::unreal::helpers::HxcppRuntime::callFunction(void *ptr, void *arg0, void *arg1, void *arg2, void *arg3, void *arg4, void *arg5, void *arg6) {
  return ::unreal::helpers::HxcppRuntimeStatic::callFunction(ptr, arg0, arg1, arg2, arg3, arg4, arg5, arg6);
}

void *::unreal::helpers::HxcppRuntime::callFunction(void *ptr, void *arg0, void *arg1, void *arg2, void *arg3, void *arg4, void *arg5, void *arg6, void *arg7) {
  return ::unreal::helpers::HxcppRuntimeStatic::callFunction(ptr, arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7);
}
