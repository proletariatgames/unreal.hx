package unreal;

@:autoBuild(ue4hx.internal.DelegateBuild.build())
interface Delegate<T : haxe.Constraints.Function> {
  /**
    Unbinds this delegate.
   **/
  function Unbind():Void;

  /**
    Tells whether this delegate is bound
   **/
  function IsBound():Bool;

  /**
    If this is a UFunction or UObject delegate, return the UObject.
    returns the object associated with this delegate if there is one.
   */
  function GetUObject():Null<UObject>;

  // added by the compiler:
  // function Execute(args):RetVal;
  // function ExecuteIfBound(args):RetVal;
}
