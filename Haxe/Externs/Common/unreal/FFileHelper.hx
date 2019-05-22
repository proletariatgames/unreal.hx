package unreal;

@:glueCppIncludes("Misc/FileHelper.h")
@:noEquals @:noCopy @:uextern extern class FFileHelper
{
	/**
	 * Load a binary file to a dynamic array.
	 *
	 * @param Result    Receives the contents of the file
	 * @param Filename  The file to read
	 * @param Flags     Flags to pass to IFileManager::CreateFileReader
	*/
	@:ublocking static function LoadFileToArray( Result:PRef<TArray<UInt8>> , Filename:TCharStar, Flags:UInt32 = 0 ):Bool;

	/**
	 * Load a text file to an FString. Supports all combination of ANSI/Unicode files and platforms.
	 *
	 * @param Result       String representation of the loaded file
	 * @param Filename     Name of the file to load
	 * @param VerifyFlags  Flags controlling the hash verification behavior ( see EHashOptions )
	 */
	@:ublocking static function LoadFileToString( Result:PRef<FString>, Filename:TCharStar ):Bool;

	/**
	 * Load a text file to an array of strings. Supports all combination of ANSI/Unicode files and platforms.
	 *
	 * @param Result       String representation of the loaded file
	 * @param Filename     Name of the file to load
	 * @param VerifyFlags  Flags controlling the hash verification behavior ( see EHashOptions )
	 */
	@:ublocking static function LoadFileToStringArray( Result:PRef<TArray<FString>>, Filename:TCharStar ):Bool;

	/**
	 * Write the FString to a file.
	 * Supports all combination of ANSI/Unicode files and platforms.
	 */
	static function SaveStringToFile(String:Const<PRef<FString>>, Filename:TCharStar) : Bool;

	/**
	 * Write the FString to a file.
	 * Supports all combination of ANSI/Unicode files and platforms.
	 */
	static function SaveStringArrayToFile(Lines:Const<PRef<TArray<FString>>>, Filename:TCharStar) : Bool;
	
}
