package unreal.projects;

@:glueCppIncludes("Interfaces/IPluginManager.h")
@:umodule("Projects")
@:noCopy @:noEquals
@:uextern extern class IPlugin {
  /**
   * Gets the plugin name.
   *
   * @return Name of the plugin.
   */
  public function GetName():FString;

  /**
   * Get a path to the plugin's descriptor
   *
   * @return Path to the plugin's descriptor.
   */
  public function GetDescriptorFileName():FString;

  /**
   * Get a path to the plugin's directory.
   *
   * @return Path to the plugin's base directory.
   */
  public function GetBaseDir():FString;

  /**
   * Get a path to the plugin's content directory.
   *
   * @return Path to the plugin's content directory.
   */
  public function GetContentDir():FString;

  /**
   * Get the virtual root path for assets.
   *
   * @return The mounted root path for assets in this plugin's content folder; typically /PluginName/.
   */
  public function GetMountedAssetPath():FString;

  /**
   * Determines if the plugin is enabled.
   *
   * @return True if the plugin is currently enabled.
   */
  public function IsEnabled():Bool;

  /**
   * Determines if the plugin can contain content.
   *
   * @return True if the plugin can contain content.
   */
  public function CanContainContent():Bool;

  // /**
  //  * Returns the plugin's location
  //  *
  //  * @return Where the plugin was loaded from
  //  */
  // public function GetLoadedFrom():EPluginLoadedFrom;

  // /**
  //  * Gets the plugin's descriptor
  //  *
  //  * @return Reference to the plugin's descriptor
  //  */
  // public function GetDescriptor():Const<PRef<FPluginDescriptor>>;

  // /**
  //  * Updates the plugin's descriptor
  //  *
  //  * @param NewDescriptor The new plugin descriptor
  //  * @param OutFailReason The error message if the plugin's descriptor could not be updated
  //  * @return True if the descriptor was updated, false otherwise.
  //  */
  // public function UpdateDescriptor(NewDescriptor:Const<PRef<FPluginDescriptor>>, OutFailReason:PRef<FText>):Bool;
}
