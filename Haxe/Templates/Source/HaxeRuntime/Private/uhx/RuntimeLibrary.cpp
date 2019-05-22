#include "Core.h"
#include "IntPtr.h"
#include "uhx/ue/RuntimeLibrary.h"
#include "HAL/PlatformAtomics.h"

static int uhx_tls_slot = 0;

#if defined(_MSC_VER)
unreal::UIntPtr *uhx::ue::RuntimeLibrary_obj::tlsObj = nullptr;
#elif defined(__GNUC__)
thread_local unreal::UIntPtr *uhx::ue::RuntimeLibrary_obj::tlsObj = nullptr;
#else
static int uhx_tls_obj = FPlatformTLS::AllocTlsSlot();

unreal::UIntPtr uhx::ue::RuntimeLibrary_obj::getTlsObj() {
  unreal::UIntPtr *ret = (unreal::UIntPtr *) FPlatformTLS::GetTlsValue(uhx_tls_obj);
  if (!ret) {
    ret = (unreal::UIntPtr*) uhx::GcRef::createRoot();
    FPlatformTLS::SetTlsValue(uhx_tls_obj, (void*) ret);
    return *ret = uhx::expose::HxcppRuntime::createArray();
  }
  return *ret;
}
#endif

int uhx::ue::RuntimeLibrary_obj::allocTlsSlot() {
  return FPlatformAtomics::InterlockedIncrement(&uhx_tls_slot);
}