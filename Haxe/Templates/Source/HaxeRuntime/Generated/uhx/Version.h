#pragma once

#include "../Launch/Resources/Version.h"
#ifndef ENGINE_MINOR_VERSION
#error "Version not found"
#endif
 
#define UE_VER (ENGINE_MAJOR_VERSION * 100 + ENGINE_MINOR_VERSION)
