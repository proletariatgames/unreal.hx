package unreal.developer.sourcecontrol;

@:glueCppIncludes("ISourceControlProvider.h")
@:noCopy @:noEquals
@:uextern extern class ISourceControlProvider
{
	/**
	 * Initialize source control provider.
	 * @param	bForceConnection	If set, this flag forces the provider to attempt a connection to its server.
	 */
	function Init(bForceConnection:Bool = true) : Void;

	/**
	 * Shut down source control provider.
	 */
	function Close() : Void;

	/** Get the source control provider name */
	@:thisConst function GetName() : Const<PRef<FName>>;

	/** Get the source control status as plain, human-readable text */
	@:thisConst function GetStatusText() : FText;

	/** Quick check if source control is enabled. Specifically, it returns true if a source control provider is set (regardless of whether the provider is available) and false if no provider is set. So all providers except the stub DefalutSourceProvider will return true. */
	@:thisConst function IsEnabled() : Bool;

	/**
	 * Quick check if source control is available for use (server-based providers can use this
	 * to return whether the server is available or not)
	 *
	 * @return	true if source control is available, false if it is not
	 */
	@:thisConst function IsAvailable() : Bool;

	/**
	 * Helper overload for state retrieval, see GetState().
	 */
	function GetState(InFile:Const<PRef<FString>>, InStateCacheUsage:EStateCacheUsage) : TThreadSafeSharedPtr<ISourceControlState>;

	/**
	 * Helper overload for operation execution, see Execute().
	 */
	function Execute(InOperation:Const<PRef<TThreadSafeSharedRef<ISourceControlOperation>>>, InFile:Const<PRef<FString>>) : ECommandResult;
}
