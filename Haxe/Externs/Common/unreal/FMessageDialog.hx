package unreal;

@:glueCppIncludes("Misc/MessageDialog.h")
@:noEquals @:noCopy @:uextern extern class FMessageDialog {
  static function Open(msgType:EAppMsgType, message:Const<PRef<FText>>, title:Const<PPtr<FText>>=null):EAppReturnType;
}
