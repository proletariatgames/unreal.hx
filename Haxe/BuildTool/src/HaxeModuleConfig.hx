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
    Adds extra static classpaths to be compiled
    Every .hx type in this folder will be compiled
   **/
  ?extraStaticClasspaths: Array<String>,

  /**
    Tells whether timing should be disabled
   **/
  ?disableTimers:Bool,

  /**
    Tells which module should the non-glue code be compiled. This allows better iteration times, since
    small changes will only trigger a recompilation on the `targetModule`.
    Note that the `targetModule`'s `Build.cs` / `Build.hx` descriptor should not derive from `HaxeModuleRules` -
    but a reference to this module should be included in the `PublicDependencyModuleNames` array
   **/
  ?targetModule:String,
}

@:enum abstract Dce(String) from String {
  var DceStd = 'std';
  var DceFull = 'full';
  var DceNo = 'no';
}
