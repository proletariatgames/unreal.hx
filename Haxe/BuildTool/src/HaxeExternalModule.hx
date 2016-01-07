import unrealbuildtool.*;

class HaxeExternalModule extends BaseModuleRules {

  override private function run(target:TargetInfo, firstRun:Bool)
  {
    this.Type = External;
    var libName = switch(target.Platform) {
      case WinRT | Win64 | Win32 | XboxOne: // TODO: see if XboxOne follows windows' path names
        'haxeruntime.lib';
      case _:
        'libhaxeruntime.a';
    };
    var outputDir = gameDir + '/Intermediate/Haxe/${target.Platform}-${target.Configuration}';
    if (UEBuildConfiguration.bBuildEditor) {
      outputDir += '-Editor';
    }

    var outputStatic = '$outputDir/$libName';
    this.PublicAdditionalLibraries.Add(outputStatic);
  }
}

