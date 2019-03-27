#include "HaxeRuntime.h"
#include "uhx/expose/HxcppRuntime.h"

extern "C" {
  HAXERUNTIME_API void uhx_print_callstack();
  HAXERUNTIME_API void uhx_print_excstack();
}

void uhx_print_callstack() {
	uhx::expose::HxcppRuntime::printCallStack();
}

void uhx_print_excstack() {
	uhx::expose::HxcppRuntime::printExceptionStack();
}