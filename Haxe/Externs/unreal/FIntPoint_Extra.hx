package unreal;

@:hasEquals
extern class FIntPoint_Extra {
  @:uname(".ctor")
  public static function createWithValues(x:Int32, y:Int32) : FIntPoint;
  @:uname("new")
  public static function createNewWithValues(x:Int32, y:Int32) : POwnedPtr<FIntPoint>;

  @:uname('.ctor') public static function createForceInit(e:EForceInit):FIntPoint;
  @:uname('new') public static function createNewForceInit(e:EForceInit):POwnedPtr<FIntPoint>;

  public var X : Int32;
  public var Y : Int32;
}
