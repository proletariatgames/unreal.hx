package unreal;

@:glueCppIncludes("Misc/PackageName.h")
@:uextern extern class FPackageName {
  /**
   * Helper function for converting short to long script package name (InputCore -> /Script/InputCore)
   *
   * @param InShortName Short package name.
   * @return Long package name.
   */
  static function ConvertToLongScriptPackageName(InShortName:TCharStar):FString;

  /**
   * Registers all short package names found in ini files.
   */
  static function RegisterShortPackageNamesForUObjectModules():Void;

  /**
   * Finds long script package name associated with a short package name.
   *
   * @param InShortName Short script package name.
   * @return Long script package name (/Script/Package) associated with short name or NULL.
   */
  static function FindScriptPackageName(InShortName:FName):PPtr<FName>;

  // /**
  //  * Tries to convert the supplied filename to long package name. Will attempt to find the package on disk (very slow).
  //  *
  //  * @param InFilename Filename to convert.
  //  * @param OutPackageName The resulting long package name if the conversion was successful.
  //  * @param OutFailureReason Description of an error if the conversion failed.
  //  * @return Returns true if the supplied filename properly maps to one of the long package roots.
  //  */
  // static function TryConvertFilenameToLongPackageName(InFilename:Const<PRef<FString>>, OutPackageName:PRef<FString>, OutFailureReason:FString* = null):Bool;
  /**
   * Converts the supplied filename to long package name.
   *  Throws a fatal error if the conversion is not successfull.
   *
   * @param InFilename Filename to convert.
   * @return Long package name.
   */
  static function FilenameToLongPackageName(InFilename:Const<PRef<FString>>):FString;
  /**
   * Tries to convert a long package name to a file name with the supplied extension.
   *
   * @param InLongPackageName Long Package Name
   * @param InExtension Package extension.
   * @return Package filename.
   */
  static function TryConvertLongPackageNameToFilename(InLongPackageName:Const<PRef<FString>>, OutFilename:PRef<FString>, @:opt("") ?InExtension:Const<PRef<FString>>):Bool;
  /**
   * Converts a long package name to a file name with the supplied extension.
   *
   * @param InLongPackageName Long Package Name
   * @param InExtension Package extension.
   * @return Package filename.
   */
  static function LongPackageNameToFilename(InLongPackageName:Const<PRef<FString>>, @:opt("") ?InExtension:Const<PRef<FString>>):FString;
  /**
   * Returns the path to the specified package, excluding the short package name
   *
   * @param InLongPackageName Package Name.
   * @return The path to the specified package.
   */
  static function GetLongPackagePath(InLongPackageName:Const<PRef<FString>>):FString;
  /**
   * Convert a long package name into root, path, and name components
   *
   * @param InLongPackageName Package Name.
   * @param OutPackageRoot The package root path, eg "/Game/"
   * @param OutPackagePath The path from the mount point to the package, eg "Maps/TestMaps/
   * @param OutPackageName The name of the package, including its extension, eg "MyMap.umap"
   * @param bStripRootLeadingSlash String any leading / character from the returned root
   * @return True if the conversion was possible, false otherwise
   */
  static function SplitLongPackageName(InLongPackageName:Const<PRef<FString>>, OutPackageRoot:PRef<FString>, OutPackagePath:PRef<FString>, OutPackageName:PRef<FString> , bStripRootLeadingSlash:Bool = false):Bool;
  /**
   * Returns the clean asset name for the specified package
   *
   * @param InLongPackageName Long Package Name
   * @return Clean asset name.
   */
  static function GetLongPackageAssetName(InLongPackageName:Const<PRef<FString>>):FString;
  // /**
  //  * Returns true if the path starts with a valid root (i.e. /Game/, /Engine/, etc) and contains no illegal characters.
  //  *
  //  * @param InLongPackageName			The package name to test
  //  * @param bIncludeReadOnlyRoots		If true, will include roots that you should not save to. (/Temp/, /Script/)
  //  * @param OutReason					When returning false, this will provide a description of what was wrong with the name.
  //  * @return							true if a valid long package name
  //  */
  // static function IsValidLongPackageName(InLongPackageName:Const<PRef<FString>>, bIncludeReadOnlyRoots:Bool  = false, OutReason:FText* = null):Bool;
  // /**
  //  * Checks if the given string is a long package name or not.
  //  *
  //  * @param PossiblyLongName Package name.
  //  * @return true if the given name is a long package name, false otherwise.
  //  */
  // static function IsShortPackageName(PossiblyLongName:Const<PRef<FString>>):Bool;
  /**
   * Checks if the given name is a long package name or not.
   *
   * @param PossiblyLongName Package name.
   * @return true if the given name is a long package name, false otherwise.
   */
  static function IsShortPackageName(PossiblyLongName:Const<FName>):Bool;
  /**
   * Converts package name to short name.
   *
   * @param Package Package which name to convert.
   * @return Short package name.
   */
  static function GetShortName(Package:Const<UPackage>):FString;
  /**
   * Converts package name to short name.
   *
   * @param LongName Package name to convert.
   * @return Short package name.
   */
  @:uname("GetShortName") static function GetShortName_FString(LongName:Const<PRef<FString>>):FString;
  /**
   * Converts package name to short name.
   *
   * @param LongName Package name to convert.
   * @return Short package name.
   */
  @:uname("GetShortName") static function GetShortName_FName(LongName:Const<PRef<FName>>):FString;
  // /**
  //  * Converts package name to short name.
  //  *
  //  * @param LongName Package name to convert.
  //  * @return Short package name.
  //  */
  // static function GetShortName(LongName:TCharStar):FString;
  /**
   * Converts package name to short name.
   *
   * @param LongName Package name to convert.
   * @return Short package name.
   */
  @:uname("GetShortFName") static function GetShortFName_FString(LongName:Const<PRef<FString>>):FName;
  /**
   * Converts package name to short name.
   *
   * @param LongName Package name to convert.
   * @return Short package name.
   */
  static function GetShortFName(LongName:Const<PRef<FName>>):FName;
  // /**
  //  * Converts package name to short name.
  //  *
  //  * @param LongName Package name to convert.
  //  * @return Short package name.
  //  */
  // static function GetShortFName(LongName:TCharStar):FName;
  /**
   * This will insert a mount point at the head of the search chain (so it can overlap an existing mount point and win).
   *
   * @param RootPath Root Path.
   * @param ContentPath Content Path.
   */
  static function RegisterMountPoint(RootPath:Const<PRef<FString>>, ContentPath:Const<PRef<FString>>):Void;

  /**
   * This will remove a previously inserted mount point.
   *
   * @param RootPath Root Path.
   * @param ContentPath Content Path.
   */
  static function UnRegisterMountPoint(RootPath:Const<PRef<FString>>, ContentPath:Const<PRef<FString>>):Void;

  /**
   * Get the mount point for a given package path
   *
   * @param InPackagePath The package path to get the mount point for
   * @return FName corresponding to the mount point, or Empty if invalid
   */
  static function GetPackageMountPoint(InPackagePath:Const<PRef<FString>>):FName;

  // /**
  //  * Checks if the package exists on disk.
  //  *
  //  * @param LongPackageName Package name.
  //  * @param OutFilename Package filename on disk.
  //  * @return true if the specified package name points to an existing package, false otherwise.
  //  **/
  // static function DoesPackageExist(LongPackageName:Const<PRef<FString>>, Guid:Const<FGuid* = NULL, OutFilename:FString* = NULL):Bool;
  //
  // /**
  //  * Attempts to find a package given its short name on disk (very slow).
  //  *
  //  * @param PackageName Package to find.
  //  * @param OutLongPackageName Long package name corresponding to the found file (if any).
  //  * @return true if the specified package name points to an existing package, false otherwise.
  //  **/
  // static function SearchForPackageOnDisk(PackageName:const PRef<FString>, OutLongPackageName:FString* = NULL, FString* OutFilename = NULL):Bool;

  /**
   * Tries to convert object path with short package name to object path with long package name found on disk (very slow)
   *
   * @param ObjectPath Path to the object.
   * @param OutLongPackageName Converted object path.
   *
   * @returns True if succeeded. False otherwise.
   */
  static function TryConvertShortPackagePathToLongInObjectPath(ObjectPath:Const<PRef<FString>>, ConvertedObjectPath:PRef<FString>):Bool;

  /**
   * Gets normalized object path i.e. with long package format.
   *
   * @param ObjectPath Path to the object.
   *
   * @returns Normalized path (or empty path, if short object path was given and it wasn't found on the disk).
   */
  static function GetNormalizedObjectPath(ObjectPath:Const<PRef<FString>>):FString;

  /**
   * Gets the resolved path of a long package as determined by the delegates registered with FCoreDelegates::PackageNameResolvers.
   * This allows systems such as localization to redirect requests for a package to a more appropriate alternative, or to
   * nix the request altogether.
   *
   * @param InSourcePackagePath	Path to the source package.
   *
   * @returns Resolved package path, or the source package path if there is no resolution occurs.
   */
  static function GetDelegateResolvedPackagePath(InSourcePackagePath:Const<PRef<FString>>):FString;

  /**
   * Gets the localized version of a long package path for the current culture, or returns the source package if there is no suitable localized package.
   *
   * @param InSourcePackagePath	Path to the source package.
   *
   * @returns Localized package path, or the source package path if there is no suitable localized package.
   */
  static function GetLocalizedPackagePath(InSourcePackagePath:Const<PRef<FString>>):FString;

  /**
   * Gets the localized version of a long package path for the given culture, or returns the source package if there is no suitable localized package.
   *
   * @param InSourcePackagePath	Path to the source package.
   * @param InCultureName			Culture name to get the localized package for.
   *
   * @returns Localized package path, or the source package path if there is no suitable localized package.
   */
  @:uname("GetLocalizedPackagePath") static function GetLocalizedPackagePath_Culture(InSourcePackagePath:Const<PRef<FString>>, InCultureName:Const<PRef<FString>>):FString;

  /**
   * Strips all path and extension information from a relative or fully qualified file name.
   *
   * @param	InPathName	a relative or fully qualified file name
   *
   * @return	the passed in string, stripped of path and extensions
   */
  static function PackageFromPath(InPathName:TCharStar):FString;

  /**
   * Returns the file extension for packages containing assets.
   *
   * @return	file extension for asset pacakges ( dot included )
   */
  static function GetAssetPackageExtension():PRef<FString>;
  /**
   * Returns the file extension for packages containing assets.
   *
   * @return	file extension for asset pacakges ( dot included )
   */
  static function GetMapPackageExtension():PRef<FString>;

  /**
   * Returns whether the passed in extension is a valid package
   * extension. Extensions with and without trailing dots are supported.
   *
   * @param	Extension to test.
   * @return	True if Ext is either an asset or a map extension, otherwise false
   */
  static function IsPackageExtension(Ext:TCharStar):Bool;

  /**
   * Returns whether the passed in filename ends with any of the known
   * package extensions.
   *
   * @param	Filename to test.
   * @return	True if the filename ends with a package extension.
   */
  static function IsPackageFilename(Filename:Const<PRef<FString>>):Bool;

  /**
   * This will recurse over a directory structure looking for packages.
   *
   * @param	OutPackages			The output array that is filled out with a file paths
   * @param	RootDirectory		The root of the directory structure to recurse through
   * @return	Returns true if any packages have been found, otherwise false
   */
  static function FindPackagesInDirectory(OutPackages:PRef<TArray<FString>>, RootDir:Const<PRef<FString>>):Bool;

  // /**
  //  * This will recurse over a directory structure looking for packages.
  //  *
  //  * @param	RootDirectory		The root of the directory structure to recurse through
  //  * @param	Visitor				Visitor to call for each package file found (takes the package filename, and optionally the stat data for the file - returns true to continue iterating)
  //  */
  // typedef TFunctionRef<bool(TCharStar)> FPackageNameVisitor;
  // typedef TFunctionRef<bool(TCharStar, Const<FFileStatData&)>> FPackageNameStatVisitor;
  // static Void IteratePackagesInDirectory(Const<PRef<FString>> RootDir, Const<FPackageNameVisitor& Visitor);
  // static Void IteratePackagesInDirectory(const PRef<FString> RootDir, const FPackageNameStatVisitor& Visitor);
  //
  // /** Event that is triggered when a new content path is mounted */
  // DECLARE_MULTICAST_DELEGATE_TwoParams( FOnContentPathMountedEvent, const PRef<FString> /* Asset path */, const PRef<FString> /* ContentPath */ );
  // static FOnContentPathMountedEvent& OnContentPathMounted()
  // {
  //   return OnContentPathMountedEvent;
  // }
  //
  // /** Event that is triggered when a new content path is removed */
  // DECLARE_MULTICAST_DELEGATE_TwoParams(FOnContentPathDismountedEvent, const PRef<FString> /* Asset path */, const PRef<FString> /* ContentPath */ );
  // static FOnContentPathDismountedEvent& OnContentPathDismounted()
  // {
  //   return OnContentPathDismountedEvent;
  // }

  /**
   * Queries all of the root content paths, like "/Game/", "/Engine/", and any dynamically added paths
   *
   * @param	OutRootContentPaths	[Out] List of content paths
   */
  static function QueryRootContentPaths(OutRootContentPaths : PRef<TArray<FString>>):Void;

  /** If the FLongPackagePathsSingleton is not created yet, this function will create it and thus allow mount points to be added */
  static function EnsureContentPathsAreRegistered():Void;

  // /**
  //  * Converts the supplied export text path to an object path and class name.
  //  *
  //  * @param InExportTextPath The export text path for an object. Takes on the form: ClassName'ObjectPath'
  //  * @param OutClassName The name of the class at the start of the path.
  //  * @param OutObjectPath The path to the object.
  //  * @return True if the supplied export text path could be parsed
  //  */
  // static function ParseExportTextPath(InExportTextPath:const PRef<FString>, FString* OutClassName, FString* OutObjectPath):Bool;

  /**
   * Returns the path to the object referred to by the supplied export text path, excluding the class name.
   *
   * @param InExportTextPath The export text path for an object. Takes on the form: ClassName'ObjectPath'
   * @return The path to the object referred to by the supplied export path.
   */
  static function ExportTextPathToObjectPath(InExportTextPath:Const<PRef<FString>>):FString;

  /**
   * Returns the name of the package referred to by the specified object path
   */
  static function ObjectPathToPackageName(InObjectPath:Const<PRef<FString>>):FString;

  /**
   * Returns the name of the object referred to by the specified object path
   */
  static function ObjectPathToObjectName(InObjectPath:Const<PRef<FString>>):FString;

  /**
   * Checks the root of the package's path to see if it is a script package
   * @return true if the root of the path matches the script path
   */
  static function IsScriptPackage(InPackageName:Const<PRef<FString>>):Bool;

  /**
   * Checks the root of the package's path to see if it is a localized package
   * @return true if the root of the path matches any localized root path
   */
  static function IsLocalizedPackage(InPackageName:Const<PRef<FString>>):Bool;

  // /**
  //  * Checks if a package name contains characters that are invalid for package names.
  //  */
  // static function DoesPackageNameContainInvalidCharacters(InLongPackageName:Const<PRef<FString>>, OutReason:FText* = NULL):Bool;

  /**
   * Checks if a package can be found using known package extensions.
   *
   * @param InPackageFilename Package filename without the extension.
   * @param OutFilename If the package could be found, filename with the extension.
   * @return true if the package could be found on disk.
   */
  static function FindPackageFileWithoutExtension(InPackageFilename:Const<PRef<FString>>, OutFilename:PRef<FString>):Bool;
}
