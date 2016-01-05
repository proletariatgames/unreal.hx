package unreal;
import unreal.helpers.Log_Glue;
import unreal.helpers.HaxeHelpers;

@:uextern
@:ueGluePath("unreal.helpers.Log_Glue")
@:glueCppIncludes("Engine.h")
@:ueCppDef("DECLARE_LOG_CATEGORY_EXTERN(HaxeLog, Log, All);\nDEFINE_LOG_CATEGORY(HaxeLog)")
class Log implements ue4hx.internal.NeedsGlue {
  @:glueHeaderCode('static void trace(void *str);')
  @:glueCppCode('void unreal::helpers::Log_Glue_obj::trace(void *str) {\n\tUE_LOG(HaxeLog,Log,TEXT("%s"),UTF8_TO_TCHAR(::unreal::helpers::HxcppRuntime::stringToConstChar(str)));\n}')
  @:glueCppIncludes('Engine.h', '<HxcppRuntime.h>')
  @:glueHeaderIncludes('<hxcpp.h>')
  public static function trace(str:String):Void {
    Log_Glue.trace(HaxeHelpers.dynamicToPointer( str ));
  }

  @:glueHeaderCode('static void warning(void *str);')
  @:glueCppCode('void unreal::helpers::Log_Glue_obj::warning(void *str) {\n\tUE_LOG(HaxeLog,Warning,TEXT("%s"),UTF8_TO_TCHAR(::unreal::helpers::HxcppRuntime::stringToConstChar(str)));\n}')
  @:glueCppIncludes('Engine.h', '<HxcppRuntime.h>')
  @:glueHeaderIncludes('<hxcpp.h>')
  public static function warning(str:String):Void {
    unreal.helpers.Log_Glue.warning(HaxeHelpers.dynamicToPointer( str ));
  }

  @:glueHeaderCode('static void error(void *str);')
  @:glueCppCode('void unreal::helpers::Log_Glue_obj::error(void *str) {\n\tUE_LOG(HaxeLog,Error,TEXT("%s"),UTF8_TO_TCHAR(::unreal::helpers::HxcppRuntime::stringToConstChar(str)));\n}')
  @:glueCppIncludes('Engine.h', '<HxcppRuntime.h>')
  @:glueHeaderIncludes('<hxcpp.h>')
  public static function error(str:String):Void {
    unreal.helpers.Log_Glue.error(HaxeHelpers.dynamicToPointer( str ));
  }

  @:glueHeaderCode('static void fatal(void *str);')
  @:glueCppCode('void unreal::helpers::Log_Glue_obj::fatal(void *str) {\n\tUE_LOG(HaxeLog,Fatal,TEXT("%s"),UTF8_TO_TCHAR(::unreal::helpers::HxcppRuntime::stringToConstChar(str)));\n}')
  @:glueCppIncludes('Engine.h', '<HxcppRuntime.h>')
  @:glueHeaderIncludes('<hxcpp.h>')
  public static function fatal(str:String):Void {
    unreal.helpers.Log_Glue.fatal(HaxeHelpers.dynamicToPointer( str ));
  }
}
