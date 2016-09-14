/**
  Allows a more fine-grained configuration of the haxe build module.
  All properties added here will be optional and not setting them will make UE4Haxe use
  the default settings
 **/
typedef HaxeModuleConfig = {
  /**
    Disables Haxe compilation entirely
    @default false
   **/
  ?disabled: Bool, /* = false */

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
    Tells which module should the glue code be compiled. This allows better iteration times, since
    small changes will only trigger a recompilation on the main module.
    Note that the `glueTargetModule`'s `Build.cs` / `Build.hx` descriptor should not derive from `HaxeModuleRules` -
    but a reference to this module should be included in the `PublicDependencyModuleNames` array
   **/
  ?glueTargetModule:String,

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
  ?debugger:Bool
}

@:enum abstract Dce(String) from String {
  var DceStd = 'std';
  var DceFull = 'full';
  var DceNo = 'no';
}
