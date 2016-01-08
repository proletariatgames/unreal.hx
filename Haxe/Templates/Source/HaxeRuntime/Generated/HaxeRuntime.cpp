#include "HaxeRuntime.h"

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
}
 
void FHaxeRuntime::ShutdownModule()
{
}
