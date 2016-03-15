package unreal.editor;

@:global
@:glueCppIncludes("PackageTools.h")
@:uextern extern class PackageTools {
  /**
   * Loads the specified package file (or returns an existing package if it's already loaded.)
   *
   * @param	InFilename	File name of package to load
   *
   * @return	The loaded package (or NULL if something went wrong.)
   */
  @:glueCppIncludes("PackageTools.h")
  @:global("PackageTools") static function LoadPackage(filename:FString):UPackage;

  /**
   * Helper function that attempts to unload the specified top-level packages.
   *
   * @param	PackagesToUnload	the list of packages that should be unloaded
   * @param	OutErrorMessage		An error message specifying any problems with unloading packages
   *
   * @return	true if the set of loaded packages was changed
   */
  @:glueCppIncludes("PackageTools.h")
  @:global("PackageTools") static function UnloadPackages(packagesToUnload:Const<PRef<TArray<UPackage>>>, outErrorMessage:PRef<FText>):Bool;
}
