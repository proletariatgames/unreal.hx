package unreal;

@:glueCppIncludes("GenericApplication.h")
@:uextern extern class FDisplayMetrics {
  @:uname("new")
  public static function create() : PHaxeCreated<FDisplayMetrics>;

  public var PrimaryDisplayWidth:Int32;
  public var PrimaryDisplayHeight:Int32;

  public static function GetDisplayMetrics(OutDisplayMetrics:PRef<FDisplayMetrics>) : Void;
}
