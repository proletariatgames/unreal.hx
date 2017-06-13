import unrealbuildtool.*;
import cs.system.collections.generic.List_1 as Lst;

@:nativeChildren
class BaseTargetRules extends TargetRules {
  public function new(target:TargetInfo) {
#if (UE_VER <= 4.14)
    super();
#else
    super(target);
#end
    init();

#if (UE_VER > 4.14)
    var moduleNames = [];
    this.setupBinaries(moduleNames);
    for (v in moduleNames) {
      this.ExtraModuleNames.Add(v);
    }
#end
  }

#if (UE_VER <= 4.14)
  override function SetupBinaries(target:TargetInfo, _:cs.Ref<List<UEBuildBinaryConfiguration>>, outExtraModuleNames:cs.Ref<List<String>>) {
    var moduleNames = [];
    this.setupBinaries(moduleNames);
    for (v in moduleNames) {
      outExtraModuleNames.Add(v);
    }
  }
#end

  function init() {
    // override me
  }

  function setupBinaries(moduleNames:Array<String>) {
    // override me
  }
}
