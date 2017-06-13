package unreal.slatecore;


@:umodule("SlateCore")
@:glueCppIncludes("Input/Reply.h")
@:noCopy @:noEquals @:uextern extern class FReply {

  static public function Handled() : FReply;
  static public function Unhandled() : FReply;

}