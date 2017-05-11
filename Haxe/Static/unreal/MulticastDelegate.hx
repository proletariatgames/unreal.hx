package unreal;

/**
  Multi-cast delegates have most of the same features as single-cast delegates.
  They only have weak references to objects, can be used with structs, can be copied around easily, etc.

  Just like regular delegates, multi-cast delegates can be loaded/saved, and triggered remotely; however,
  multi-cast delegate functions cannot use return values.
  They are best used to easily pass a collection of delegates around.

  In order to bind to those delegates, see `unreal.Delegates` helper macros
 **/
@:genericBuild(uhx.compiletime.DelegateBuild.build("MulticastDelegate"))
class MulticastDelegate<SelfType, T : haxe.Constraints.Function> {
  /**
    Removes a function from this multi-cast delegate
   **/
  // function Remove(handle:PStruct<FDelegateHandle>):Void {}

  /**
    Clears the current delegate
   **/
  // function Clear():Void {}

  // /**
  //   Removes all functions from this multi-cast delegate's invocation list that are bound to the specified UserObject
  //  **/
  // function RemoveAll():Void;

  // added by the compiler:
  // function Broadcast(args):Void;

  // unimplemented functions (TODO): (see /Runtime/Core/Public/Delegates/MulticastDelegateBase.h)
  // function IsBoundToObject(obj):Bool;
  // function RemoveAll(obj):Void;
}
