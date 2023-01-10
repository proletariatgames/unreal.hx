package unreal;

#if PLATFORM_SWITCH
@:glueCppIncludes("Switch/SwitchPlatformMisc.h")
@:noEquals @:noCopy @:uextern extern class FSwitchPlatformMisc {
  #if proletariat
  static function ShowErrorDialog(category:Int32, number:Int32):Void;
  static function IsNifmAvailable():Bool;
  static function ConditionalStartNifm():Bool;
  static function SetCPUBoostModeEnabled(bEnabled:Bool):Void;
  #end
}
#end
