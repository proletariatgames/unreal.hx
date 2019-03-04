/**
  Allows a more fine-grained configuration of the haxe build module.
  All properties added here will be optional and not setting them will make UE4Haxe use
  the default settings
 **/
typedef UhxBuildConfig = {
  /**
    Disables Haxe compilation entirely
    @default false
   **/
  ?disabled: Bool, /* = false */

  ?verbose: Bool,

  ?uhtVerbose: Bool,

  /**
    Force bake all externs
   **/
  ?forceBakeExterns:Bool,

  /**
    Overrides DCE config
   **/
  ?dce:Dce, /* can be 'full' or 'no' */

  /**
    Adds compilation arguments to the build hxml.
    This follows the hxml convention, with each argument representing a line in the hxml.
    Empty lines and comments are supported
   **/
  ?extraCompileArgs:Array<String>,

  /**
    Adds compilation arguments to the cppia build hxml.
    This follows the hxml convention, with each argument representing a line in the hxml.
    Empty lines and comments are supported
   **/
  ?extraCppiaCompileArgs:Array<String>,

  /**
    Adds extra static classpaths to be compiled
    Every .hx type in this folder will be compiled
   **/
  ?extraStaticClasspaths: Array<String>,

  /**
    Adds extra script classpaths to be compiled
    Every .hx type in this folder will be compiled
   **/
  ?extraScriptClasspaths: Array<String>,

  /**
    Tells whether timing should be enabled
   **/
  ?enableTimers:Bool,

  /**
    Tells whether macro timing should be enabled
   **/
  ?enableMacroTimers:Bool,

  /**
    If true, will compile everything as static
    Be aware that even if this is false, cppia will only be compiled if this is an editor build,
    and if DCE is either null or set to 'no'
   **/
  ?disableCppia:Bool /* = false */,

  /**
    Forces all Static folder be compiled as a script (for cppia). This only has an effect if cppia
    is enabled
   **/
  ?noStatic:Bool /* = false */,

  /**
    Forces some modules to be excluded from cppia build
   **/
  ?cppiaModuleExclude:Array<String>,

  /**
    forces the Haxe compilation to include -debug, even in shipping mode
   **/
  ?forceDebug:Bool,

  /**
    forces the Haxe compilation to compile with the debug symbols, even in shipping
  **/
  ?debugSymbols:Bool,

  /**
    Do not compile with UObject support (defines -D UHX_NO_UOBJECT)
   **/
  ?disableUObject:Bool,

  /**
    Compile with hxcpp debugger support
   **/
  ?debugger:Bool,

  /**
    If no engine version was found, use this to set the engine version
    If the engine version was found, this is ignored
   **/
  ?engineVersion:String,

  /**
    Set this to true to disable dynamically created uclasses (only relevant when cppia is enabled)
   **/
  ?noDynamicObjects:Bool,

  /**
    Automatically generate the externs for this project's types
   **/
  ?generateExterns:Bool,

  /**
    Disable glue unity builds
   **/
  ?noGlueUnityBuild:Bool,

  /**
    The port which the compilation server must use
   **/
  ?compilationServer:Null<Int>,

  /**
    Set a custom haxe path that is not on PATH
  **/
  ?haxeInstallPath:Null<String>,

  /**
    Set a custom neko path that is not on PATH
  **/
  ?nekoInstallPath:Null<String>,

  /**
    Set a custom HAXELIB_PATH
  **/
  ?haxelibPath:Null<String>,

  /**
    Skip the UhxBuild native compilation and instead interpret using Haxe's interpreter
  **/
  ?interp:Bool,

  /**
    Skips the extern baker step entirely
  **/
  ?skipBake:Bool,

  /**
    Tells the maximum amount of processes to use
  **/
  ?numProcessors:Int,

  /**
    Disables the extern baker check if the source file of each target file has changed, while the original still exists
  **/
  ?disableBakerSourceCheck:Bool,

  /**
    Enables the use of pre-build hooks to build Unreal.hx. Note that this should only be used if you're in an Unreal Engine
    version that contains the pre-build steps fixes
  **/
  ?hooksEnabled:Bool,

  /**
    Sets the main module (whose source will be at `Source/{mainModule}`)
  **/
  ?mainModule:String,

  /**
    Ignores the UHXERR error messages when recompiling cppia. This only has effect
    if compiling through `gen-build-script.hxml`
  **/
  ?ignoreStaticErrors:Bool,

  /**
    Sets UhxBuild to test mode, which allows assertions to be passed onto it
  **/
  ?testMode:Bool,

  /**
    Ignores the static/cppia build checks and always build them
  **/
  ?alwaysBuild:BuildKind,

  //#region vscode
  /**
    Skips the vscode project generation
  **/
  ?skipVscodeGeneration:Bool,

  /**
    When generating the vscode build configuration, setting this to a map path will set the default server map when debugging or
    launching through vscode
  **/
  ?serverDefaultMap:String,

  /**
    Adds extra launch configurations to the game. Adds a few extra parameters that can be used, like ${engineDir}, ${projectDir},
    ${projectFile}, etc
  **/
  ?extraLaunchConfigurations:Array<Dynamic>,

  /**
    Adds extra excludes from the vscode workspace. Adds the same extra parameters as `extraLaunchConfigurations`
  **/
  ?extraExcludes:Array<String>,

  /**
    If the vscode project is also being generated by Unreal, this can define extra directories that should be included.
    This will look for exclude definitions that end with the substrings defined and remove them from the list
  **/
  ?extraEndsWithIncludes:Array<String>,

  /**
    Defines extra fields to be merged with the main vscode settings.json. Adds the same extra parameters as `extraLaunchConfigurations`
  **/
  ?extraVscodeSettings:Array<Dynamic>,

  /**
    Defines extra vscode tasks
  **/
  ?extraVscodeTasks:Array<Dynamic>,

  //#endregion vscode

}

@:enum abstract BuildKind(String) from String {
  /**
    Neither cppia nor static builds
  **/
  var None = "none";

  /**
    Represents both cppia and static builds
  **/
  var All = "all";

  /**
    Represents a cppia build
  **/
  var Cppia = "cppia";

  /**
    Represents a static build
  **/
  var Static = "static";


  inline public function hasCppia()
  {
    return this == All || this == Cppia;
  }


  inline public function hasStatic()
  {
    return this == All || this == Static;
  }
}

@:enum abstract Dce(String) from String {
  var DceStd = 'std';
  var DceFull = 'full';
  var DceNo = 'no';
}