#pragma once
#include <stdio.h>
#include "IntPtr.h"

void uhx_printf(const char * const format, ...);

class PrintfHelper_obj {
	public:
	static unreal::UIntPtr getAndFlush();
};