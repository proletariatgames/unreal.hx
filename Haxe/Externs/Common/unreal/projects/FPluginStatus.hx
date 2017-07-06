package unreal.projects;

@:glueCppIncludes("Interfaces/IPluginManager.h")
@:umodule("Projects")
@:noCopy @:noEquals
@:uextern extern class FPluginStatus {
  /** The name of this plug-in. */
  var Name:FString;

  /** Path to plug-in directory on disk. */
  var PluginDirectory:FString;

  /** True if plug-in is currently enabled. */
  var bIsEnabled:Bool;

  // /** Where the plugin was loaded from */
  // var LoadedFrom:EPluginLoadedFrom;

  // /** The plugin descriptor */
  // var Descriptor:FPluginDescriptor;
}
