package unreal;

extern class UPlayerInput_Extra {

  /**
    This player's version of Action Mappings
   **/
  public var ActionMappings : TArray<FInputActionKeyMapping>;

  /**
    This player's version of Axis Mappings
   **/
  public var AxisMappings : TArray<FInputAxisKeyMapping>;

  /**
    Clear the current cached key maps and rebuild from the source arrays.
   **/
  public function ForceRebuildingKeyMaps(?bRestoreDefaults:Bool = false) : Void;

  /** Gets the axis properties for a given AxisKey.  Returns if true if AxisKey was found in the AxisConfig array. */
  public function GetAxisProperties(AxisKey:unreal.inputcore.FKey, AxisProperties:PRef<FInputAxisProperties>) : Bool;

  /** Gets the axis properties for a given AxisKey.  Returns if true if AxisKey was found in the AxisConfig array. */
  public function SetAxisProperties(AxisKey:unreal.inputcore.FKey, AxisProperties:Const<PRef<FInputAxisProperties>>) : Void;

  /**
    Returns whether an Axis Mapping is inverted
   **/
  public function GetInvertAxis(AxisName : FName) : Bool;

	/** Add a player specific action mapping. */
  public function AddActionMapping(KeyMapping : Const<PRef<FInputActionKeyMapping>>) : Void;

	/** Remove a player specific action mapping. */
	public function RemoveActionMapping(KeyMappingconst : Const<PRef<FInputActionKeyMapping>>) : Void;

	/** Add a player specific axis mapping. */
	public function AddAxisMapping(KeyMapping : Const<PRef<FInputAxisKeyMapping>>) : Void;

	/** Remove a player specific axis mapping. */
	public function RemoveAxisMapping(KeyMapping : Const<PRef<FInputAxisKeyMapping>>) : Void;

#if (UE_VER >= 4.22)
  @:uname('SetMouseSensitivity')
  public function SetMouseSensitivityPerAxis(SensitivityX:Float32, SensitivityY:Float32) : Void;
#end
}
