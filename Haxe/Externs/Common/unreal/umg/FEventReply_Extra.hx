package unreal.umg;
import unreal.slatecore.FReply;
/**
  Allows users to handle events and return information to the underlying UI layer.
**/
@:umodule("UMG")
@:glueCppIncludes("UMG.h", "Public/Components/SlateWrapperTypes.h")
extern class FEventReply_Extra {
  @:uname('.ctor') static function create(IsHandled:Bool=false):FEventReply;
  @:uname('new') static function createNew(IsHandled:Bool=false):POwnedPtr<FEventReply>;

  public var NativeReply:FReply;
}
