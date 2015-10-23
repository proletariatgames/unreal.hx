package unreal;

/** Secondary condition to check before considering the replication of a lifetime property. **/
@:glueCppIncludes("UObject/UObject.h")
@:uextern extern enum ELifetimeCondition {
  COND_None;
  COND_InitialOnly;
  COND_OwnerOnly;
  COND_SkipOwner;
  COND_SimulatedOnly;
  COND_AutonomousOnly;
  COND_SimulatedOrPhysics;
  COND_InitialOrOwner;
  COND_Custom;
  COND_Max;
}

@:glueCppIncludes("UObject/UObject.h")
@:uextern extern enum ELifetimeRepNotifyCondition {
  REPNOTIFY_OnChanged;
  REPNOTIFY_Always;
}

/** FLifetimeProperty
 *	This class is used to track a property that is marked to be replicated for the lifetime of the actor channel.
 *  This doesn't mean the property will necessarily always be replicated; it just means:
 *	"check this property for replication for the life of the actor; and I don't want to think about it anymore"
 *  A secondary condition can also be used to skip replication based on the condition results
 **/
@:glueCppIncludes("UObject/UObject.h")
@:uname("FLifetimeProperty")
@:uextern extern class FLifetimeProperty {
  public var RepIndex:UInt16;
  public var Condition:ELifetimeCondition;
  public var RepNotifyCondition:ELifetimeRepNotifyCondition;
}
