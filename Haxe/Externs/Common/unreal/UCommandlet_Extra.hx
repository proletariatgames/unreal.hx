package unreal;

extern class UCommandlet_Extra {
	/**
	 * Entry point for your commandlet
	 *
	 * @param Params the string containing the parameters for the commandlet
	 */
	function Main(Params:Const<PRef<FString>>) : Int32;

	/**
	 * Allows commandlets to override the default behavior and create a custom engine class for the commandlet. If
	 * the commandlet implements this function, it should fully initialize the UEngine object as well.  Commandlets
	 * should indicate that they have implemented this function by assigning the custom UEngine to GEngine.
	 */
	function CreateCustomEngine(Params:Const<PRef<FString>>) : Void;

	/**
	 * Parses a string into tokens, separating switches (beginning with - or /) from
	 * other parameters
	 *
	 * @param	CmdLine		the string to parse
	 * @param	Tokens		[out] filled with all parameters found in the string
	 * @param	Switches	[out] filled with all switches found in the string
	 *
	 * @return	@todo document
	 */
	static function ParseCommandLine(CmdLine:Const<TCharStar>, Tokens:PRef<TArray<FString>>, Switches:PRef<TArray<FString>>) : Void;
}
