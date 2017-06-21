using UnrealBuildTool;

/**
  This module only setups the HaxeRuntime project correctly as a game module.
  We need HaxeRuntime to be a game module instead of a plugin module since UE4 has some
  different behaviours with plugin code - for example, it does not recompile plugins unless
  the binaries are missing.
 **/
public class HaxeInit : BaseModuleRules {
#if (UE_OLDER_416)
  public HaxeInit(TargetInfo target) : base(target) {
  }
#else
  public HaxeInit(ReadOnlyTargetRules target) : base(target) {
  }
#endif
}
