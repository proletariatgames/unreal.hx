package unreal;

extern class FDamageEvent_Extra {
  @:uname('.ctor') public static function createWithDamageType(dmgType:TSubclassOf<UDamageType>) : FDamageEvent;
  @:uname('new') public static function createNewWithDamageType(dmgType:TSubclassOf<UDamageType>) : POwnedPtr<FDamageEvent>;

	@thisConst
	public function GetTypeID() : Int32;

	@thisConst
	public function IsOfType(InID : Int32) : Bool;

	public static var ClassID(get,never) : Int32;
}
