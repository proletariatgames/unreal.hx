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
    forces the Haxe compilation to not include -debug. Set explicitly to `false` to force debug mode,
    even in Shipping
   **/
  ?noDebug:Bool,

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
}

@:enum abstract Dce(String) from String {
  var DceStd = 'std';
  var DceFull = 'full';
  var DceNo = 'no';
}