#include "HaxeRuntime.h"
#include "HaxeInit.h"
#include "IntPtr.h"
#include "Core.h"
#include "HAL/PlatformAtomics.h"
#include <cstdio>
#include <cstdlib>
#include <clocale>
#include <string.h>
#include "Misc/CommandLine.h"

// argument handling
extern int _hxcpp_argc;
extern char **_hxcpp_argv;

/*
ISWHITE and ParseCommandLine are based on the implementation of the
.NET Core runtime, CoreCLR, which is licensed under the MIT license:
Copyright (c) Microsoft. All rights reserved.
See LICENSE file in the CoreCLR project root for full license information.

The original source code of ParseCommandLine can be found in
https://github.com/dotnet/coreclr/blob/master/src/vm/util.cpp
*/

#define ISWHITE(x) ((x)==(' ') || (x)==('\t') || (x)==('\n') || (x)==('\r') )

static void ParseCommandLine(char *psrc, TArray<char *> &out)
{
    unsigned int argcount = 1;       // discovery of arg0 is unconditional, below

    bool    fInQuotes;
    int     iSlash;

    /* A quoted program name is handled here. The handling is much
       simpler than for other arguments. Basically, whatever lies
       between the leading double-quote and next one, or a terminal null
       character is simply accepted. Fancier handling is not required
       because the program name must be a legal NTFS/HPFS file name.
       Note that the double-quote characters are not copied, nor do they
       contribute to numchars.

       This "simplification" is necessary for compatibility reasons even
       though it leads to mishandling of certain cases.  For example,
       "c:\tests\"test.exe will result in an arg0 of c:\tests\ and an
       arg1 of test.exe.  In any rational world this is incorrect, but
       we need to preserve compatibility.
    */

    char *pStart = psrc;
    bool skipQuote = false;

    // Pairs of double-quotes vanish...
    while(psrc[0]=='\"' && psrc[1]=='\"')
       psrc += 2;

    if (*psrc == '\"')
    {
        // scan from just past the first double-quote through the next
        // double-quote, or up to a null, whichever comes first
        psrc++;
        while ((*psrc!= '\"') && (*psrc != '\0'))
        {
           psrc++;
           // Pairs of double-quotes vanish...
           while(psrc[0]=='\"' && psrc[1]=='\"')
              psrc += 2;
        }

        skipQuote = true;
    }
    else
    {
        /* Not a quoted program name */

        while (!ISWHITE(*psrc) && *psrc != '\0')
            psrc++;
    }

    // We have now identified arg0 as pStart (or pStart+1 if we have a leading
    // quote) through psrc-1 inclusive
    if (skipQuote)
        pStart++;
    char *arg0 = (char*) calloc(psrc - pStart + 1, sizeof(char));
    memcpy(arg0, pStart, psrc - pStart);
    pStart = psrc;
    out.Push(arg0); // the command isn't part of Sys.args()

    // if we stopped on a double-quote when arg0 is quoted, skip over it
    if (skipQuote && *psrc == '\"')
        psrc++;

    while ( *psrc != '\0')
    {
LEADINGWHITE:

        // The outofarg state.
        while (ISWHITE(*psrc))
            psrc++;

        if (*psrc == '\0')
            break;
        else
        if (*psrc == '#')
        {
            while (*psrc != '\0' && *psrc != '\n')
                psrc++;     // skip to end of line

            goto LEADINGWHITE;
        }

        argcount++;
        fInQuotes = false;

        char *argStart = psrc;
        TArray<char> arg;

        while ((!ISWHITE(*psrc) || fInQuotes) && *psrc != '\0')
        {
            switch (*psrc)
            {
            case '\\':
                iSlash = 0;
                while (*psrc == '\\')
                {
                    iSlash++;
                    psrc++;
                }

                if (*psrc == '\"')
                {
                    for ( ; iSlash >= 2; iSlash -= 2)
                    {
                        arg.Push('\\');
                    }

                    if (iSlash & 1)
                    {
                        arg.Push(*psrc);
                        psrc++;
                    }
                    else
                    {
                        fInQuotes = !fInQuotes;
                        psrc++;
                    }
                }
                else
                    for ( ; iSlash > 0; iSlash--)
                    {
                        arg.Push('\\');
                    }

                break;

            case '\"':
                fInQuotes = !fInQuotes;
                psrc++;
                break;

            default:
                arg.Push(*psrc);
                psrc++;
            }
        }

        char *toAdd = (char*) calloc(arg.Num() + 1, sizeof(char));
        memcpy(toAdd, arg.GetData(), arg.Num());
        out.Add(toAdd);
        arg = TArray<char>();
    }
}

/**
  Initializes _hxcpp_argc and _hxcpp_argv so that Sys.args() doesn't go through the normal path.
  This is needed because we can run into locale issues due to incompatibilities between Unreal and hxcpp,
  which can lead to hard crashes while parsing the command-line (due to the setlocale call which is made inside the hxcpp initialization)
  So instead of letting hxcpp do the work, we are going to fill the _hxcpp_argc and _hxcpp_argv information as if
  it was run in a normal `main` code, and instead parse the command-line ourselves with an UTF8 version of it
**/
static void uhx_init_args()
{
  if (_hxcpp_argc == 0)
  {
    TArray<char *> Ret;
    ParseCommandLine(TCHAR_TO_UTF8(FCommandLine::GetOriginal()), Ret);
    _hxcpp_argc = Ret.Num() + 1;
    _hxcpp_argv = (char**) calloc(Ret.Num() + 3, sizeof(char*));
    memcpy(_hxcpp_argv + 1, Ret.GetData(), Ret.Num() * sizeof(char*));
    _hxcpp_argv[0] = _hxcpp_argv[1]; // we skip the first argument as it should be the executable path
  }
}

#if PLATFORM_WINDOWS || PLATFORM_XBOXONE
  namespace Windows {
  typedef struct _MEMORY_BASIC_INFORMATION {
    LPVOID  BaseAddress;
    LPVOID  AllocationBase;
    DWORD  AllocationProtect;
    SIZE_T RegionSize;
    DWORD  State;
    DWORD  Protect;
    DWORD  Type;
  } MEMORY_BASIC_INFORMATION, *PMEMORY_BASIC_INFORMATION;
  extern "C" __declspec(dllimport) SIZE_T WINAPI VirtualQuery(LPCVOID lpAddress, PMEMORY_BASIC_INFORMATION lpBuffer, SIZE_T dwLength);
  }
#elif PLATFORM_MAC || PLATFORM_IOS || PLATFORM_LINUX || PLATFORM_ANDROID
  #include <pthread.h>
#endif

#define UHX_CAS(Dest, Exchange, Comparand) FPlatformAtomics::InterlockedCompareExchange((volatile int32*) Dest, Exchange, Comparand)

extern "C" void  gc_set_top_of_stack(int *inTopOfStack,bool inPush);
extern "C" const char *hxRunLibrary();
// void __scriptable_load_cppia(String inCode);

#if PLATFORM_WINDOWS || PLATFORM_XBOXONE
  #define DECLARE_FAST_TLS(name) static __declspec( thread ) void *name
  #define GET_TLS_VALUE(name) name
  #define SET_TLS_VALUE(name, value) name = value
#elif PLATFORM_LINUX || PLATFORM_ANDROID
  #define DECLARE_FAST_TLS(name) static thread_local void *name
  #define GET_TLS_VALUE(name) name
  #define SET_TLS_VALUE(name, value) name = value
#else
  #define DECLARE_FAST_TLS(name) static uint32 name = FPlatformTLS::AllocTlsSlot()
  #define GET_TLS_VALUE(name) FPlatformTLS::GetTlsValue(name)
  #define SET_TLS_VALUE(name, value) FPlatformTLS::SetTlsValue(name, value)
#endif

int __hxcpp_GetCurrentThreadNumber();

namespace TlsRegisterEnum
{
  enum Value {
    NotRegistered = 0,
    RegLocally,
    RegLocallyAndWrapped,
    #if WITH_EDITOR
    RegGlobally,
    RegGloballyAndWrapped,
    #endif
    HaxeThread,
    HaxeThreadWrapped,
  };
}

static void *get_top_of_stack(void)
{
#if PLATFORM_WINDOWS || PLATFORM_XBOXONE //TODO: see if XBOXONE really behaves like Windows
  Windows::MEMORY_BASIC_INFORMATION info;
  Windows::VirtualQuery(&info, &info, sizeof(Windows::MEMORY_BASIC_INFORMATION));
  return (void *) (( (char *) info.BaseAddress) + info.RegionSize);
#elif PLATFORM_MAC || PLATFORM_IOS
  return pthread_get_stackaddr_np(pthread_self());
#elif PLATFORM_LINUX || PLATFORM_ANDROID
  pthread_t self = pthread_self();
  pthread_attr_t attr;
  void* addr;
  size_t size;

  pthread_getattr_np(self, &attr);
  pthread_attr_getstack(&attr, &addr, &size);
  pthread_attr_destroy(&attr);

  return (void *) (((unreal::IntPtr)addr) + size);
#else //PLATFORM_PS4, PLATFORM_HTML5
  return NULL;
#endif
}

static volatile uint32 gDidInit = 0;
DECLARE_FAST_TLS(tlsRegistered);

static bool uhx_init_if_needed(void *top_of_stack)
{
  if (gDidInit || UHX_CAS(&gDidInit, 1, 0) != 0) {
    if (GET_TLS_VALUE(tlsRegistered)) {
      // we are currently initializing in the main thread
      return false;
    }

    while (gDidInit != 2) {
      // spin while waiting for the initialization to finish
      FPlatformProcess::Sleep(0.01f);
    }
    return false;
  }

  // This code will execute after your module is loaded into memory (but after global variables are initialized, of course.)

#ifdef WITH_HAXE
  #if WITH_EDITOR
  SET_TLS_VALUE(tlsRegistered, (void *) (unreal::IntPtr) TlsRegisterEnum::RegGlobally);
  top_of_stack = get_top_of_stack();
  #else
  SET_TLS_VALUE(tlsRegistered, (void *) (unreal::IntPtr) TlsRegisterEnum::RegLocally);
  #endif

  uhx_init_args();
  gc_set_top_of_stack((int *)top_of_stack, false);
  const char *error = hxRunLibrary();
  if (error) { UE_LOG(HaxeLog, Fatal, TEXT("Error on Haxe main function: %s"), UTF8_TO_TCHAR(error)); }
  // hxcpp sets the locale to "" which is incompatible with Unreal - so let's set it back to C
  // see https://github.com/HaxeFoundation/hxcpp/commit/94812c34d7df0d9d50127a8ce6033c4e3f98cc9a for the commit that added this
  setlocale(LC_ALL, "C");
#endif
  gDidInit = 2;
  return true;
}

bool uhx_start_stack(void *top_of_stack)
{
  if (gDidInit != 2 && uhx_init_if_needed(top_of_stack))
  {
    #if WITH_EDITOR
    return false; // it was registered globally
    #else
    return true;
    #endif
  }
  unreal::IntPtr reg = (unreal::IntPtr) GET_TLS_VALUE(tlsRegistered);

  if (!reg)
  {
    int threadNum = __hxcpp_GetCurrentThreadNumber();
    if (threadNum == 0)
    {
      #ifdef WITH_HAXE
      gc_set_top_of_stack((int*) top_of_stack, false);
      #endif
      SET_TLS_VALUE(tlsRegistered, (void *) (unreal::IntPtr) TlsRegisterEnum::RegLocally);
    } else {
      // this is a haxe thread, so it's already registered
      SET_TLS_VALUE(tlsRegistered, (void *) (unreal::IntPtr) TlsRegisterEnum::HaxeThread);
      return false;
    }

    return true;
  }

  return false;
}

bool uhx_needs_wrap()
{
  unreal::IntPtr reg = (unreal::IntPtr) GET_TLS_VALUE(tlsRegistered);
  switch(reg)
  {
    case TlsRegisterEnum::RegLocallyAndWrapped:
    case TlsRegisterEnum::HaxeThreadWrapped:
    #if WITH_EDITOR
    case TlsRegisterEnum::RegGloballyAndWrapped:
    #endif
      return false;
    case TlsRegisterEnum::RegLocally:
      SET_TLS_VALUE(tlsRegistered, (void *) (unreal::IntPtr) TlsRegisterEnum::RegLocallyAndWrapped);
      return true;
    #if WITH_EDITOR
    case TlsRegisterEnum::RegGlobally:
      SET_TLS_VALUE(tlsRegistered, (void *) (unreal::IntPtr) TlsRegisterEnum::RegGloballyAndWrapped);
      return true;
    #endif
    case TlsRegisterEnum::HaxeThread:
      SET_TLS_VALUE(tlsRegistered, (void *) (unreal::IntPtr) TlsRegisterEnum::HaxeThreadWrapped);
      return true;
    default:
      UE_LOG(HaxeLog, Fatal, TEXT("uhx_needs_wrap was called before Haxe stack was registered (value %d)"), (int) reg);
      return true;
  }
}

void uhx_end_wrap()
{
  unreal::IntPtr reg = (unreal::IntPtr) GET_TLS_VALUE(tlsRegistered);
  switch(reg)
  {
    case TlsRegisterEnum::RegLocallyAndWrapped:
      reg = TlsRegisterEnum::RegLocally;
      break;
    case TlsRegisterEnum::HaxeThreadWrapped:
      reg = TlsRegisterEnum::HaxeThread;
      break;
    #if WITH_EDITOR
    case TlsRegisterEnum::RegGloballyAndWrapped:
      reg = TlsRegisterEnum::RegGlobally;
      break;
    #endif
    case TlsRegisterEnum::RegLocally:
    #if WITH_EDITOR
    case TlsRegisterEnum::RegGlobally:
    #endif
    case TlsRegisterEnum::HaxeThread:
    default:
      #if UE_BUILD_SHIPPING
      UE_LOG(HaxeLog, Error, TEXT("uhx_end_wrap was called in a thread that is not wrapped (current value %d)"), (int) reg);
      return;
      #else
      UE_LOG(HaxeLog, Fatal, TEXT("uhx_end_wrap was called in a thread that is not wrapped (current value %d)"), (int) reg);
      #endif
  }
  SET_TLS_VALUE(tlsRegistered, (void *) reg);
}

void uhx_end_stack()
{
  if (GET_TLS_VALUE(tlsRegistered) > (void*) (unreal::IntPtr) TlsRegisterEnum::RegLocallyAndWrapped)
  {
    #if UE_BUILD_SHIPPING
    UE_LOG(HaxeLog, Error, TEXT("uhx_end_stack called on a haxe/global stack"));
    #else
    UE_LOG(HaxeLog, Fatal, TEXT("uhx_end_stack called on a haxe/global stack"));
    #endif
  }

  #ifdef WITH_HAXE
  gc_set_top_of_stack(0, false);
  #endif

  SET_TLS_VALUE(tlsRegistered, (void *) (unreal::IntPtr) TlsRegisterEnum::NotRegistered);
}
