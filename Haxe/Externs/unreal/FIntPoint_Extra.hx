package unreal;

@:hasEquals
extern class FIntPoint_Extra {
  @:uname("new")
  public static function createWithValues(x:Int32, y:Int32) : POwnedPtr<FIntPoint>;

  @:uname('new') public static function createForceInit(e:EForceInit):POwnedPtr<FIntPoint>;

  public var X : Int32;
  public var Y : Int32;
}
