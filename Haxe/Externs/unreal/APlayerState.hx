package unreal;

@:glueCppIncludes("Engine.h")
@:uextern extern class APlayerState extends AInfo {

	public function CopyProperties(playerState:APlayerState) : Void;
}
