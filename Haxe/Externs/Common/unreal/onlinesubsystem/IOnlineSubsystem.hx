package unreal.onlinesubsystem;

import unreal.*;

@:glueCppIncludes("Online.h", "OnlineSubsystem.h") @:umodule("OnlineSubsystem")
@:uname("IOnlineSubsystem")
@:noCopy
@:uextern extern class IOnlineSubsystem {
  /**
	 * Get the online subsystem for a given service
	 * @param SubsystemName - Name of the requested online service
	 * @return pointer to the appropriate online subsystem
	 */
  public static function Get(@:opt(unreal.FName.None) ?subsystemName:Const<PRef<FName>>) : unreal.PPtr<IOnlineSubsystem>;

  /**
	 * Get the online subsystem based on current platform
	 *
	 * @param bAutoLoad - load the module if not already loaded
	 *
	 * @return pointer to the appropriate online subsystem
	 */
  public static function GetByPlatform(bAutoLoad:Bool=true) : PPtr<IOnlineSubsystem>;

  /**
	 * Destroy a single online subsystem instance
	 * @param SubsystemName - Name of the online service to destroy
	 */
	static function Destroy(SubsystemName:FName):Void;

	/**
	 * Determine if an instance of the subsystem already exists
	 * @param SubsystemName - Name of the requested online service
	 * @return true if instance exists, false otherwise
	 */
	static function DoesInstanceExist(@:opt(unreal.FName.None) ?SubsystemName:Const<PRef<FName>>) : Bool;

	/**
	 * Determine if the subsystem for a given interface is already loaded
	 * @param SubsystemName - Name of the requested online service
	 * @return true if module for the subsystem is loaded
	 */
	static function IsLoaded(@:opt(unreal.FName.None) ?SubsystemName:Const<PRef<FName>>) : Bool;

	/**
	 * Return the name of the subsystem @see OnlineSubsystemNames.h
	 *
	 * @return the name of the subsystem, as used in calls to IOnlineSubsystem::Get()
	 */
	function GetSubsystemName():FName;

	/**
	 * Get the instance name, which is typically "default" or "none" but distinguishes
	 * one instance from another in "Play In Editor" mode.  Most platforms can't do this
	 * because of third party requirements that only allow one login per machine instance
	 *
	 * @return the instance name of this subsystem
	 */
	function GetInstanceName():FName;

	/** @return true if the subsystem is enabled, false otherwise */
	function IsEnabled():Bool;

	/**
	 * Get custom UObject data preserved by the online subsystem
	 *
	 * @param InterfaceName key to the custom data
	 */
	function GetNamedInterface(InterfaceName:FName):UObject;

	/**
	 * Set a custom UObject to be preserved by the online subsystem
	 *
	 * @param InterfaceName key to the custom data
	 * @param NewInterface object to preserve
	 */
	function SetNamedInterface(InterfaceName:FName, NewInterface:UObject):Void;

	/**
	 * Is the online subsystem associated with the game/editor/engine running as dedicated.
	 * May be forced into this mode by EditorPIE, but basically asks if the OSS is serving
	 * in a dedicated capacity
	 *
	 * @return true if the online subsystem is in dedicated server mode, false otherwise
	 */
	function IsDedicated():Bool;

	/**
	 * Is this instance of the game running as a server (dedicated OR listen)
	 * checks the Engine if possible for netmode status
	 *
	 * @return true if this is the server, false otherwise
	 */
	function IsServer():Bool;

	/**
	 * Force the online subsystem to behave as if it's associated with running a dedicated server
	 *
	 * @param bForce force dedicated mode if true
	 */
	function SetForceDedicated(bForce:Bool):Void;

	/**
	 * Is a player local to this machine by unique id
	 *
	 * @param UniqueId UniqueId of the player
	 *
	 * @return true if unique id is local to this machine, false otherwise
	 */
	function IsLocalPlayer(UniqueId:Const<PRef<FUniqueNetId>>):Bool;

	/**
	 * Initialize the underlying subsystem APIs
	 * @return true if the subsystem was successfully initialized, false otherwise
	 */
	function Init():Bool;

	/**
	 * Perform any shutdown actions prior to any other modules being unloaded/shutdown
	 */
	function PreUnload():Void;

	/**
	 * Shutdown the underlying subsystem APIs
	 * @return true if the subsystem shutdown successfully, false otherwise
	 */
	function Shutdown():Bool;

	/**
	 * Each online subsystem has a global id for the app
	 *
	 * @return the app id for this app
	 */
	function GetAppId():FString;

  public function GetAchievementsInterface() : unreal.TThreadSafeSharedPtr<IOnlineAchievements>;
  public function GetLeaderboardsInterface() : unreal.TThreadSafeSharedPtr<IOnlineLeaderboards>;
  public function GetIdentityInterface() : unreal.TThreadSafeSharedPtr<IOnlineIdentity>;
  public function GetExternalUIInterface() : unreal.TThreadSafeSharedPtr<IOnlineExternalUI>;

  @:thisConst
  public function GetSessionInterface() : TThreadSafeSharedPtr<IOnlineSession>;
}
