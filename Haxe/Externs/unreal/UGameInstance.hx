package unreal;

@:glueCppIncludes("Engine/GameInstance.h")
@:uextern extern class UGameInstance extends UObject {

	/** virtual function to allow custom GameInstances an opportunity to set up what it needs */
	@:uexpose
	public function Init() : Void;

	@:uproperty()
	private var LocalPlayers : TArray<ULocalPlayer>; // List of locally participating players in this game instance	
}
