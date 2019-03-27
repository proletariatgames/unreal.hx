package unreal;

@:glueCppIncludes("Logging/LogScopedCategoryAndVerbosityOverride.h")
@:uextern extern class FLogScopedCategoryAndVerbosityOverride
{
  function new(Category:FName, Verbosity:ELogVerbosity);
}
