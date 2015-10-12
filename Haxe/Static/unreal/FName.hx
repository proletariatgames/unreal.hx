package unreal;
import unreal.helpers.FName_Glue;
import unreal.helpers.HaxeHelpers;

@:forward abstract FName(FNameImpl) from FNameImpl to FNameImpl {
#if !bake_externs
  inline public function new(str:String) {
    this = FName_Helper.from_string(str);
  }

  inline public static function create(str:String):unreal.PHaxeCreated<FName> {
    return FName_Helper.from_string(str);
  }

  @:from inline private static function fromString(str:String):FName {
    return create(str);
  }

  public function toString():String {
    return this.ToString();
  }
#end
}

@:uextern
@:ueGluePath("unreal.helpers.FName_Glue")
@:glueCppIncludes("Engine.h")
@:glueHeaderIncludes("<unreal/helpers/UEPointer.h>")
class FName_Helper {
#if !bake_externs
  @:glueHeaderCode('static ::unreal::helpers::UEPointer *from_string(void *str);')
  @:glueCppCode('::unreal::helpers::UEPointer *unreal::helpers::FName_Glue_obj::from_string(void *str) {\n\treturn new PHaxeCreated<FName>(new FName(UTF8_TO_TCHAR(::unreal::helpers::HxcppRuntime::stringToConstChar(str))));\n}')
  @:glueCppIncludes('<OPointers.h>', '<unreal/helpers/HxcppRuntime.h>')
  @:glueHeaderIncludes('<hxcpp.h>')
  public static function from_string(str:String):unreal.PHaxeCreated<FName> {
    var ptr = HaxeHelpers.dynamicToPointer( str );
    return cast @:privateAccess FNameImpl.wrap( FName_Glue.from_string(ptr) );
  }
#end
}
