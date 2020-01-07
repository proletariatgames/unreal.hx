package unreal;
import unreal.inputcore.*;

extern class UInputComponent_Extra {


	/** The collection of key bindings. */
	public var KeyBindings:TArray<FInputKeyBinding>;

	/** The collection of touch bindings. */
	public var TouchBindings:TArray<FInputTouchBinding>;

	/** The collection of axis bindings. */
	public var AxisBindings:TArray<FInputAxisBinding>;

	/** The collection of axis key bindings. */
	public var AxisKeyBindings:TArray<FInputAxisKeyBinding>;

	/** The collection of vector axis bindings. */
	public var VectorAxisBindings:TArray<FInputVectorAxisBinding>;

	/** The collection of gesture bindings. */
	public var GestureBindings:TArray<FInputGestureBinding>;

	/** The priority of this input component when pushed in to the stack. */
	public var Priority:Int32;

	/** Whether any components lower on the input stack should be allowed to receive input. */
	public var bBlockInput:Bool;

	/**
	 * Gets the current value of the axis with the specified name.
	 *
	 * @param AxisName The name of the axis.
	 * @return Axis value.
	 * @see GetAxisKeyValue, GetVectorAxisValue
	 */
	public function GetAxisValue( AxisName:FName ):Float32;

	/**
	 * Gets the current value of the axis with the specified key.
	 *
	 * @param AxisKey The key of the axis.
	 * @return Axis value.
	 * @see GetAxisKeyValue, GetVectorAxisValue
	 */
	public function GetAxisKeyValue( AxisKey:unreal.inputcore.FKey ):Float32;

	/**
	 * Gets the current vector value of the axis with the specified key.
	 *
	 * @param AxisKey The key of the axis.
	 * @return Axis value.
	 * @see GetAxisValue, GetAxisKeyValue
	 */
	public function GetVectorAxisValue( AxisKey:unreal.inputcore.FKey ):FVector;

	/**
	 * Checks whether this component has any input bindings.
	 *
	 * @return true if any bindings are set, false otherwise.
	 */
	public function HasBindings( ) : Bool;

	/**
	 * Adds the specified action binding.
	 *
	 * @param Binding The binding to add.
	 * @return The last binding in the list.
	 * @see ClearActionBindings, GetActionBinding, GetNumActionBindings, RemoveActionBinding
	 */
	public function AddActionBinding( Binding:Const<PRef<FInputActionBinding>> ):PRef<FInputActionBinding>;

	/**
	 * Removes all action bindings.
	 *
	 * @see AddActionBinding, GetActionBinding, GetNumActionBindings, RemoveActionBinding
	 */
	public function ClearActionBindings( ) : Void;

	/**
	 * Gets the action binding with the specified index.
	 *
	 * @param BindingIndex The index of the binding to get.
	 * @see AddActionBinding, ClearActionBindings, GetNumActionBindings, RemoveActionBinding
	 */
	public function GetActionBinding(BindingIndex:Int32):PRef<FInputActionBinding>;

	/**
	 * Gets the number of action bindings.
	 *
	 * @return Number of bindings.
	 * @see AddActionBinding, ClearActionBindings, GetActionBinding, RemoveActionBinding
	 */
	public function GetNumActionBindings():Int32;

	/**
	 * Removes the action binding at the specified index.
	 *
	 * @param BindingIndex The index of the binding to remove.
	 * @see AddActionBinding, ClearActionBindings, GetActionBinding, GetNumActionBindings
	 */
	public function RemoveActionBinding( BindingIndex:Int32 ):Void;

	/** Clears all cached binding values. */
	public function ClearBindingValues():Void;

  /**
   * Binds a delegate function to an Action defined in the project settings.
   * Returned reference is only guaranteed to be valid until another action is bound. (MethodPointer version)
   */
  @:uname("BindAction") public function BindAction(actionName:Const<FName>, keyEvent:EInputEvent, object:UObject, func:MethodPointer<UObject,Void->Void>) : PRef<FInputActionBinding>;

  /**
   * Binds a delegate function to an Action defined in the project settings.
   * Returned reference is only guaranteed to be valid until another action is bound.
   */
  @:expr({
    var ab = new unreal.FInputActionBinding(actionName, keyEvent);
		var delegate = unreal.FInputActionUnifiedDelegate.FInputActionHandlerWithKeySignature.create();
		if (object != null) {
			var fn = func;
			func = function(key:unreal.inputcore.FKey) {
				if (!object.isValid()) {
					if (delegate != null) {
						delegate.Unbind();
						delegate.dispose();
						delegate = null;
					}
				} else {
					fn(key);
				}
			}
		}
		delegate.BindLambda(func);
		ab.ActionDelegate = unreal.FInputActionUnifiedDelegate.createWithDelegateWithKey(delegate);
		ab.bConsumeInput = bConsumeInput;
		return AddActionBinding(ab);
  })
	public function BindActionHx(actionName:FName, keyEvent:EInputEvent, object:Null<UObject>, func:unreal.inputcore.FKey->Void, bConsumeInput:Bool=true) : FInputActionBinding;

	@:expr({
		return BindActionHx(actionName, keyEvent, object, function(key) func(), bConsumeInput);
	})
	public function BindActionHxVoid(actionName:FName, keyEvent:EInputEvent, object:Null<UObject>, func:Void->Void, bConsumeInput:Bool=true) : FInputActionBinding;


  /**
   * Binds a delegate function an Axis defined in the project settings.
   * Returned reference is only guaranteed to be valid until another axis is bound. (MethodPointer version)
   */
  @:uname("BindAxis") public function BindAxisStatic(axisName:Const<FName>, object:UObject, func:MethodPointer<UObject,Float32->Void>) : PRef<FInputAxisBinding>;

  @:uname("BindAxis") public function BindAxisCreate(axisName:Const<FName>) : PRef<FInputAxisBinding>;

  /**
   * Binds a delegate function an Axis defined in the project settings.
   * Returned reference is only guaranteed to be valid until another axis is bound.
   */
  @:expr({
    var ab = BindAxisCreate(axisName);
		var delegate = ab.AxisDelegate.GetDelegateForManualSet();
		if (object != null) {
			var fn = func;
			func = function(val:Float32) {
				if (!object.isValid()) {
					if (delegate != null) {
						delegate.Unbind();
						delegate.dispose();
						delegate = null;
					}
				} else {
					fn(val);
				}
			}
		}
		delegate.BindLambda(func);
		return ab;
  })
	public function BindAxis(axisName:FName, object:Null<UObject>, func:Float->Void) : FInputAxisBinding;


	/**
	 * Indicates that the InputComponent is interested in knowing/consuming a vector axis key's
	 * value (via GetVectorAxisKeyValue) but does not want a delegate function called each frame.
	 * Returned reference is only guaranteed to be valid until another vector axis key is bound. (MethodPointer version)
	 */
  @:uname("BindVectorAxis") public function BindVectorAxisStatic(axisKey:Const<FKey>, object:UObject, func:MethodPointer<UObject,FVector->Void>) : PRef<FInputVectorAxisBinding>;

  @:uname("BindVectorAxis") public function BindVectorAxisCreate(axisKey:Const<FKey>) : PRef<FInputVectorAxisBinding>;

	/**
	 * Indicates that the InputComponent is interested in knowing/consuming a vector axis key's
	 * value (via GetVectorAxisKeyValue) but does not want a delegate function called each frame.
	 * Returned reference is only guaranteed to be valid until another vector axis key is bound.
	 */
  @:expr({
    var ab = BindVectorAxisCreate(axisKey);
		var delegate = ab.AxisDelegate.GetDelegateForManualSet();
		if (object != null) {
			var fn = func;
			func = function(val:unreal.FVector) {
				if (!object.isValid()) {
					if (delegate != null) {
						delegate.Unbind();
						delegate.dispose();
						delegate = null;
					}
				} else {
					fn(val);
				}
			}
		}
		delegate.BindLambda(func);
		return ab;
  })
	public function BindVectorAxis(axisKey:FKey, object:Null<UObject>, func:FVector->Void) : FInputVectorAxisBinding;

	/**
	 * Binds a key event to a delegate function.
	 * Returned reference is only guaranteed to be valid until another input key is bound.
	 */
  @:uname("BindKey") public function BindKeyStatic(chord:unreal.slate.FInputChord, keyEvent:EInputEvent, object:UObject, func:MethodPointer<UObject,Void->Void>) : PRef<FInputKeyBinding>;

	/**
	 * Binds a key event to a delegate function.
	 * Returned reference is only guaranteed to be valid until another input key is bound.
	 */
  @:expr({
    var kb = new FInputKeyBinding(chord, keyEvent);
		var delegate = unreal.FInputActionUnifiedDelegate.FInputActionHandlerWithKeySignature.create();
		if (object != null) {
			var fn = func;
			func = function(val:unreal.inputcore.FKey) {
				if (!object.isValid()) {
					if (delegate != null) {
						delegate.Unbind();
						delegate.dispose();
						delegate = null;
					}
				} else {
					fn(val);
				}
			}
		}
		delegate.BindLambda(func);
		kb.KeyDelegate = unreal.FInputActionUnifiedDelegate.createWithDelegateWithKey(delegate);
		KeyBindings.push(kb);
		return KeyBindings[KeyBindings.length-1];
  })
	public function BindKey(chord:unreal.slate.FInputChord, keyEvent:EInputEvent, object:Null<UObject>, func:FKey->Void) : FInputKeyBinding;

	@:expr({
		return BindKey(chord, keyEvent, object, function(_) func());
	})
	public function BindKeyVoid(chord:unreal.slate.FInputChord, keyEvent:EInputEvent, object:Null<UObject>, func:Void->Void) : FInputKeyBinding;

	/**
	 * Binds this input component to touch events.
	 * Returned reference is only guaranteed to be valid until another touch event is bound.
	 */
  @:expr({
    var kb = new FInputTouchBinding(keyEvent);
		var delegate = kb.TouchDelegate.GetDelegateForManualSet();
		if (object != null) {
			var fn = func;
			func = function(v1:unreal.inputcore.ETouchIndex, v2:unreal.FVector) {
				if (!object.isValid()) {
					if (delegate != null) {
						delegate.Unbind();
						delegate.dispose();
						delegate = null;
					}
				} else {
					fn(v1,v2);
				}
			}
		}
		delegate.BindLambda(func);
		TouchBindings.push(kb);
		return TouchBindings[TouchBindings.length-1];
  })
	public function BindTouch(keyEvent:EInputEvent, object:Null<UObject>, func:ETouchIndex->FVector->Void) : FInputTouchBinding;

	/**
	 * Binds a gesture event to a delegate function.
	 * Returned reference is only guaranteed to be valid until another gesture event is bound.
	 */
  @:expr({
    var kb = new FInputGestureBinding(gestureKey);
		var delegate = kb.GestureDelegate.GetDelegateForManualSet();
		if (object != null) {
			var fn = func;
			func = function(val:unreal.Float32) {
				if (!object.isValid()) {
					if (delegate != null) {
						delegate.Unbind();
						delegate.dispose();
						delegate = null;
					}
				} else {
					fn(val);
				}
			}
		}
		delegate.BindLambda(func);
		GestureBindings.push(kb);
		return GestureBindings[GestureBindings.length-1];
  })
	public function BindGesture(gestureKey:FKey, object:Null<UObject>, func:Float->Void) : FInputGestureBinding;
}
