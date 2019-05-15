package unreal;

@:glueCppIncludes("GenericPlatform/GenericPlatformFile.h")
@:noCopy @:noEquals
@:uextern extern class IPlatformFile {
  /** Return true if the file exists. **/
  @:ublocking function FileExists(file:TCharStar):Bool;
  function GetName():TCharStar;
  static function GetPlatformPhysical():PRef<IPlatformFile>;
  /** Return the size of the file, or -1 if it doesn't exist. **/
  @:ublocking function FileSize(FileName:Const<TCharStar>):Int64;
  /** Delete a file and return true if the file exists. Will not delete read only files. **/
  @:ublocking function DeleteFile(FileName:Const<TCharStar>):Bool;
  /** Return true if the file is read only. **/
  @:ublocking function IsReadOnly(FileName:Const<TCharStar>):Bool;
  /** Attempt to move a file. Return true if successful. Will not overwrite existing files. **/
  @:ublocking function MoveFile(To:Const<TCharStar>, From:Const<TCharStar>):Bool;
  /** Attempt to change the read only status of a file. Return true if successful. **/
  @:ublocking function SetReadOnly(FileName:Const<TCharStar>, bNewReadOnlyValue:Bool):Bool;
  /** For case insensitive filesystems, returns the full path of the file with the same case as in the filesystem */
  @:ublocking function GetFilenameOnDisk(FileName:Const<TCharStar>):FString;


  /** Attempt to open a file for reading.
   *
   * @param Filename file to be opened
   * @param bAllowWrite (applies to certain platforms only) whether this file is allowed to be written to by other processes. This flag is needed to open files that are currently being written to as well.
   *
   * @return If successful will return a non-nullptr pointer. Close the file by delete'ing the handle.
   */
  // You must call .dispose() on these file handles to close the files
  @:ublocking function OpenRead(Filename:Const<TCharStar>, bAllowWrite:Bool = false):POwnedPtr<IFileHandle>;

  // You must call .dispose() on these file handles to close the files
  @:ublocking function OpenReadNoBuffering(Filename:Const<TCharStar>, bAllowWrite:Bool = false):POwnedPtr<IFileHandle>;

  // You must call .dispose() on these file handles to close the files
  /** Attempt to open a file for writing. If successful will return a non-nullptr pointer. Close the file by delete'ing the handle. **/
  @:ublocking function OpenWrite(Filename:Const<TCharStar>, bAppend:Bool = false, bAllowRead:Bool = false):POwnedPtr<IFileHandle>;

  /** Return true if the directory exists. **/
  @:ublocking function DirectoryExists(Directory:TCharStar):Bool;
  /** Create a directory and return true if the directory was created or already existed. **/
  @:ublocking function CreateDirectory(Directory:TCharStar):Bool;
  /** Delete a directory and return true if the directory was deleted or otherwise does not exist. **/
  @:ublocking function DeleteDirectory(Directory:TCharStar):Bool;

  /** Return the stat data for the given file or directory. Check the FFileStatData::bIsValid member before using the returned data */
  @:ublocking function GetStatData(FilenameOrDirectory:Const<TCharStar>):FFileStatData;

  /**
   * Finds all the files within the given directory, with optional file extension filter
   * @param Directory			The directory to iterate the contents of
   * @param FileExtension		If FileExtension is NULL, or an empty string "" then all files are found.
   * 							Otherwise FileExtension can be of the form .EXT or just EXT and only files with that extension will be returned.
   * @return FoundFiles		All the files that matched the optional FileExtension filter, or all files if none was specified.
   */
  @:ublocking function FindFiles( FoundFiles:PRef<TArray<FString>>, Directory:Const<TCharStar>, FileExtension:Const<TCharStar>):Void;
}
