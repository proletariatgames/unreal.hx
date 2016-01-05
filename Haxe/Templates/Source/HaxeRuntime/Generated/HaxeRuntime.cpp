#include "HaxeRuntime.h"
extern "C" void check_hx_init();

class FHaxeRuntime : public IModuleInterface
{
public:
  virtual void StartupModule() override;
  virtual void ShutdownModule() override;

  virtual bool IsGameModule() const override
  {
    return true;
  }
};

IMPLEMENT_MODULE( FHaxeRuntime, HaxeRuntime )

void FHaxeRuntime::StartupModule()
{
  check_hx_init();
}
 
void FHaxeRuntime::ShutdownModule()
{
}
