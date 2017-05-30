package unreal;

@:glueCppIncludes("Misc/HotReloadInterface.h")
@:noCopy
@:uextern extern class IHotReloadInterface {
  static function GetPtr():PPtr<IHotReloadInterface>;

  /**
   * Recompiles a single module
   *
   * @param InModuleName Name of the module to compile
   * @param bReloadAfterRecompile Should the module be reloaded after recompile
   * @param Ar Output device (logging)
   * @param bForceCodeProject Even if this is not code-based project compile with game project as the target for UBT (do not use UE4Editor target)
   */
  function RecompileModule(InModuleName:Const<FName>, bReloadAfterRecompile:Bool, Ar:PRef<FOutputDevice>, bFailIfGeneratedCodeChanges:Bool = true, bForceCodeProject:Bool = false):Bool;

  /**
   * Returns whether modules are currently being compiled
   */
  function IsCurrentlyCompiling():Bool;

  /**
   * Request that current compile be stopped
   */
  function RequestStopCompilation():Void;

  /**
   * Performs hot reload from the editor of all currently loaded game modules.
   * @param	bWaitForCompletion	True if RebindPackages should not return until the recompile and reload has completed
   * @return	If bWaitForCompletion was set to true, this will return the result of the compilation, otherwise will return ECompilationResult::Unknown
   */
  function DoHotReloadFromEditor(bWaitForCompletion:Bool):ECompilationResult;

  /**
   * HotReload: Reloads the DLLs for given packages.
   * @param	Package				Packages to reload.
   * @param	DependentModules	Additional modules that don't contain UObjects, but rely on them
   * @param	bWaitForCompletion	True if RebindPackages should not return until the recompile and reload has completed
   * @param	Ar					Output device for logging compilation status
   *
   * @return	If bWaitForCompletion was set to true, this will return the result of the compilation, otherwise will return ECompilationResult::Unknown
   */
  function RebindPackages(Packages:TArray<UPackage>, DependentModules:TArray<FName>, bWaitForCompletion:Bool, Ar:PRef<FOutputDevice>):ECompilationResult;
}
