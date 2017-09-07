#include "HaxeRuntime.h"
#include "HaxeInit.h"
#include "Core.h"
#include "HAL/PlatformAtomics.h"
#include <cstdio>

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

extern "C" void  gc_set_top_of_stack(int *inTopOfStack,bool inForce);
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

  return (void *) (((intptr_t)addr) + size);
#else //PLATFORM_PS4, PLATFORM_HTML5
  return NULL;
#endif
}

static volatile uint32 gDidInit = 0;
DECLARE_FAST_TLS(tlsDidInit);

void check_hx_init()
{
  bool firstInit = true;
  if (gDidInit || UHX_CAS(&gDidInit, 1, 0) != 0) {
    // check if the thread was registered
    if (!GET_TLS_VALUE(tlsDidInit)) {
      SET_TLS_VALUE(tlsDidInit, (void *) (intptr_t) 1);
    } else {
      return;
    }
    while (gDidInit == 1) {
      // spin while waiting for the initialization to finish
      FPlatformProcess::Sleep(0.01f);
    }

    firstInit = false;
  } else {
    // main thread needs TLS too
    SET_TLS_VALUE(tlsDidInit, (void *) (intptr_t) 1);
  }

  // This code will execute after your module is loaded into memory (but after global variables are initialized, of course.)
  int x;
  void *top_of_stack = get_top_of_stack();
  if (NULL == top_of_stack)
  {
    UE_LOG(HaxeLog, Error, TEXT("Currently unsupported Haxe runtime platform. Trying to get approximate stack size"));
    top_of_stack = &x;
  }

#ifdef WITH_HAXE
  gc_set_top_of_stack((int *)top_of_stack, false);
  if (firstInit) {
    const char *error = hxRunLibrary();
    if (error) { UE_LOG(HaxeLog, Fatal, TEXT("Error on Haxe main function: %s"), UTF8_TO_TCHAR(error)); }
  }
#endif
  gDidInit = 2;
}
