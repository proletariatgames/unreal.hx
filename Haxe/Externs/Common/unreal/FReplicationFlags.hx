package unreal;

@:glueCppIncludes("Engine/EngineTypes.h")
@:uextern extern class FReplicationFlags {
  /** True if replicating actor is owned by the player controller on the target machine. */
  var bNetOwner:Bool;
  #if proletariat
  /** True if replicating actor is owned by a player controller that the target machine's player controller is spectating */
  var bSpectatingNetOwner:Bool;
  #end
  /** True if this is the initial network update for the replicating actor. */
  var bNetInitial:Bool;
  /** True if this is actor is RemoteRole simulated. */
  var bNetSimulated:Bool;
  /** True if this is actor's ReplicatedMovement.bRepPhysics flag is true. */
  var bRepPhysics:Bool;
  /** True if this actor is replicating on a replay connection. */
  var bReplay:Bool;

  var Value:UInt32;

  function new();
}
