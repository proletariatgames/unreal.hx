package unreal;

@:glueCppIncludes("GenericPlatform/GenericPlatformFile.h")
@:noCopy @:noEquals
@:uextern extern class IPlatformFile {
  function FileExists(file:TCharStar):Bool;
  function DirectoryExists(dir:TCharStar):Bool;
  function FileSize(file:TCharStar):Int64;
  function GetName():TCharStar;
  static function GetPlatformPhysical():PRef<IPlatformFile>;
  // You must call .dispose() on these file handles to close the files
  function OpenRead(filename:TCharStar, allowWrite:Bool):POwnedPtr<IFileHandle>;
  function OpenWrite(filename:TCharStar, append:Bool, allowRead:Bool):POwnedPtr<IFileHandle>;
}
