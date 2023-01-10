package unreal;

extern class TSoftObjectPtr_Extra {

	/**
	 * Test if this can never point to a live UObject
	 *
	 * @return true if this is explicitly pointing to no object
	 */
	@:thisConst public function IsNull():Bool;

	/**
	 * Test if this does not point to a live UObject, but may in the future
	 *
	 * @return true if this does not point to a real object, but could possibly
	 */
	@:thisConst public function IsPending():Bool;

	/**
	 * Test if this points to a live UObject
	 *
	 * @return true if Get() would return a valid non-null pointer
	 */
	@:thisConst public function IsValid():Bool;

}
