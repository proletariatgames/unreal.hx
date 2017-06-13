package unreal;

@:glueCppIncludes("GenericApplication.h")
@:uextern extern class FDisplayMetrics {
  @:uname(".ctor")
  public static function create() : FDisplayMetrics;
  @:uname("new")
  public static function createNew() : POwnedPtr<FDisplayMetrics>;

  public var PrimaryDisplayWidth:Int32;
  public var PrimaryDisplayHeight:Int32;

  public static function GetDisplayMetrics(OutDisplayMetrics:PRef<FDisplayMetrics>) : Void;
}
