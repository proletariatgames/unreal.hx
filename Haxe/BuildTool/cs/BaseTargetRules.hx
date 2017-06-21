import unrealbuildtool.*;
import cs.system.collections.generic.List_1 as List;

@:nativeGen
@:nativeChildren
extern class BaseTargetRules extends TargetRules {
  public function new(target:TargetInfo);

  private function init(target:TargetInfo):Void;
  private function setupBinaries(moduleNames:List<String>):Void;
}
