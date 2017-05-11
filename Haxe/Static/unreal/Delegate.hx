package unreal;

@:genericBuild(uhx.compiletime.DelegateBuild.build("Delegate"))
class Delegate<SelfType, T : haxe.Constraints.Function> {
  /**
    Unbinds this delegate.
   **/
  // function Unbind():Void {}

  /**
    Tells whether this delegate is bound
   **/
  // function IsBound():Bool { return false; }

  /**
    If this is a UFunction or UObject delegate, return the UObject.
    returns the object associated with this delegate if there is one.
   */
  // function GetUObject():Null<UObject> { return null; }

  // added by the compiler:
  // function Execute(args):RetVal;
  // function ExecuteIfBound(args):RetVal;
}
