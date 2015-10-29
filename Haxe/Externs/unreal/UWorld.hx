package unreal;

@:glueCppIncludes("Engine.h")
/**
 * The World is the top level object representing a map or a sandbox in which Actors and Components will exist and be rendered.
 *
 * A World can be a single Persistent Level with an optional list of streaming levels that are loaded and unloaded via volumes and blueprint functions
 * or it can be a collection of levels organized with a World Composition.
 *
 * In a standalone game, generally only a single World exists except during seamless area transitions when both a destination and current world exists.
 * In the editor many Worlds exist: The level being edited, each PIE instance, each editor tool which has an interactive rendered viewport, and many more.
 *
 */

@:uclass(customConstructor, config=Engine)
@:uname("UWorld")
@:uextern extern class UWorld extends UObject {
	/** Time in seconds since level began play, but is NOT paused when the game is paused, and is NOT dilated/clamped. */
	public var RealTimeSeconds : Float32;

  @:thisConst
  public function GetGameState() : AGameState;
}
