import unrealbuildtool.*;
import cs.system.io.Path;

class HaxeProgramRules extends HaxeModuleRules {
  public function new(target) {
    super(target);
  }

  override private function getHaxeDir() {
    return Path.GetFullPath('$modulePath/../Haxe');
  }
}
