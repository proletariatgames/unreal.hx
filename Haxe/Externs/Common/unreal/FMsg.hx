package unreal;

@:glueCppIncludes("Logging/LogMacros.h")
@:uextern extern class FMsg {
  @:glueHeaderCode('
		static void Logf(unreal::UIntPtr file, int line, unreal::VariantPtr category, int verbosity, unreal::UIntPtr data);
  ')
  @:glueCppCode('
  void uhx::glues::FMsg_Glue_obj::Logf(unreal::UIntPtr file, int line, unreal::VariantPtr category, int verbosity, unreal::UIntPtr data) {
    FMsg::Logf(TCHAR_TO_ANSI(UTF8_TO_TCHAR(::uhx::expose::HxcppRuntime::stringToConstChar((unreal::UIntPtr) (file)))), line, *::uhx::StructHelper< FName >::getPointer(category), ( (ELogVerbosity::Type) verbosity ), TEXT("%s"), UTF8_TO_TCHAR(::uhx::expose::HxcppRuntime::stringToConstChar((unreal::UIntPtr) (data))));
  }
  ')
  static function Logf(file:AnsiCharStar, line:Int, category:Const<PRef<FName>>, verbosity:ELogVerbosity, data:TCharStar):Void;
}