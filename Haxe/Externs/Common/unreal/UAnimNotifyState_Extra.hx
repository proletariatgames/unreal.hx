package unreal;

extern class UAnimNotifyState_Extra
{
  public function NotifyBegin(MeshComp:USkeletalMeshComponent, Animation:UAnimSequenceBase, TotalDuration:Float32) : Void;
	public function NotifyTick(MeshComp:USkeletalMeshComponent, Animation:UAnimSequenceBase, FrameDeltaTime:Float32) : Void;
	public function NotifyEnd(MeshComp:USkeletalMeshComponent, Animation:UAnimSequenceBase) : Void;
}
