#ifndef __HAXERUNTIMEHELPERS_H__
#define __HAXERUNTIMEHELPERS_H__

#include "HaxeRuntime.h"
#include "Engine.h"

namespace unreal {
namespace glue {

class RuntimeHelpers
{
  public:
    static const char *FStringToHxcpp(FString &str);
    static FString HxcppToFString(const char *str);
    static const char *FTextToHxcpp(FText& str);
    static FText HxcppToFText(const char *str);
};

}
}


#endif

