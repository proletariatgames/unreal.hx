package unreal;

extern class UField_Extra {
  var Next:UField;

  function AddCppProperty(property:UProperty):Void;
#if WITH_EDITOR
  function GetBoolMetaData(key:FName):Bool;
  function GetFLOATMetaData(key:FName):Float32;
  function GetINTMetaData(key:FName):Int32;
  function GetMetaData(key:FName):Const<PRef<FString>>;
  function GetDisplayNameText():FText;
  function HasMetaData(key:FName):Bool;
  function SetMetaData(key:FName, value:Const<TCharStar>):Void;
#end

  function Bind():Void;
}
