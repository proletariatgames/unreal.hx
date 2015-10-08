#include "HaxeRuntime.h"
extern "C" void check_hx_init();


void FHaxeRuntime::StartupModule()
{
  check_hx_init();
}
 
void FHaxeRuntime::ShutdownModule()
{
}
