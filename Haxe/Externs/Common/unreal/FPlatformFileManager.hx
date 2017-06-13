package unreal;

@:glueCppIncludes("HAL/PlatformFilemanager.h")
@:uextern extern class FPlatformFileManager {
  static function Get():FPlatformFileManager;
  function GetPlatformFile():PRef<IPlatformFile>;
  @:uname("GetPlatformFile") function GetPlatformFileWithName(name:TCharStar):PPtr<IPlatformFile>;
  function SetPlatformFile(file:PRef<IPlatformFile>):Void;
}
