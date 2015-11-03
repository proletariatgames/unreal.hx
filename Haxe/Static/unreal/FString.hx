package unreal;

/**
  Represents an Unreal String - will be converted to a normal Haxe String
 **/
@:forward abstract FString(FStringImpl) from FStringImpl to FStringImpl {
#if !bake_externs
  inline public function new(str:String) {
    this = FStringImpl.create(str);
  }

  inline public static function create(str:String):unreal.PHaxeCreated<FString> {
    return FStringImpl.create(str);
  }

  @:from inline private static function fromString(str:String):FString {
    return create(str);
  }

  public function toString():String {
    return this.op_Dereference();
  }
#end
}


// @:uextern
// @:ueGluePath("unreal.helpers.FString_Glue")
// @:glueCppIncludes("Engine.h")
// @:glueHeaderIncludes("<unreal/helpers/UEPointer.h>")
// class FString_Helper implements ue4hx.internal.NeedsGlue {
// #if !bake_externs
//   @:glueHeaderCode('static void* to_string(haxe::helpers::UEPointer* str);')
//   @:glueCppCode('void* unreal::helpers::FString_Glue_obj::to_string(haxe::helpers::UEPointer* str) {\n\treturn ::unreal::helpers::HxcppRuntime::constCharToString(TCHAR_TO_UTF8( **((FString*)str->getPointer()) ));\n}');
//   @:glueCppIncludes('<OPointers.h>', '<unreal/helpers/HxcppRuntime.h>')
//   @:glueHeaderIncludes('<hxcpp.h>')
//   public static function toString(str:FStringImpl):String {
//     @:privateAccess str.wrapped
//     return cast @:privateAccess FNameImpl.wrap( FName_Glue.from_string(ptr) );
//   }
// #end
// }
//
