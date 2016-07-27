package unreal.umg;

extern class UEditableText_Extra {
  function SetText(InText:FText) : Void;
  @:thisConst function GetText() : FText;
  function SetHintText(hintText:FText) : Void;
}