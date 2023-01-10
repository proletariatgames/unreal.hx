package unreal.aimodule;

extern class AAIController_Extra {

  public function GetPerceptionComponent() : UAIPerceptionComponent;
  public function GetBlackboardComponent() : UBlackboardComponent;
  public function GetBrainComponent() : UBrainComponent;

  @:thisConst
	public function GetGenericTeamId() : FGenericTeamId;
}
