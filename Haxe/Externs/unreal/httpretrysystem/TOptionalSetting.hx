package unreal.httpretrysystem;

@:glueCppIncludes('HttpRetrySystem.h')
@:uname('FHttpRetrySystem.TOptionalSetting')
@:uextern extern class TOptionalSetting<IntrinsicType> {
  var bUseValue:Bool;
  var Value:IntrinsicType;

  @:uname('.ctor') public static function create<IntrinsicType>(value:IntrinsicType):TOptionalSetting<IntrinsicType>;
  public static function Unused<IntrinsicType>():TOptionalSetting<IntrinsicType>;
}
