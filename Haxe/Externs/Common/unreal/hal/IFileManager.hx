package unreal.hal;

@:glueCppIncludes("HAL/FileManager.h")
@:noCopy @:noEquals
@:uextern extern class IFileManager
{
	/** Singleton access, platform specific, also calls PreInit() **/
	static function Get() : PRef<IFileManager>;

	/** Allow the file manager to handle the commandline */
	function ProcessCommandLineOptions() : Void;

	/** Enables/disables the sandbox, if it is being used */
	function SetSandboxEnabled(bInEnabled:Bool) : Void;
	/** Returns whether the sandbox is enabled or not */
	@:thisConst function IsSandboxEnabled() : Bool;

	/** Creates file reader archive. */
	function CreateFileReader(Filename:Const<TCharStar>, ReadFlags:UInt32 = 0) : PPtr<FArchive>;

	/** Creates file writer archive. */
	function CreateFileWriter(Filename:Const<TCharStar>, WriteFlags:UInt32 = 0) : PPtr<FArchive>;

	// If you're writing to a debug file, you should use CreateDebugFileWriter, and wrap the calling code in #if ALLOW_DEBUG_FILES.
#if ALLOW_DEBUG_FILES
	function CreateDebugFileWriter(Filename:Const<TCharStar>, WriteFlags:UInt32 = 0) : PPtr<FArchive>;
#end

	/** Checks if a file is read-only. */
	function IsReadOnly(Filename:Const<TCharStar>) : Bool;

	/** Deletes a file. */
	function Delete(Filename:Const<TCharStar>, RequireExists:Bool = false, EvenReadOnly:Bool = false, Quiet:Bool = false) : Bool;

	/** Copies a file. */
	// function Copy(Dest:Const<TCharStar>, Src:Const<TCharStar>, Replace:Bool = true, EvenIfReadOnly:Bool = false, Attributes:Bool = false, Progress:PPtr<FCopyProgress> = null, ReadFlags:EFileRead = FILEREAD_None, WriteFlags:EFileWrite = FILEWRITE_None) : UInt32;

	/** Moves/renames a file. */
	function Move(Dest:Const<TCharStar>, Src:Const<TCharStar>, Replace:Bool = true, EvenIfReadOnly:Bool = false, Attributes:Bool = false, bDoNotRetryOrError:Bool = false) : Bool;

	/** Checks if a file exists */
	function FileExists(Filename:Const<TCharStar>) : Bool;

	/** Checks if a directory exists. */
	function DirectoryExists(InDirectory:Const<TCharStar>) : Bool;

	/** Creates a directory. */
	function MakeDirectory(Path:Const<TCharStar>, Tree:Bool = false) : Bool;

	/** Deletes a directory. */
	function DeleteDirectory(Path:Const<TCharStar>, RequireExists:Bool = false, Tree:Bool = false) : Bool;

	/** Return the stat data for the given file or directory. Check the FFileStatData::bIsValid member before using the returned data */
	// function GetStatData(FilenameOrDirectory:Const<TCharStar>) : FFileStatData;

	/** Finds file or directories. */
	function FindFiles(FileNames:PRef<TArray<FString>>, Filename:Const<TCharStar>, Files:Bool, Directories:Bool) : Void;

	/**
	 * Finds all the files within the given directory, with optional file extension filter.
	 *
	 * @param Directory, the absolute path to the directory to search. Ex: "C:\UE4\Pictures"
	 *
	 * @param FileExtension, If FileExtension is NULL, or an empty string "" then all files are found.
	 * 			Otherwise FileExtension can be of the form .EXT or just EXT and only files with that extension will be returned.
	 *
	 * @return FoundFiles, All the files that matched the optional FileExtension filter, or all files if none was specified.
	 */
	// function FindFiles(FoundFiles:PRef<TArray<FString>>, Directory:Const<TCharStar>, FileExtension:Const<TCharStar> = nullptr) : Void;

	/** Finds file or directories recursively. */
	function FindFilesRecursive(FileNames:PRef<TArray<FString>>, StartDirectory:Const<TCharStar>, Filename:Const<TCharStar>, Files:Bool, Directories:Bool, bClearFileNames:Bool = true) : Void;

	/**
	 * Call the Visit function of the visitor once for each file or directory in a single directory. This function does not explore subdirectories.
	 * @param Directory		The directory to iterate the contents of.
	 * @param Visitor		Visitor to call for each element of the directory
	 * @return				false if the directory did not exist or if the visitor returned false.
	**/
	// function IterateDirectory(Directory:Const<TCharStar>, Visitor:PRef<FDirectoryVisitor>) : Bool;

	/**
	 * Call the Visit function of the visitor once for each file or directory in a directory tree. This function explores subdirectories.
	 * @param Directory		The directory to iterate the contents of, recursively.
	 * @param Visitor		Visitor to call for each element of the directory and each element of all subdirectories.
	 * @return				false if the directory did not exist or if the visitor returned false.
	**/
	// function IterateDirectoryRecursively(Directory:Const<TCharStar>, Visitor:PRef<FDirectoryVisitor>) : Bool;

	/**
	 * Call the Visit function of the visitor once for each file or directory in a single directory. This function does not explore subdirectories.
	 * @param Directory		The directory to iterate the contents of.
	 * @param Visitor		Visitor to call for each element of the directory
	 * @return				false if the directory did not exist or if the visitor returned false.
	**/
	// function IterateDirectoryStat(Directory:Const<TCharStar>, Visitor:PRef<FDirectoryStatVisitor>) : Bool;

	/**
	 * Call the Visit function of the visitor once for each file or directory in a directory tree. This function explores subdirectories.
	 * @param Directory		The directory to iterate the contents of, recursively.
	 * @param Visitor		Visitor to call for each element of the directory and each element of all subdirectories.
	 * @return				false if the directory did not exist or if the visitor returned false.
	**/
	// function IterateDirectoryStatRecursively(Directory:Const<TCharStar>, Visitor:PRef<FDirectoryStatVisitor> ) : Bool;

	/** Gets the age of a file measured in seconds. */
	function GetFileAgeSeconds(Filename:Const<TCharStar>) : Float64;

	/**
	 * @return the modification time of the given file (or FDateTime::MinValue() on failure)
	 */
	// function GetTimeStamp(Path:Const<TCharStar>) : FDateTime;

	/**
	* @return the modification time of the given file (or FDateTime::MinValue() on failure)
	*/
	// function GetTimeStampPair(PathA:Const<TCharStar>, PathB:Const<TCharStar>, OutTimeStampA:PRef<FDateTime>, OutTimeStampB:PRef<FDateTime>) : Void;

	/**
	 * Sets the modification time of the given file
	 */
	// function SetTimeStamp(Path:Const<TCharStar>, TimeStamp:FDateTime) : Bool;

	/**
	 * @return the last access time of the given file (or FDateTime::MinValue() on failure)
	 */
	// function GetAccessTimeStamp(Filename:Const<TCharStar>) : FDateTime;

	/**
	 * Converts passed in filename to use a relative path.
	 *
	 * @param	Filename	filename to convert to use a relative path
	 *
	 * @return	filename using relative path
	 */
	function ConvertToRelativePath(Filename:Const<TCharStar>) : FString;

	/**
	 * Converts passed in filename to use an absolute path (for reading)
	 *
	 * @param	Filename	filename to convert to use an absolute path, safe to pass in already using absolute path
	 *
	 * @return	filename using absolute path
	 */
	function ConvertToAbsolutePathForExternalAppForRead(AbsolutePath:Const<TCharStar>) : FString;

	/**
	 * Converts passed in filename to use an absolute path (for writing)
	 *
	 * @param	Filename	filename to convert to use an absolute path, safe to pass in already using absolute path
	 *
	 * @return	filename using absolute path
	 */
	function ConvertToAbsolutePathForExternalAppForWrite(AbsolutePath:Const<TCharStar>) : FString;

	/**
	 *	Returns the size of a file. (Thread-safe)
	 *
	 *	@param Filename		Platform-independent Unreal filename.
	 *	@return				File size in bytes or INDEX_NONE if the file didn't exist.
	 **/
	function FileSize(Filename:Const<TCharStar>) : Int64;

	/**
	 * Sends a message to the file server, and will block until it's complete. Will return
	 * immediately if the file manager doesn't support talking to a server.
	 *
	 * @param Message	The string message to send to the server
	 *
	 * @return			true if the message was sent to server and it returned success, or false if there is no server, or the command failed
	 */
	// function SendMessageToServer(Message:Const<TCharStar>, Handler:PPtr<IFileServerMessageHandler>) : Bool;

	/**
	* For case insensitive filesystems, returns the full path of the file with the same case as in the filesystem.
	*
	* @param Filename	Filename to query
	*
	* @return	Filename with the same case as in the filesystem.
	*/
	function GetFilenameOnDisk(Filename:Const<TCharStar>) : FString;
}
