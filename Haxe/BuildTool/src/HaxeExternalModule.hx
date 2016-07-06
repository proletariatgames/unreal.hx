import unrealbuildtool.*;

/**
  This module is here in order to make the dependency on the hxcpp static library private
  Otherwise, any module that depends on our own module will statically link to the hxcpp library
 **/
class HaxeExternalModule extends BaseModuleRules {

  override private function run(target:TargetInfo, firstRun:Bool)
  {
    this.Type = External;
    this.PublicAdditionalLibraries.Add(HaxeModuleRules.getLibLocation(null, target));
  }
}

