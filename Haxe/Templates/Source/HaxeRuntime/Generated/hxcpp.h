// this is a minimal hxcpp header so we can reference some select hxcpp-generated headers in UE4
// the actual hxcpp header can't be included by the UE4 build because of incompatible compiler options

#ifndef HXCPP_H
#define HXCPP_H

#ifndef _MSC_VER
   #include <stdint.h>
   #ifndef EMSCRIPTEN
      #ifndef __MINGW32__
         typedef int64_t  __int64;
      #endif
   #endif
#endif

#if defined(EMSCRIPTEN) || defined(IPHONE)
  #include <unistd.h>
  #include <cstdlib>
#endif

#include <string.h>
#include <wchar.h>

#ifdef HX_LINUX
  #include <unistd.h>
  #include <cstdio>
  #include <stddef.h>
#endif

#define HXCPP_CLASS_ATTRIBUTES HAXERUNTIME_API

typedef char HX_CHAR;

#pragma warning(disable:4251)
#pragma warning(disable:4800)

#if defined(_MSC_VER) && _MSC_VER < 1201
#error MSVC 7.1 does not support template specialization and is not supported by HXCPP
#endif


// HXCPP includes...

// Basic mapping from haxe -> c++

typedef int Int;
typedef bool Bool;

#ifdef HXCPP_FLOAT32
typedef float Float;
#else
typedef double Float;
#endif

// Extended mapping - cpp namespace
namespace cpp
{
   typedef signed char Int8;
   typedef unsigned char UInt8;
   typedef char Char;
   typedef signed short Int16;
   typedef unsigned short UInt16;
   typedef signed int Int32;
   typedef unsigned int UInt32;
   #ifdef _WIN32
   typedef __int64 Int64;
   typedef unsigned __int64 UInt64;
   // TODO - EMSCRIPTEN?
   #else
   typedef int64_t Int64;
   typedef uint64_t UInt64;
   #endif
   typedef float Float32;
   typedef double Float64;
};
// Extended mapping - old way
namespace haxe { namespace io { typedef unsigned char Unsigned_char__; } }

// --- Forward decalarations --------------------------------------------

namespace cpp { class CppInt32__; }
namespace hx { class Object; }
namespace hx { class FieldRef; }
namespace hx { class IndexRef; }
namespace hx { template<typename O> class ObjectPtr; }
namespace cpp { template<typename S,typename H> class Struct; }
template<typename ELEM_> class Array_obj;
template<typename ELEM_> class Array;
namespace hx {
   class Class_obj;
   typedef hx::ObjectPtr<hx::Class_obj> Class;
}

#if (HXCPP_API_LEVEL < 320) && !defined(__OBJC__)
typedef hx::Class Class;
typedef hx::Class_obj Class_obj;
#endif

class Dynamic;
class String;

// Use an external routine to throw to avoid sjlj overhead on iphone.
namespace hx { HXCPP_EXTERN_CLASS_ATTRIBUTES Dynamic Throw(Dynamic inDynamic); }
namespace hx { HXCPP_EXTERN_CLASS_ATTRIBUTES void CriticalError(const String &inError); }
namespace hx { HXCPP_EXTERN_CLASS_ATTRIBUTES void NullReference(const char *type, bool allowFixup); }
namespace hx { extern String sNone[]; }
void __hxcpp_check_overflow(int inVal);

#endif
