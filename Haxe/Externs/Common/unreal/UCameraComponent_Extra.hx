package unreal;

extern class UCameraComponent_Extra
{
	/** Adds an Blendable (implements IBlendableInterface) to the array of Blendables (if it doesn't exist) and update the weight */
	public function AddOrUpdateBlendable(InBlendableObject:TScriptInterface<IBlendableInterface>, InWeight:Float32) : Void;
	/** Removes a blendable. */
	public function RemoveBlendable(InBlendableObject:TScriptInterface<IBlendableInterface>) : Void;
}
