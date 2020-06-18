package unreal.onlinesubsystem;

import unreal.*;
import unreal.onlinesubsystem.*;

@:glueCppIncludes("OnlineKeyValuePair.h") @:umodule("OnlineSubsystem")
@:uname("FOnlineKeyValuePairs")
@:keep
@:uextern extern class FOnlineKeyValuePairs<K, V>
{
  public function Add(InKey:K, InValue:V):V;
}
