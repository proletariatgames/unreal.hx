package unreal;

@:glueCppIncludes("Internationalization/Text.h")
@:uname("FText")
@:uextern extern class FTextImpl {
  static function FromString(str:FString) : FTextImpl;
  function ToString():unreal.Const<unreal.PRef<FString>>;

  @:expr(return this.ToString().op_Dereference()) public function toString():String;
}


