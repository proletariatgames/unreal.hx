package unreal;

@:glueCppIncludes("Ticker.h")
@:uextern @:noCopy @:noEquals extern class FTickableObjectBase
{
  /**
   * Pure virtual that must be overloaded by the inheriting class. It will
   * be called from within LevelTick.cpp after ticking all actors or from
   * the rendering thread (depending on bIsRenderingThreadObject)
   *
   * @param DeltaTime Game time passed since the last call.
   */
  public function Tick( DeltaTime:Float32 ) : Void;

  /**
   * Pure virtual that must be overloaded by the inheriting class. It is
   * used to determine whether an object is ready to be ticked. This is
   * required for example for all UObject derived classes as they might be
   * loaded async and therefore won't be ready immediately.
   *
   * @return  true if class is ready to be ticked, false otherwise.
   */
  public function IsTickable() : Bool;

  /** return the stat id to use for this tickable **/
  public function GetStatId() : TStatId;

}
