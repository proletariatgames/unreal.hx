package unreal;

@:glueCppIncludes("GenericPlatform/GenericPlatformFile.h")
@:uextern extern class FFileStatData {
  public function new();

	/** The time that the file or directory was originally created, or FDateTime::MinValue if the creation time is unknown */
	public var CreationTime:FDateTime;

	/** The time that the file or directory was last accessed, or FDateTime::MinValue if the access time is unknown */
	public var AccessTime:FDateTime;

	/** The time the the file or directory was last modified, or FDateTime::MinValue if the modification time is unknown */
	public var ModificationTime:FDateTime;

	/** Size of the file (in bytes), or -1 if the file size is unknown */
	public var FileSize:Int64;

	/** True if this data is for a directory, false if it's for a file */
	public var bIsDirectory : Bool;

	/** True if this file is read-only */
	public var bIsReadOnly : Bool;

	/** True if file or directory was found, false otherwise. Note that this value being true does not ensure that the other members are filled in with meaningful data, as not all file systems have access to all of this data */
	public var bIsValid : Bool;
}