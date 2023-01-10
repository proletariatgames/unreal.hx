package unreal.umg;

@:umodule("UMG")
@:glueCppIncludes("UMG.h")
@:uextern extern class UEditableText_Extra extends unreal.umg.UWidget
{

	/**
	 * The maximum number of characters allowed in the text field.
	 * A value of `0` means there is no bound.
	 * Negative numbers are equivalent to the value being `0`.
	 */
	public var MaximumTextLength:Int32;

}
