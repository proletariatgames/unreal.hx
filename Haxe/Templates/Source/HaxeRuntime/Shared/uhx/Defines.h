#pragma once

#ifndef UHX_FAT_VARIANTPTR
// For now we default to use fat pointers if we're not on a 64-bit platform
// However the trick for 64-bit platforms is not universal and depends on the fact
// that in both Linux and Windows, negative pointers are reserved for kernel memory
// so we can be sure that these addresses are unused
  #if defined(_WIN32) || defined(_WIN64)
    #if defined(_WIN64) && _WIN64
      #define UHX_FAT_VARIANTPTR 0
    #else
      #define UHX_FAT_VARIANTPTR 1
    #endif
  #elif defined(__x86_64__) && __x86_64__
      #define UHX_FAT_VARIANTPTR 0
  #else
    #define UHX_FAT_VARIANTPTR 1
  #endif

#endif

#ifndef UHX_IGNORE_POD
// this was an optimization we used to do to make POD struct wrappers smaller,
// but it causes issues when we try to extend POD structs
#define UHX_IGNORE_POD 1
#endif

#ifndef UHX_DEBUG
#if defined(UE_BUILD_SHIPPING)
#define UHX_DEBUG !UE_BUILD_SHIPPING
#elif defined(HXCPP_DEBUG)
#define UHX_DEBUG HXCPP_DEBUG
#else
#define UHX_DEBUG 0
#endif
#endif