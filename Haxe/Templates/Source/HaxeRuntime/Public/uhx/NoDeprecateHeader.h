#ifdef __clang__
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
#elif _MSC_VER
#pragma warning( disable : 4996 )
#define _CRT_SECURE_NO_WARNINGS 1
#define _CRT_SECURE_NO_WARNINGS_GLOBALS 1
#define _CRT_SECURE_NO_DEPRECATE 1
#endif
