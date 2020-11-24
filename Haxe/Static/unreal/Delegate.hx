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
	 * Checks to see if this delegate is bound to the given user object.
	 *
	 * @return True if this delegate is bound to InUserObject, false otherwise.
	 */
  // function IsBoundToObject(uobject):Void;

	/**
	 * Static: Binds a C++ lambda delegate
	 * technically this works for any functor types, but lambdas are the primary use case
	 */
  // function BindLambda(lambda):Void;

	/**
	 * Static: Binds a weak object C++ lambda delegate
	 * technically this works for any functor types, but lambdas are the primary use case
	 */
  // function BindWeakLambda(uobject, lambda):Void;

	/**
	 * Binds a UObject-based member function delegate.
	 *
	 * UObject delegates keep a weak reference to your object.
	 * You can use ExecuteIfBound() to call them.
	 */
  // function BindUObject(uobject, function):Void;

  /**
    If this is a UFunction or UObject delegate, return the UObject.
    returns the object associated with this delegate if there is one.
   */
  // function GetUObject():Null<UObject> { return null; }

  // added by the compiler:
  // function Execute(args):RetVal;
  // function ExecuteIfBound(args):RetVal;
}
