#include "HaxeRuntime.h"
#include "uhx/NoDeprecateHeader.h"

#include "PrintfCaptureTypes.h"
#include "CoreMinimal.h"
#include "uhx/expose/HxcppRuntime.h"
#include <stdlib.h>
#include <stdio.h>
#include <stdarg.h>
#include <string.h>

#if PLATFORM_WINDOWS && !defined(vsnprintf)
	#define vsnprintf _vsnprintf
#endif

#define PRINTF_BUFFER_SIZE 2048

static FString& getPrintfString() {
	static FString str;
	return str;
}

void uhx_printf(const char * const format, ...) {
	va_list args;
	int len = 0;
	char buffer[PRINTF_BUFFER_SIZE];

	va_start( args, format );
	len = vsnprintf(buffer, PRINTF_BUFFER_SIZE, format, args);

	if (len < 0) {
		strcpy(buffer, "(internal printf capture format error)\n");
	} else {
		buffer[len] = '\0';
	}

	getPrintfString() += UTF8_TO_TCHAR(buffer);

	va_end(args);
}

unreal::UIntPtr PrintfHelper_obj::getAndFlush() {
	FString ret = getPrintfString();
	getPrintfString() = TEXT("");
	return uhx::expose::HxcppRuntime::constCharToString(TCHAR_TO_UTF8(*ret));
}

#include "uhx/NoDeprecateFooter.h"