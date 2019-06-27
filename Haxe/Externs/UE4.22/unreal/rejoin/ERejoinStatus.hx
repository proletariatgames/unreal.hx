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
package unreal.rejoin;

/**
  Possible states that a rejoin check can be in at any given time
**/
@:umodule("Rejoin")
@:glueCppIncludes("Public/RejoinCheck.h")
@:uname("ERejoinStatus")
@:class @:uextern @:uenum extern enum ERejoinStatus {
  
  /**
    There is no match to rejoin.  The user is already in a match or there is no match in progress for the user.
  **/
  NoMatchToRejoin;
  
  /**
    There is a rejoin available for the user
  **/
  RejoinAvailable;
  
  /**
    We are currently updating the status of rejoin
  **/
  UpdatingStatus;
  
  /**
    We need to recheck the state before allowing any further progress through the UI (e.g right after login or right after leaving a match without it ending normally).
  **/
  NeedsRecheck;
  
  /**
    Match ended normally, no check required (only set when returning from a match)
  **/
  NoMatchToRejoin_MatchEnded;
  
}