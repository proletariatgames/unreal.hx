package unreal;

@:glueCppIncludes("Kismet/GameplayStatics.h")
@:uextern extern class UGameplayStatics extends UBlueprintFunctionLibrary
{
  public static function GetPlayerPawn(WorldContextObject:UObject, PlayerIndex:Int) : APawn;
}
