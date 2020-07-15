package unreal.onlinesubsystem;

@:glueCppIncludes("OnlineIdentityInterface.h") @:umodule("OnlineSubsystem")
@:uname("EUserPrivileges.Type")
@:uextern enum abstract EPrivilegeResults(FakeUInt32) from FakeUInt32 to FakeUInt32 {
	/** The user has the requested privilege */
	var NoFailures							 =	0;
	/** Patch required before the user can use the privilege */
	var RequiredPatchAvailable	 =	1 << 0;
	/** System update required before the user can use the privilege */
	var RequiredSystemUpdate		 =	1 << 1;
	/** Parental control failure usually */
	var AgeRestrictionFailure		 =	1 << 2;
	/** XboxLive Gold / PSPlus required but not available */
	var AccountTypeFailure			 =	1 << 3;
	/** Invalid user */
	var UserNotFound						 =	1 << 4;
	/** User must be logged in */
	var UserNotLoggedIn					 =	1 << 5;
	/** User restricted from chat */
	var ChatRestriction					 =	1 << 6;
	/** User restricted from User Generated Content */
	var UGCRestriction					 =	1 << 7;
	/** Platform failed for unknown reason and handles its own dialogs */
	var GenericFailure					 =	1 << 8;
	/** Online play is restricted */
	var OnlinePlayRestricted		 =	1 << 9;
	/** Check failed because network is unavailable */
	var NetworkConnectionUnavailable	 = 1 << 10;

	@:extern inline private function t() {
		return this;
	}

	@:op(A | B) @:extern inline public function add(flag:EPrivilegeResults):EPrivilegeResults {
		return this | flag.t();
	}

	@:op(A & B) @:extern inline public function and(mask:EPrivilegeResults):EPrivilegeResults {
		return this & mask.t();
	}
}
