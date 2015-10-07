// Copyright 1998-2015 Epic Games, Inc. All Rights Reserved.

#include "HaxeRuntime.h"

#if PLATFORM_WINDOWS || PLATFORM_WINRT || PLATFORM_XBOXONE
	#include <windows.h>
#elif PLATFORM_MAC || PLATFORM_IOS || PLATFORM_LINUX || PLATFORM_ANDROID
	#include <pthread.h>
#else
#endif

IMPLEMENT_GAME_MODULE( FHaxeRuntime, HaxeSources );

extern "C" void  gc_set_top_of_stack(int *inTopOfStack,bool inForce);
extern "C" const char *hxRunLibrary();
// void __scriptable_load_cppia(String inCode);

static void *get_top_of_stack(void)
{
#if PLATFORM_WINDOWS || PLATFORM_WINRT || PLATFORM_XBOXONE //TODO: see if XBOXONE really behaves like Windows
  MEMORY_BASIC_INFORMATION info;
  VirtualQuery(&info, &info, sizeof(MEMORY_BASIC_INFORMATION));
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

static bool did_init = false;

extern "C" void check_hx_init()
{
  if (did_init) return;
  did_init = true;

  // This code will execute after your module is loaded into memory (but after global variables are initialized, of course.)
  int x;
  void *top_of_stack = get_top_of_stack();
  if (NULL == top_of_stack)
  {
    // UE_LOG(HXR, Error, TEXT("Currently unsupported Haxe runtime platform. Trying to get approximate stack size"));
    top_of_stack = &x;
  }

#ifdef WITH_HAXE
  gc_set_top_of_stack((int *)top_of_stack, false);
  const char *error = hxRunLibrary();
  // if (error) { UE_LOG(HXR, Error, TEXT("Error on Haxe main function: %s"), UTF8_TO_TCHAR(error)); }
  if (error) { fprintf(stderr, "Error on Haxe main function: %s", error); }
#endif
}

void FHaxeRuntime::StartupModule()
{
  check_hx_init();
}
 
void FHaxeRuntime::ShutdownModule()
{
}
