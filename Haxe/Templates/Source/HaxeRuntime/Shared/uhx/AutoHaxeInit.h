#pragma once
#include "HaxeInit.h"

struct AutoHaxeInit
{
  bool wasRegistered;
  AutoHaxeInit()
  {
    this->wasRegistered = uhx_start_stack(&this->wasRegistered);
  }

  ~AutoHaxeInit()
  {
    if (this->wasRegistered)
    {
      uhx_end_stack();
    }
  }
};