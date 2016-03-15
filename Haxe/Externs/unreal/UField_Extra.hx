package unreal;

extern class UField_Extra {
  var Next:UField;

  function AddCppProperty(property:UProperty):Void;
#if WITH_EDITOR
  function GetBoolMetaData(key:Const<TCharStar>):Bool;
  function GetFLOATMetaData(key:Const<TCharStar>):Float32;
  function GetINTMetaData(key:Const<TCharStar>):Int32;
  function GetMetaData(key:Const<TCharStar>):Const<PRef<FString>>;
  function GetDisplayNameText():FText;
  function HasMetaData(key:Const<TCharStar>):Bool;
  function SetMetaData(key:Const<TCharStar>, value:Const<TCharStar>):Void;
#end
}
