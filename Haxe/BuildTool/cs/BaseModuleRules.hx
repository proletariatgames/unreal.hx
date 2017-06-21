import unrealbuildtool.*;

@:nativeGen
@:nativeChildren
extern class BaseModuleRules extends ModuleRules {
#if (UE_VER <= 4.14)
  public function new(target:TargetInfo) {}
#else
  public function new(target:ReadOnlyTargetRules) {}
#end

  private function init():Void;
  private function run():Void;
}
