package unreal;

import unreal.APlayerController;

/**
 * Abstract base class of all Engine classes, responsible for management of systems critical to editor or game systems.
 * Also defines default classes for certain engine systems.
 */
@:glueCppIncludes("Engine.h")
@:uclass(config=Engine, defaultconfig, transient)
@:uextern extern class UEngine extends UObject {
  /** Current display gamma setting */
  @:uproperty(config)
  public var DisplayGamma : Float32;

	/** Gets all local players associated with the engine. 
	 *	This function should only be used in rare cases where no UWorld* is available to get a player list associated with the world.
	 *  E.g, - use GetFirstLocalPlayerController(UWorld *InWorld) when possible!
	 */
	public function GetAllLocalPlayerControllers(PlayerList:PRef<TArray<APlayerController>>) : Void;

  // global UEngine *
  @:global static var GEngine : UEngine;
}

