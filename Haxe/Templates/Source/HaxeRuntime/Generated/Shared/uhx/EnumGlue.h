#pragma once
#include "IntPtr.h"

namespace uhx {

template<typename T>
struct EnumGlue {
  static T haxeToUe(unreal::UIntPtr haxe);
  static unreal::UIntPtr ueToHaxe(T ue);
};

}
