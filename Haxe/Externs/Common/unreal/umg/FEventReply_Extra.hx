package unreal.umg;

/**
  Allows users to handle events and return information to the underlying UI layer.
**/
@:umodule("UMG")
@:glueCppIncludes("UMG.h", "Public/Components/SlateWrapperTypes.h")
extern class FEventReply_Extra {
  @:uname('.ctor') static function create(IsHandled:Bool=false):FEventReply;
  @:uname('new') static function createNew(IsHandled:Bool=false):POwnedPtr<FEventReply>;
}
