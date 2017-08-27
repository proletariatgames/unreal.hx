#ifdef __clang__
#pragma clang diagnostic pop
#elif _MSC_VER
#undef _CRT_SECURE_NO_WARNINGS
#undef _CRT_SECURE_NO_WARNINGS_GLOBALS
#undef _CRT_SECURE_NO_DEPRECATE
#pragma warning( default : 4996 )
#endif