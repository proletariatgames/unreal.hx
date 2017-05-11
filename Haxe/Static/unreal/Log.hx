package unreal;
import uhx.internal.Log_Glue;
import uhx.internal.HaxeHelpers;

@:uextern
@:ueGluePath("uhx.internal.Log_Glue")
@:glueCppIncludes("Core.h", "HaxeInit.h")
@:glueHeaderIncludes("IntPtr.h")
@:ueCppDef("DEFINE_LOG_CATEGORY(HaxeLog)")
class Log implements uhx.NeedsGlue {
  @:glueHeaderCode('static void trace(unreal::UIntPtr str);')
  @:glueCppCode('void uhx::internal::Log_Glue_obj::trace(unreal::UIntPtr str) {\n\tUE_LOG(HaxeLog,Log,TEXT("%s"),UTF8_TO_TCHAR(::uhx::expose::HxcppRuntime::stringToConstChar(str)));\n}')
  @:glueCppIncludes('Core.h', '<uhx/expose/HxcppRuntime.h>')
  @:glueHeaderIncludes('<hxcpp.h>')
  public static function trace(str:String):Void {
    Log_Glue.trace(HaxeHelpers.dynamicToPointer( str ));
  }

  @:glueHeaderCode('static void warning(unreal::UIntPtr str);')
  @:glueCppCode('void uhx::internal::Log_Glue_obj::warning(unreal::UIntPtr str) {\n\tUE_LOG(HaxeLog,Warning,TEXT("%s"),UTF8_TO_TCHAR(::uhx::expose::HxcppRuntime::stringToConstChar(str)));\n}')
  @:glueCppIncludes('Core.h', '<uhx/expose/HxcppRuntime.h>')
  @:glueHeaderIncludes('<hxcpp.h>')
  public static function warning(str:String):Void {
    Log_Glue.warning(HaxeHelpers.dynamicToPointer( str ));
  }

  @:glueHeaderCode('static void error(unreal::UIntPtr str);')
  @:glueCppCode('void uhx::internal::Log_Glue_obj::error(unreal::UIntPtr str) {\n\tUE_LOG(HaxeLog,Error,TEXT("%s"),UTF8_TO_TCHAR(::uhx::expose::HxcppRuntime::stringToConstChar(str)));\n}')
  @:glueCppIncludes('Core.h', '<uhx/expose/HxcppRuntime.h>')
  @:glueHeaderIncludes('<hxcpp.h>')
  public static function error(str:String):Void {
    Log_Glue.error(HaxeHelpers.dynamicToPointer( str ));
  }

  @:glueHeaderCode('static void fatal(unreal::UIntPtr str);')
  @:glueCppCode('void uhx::internal::Log_Glue_obj::fatal(unreal::UIntPtr str) {\n\tUE_LOG(HaxeLog,Fatal,TEXT("%s"),UTF8_TO_TCHAR(::uhx::expose::HxcppRuntime::stringToConstChar(str)));\n}')
  @:glueCppIncludes('Core.h', '<uhx/expose/HxcppRuntime.h>')
  @:glueHeaderIncludes('<hxcpp.h>')
  public static function fatal(str:String):Void {
    Log_Glue.fatal(HaxeHelpers.dynamicToPointer( str ));
  }
}
