#include "HXRuntimePrivatePCH.h"

#if PLATFORM_WINDOWS || PLATFORM_WINRT
	#include <windows.h>
#elif PLATFORM_MAC || PLATFORM_IOS || PLATFORM_LINUX || PLATFORM_ANDROID
	#include <pthread.h>
#else
#endif

extern "C" void  gc_set_top_of_stack(int *inTopOfStack,bool inForce);
extern "C" const char *hxRunLibrary();

static void *get_top_of_stack(void)
{
#if (PLATFORM_WINDOWS || PLATFORM_WINRT)
	MEMORY_BASIC_INFORMATION info;
	VirtualQuery(&info, &info, sizeof(MEMORY_BASIC_INFORMATION));
	return (void *)info.BaseAddress + info.RegionSize;
#elif (PLATFORM_MAC || PLATFORM_IOS)
	printf("mac\n");
	return (void *)pthread_get_stackaddr_np(pthread_self());
#elif (PLATFORM_LINUX || PLATFORM_ANDROID)
	return NULL;
#else //PLATFORM_PS4, PLATFORM_XBOXONE, PLATFORM_HTML5
// #elif 
	return NULL;
#endif
}

class FHXRuntime : public IHXRuntime
{
	/** IModuleInterface implementation */
	virtual void StartupModule() override;
	virtual void ShutdownModule() override;
};

IMPLEMENT_MODULE( FHXRuntime, hxruntime )

static int do_init()
{
	int x;
	printf("INITIALIZING INSIDE MODULE(2) : %llx\n", (long long int) &x);
	void *top_of_stack = get_top_of_stack();
	printf("TOP OF STACK: %lld ; COMMAND LINE ARGS: %lld\n",(long long int) top_of_stack, (long long int) FCommandLine::Get());
	return 42;
}

static int my_init = do_init();

void FHXRuntime::StartupModule()
{
	printf("======================\n\nSTARTUP MODULE (2) \\o/\n");
	int x;
	printf("STARTUP MODULE: %llx\n", (long long int) &x);
	// This code will execute after your module is loaded into memory (but after global variables are initialized, of course.)
}


void FHXRuntime::ShutdownModule()
{
	// This function may be called during shutdown to clean up your module.  For modules that support dynamic reloading,
	// we call this function before unloading the module.
}

