package unreal;

extern class UUserInterfaceSettings_Extra {
	/** Gets the current scale of the UI based on the size of a viewport */
  @:thisConst
	function GetDPIScaleBasedOnSize(Size:FIntPoint) : Float32;
}