package unreal;

@:glueCppIncludes("HttpModule.h")
@:umodule("HTTP")
@:uextern @:noCopy @:noEquals extern class FHttpModule
{
  static function Get() : PRef<FHttpModule>;

  function CreateRequest() : TSharedRef<IHttpRequest>;

  @:thisConst
  function IsHttpEnabled() : Bool;

  function GetHttpManager() : PRef<FHttpManager>;
}