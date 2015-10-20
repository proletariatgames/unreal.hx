package unreal;

@:glueCppIncludes("Engine.h")
@:uextern extern class ULocalPlayer extends UPlayer {

  @:thisConst
  public function GetNickname() : FString;
}
