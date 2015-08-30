#pragma once

#ifndef __HAXESOURCES_H__
#define __HAXESOURCES_H__

#ifdef WITH_HAXE
#include <hxcpp.h>
#endif
 
#include "Engine.h"
#include "ModuleManager.h"
#include "UnrealEd.h"

class FHaxeRuntime : public IModuleInterface
{
public:
  virtual void StartupModule() override;
  virtual void ShutdownModule() override;
};


#endif

