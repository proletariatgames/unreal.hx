package uhx.build;

@:structInit class UhxBuildData {
  public var engineDir(default, null):String;
  public var projectDir(default, null):String;
  public var targetName(default, null):String;
  public var targetPlatform(default, null):TargetPlatform;
  public var targetConfiguration(default, null):TargetConfiguration;
  public var targetType(default, null):TargetType;
  public var projectFile(default, null):String;
  public var pluginDir(default, null):String;
}
