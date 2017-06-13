package unreal.editor;

extern class ULevelEditorPlaySettings_Extra {
  function SetPlayNetMode(InPlayNetMode:EPlayNetMode):Void;
  function IsPlayNetModeActive():Bool;

  // TODO - reference to basic
  // function GetPlayNetMode(InPlayNetMode:PRef<EPlayNetMode>):Bool;
  function SetRunUnderOneProcess(value:Bool):Void;
  function IsRunUnderOneProcessActive():Bool;
  // TODO - reference to basic
  // function GetRunUnderOneProcess(value:PRef<Bool>):Void;

  function SetPlayNetDedicated(value:Bool):Void;
  function IsPlayNetDedicatedActive():Bool;
  // TODO - reference to basic
  // function GetPlayNetDedicated(value:PRef<Bool>):Void;

  function SetPlayNumberOfClients(value:Int32):Void;
  function IsPlayNumberOfClientsActive():Bool;
  // TODO - reference to basic
  // function GetPlayerNumberOfClients(value:PRef<Int32>):Void;
}
