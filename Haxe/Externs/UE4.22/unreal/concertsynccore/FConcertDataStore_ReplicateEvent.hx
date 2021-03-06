/**
 * 
 * WARNING! This file was autogenerated by: 
 *  _   _ _   _ __   __ 
 * | | | | | | |\ \ / / 
 * | | | | |_| | \ V /  
 * | | | |  _  | /   \  
 * | |_| | | | |/ /^\ \ 
 *  \___/\_| |_/\/   \/ 
 * 
 * This file was autogenerated by UnrealHxGenerator using UHT definitions.
 * It only includes UPROPERTYs and UFUNCTIONs. Do not modify it!
 * In order to add more definitions, create or edit a type with the same name/package, but with an `_Extra` suffix
**/
package unreal.concertsynccore;

/**
  The event message sent by the server to the client to perform the initial replication, sending
  all currently stored key/value pairs to a new session client(s) or to notify any further changes,
  pushing an updated key/value pair to all clients except the one who performed the change.
**/
@:umodule("ConcertSyncCore")
@:glueCppIncludes("Public/ConcertDataStoreMessages.h")
@:noCopy @:noEquals @:uextern @:ustruct extern class FConcertDataStore_ReplicateEvent {
  
  /**
    The initial values or the values that recently changed.
  **/
  @:uproperty public var Values : unreal.TArray<unreal.concertsynccore.FConcertDataStore_KeyValuePair>;
  
}
