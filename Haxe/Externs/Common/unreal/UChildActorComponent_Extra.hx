package unreal;

extern class UChildActorComponent_Extra
{
	/** Create the child actor */
	public function CreateChildActor() : Void;

	@:thisConst
	public function GetChildActor() : AActor;
	@:thisConst
	public function GetChildActorTemplate() : AActor;

	@:thisConst
	public function GetChildActorName() : FName;

	/** Kill any currently present child actor */
	public function DestroyChildActor() : Void;
}