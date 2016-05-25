package unreal.developer.hotreload;

@:glueCppIncludes("Developer/HotReload/Public/IHotReload.h")
@:noCopy @:noEquals
@:uextern extern class IHotReloadModule {

  /**
   * Singleton-like access to this module's interface.  This is just for convenience!
   * Beware of calling this during the shutdown phase, though.  Your module might have been unloaded already.
   *
   * @return Returns singleton instance, loading the module on demand if needed
   */
  static function Get():PRef<IHotReloadModule>;

  /**
   * Checks to see if this module is loaded and ready.  It is only valid to call Get() if IsAvailable() returns true.
   *
   * @return True if the module is loaded and ready to use
   */
  static function IsAvailable():Bool;

  /**
   * Returns whether modules are currently being compiled
   */
  @:thisConst function IsCurrentlyCompiling():Bool;

  /**
   * Request that current compile be stopped
   */
  @:thisConst function RequestStopCompilation():Void;


  /** Called when a Hot Reload event has completed.
   *
   * @param	bWasTriggeredAutomatically	True if the hot reload was invoked automatically by the hot reload system after detecting a changed DLL
   */
  function OnHotReload():PRef<FHotReloadEvent>;

  /**
   * Gets an event delegate that is executed when compilation of a module has started.
   *
   * @return The event delegate.
   */
  function OnModuleCompilerStarted():PRef<FModuleCompilerStartedEvent>;

  /**
   * Gets an event delegate that is executed when compilation of a module has finished.
   *
   * The first parameter is the result of the compilation operation.
   * The second parameter determines whether the log should be shown.
   *
   * @return The event delegate.
   */
  function OnModuleCompilerFinished():PRef<FModuleCompilerFinishedEvent>;

  /**
   * Checks if there's any game modules currently loaded
   */
  function IsAnyGameModuleLoaded():Bool;
}

@:glueCppIncludes("Misc/HotReloadInterface.h")
@:uname("IHotReloadInterface.FHotReloadEvent")
typedef FHotReloadEvent = MulticastDelegate<FHotReloadEvent, Bool->Void>;

@:glueCppIncludes("Misc/HotReloadInterface.h")
@:uname("IHotReloadInterface.FModuleCompilerStartedEvent")
typedef FModuleCompilerStartedEvent = MulticastDelegate<FModuleCompilerStartedEvent, Bool->Void>;

@:glueCppIncludes("Misc/HotReloadInterface.h")
@:uname("IHotReloadInterface.FModuleCompilerFinishedEvent")
typedef FModuleCompilerFinishedEvent = MulticastDelegate<FModuleCompilerFinishedEvent, Const<PRef<FString>>->ECompilationResult->Bool->Void>;
