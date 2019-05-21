package unreal;

@:glueCppIncludes("HAL/PlatformFilemanager.h")
@:uextern @:noCopy @:noEquals extern class FPlatformFileManager {
  static function Get():PRef<FPlatformFileManager>;
  function GetPlatformFile():PRef<IPlatformFile>;
  @:uname("GetPlatformFile") function GetPlatformFileWithName(name:TCharStar):PPtr<IPlatformFile>;
  function SetPlatformFile(file:PRef<IPlatformFile>):Void;
}
