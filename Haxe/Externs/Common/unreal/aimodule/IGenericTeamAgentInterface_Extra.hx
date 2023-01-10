package unreal.aimodule;

extern class IGenericTeamAgentInterface_Extra {

	/** Assigns Team Agent to given TeamID */
	//public function SetGenericTeamId(TeamID:Const<PRef<FGenericTeamId>>) : Void;

	/** Retrieve team identifier in form of FGenericTeamId */
	@:thisConst
	public function GetGenericTeamId() : FGenericTeamId;

	/** Retrieved owner attitude toward given Other object */
	//@:thisConst
	//public function GetTeamAttitudeTowards(Other:Const<PRef<AActor>>) : ETeamAttitude;

}
