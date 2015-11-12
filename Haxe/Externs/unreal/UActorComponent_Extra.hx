package unreal;

extern class UActorComponent_Extra {
  /**
   * Function called every frame on this ActorComponent. Override this function to implement custom logic to be executed every frame.
   * Only executes if the component is registered, and also PrimaryComponentTick.bCanEverTick must be set to true.
   *
   * @param DeltaTime - The time since the last tick.
   * @param TickType - The kind of tick this is, for example, are we paused, or 'simulating' in the editor
   * @param ThisTickFunction - Internal tick function struct that caused this to run
   */
  public function TickComponent(deltaTime:Float32, tickType:ELevelTick, thisTickFunction:PExternal<FActorComponentTickFunction>) : Void;
}
