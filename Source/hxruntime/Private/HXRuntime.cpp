#include "HXRuntimePrivatePCH.h"

#if PLATFORM_WINDOWS || PLATFORM_WINRT || PLATFORM_XBOXONE
	#include <windows.h>
#elif PLATFORM_MAC || PLATFORM_IOS || PLATFORM_LINUX || PLATFORM_ANDROID
	#include <pthread.h>
#else
#endif

// DEFINE_LOG_CATEGORY(HXR);

extern "C" void  gc_set_top_of_stack(int *inTopOfStack,bool inForce);
extern "C" const char *hxRunLibrary();
// void __scriptable_load_cppia(String inCode);

static void *get_top_of_stack(void)
{
#if PLATFORM_WINDOWS || PLATFORM_WINRT || PLATFORM_XBOXONE //TODO: see if XBOXONE really behaves like Windows
	MEMORY_BASIC_INFORMATION info;
	VirtualQuery(&info, &info, sizeof(MEMORY_BASIC_INFORMATION));
	return (void *)info.BaseAddress + info.RegionSize;
#elif PLATFORM_MAC || PLATFORM_IOS
	return pthread_get_stackaddr_np(pthread_self());
#elif PLATFORM_LINUX || PLATFORM_ANDROID
	return NULL;
#else //PLATFORM_PS4, PLATFORM_HTML5
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

static void *get_init_stack()
{
	int x;
	void *x_addr = (void *) (intptr_t) &x;
	return x_addr;
}

static void *init_stack = get_init_stack();

void FHXRuntime::StartupModule()
{
	// This code will execute after your module is loaded into memory (but after global variables are initialized, of course.)
	int x;
	void *top_of_stack = get_top_of_stack();
	if (NULL == top_of_stack)
	{
		// UE_LOG(HXR, Error, TEXT("Currently unsupported Haxe runtime platform. Trying to get approximate stack size"));
		top_of_stack = &x;
		if (init_stack > top_of_stack)
			top_of_stack = init_stack;
	}

	gc_set_top_of_stack((int *)top_of_stack, false);
	const char *error = hxRunLibrary();
	// if (error) { UE_LOG(HXR, Error, TEXT("Error on Haxe main function: %s"), UTF8_TO_TCHAR(error)); }
	if (error) { fprintf(stderr, "Error on Haxe main function: %s", error); }
}


void FHXRuntime::ShutdownModule()
{
	// This function may be called during shutdown to clean up your module.  For modules that support dynamic reloading,
	// we call this function before unloading the module.
}

