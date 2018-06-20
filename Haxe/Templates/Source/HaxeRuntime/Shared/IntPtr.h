#pragma once
#ifndef _MSC_VER
#include <stdint.h>
#endif

namespace unreal {

#ifdef _WIN32
#ifdef _WIN64
typedef signed __int64 IntPtr;
typedef unsigned __int64 UIntPtr;

typedef unsigned __int64 SizeT;
#else
typedef __W64 signed int IntPtr;
typedef __W64 unsigned int UIntPtr;

typedef unsigned long SizeT;
#endif
#elif defined(__APPLE__) && __APPLE__

typedef size_t SizeT;

#if defined(_M_X64) || defined(__amd64__)
typedef signed long long int IntPtr;
typedef unsigned long long int UIntPtr;
#else
typedef signed int IntPtr;
typedef unsigned int UIntPtr;
#endif

#else
typedef intptr_t IntPtr;
typedef uintptr_t UIntPtr;
typedef size_t SizeT;
#endif

}
