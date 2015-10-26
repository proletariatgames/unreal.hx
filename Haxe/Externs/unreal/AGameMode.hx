package unreal;

@:glueCppIncludes("Engine.h")
@:uextern extern class AGameMode extends AInfo {
  @:global("MatchState")
  public static var EnterinMap:PStruct<FName>;
  public static var WaitingToStart:PStruct<FName>;
  public static var InProgress:PStruct<FName>;
  public static var WaitingPostMatch:PStruct<FName>;
  public static var LeavingMap:PStruct<FName>;
  public static var Aborted:PStruct<FName>;
}