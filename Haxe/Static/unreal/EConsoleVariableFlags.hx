package unreal;

@:uextern
@:glueCppIncludes("IConsoleManager.h")
@:umodule("HAL")
@:enum abstract EConsoleVariableFlags(Int) from Int to Int {
  /**
   * Default, no flags are set, the value is set by the constructor
   */
  var ECVF_Default = 0x0;
  /**
   * Console variables marked with this flag behave differently in a final release build.
   * Then they are are hidden in the console and cannot be changed by the user.
   */
  var ECVF_Cheat = 0x1;
  /**
   * Console variables cannot be changed by the user (from console).
   * Changing from C++ or ini is still possible.
   */
  var ECVF_ReadOnly = 0x4;
  /**
   * UnregisterConsoleObject() was called on this one.
   * If the variable is registered again with the same type this object is reactivated. This is good for DLL unloading.
   */
  var ECVF_Unregistered = 0x8;
  /**
   * This flag is set by the ini loading code when the variable wasn't registered yet.
   * Once the variable is registered later the value is copied over and the variable is destructed.
   */
  var ECVF_CreatedFromIni = 0x10;
  /**
   * Maintains another shadow copy and updates the copy with render thread commands to maintain proper ordering.
   * Could be extended for more/other thread.
   * Note: On console variable references it assumes the reference is accessed on the render thread only
   * (Don't use in any other thread or better don't use references to avoid the potential pitfall).
   */
  var ECVF_RenderThreadSafe = 0x20;

  /* ApplyCVarSettingsGroupFromIni will complain if this wasn't set, should not be combined with ECVF_Cheat */
  var ECVF_Scalability = 0x40;

  /* those cvars control other cvars with the flag ECVF_Scalability, names should start with "sg." */
  var ECVF_ScalabilityGroup = 0x80;

  // ------------------------------------------------

  /* to get some history of where the last value was set by ( useful for track down why a cvar is in a specific state */
  var ECVF_SetByMask =        0xff000000;

  // the ECVF_SetBy are sorted in override order (weak to strong), the value is not serialized, it only affects it's override behavior when calling Set()

  // lowest priority (default after console variable creation)
  var ECVF_SetByConstructor =     0x00000000;
  // from Scalability.ini (lower priority than game settings so it's easier to override partially)
  var ECVF_SetByScalability =     0x01000000;
  // (in game UI or from file)
  var ECVF_SetByGameSetting =     0x02000000;
  // project settings (editor UI or from file, higher priority than game setting to allow to enforce some setting fro this project)
  var ECVF_SetByProjectSetting =    0x03000000;
  // per device setting (e.g. specific iOS device, higher priority than per project to do device specific settings)
  var ECVF_SetByDeviceProfile =   0x04000000;
  // per project setting (ini file e.g. Engine.ini or Game.ini)
  var ECVF_SetBySystemSettingsIni = 0x05000000;
  // consolevariables.ini (for multiple projects)
  var ECVF_SetByConsoleVariablesIni = 0x06000000;
  // a minus command e.g. -VSync (very high priority to enforce the setting for the application)
  var ECVF_SetByCommandline =     0x07000000;
  // least useful, likely a hack, maybe better to find the correct SetBy...
  var ECVF_SetByCode =        0x08000000;
  // editor UI or console in game or editor
  var ECVF_SetByConsole =       0x09000000;

  // ------------------------------------------------

  @:extern inline private function t() {
    return this;
  }

  @:op(A | B) @:extern inline public function add(flag:EConsoleVariableFlags):EConsoleVariableFlags {
    return this | flag.t();
  }

  @:op(A & B) @:extern inline public function and(mask:EConsoleVariableFlags):EConsoleVariableFlags {
    return this & mask.t();
  }
}
