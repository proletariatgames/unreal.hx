package unreal.onlinesubsystem;


@:umodule("OnlineSubsystem")
@:glueCppIncludes("OnlineSubsystemTypes.h")
@:uname("EOnlineDataAdvertisementType.Type")
@:uextern extern enum EOnlineDataAdvertisementType {
  /** Don't advertise via the online service or QoS data */
  DontAdvertise;
  /** Advertise via the server ping data only */
  ViaPingOnly;
  /** Advertise via the online service only */
  ViaOnlineService;
  /** Advertise via the online service and via the ping data */
  ViaOnlineServiceAndPing;
}
