#include "HaxeRuntime.h"
#include "HaxeRuntimeHelpers.h"

namespace unreal {
namespace glue {

const char *RuntimeHelpers::FStringToHxcpp(FString str)
{
  return TCHAR_TO_UTF8( *str );
}

FString RuntimeHelpers::HxcppToFString(const char *str)
{
  if (NULL == str) return FString("null");
  return FString( UTF8_TO_TCHAR(str) );
}

const char *RuntimeHelpers::FTextToHxcpp(FText str)
{
  return TCHAR_TO_UTF8( *(str.ToString()) );
}

FText RuntimeHelpers::HxcppToFText(const char *str)
{
  if (NULL == str) return FText::FromString(TEXT("null"));
  return FText::FromString( FString(UTF8_TO_TCHAR(str)) );
}

}
}
