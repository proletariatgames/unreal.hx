package unreal;

@:glueCppIncludes("Logging/LogCategory.h")
@:uextern extern class FLogCategoryBase {
  /**
	* Constructor, registers with the log suppression system and sets up the default values.
	* @param CategoryName, name of the category
	* @param InDefaultVerbosity, default verbosity for the category, may ignored and overrridden by many other mechanisms
	* @param InCompileTimeVerbosity, mostly used to keep the working verbosity in bounds, macros elsewhere actually do the work of stripping compiled out things.
	**/
	public function new(CategoryName:TCharStar, InDefaultVerbosity:ELogVerbosity, InCompileTimeVerbosity:ELogVerbosity);

  function IsSuppressed(VerbosityLevel:ELogVerbosity):Bool;

	function GetCategoryName():FName;

	/** Gets the working verbosity **/
	function GetVerbosity():ELogVerbosity;

	/** Sets up the working verbosity and clamps to the compile time verbosity. **/
	function SetVerbosity(Verbosity:ELogVerbosity):Void;
}