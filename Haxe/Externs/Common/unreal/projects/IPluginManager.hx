package unreal.projects;

@:glueCppIncludes("Interfaces/IPluginManager.h")
@:umodule("Projects")
@:noCopy @:noEquals
@:uextern extern class IPluginManager {
  public static function Get():PRef<IPluginManager>;

  /**
   * Updates the list of plugins.
   */
  public function RefreshPluginsList():Void;

  // /**
  //  * Loads all plug-ins
  //  *
  //  * @param	LoadingPhase	Which loading phase we're loading plug-in modules from.  Only modules that are configured to be
  //  *							loaded at the specified loading phase will be loaded during this call.
  //  */
  // public function LoadModulesForEnabledPlugins( const ELoadingPhase::Type LoadingPhase ):Bool;

  /**
   * Get the localization paths for all enabled plugins.
   *
   * @param	OutLocResPaths	Array to populate with the localization paths for all enabled plugins.
   */
  public function GetLocalizationPathsForEnabledPlugins( OutLocResPaths:Const<PRef<TArray<FString>>> ):Void;

  /**
   * Sets the delegate to call to register a new content mount point.  This is used internally by the plug-in manager system
   * and should not be called by you.  This is registered at application startup by FPackageName code in CoreUObject.
   *
   * @param	Delegate	The delegate to that will be called when plug-in manager needs to register a mount point
   */
  public function SetRegisterMountPointDelegate(Delegate:Const<PRef<FRegisterMountPointDelegate>>):Void;

  /**
   * Checks if all the required plug-ins are available. If not, will present an error dialog the first time a plug-in is loaded or this function is called.
   *
   * @returns true if all the required plug-ins are available.
   */
  public function AreRequiredPluginsAvailable():Bool;

  /**
   * Checks whether modules for the enabled plug-ins are up to date.
   *
   * @param OutIncompatibleNames	Array to receive a list of incompatible module names.
   * @returns true if the enabled plug-in modules are up to date.
   */
  public function CheckModuleCompatibility( OutIncompatibleModules:PRef<TArray<FString>> ):Bool;

  /**
   * Finds information for an enabled plugin.
   *
   * @return	 Pointer to the plugin's information, or nullptr.
   */
  public function FindPlugin(Name:Const<PRef<FString>>):TSharedPtr<IPlugin>;

  /**
   * Gets an array of all the enabled plugins.
   *
   * @return	Array of the enabled plugins.
   */
  public function GetEnabledPlugins():TArray<TSharedRef<IPlugin>>;

  /**
   * Gets an array of all the discovered plugins.
   *
   * @return	Array of the discovered plugins.
   */
  public function GetDiscoveredPlugins():TArray<TSharedRef<IPlugin>>;

  /**
   * Gets status about all currently known plug-ins.
   *
   * @return	 Array of plug-in status objects.
   */
  public function QueryStatusForAllPlugins():TArray<FPluginStatus>;

  /**
   * Stores the specified path, utilizing it in future search passes when
   * searching for available plugins. Optionally refreshes the manager after
   * the new path has been added.
   *
   * @param  ExtraDiscoveryPath	The path you want searched for additional plugins.
   * @param  bRefresh				Signals the function to refresh the plugin database after the new path has been added
   */
  public function AddPluginSearchPath(ExtraDiscoveryPath:Const<PRef<FString>>, bRefresh:Bool):Void;

  /**
   * Gets an array of plugins that loaded their own content pak file
   */
  public function GetPluginsWithPakFile():TArray<TSharedRef<IPlugin>>;

  // /**
  //  * Event signature for being notified that a new plugin has been mounted
  //  */
  // DECLARE_EVENT_OneParam(IPluginManager, FNewPluginMountedEvent, IPlugin&);
  //
  // /**
  //  * Gets an array of plugins that loaded their own content pak file
  //  */
  // public function& OnNewPluginMounted():FNewPluginMountedEvent;

  /**
   * Marks a newly created plugin as enabled, mounts its content and tries to load its modules
   */
  public function MountNewlyCreatedPlugin(PluginName:Const<PRef<FString>>):Void;
}

/** Delegate type for mounting content paths.  Used internally by FPackageName code. */
@:glueCppIncludes("Interfaces/IPluginManager.h")
@:uname("IPluginManager.FRegisterMountPointDelegate")
typedef FRegisterMountPointDelegate = unreal.Delegate<FRegisterMountPointDelegate, Const<PRef<FString>>->Const<PRef<FString>>->Void>;


