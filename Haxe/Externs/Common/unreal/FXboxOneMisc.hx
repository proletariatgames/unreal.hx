package unreal;

/**
 * XboxOne implementation of the misc OS functions.
*/
#if PLATFORM_XBOXONE
@:glueCppIncludes("XboxOne/XboxOneMisc.h")
@:noEquals @:noCopy @:uextern extern class FXboxOneMisc {
	/**
	 * Returns an enum for the type of the Xbox console this app is running on
	*/
	static function GetConsoleType():EXboxOneConsoleType;

	/**
	 * Returns true if the game wants 4k, the connected TV is 4k, and the device is a Scorpio
	*/
	static function ShouldUse4KBackBuffer():Bool;
}
#end
