package unreal;

@:glueCppIncludes("Engine/GameInstance.h")
@:uextern extern class UGameInstance extends UObject {

	@:uproperty()
	private var LocalPlayers : TArray<ULocalPlayer>; // List of locally participating players in this game instance	
}
