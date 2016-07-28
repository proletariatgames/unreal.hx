package unreal.umg;

extern class UEditableTextBox_Extra {

  @:thisConst
  function GetText() : FText;
  function SetText(inText:FText) : Void;
  function SetError(inError:FText) : Void;
}