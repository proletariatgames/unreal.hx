package unreal;

/**
  Dynamic delegates can be serialized, their functions can be found by name, and they are slower than regular delegates.
  Only `UObject` functions that are either native or overridden from native, or `@:ufunction`/`@:uexpose` can be bound to them

  In order to bind to those delegates, see `unreal.Delegates` helper macros
 **/
@:autoBuild(ue4hx.internal.DelegateBuild.build())
interface DynamicDelegate<T : haxe.Constraints.Function> extends Event<T> {
  function IsBound():Bool;

  // added by the compiler:
  // function Execute(args):RetVal;
  // function ExecuteIfBound(args):RetVal;
}
