package unreal;

@:glueCppIncludes("Ticker.h")
@:uextern @:noCopy @:noEquals extern class FTickableGameObject extends FTickableObjectBase
{

  /**
   * Used to determine if an object should be ticked when the game is paused.
   * Defaults to false, as that mimics old behavior.
   *
   * @return true if it should be ticked when paused, false otherwise
   */
  @:thisConst
  public function IsTickableWhenPaused() : Bool;

  /**
   * Used to determine whether the object should be ticked in the editor.  Defaults to false since
   * that is the previous behavior.
   *
   * @return  true if this tickable object can be ticked in the editor
   */
  @:thisConst
  public function IsTickableInEditor() : Bool;
}
