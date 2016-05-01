package unreal;

/**
  Dynamic delegates can be serialized, their functions can be found by name, and they are slower than regular delegates.
  Only `UObject` functions that are either native or overridden from native, or `@:ufunction`/`@:uexpose` can be bound to them

  In order to bind to those delegates, see `unreal.Delegates` helper macros
 **/
@:genericBuild(ue4hx.internal.DelegateBuild.build("DynamicMulticastDelegate"))
class DynamicMulticastDelegate<@:const Name, T : haxe.Constraints.Function> {
  // added by the compiler:
  // function Broadcast(args):Void;
}
