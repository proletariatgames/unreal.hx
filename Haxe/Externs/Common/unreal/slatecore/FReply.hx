package unreal.slatecore;

import unreal.*;

@:umodule("SlateCore")
@:glueCppIncludes("Input/Reply.h")
@:noCopy @:noEquals @:uextern extern class FReply {

  static public function Handled() : FReply;
  static public function Unhandled() : FReply;

  public function UseHighPrecisionMouseMovement(InMouseCaptor : TSharedRef<SWidget>) : PRef<FReply>;
  public function CaptureMouse(InMouseCaptor : TSharedRef<SWidget>) : PRef<FReply>;
  public function LockMouseToWidget(InMouseCaptor : TSharedRef<SWidget>) : PRef<FReply>;
  public function ReleaseMouseCapture() : PRef<FReply>;
  public function ReleaseMouseLock() : PRef<FReply>;

}