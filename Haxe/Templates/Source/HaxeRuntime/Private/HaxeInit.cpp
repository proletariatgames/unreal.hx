#include "HaxeRuntime.h"
#include "HaxeInit.h"
#include "IntPtr.h"
#include "Core.h"
#include "HAL/PlatformAtomics.h"
#include <cstdio>
#include <clocale>

#if PLATFORM_WINDOWS || PLATFORM_XBOXONE
  #include "Windows/MinimalWindowsApi.h"
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
