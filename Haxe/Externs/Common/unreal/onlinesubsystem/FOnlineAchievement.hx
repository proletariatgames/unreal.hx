package unreal.onlinesubsystem;

import unreal.*;

@:glueCppIncludes("OnlineAchievementsInterface.h") @:umodule("OnlineSubsystem")
@:uextern extern class FOnlineAchievement
{
	/** The id of the achievement */
	public var Id : FString;
	/** The progress towards completing this achievement: 0.0-100.0 */
	public var Progress : Float32;

	// /**
	//  * Constructor
	//  */
	public function new();
	@:uname('.ctor') public static function create() : FOnlineAchievement;
}

