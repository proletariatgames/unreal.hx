package unreal.developer.sourcecontrol;

@:glueCppIncludes("ISourceControlModule.h")
@:noCopy @:noEquals
@:uextern extern class ISourceControlModule {

	/**
	 * Gets a reference to the source control module instance.
	 *
	 * @return A reference to the source control module.
	 */
  static function Get():PRef<ISourceControlModule>;

	/**
	 * Check whether source control is enabled.	Specifically, it returns true if a source control provider is set (regardless of whether the provider is available) and false if no provider is set.
	 */
	@:thisConst function IsEnabled() : Bool;

	/**
	 * Get the source control provider that is currently in use.
	 */
	@:thisConst function GetProvider() : PRef<ISourceControlProvider>;

	/**
	 * Set the current source control provider to the one specified here by name.
	 * This will assert if the provider does not exist.
	 * @param	InName	The name of the provider
	 */
	function SetProvider(InName:Const<PRef<FName>>) : Void;
}
