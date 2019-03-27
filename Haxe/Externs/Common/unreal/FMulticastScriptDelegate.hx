package unreal;

@:glueCppIncludes("UObject/ScriptDelegates.h")
@:uextern extern class FMulticastScriptDelegate {
  public function new();

  @:uname(".ctor") static function create():FMulticastScriptDelegate;

  @:uname("new") static function createNew():POwnedPtr<FMulticastScriptDelegate>;

  /**
   * Checks to see if the user object bound to this delegate is still valid
   *
   * @return  True if the object is still valid and it's safe to execute the function call
   */
  function IsBound():Bool;

  /**
   * Checks whether a function delegate is already a member of this multi-cast delegate's invocation list
   *
   * @param	InDelegate	Delegate to check
   * @return	True if the delegate is already in the list.
   */
  @:uname("Contains") function ContainsDelegate(InDelegate:Const<PRef<FScriptDelegate>>):Bool;

#if !UHX_NO_UOBJECT
  function Contains(uobj:UObject, functionName:FName):Bool;

  /**
   * Removes a function from this multi-cast delegate's invocation list (performance is O(N)).  Note that the
   * order of the delegates may not be preserved!
   *
   * @param	InObject		Object of the delegate to remove
   * @param	InFunctionName	Function name of the delegate to remove
   */
  function Remove(InObject:UObject, InFunctionName:FName):Void;

  /**
   * Removes all delegate bindings from this multicast delegate's
   * invocation list that are bound to the specified object.
   *
   * This method also compacts the invocation list.
   *
   * @param InObject The object to remove bindings for.
   */
  function RemoveAll( Object:UObject ):Void;

  /**
   * Executes a multi-cast delegate by calling all functions on objects bound to the delegate.  Always
   * safe to call, even if when no objects are bound, or if objects have expired.  In general, you should
   * never call this function directly.  Instead, call Broadcast() on a derived class.
   *
   * @param	Params				Parameter structure
   */
  // see FCallDelegateHelper
  @:uname("ProcessMulticastDelegate<UObject>")
  function ProcessMulticastDelegate(Parameters:AnyPtr):Void;
#end

  /**
   * Adds a function delegate to this multi-cast delegate's invocation list
   *
   * @param	InDelegate	Delegate to add
   */
  function Add(InDelegate:Const<PRef<FScriptDelegate>>):Void;

  /**
   * Adds a function delegate to this multi-cast delegate's invocation list if a delegate with the same signature
   * doesn't already exist in the invocation list
   *
   * @param	InDelegate	Delegate to add
   */
  function AddUnique(InDelegate:Const<PRef<FScriptDelegate>>):Void;

  /**
   * Removes a function from this multi-cast delegate's invocation list (performance is O(N)).  Note that the
   * order of the delegates may not be preserved!
   *
   * @param	InDelegate	Delegate to remove
   */
  @:uname("Remove") function RemoveDelegate(InDelegate:Const<PRef<FScriptDelegate>>):Void;

  /**
   * Removes all functions from this delegate's invocation list
   */
  function Clear():Void;
}
