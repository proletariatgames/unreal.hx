using StringTools;

@:structInit class UhxBuildData {
  public var engineDir(default, null):String;
  public var projectDir(default, null):String;
  public var targetName(default, null):String;
  public var targetPlatform(default, null):TargetPlatform;
  public var targetConfiguration(default, null):TargetConfiguration;
  public var targetType(default, null):TargetType;
  public var projectFile(default, null):String;
  public var pluginDir(default, null):String;
  public var rootDir(default, null):String;

  public var skipBake(default, null):Bool;
  public var cppiaRecompile(default, null):Bool;
  public var ueEditorRecompile(default, null):Bool;
  public var ueEditorCompile(default, null):Bool;

  public static function fromArgs(args:haxe.DynamicAccess<Dynamic>) {
    var ret:UhxBuildData = {
        engineDir: args['engineDir'],
        projectDir: args['projectDir'],
        targetName: args['targetName'],
        targetPlatform: args['targetPlatform'],
        targetConfiguration: args['targetConfiguration'],
        targetType: args['targetType'],
        projectFile: args['projectFile'],
        pluginDir: args['pluginDir'],
        rootDir: args['rootDir'],

        skipBake: args['skipBake'],
        cppiaRecompile: args['cppiaRecompile'],
        ueEditorRecompile: args['ueEditorRecompile'],
        ueEditorCompile: args['ueEditorCompile'],
    };
    return ret;
  }
}