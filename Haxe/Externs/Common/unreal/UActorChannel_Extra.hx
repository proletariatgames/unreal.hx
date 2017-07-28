package unreal;

extern class UActorChannel_Extra {
  function ReplicateSubobject(Obj:UObject, Bunch:PRef<FOutBunch>, RepFlags:Const<PRef<FReplicationFlags>>):Bool;
  @:noTemplate
  @:uname("ReplicateSubobjectList<UObject>")
  function ReplicateSubobjectList<T : UObject>(ObjList:TArray<T>, Bunch:PRef<FOutBunch>, RepFlags:Const<PRef<FReplicationFlags>>):Bool;
}
