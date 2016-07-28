package unreal.onlinesubsystem;

import unreal.*;

@:glueCppIncludes("OnlineStats.h") @:umodule("OnlineSubsystem")
@:uname("FOnlineStats")
@:noCopy
@:uextern extern class FOnlineStats {
  public function SetFloatStat(statName : FName, value : Float ) : Void;
  public function SetIntStat(statName : FName, value : Int32 ) : Void;
  public function IncrementFloatStat(statName : FName) : Void;
  public function IncrementIntStat(statName : FName) : Void;
  public function DecrementFloatStat(statName : FName) : Void;
  public function DecrementIntStat(statName : FName) : Void;
}
