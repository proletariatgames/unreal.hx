package unreal;

extern class UActorChannel_Extra {
  function ReplicateSubobject(Obj:UObject, Bunch:PRef<FOutBunch>, RepFlags:Const<PRef<FReplicationFlags>>):Bool;
}
