#include "HaxeInitPrivatePCH.h"

class FHaxeInit : public IHaxeInit
{
	/** IModuleInterface implementation */
	virtual void StartupModule() override;
	virtual void ShutdownModule() override;
};

// IMPLEMENT_MODULE( FHaxeInit, HaxeInit )
void FHaxeInit::StartupModule()
{
  // This module is empty; we only need the build system integration
  // (sources at /Haxe/BuildTool/src/ubuild/HaxeInit.hx)
}


void FHaxeInit::ShutdownModule()
{
}

