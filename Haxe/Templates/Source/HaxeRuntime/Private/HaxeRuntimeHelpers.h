#ifndef __HAXERUNTIMEHELPERS_H__
#define __HAXERUNTIMEHELPERS_H__

#include "HaxeRuntime.h"
#include <UObject/UnrealString.h>
#include <hx/CFFI.h>

namespace unreal {
namespace glue {

class RuntimeHelpers_obj
{
  public:
    static value FStringToHxcpp(FString &str)
    {
      return alloc_string( TCHAR_TO_UTF8( *str ) );
    }

    static FString HxcppToFString(value str)
    {
      if (!val_is_string(str)) return FString("null");
      return FString( UTF8_TO_TCHAR(val_string(str)) );
    }

    static value FTextToHxcpp(FText& str)
    {
      return alloc_string( TCHAR_TO_UTF8( *(str.ToString()) ) );
    }

    static FText HxcppToFText(value str)
    {
      if (!val_is_string(str)) return LOCTEXT("null");
      return FText::FromString( FString(UTF8_TO_TCHAR(val_string(str))) );
    }
}

}
}


#endif
