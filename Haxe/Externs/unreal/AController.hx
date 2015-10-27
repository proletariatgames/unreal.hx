package unreal;

@:glueCppIncludes("Engine.h")
@:uextern extern class AController extends AActor {

  public function PawnPendingDestroy(inPawn:APawn) : Void;
  public function Possess(InPawn:APawn) : Void;

  @:thisConst
  public function GetDesiredRotation() : PStruct<FRotator> ;

  @:thisConst
  public function GetCharacter() : ACharacter;
}

