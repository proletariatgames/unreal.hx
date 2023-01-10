package unreal.aimodule;

extern class FGenericTeamId_Extra {

	@:expr(255) static var NoTeamId:UInt8;

	public static var NoTeam(get,never):FGenericTeamId;

  public function new(@:opt(NoTeamId) InTeamID:UInt8);

	@:uname('.ctor') public static function createWithValue(InTeamID:UInt8):FGenericTeamId;
  @:uname('new') public static function createNewWithValue(InTeamID:UInt8):POwnedPtr<FGenericTeamId>;

	@:thisConst
	public function GetId() : UInt8;

	public static function GetTeamIdentifier(TeamMember:Const<AActor>) : FGenericTeamId;
	public static function GetAttitude(TeamA:FGenericTeamId, TeamB:FGenericTeamId) : ETeamAttitude;
}
