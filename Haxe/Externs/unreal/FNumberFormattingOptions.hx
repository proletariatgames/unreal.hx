package unreal;

@:glueCppIncludes("Internationalization/Text.h")
@:uname("FNumberFormattingOptions")
@:uextern extern class FNumberFormattingOptions {
  @:uname("new") static function create(color:Const<PRef<FNumberFormattingOptions>>):PHaxeCreated<FNumberFormattingOptions>;
  static function DefaultWithGrouping() : Const<PRef<FNumberFormattingOptions>>;
  static function DefaultNoGrouping() : Const<PRef<FNumberFormattingOptions>>;
}


