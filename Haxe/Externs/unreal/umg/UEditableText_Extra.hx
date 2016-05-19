package unreal.umg;

extern class UEditableText_Extra {
  function SetText(InText:FText) : Void;
  @:thisConst function GetText() : FText;
  function SetIsPassword(isPassword:Bool) : Void;
  function SetHintText(hintText:FText) : Void;
  function SetIsReadOnly(readOnly:Bool) : Void;
}