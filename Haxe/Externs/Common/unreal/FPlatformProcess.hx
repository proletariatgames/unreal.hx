package unreal;

@:glueCppIncludes('HAL/PlatformProcess.h')
@:uextern extern class FPlatformProcess {
	public static function BaseDir():Const<TCharStar>;
	public static function UserDir():Const<TCharStar>;
	public static function UserTempDir():Const<TCharStar>;
	public static function UserSettingsDir():Const<TCharStar>;
	public static function ApplicationSettingsDir():Const<TCharStar>;
	public static function ComputerName():Const<TCharStar>;
	public static function UserName(bOnlyAlphaNumeric:Bool = true):Const<TCharStar>;
	public static function SetCurrentWorkingDirectoryToBaseDir():Void;
	public static function GetCurrentWorkingDirectory():FString;
	public static function ShaderWorkingDir():Const<FString>;
	public static function ExecutableName(bRemoveExtension:Bool = true):Const<TCharStar>;
	public static function GetModuleExtension():Const<TCharStar>;
	public static function GetBinariesSubdirectory():Const<TCharStar>;
	public static function GetModulesDirectory():Const<FString>;
	public static function CanLaunchURL(URL:Const<TCharStar>):Bool;
	public static function LaunchURL(URL:Const<TCharStar>, Parms:Const<TCharStar>, Error:PPtr<FString>):Void;
	@:ublocking public static function Sleep(Seconds:Float32):Void;
	public static function GetCurrentProcessId():Int;
	public static function ExecProcess( URL:TCharStar, Params:TCharStar, OutReturnCode:Ptr<Int>, OutStdOut:PPtr<FString>, OutStdErr:PPtr<FString> ):Bool;
}
