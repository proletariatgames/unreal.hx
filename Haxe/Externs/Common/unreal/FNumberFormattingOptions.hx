package unreal;

@:glueCppIncludes("Internationalization/Text.h")
@:uname("FNumberFormattingOptions")
@:uextern extern class FNumberFormattingOptions {
  @:uname(".ctor") static function create():FNumberFormattingOptions;
  @:uname("new") static function createNew():POwnedPtr<FNumberFormattingOptions>;
  static function DefaultWithGrouping() : Const<PRef<FNumberFormattingOptions>>;
  static function DefaultNoGrouping() : Const<PRef<FNumberFormattingOptions>>;
  var MaximumFractionalDigits:Int32;
  var MaximumIntegralDigits:Int32;
  var MinimumFractionalDigits:Int32;
  var MinimumIntegralDigits:Int32;
  var UseGrouping:Bool;
  var RoundingMode:ERoundingMode;
}


