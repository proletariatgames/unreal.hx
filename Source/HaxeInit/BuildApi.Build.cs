using System.Collections.Generic;
using System.Reflection;
using System.Diagnostics;
using System;
using System.IO;
using UnrealBuildTool;

public class BaseModuleRules : ModuleRules {
  private static Dictionary<string, bool> firstRunMap = new Dictionary<string, bool>();

// US_OLDER_416 is defined by Unreal.hx when `haxe init-plugin.hxml` is called
#if (UE_OLDER_416)
  public BaseModuleRules(TargetInfo target) {
    this.init();
    if (!isGeneratingProjectFiles()) {
      this.run();
    }
  }
#else
  public BaseModuleRules(ReadOnlyTargetRules target) : base(target) {
    this.init();
    if (!isGeneratingProjectFiles()) {
      this.run();
    }
  }
#endif

  static bool isGeneratingProjectFiles() {
    System.Type t = System.Type.GetType("UnrealBuildTool.ProjectFileGenerator");
    if (t != null) {
      FieldInfo f = t.GetField("bGenerateProjectFiles");
      if (f != null) {
        return (bool) f.GetValue(null);
      }
      PropertyInfo p = t.GetProperty("bGenerateProjectFiles");
      if (p != null) {
        return (bool) p.GetValue(null);
      }
    }
    return false;
  }

  virtual protected void init() {
  }

  virtual protected void run() {
    throw new NotImplementedException();
  }
}

/**
 * This is a helper that makes it easy to write build code that is compatible with
 * multiple different Unreal Engine versions. Subclassing this is optional
 **/
public class BaseTargetRules : TargetRules {
#if (UE_OLDER_416)
  public BaseTargetRules(TargetInfo target) {
    this.init(target);
  }

  public override void SetupBinaries(
      TargetInfo target,
      ref List<UEBuildBinaryConfiguration> OutBuildBinaryConfigurations,
      ref List<string> OutExtraModuleNames)
  {
    List<string> moduleNames = new List<string>();
    this.setupBinaries(moduleNames);
    foreach (string module in moduleNames) {
      OutExtraModuleNames.Add(module);
    }
  }
#else
  public BaseTargetRules(TargetInfo target) : base(target) {
    this.init(target);

    List<string> moduleNames = new List<string>();
    this.setupBinaries(moduleNames);
    foreach (string module in moduleNames) {
      ExtraModuleNames.Add(module);
    }
  }

#endif

  virtual protected void init(TargetInfo target) {
  }

  virtual protected void setupBinaries(List<string> moduleNames) {
  }
}

public class HaxeModuleRules : BaseModuleRules {
  /**
   * Set this to true if you'd like to manually manage the dependencies.
   * This is faster since Unreal doesn't have to rebuild every time
   **/
  public bool manualDependencies;
  public bool disabled;

#if (UE_OLDER_416)
  public HaxeModuleRules(TargetInfo target) : base(target) {
  }
#else
  public HaxeModuleRules(ReadOnlyTargetRules target) : base(target) {
  }
#endif

  protected bool forceNextRun(HaxeCompilationInfo info) {
    string modulePath = RulesCompiler.GetFileNameFromType(GetType());
    // we need to touch a Build/uproject file to make sure this function will get called every single compilation
    // otherwise, the dependencies won't be updated.
    // This means that setting manual dependencies on will make C++ compile slightly faster
    Log.TraceInformation("Touching " + modulePath);
    DateTime thisTime = DateTime.UtcNow;
    try {
      File.SetLastWriteTimeUtc(modulePath, thisTime);
      return true;
    }
    catch(Exception) {
      // finding uproject
      if (info != null && info.uprojectPath != null) {
        Log.TraceInformation("Touching " + modulePath + " failed. Touching " + info.uprojectPath);
        File.SetLastWriteTimeUtc(info.uprojectPath, thisTime);
        return true;
      }
    }
    return false;
  }

  override protected void run() {
    bool didTouch = this.forceNextRun(null);
    if (disabled) {
      Log.TraceInformation("Compiling without Haxe support");
    }

    if (!manualDependencies) {
      if (Target.Type != TargetType.Program) {
        this.PublicDependencyModuleNames.AddRange(new string[] {"Core","CoreUObject","Engine","InputCore","SlateCore"});
        if (Target.Type == TargetType.Editor) {
          this.PrivateDependencyModuleNames.Add("UnrealEd");
        }
      } else {
        this.PrivateDependencyModuleNames.Add("Core");
      }
    }

    HaxeCompilationInfo info = setupHaxeTarget(this);
    if (!didTouch) {
      didTouch = this.forceNextRun(info);
    }
    if (!manualDependencies) {
      string modulesPath = info.outputDir + "/Static/Built/Data/modules.txt";
      string curName = this.GetType().Name;
      if (!File.Exists(modulesPath)) {
        Log.TraceInformation("Could not find module definition at " + modulesPath);
      } else {
        foreach (string dep in File.ReadAllText(modulesPath).Trim().Split('\n')) {
          if (dep != curName) {
            this.PrivateDependencyModuleNames.Add(dep);
          }
        }
      }
    }
  }

  public static HaxeCompilationInfo setupHaxeTarget(ModuleRules rules) {
    rules.PrivateIncludePaths.Add(Path.Combine(rules.ModuleDirectory, "Generated/Private"));
    rules.PublicIncludePaths.Add(Path.Combine(rules.ModuleDirectory, "Generated"));
    rules.PublicIncludePaths.Add(Path.Combine(rules.ModuleDirectory, "Generated/Shared"));
    rules.PublicIncludePaths.Add(Path.Combine(rules.ModuleDirectory, "Generated/Public"));

    HaxeCompilationInfo info = new HaxeCompilationInfo(rules);
    rules.PublicAdditionalLibraries.Add(info.libPath);

    Log.TraceInformation("Using Haxe");
    rules.Definitions.Add("WITH_HAXE=1");
    rules.Definitions.Add("HXCPP_EXTERN_CLASS_ATTRIBUTES=");
    rules.Definitions.Add("MAY_EXPORT_SYMBOL=");

    BuildVersion version;
    if (BuildVersion.TryRead("../Build/Build.version", out version)) {
      rules.Definitions.Add("UE_VER=" + version.MajorVersion + version.MinorVersion);
    } else {
      Log.TraceInformation("Cannot read build.version");
    }

    switch (rules.Target.Platform) {
      case UnrealTargetPlatform.Win64:
      case UnrealTargetPlatform.Win32:
        rules.Definitions.Add("HX_WINDOWS");
        break;
      case UnrealTargetPlatform.Mac:
        rules.Definitions.Add("HX_MACOS");
        break;
      case UnrealTargetPlatform.Linux:
        rules.Definitions.Add("HX_LINUX");
        break;
      case UnrealTargetPlatform.Android:
        rules.Definitions.Add("HX_ANDROID");
        break;
      case UnrealTargetPlatform.IOS:
        rules.Definitions.Add("IPHONE");
        rules.Definitions.Add("IPHONEOS");
        break;
      case UnrealTargetPlatform.HTML5:
        rules.Definitions.Add("EMSCRIPTEN");
        break;
      default:
        break;
        // XboxOne, PS4
    }

    if (rules.Target.Platform == UnrealTargetPlatform.Mac && Directory.Exists("/usr/local/bin")) {
      string path = Environment.GetEnvironmentVariable("PATH");
      Environment.SetEnvironmentVariable("PATH", path + ":/usr/local/bin");
    }

    Log.TraceWarning("Calling Haxe");
    string haxeInitPath = RulesCompiler.GetFileNameFromType(typeof(HaxeInit));
    string pluginPath = Path.GetFullPath(haxeInitPath + "/../../..");
    string engineDir = Path.GetFullPath("..");

    string cserver = Environment.GetEnvironmentVariable("HAXE_COMPILATION_SERVER");
    if (cserver != null) {
      Environment.SetEnvironmentVariable("HAXE_COMPILATION_SERVER", null);
      Environment.SetEnvironmentVariable("HAXE_COMPILATION_SERVER_DEFER", cserver);
    }


    Process proc = new Process();
    proc.StartInfo.CreateNoWindow = true;
    proc.StartInfo.UseShellExecute = false;
    proc.StartInfo.FileName = "haxe";
    proc.StartInfo.Arguments = "--cwd \"" + pluginPath + "/Haxe/BuildTool\" compile-project.hxml -D \"EngineDir=" + engineDir + 
        "\" -D \"ProjectDir=" + info.gameDir + "\" -D \"TargetName=" + rules.Target.Name + "\" -D \"TargetPlatform=" + rules.Target.Platform + 
        "\" -D \"TargetConfiguration=" + rules.Target.Configuration + "\" -D \"TargetType=" + rules.Target.Type + "\" -D \"ProjectFile=" + info.uprojectPath +
        "\" -D \"PluginDir=" + pluginPath + "\"";
    proc.StartInfo.RedirectStandardOutput = true;
    proc.StartInfo.RedirectStandardError = true;
    proc.OutputDataReceived += (sender, args) => Log.TraceInformation(args.Data);
    proc.ErrorDataReceived += (sender, args) => Log.TraceError(args.Data);
    proc.Start();
    proc.BeginOutputReadLine();
    proc.BeginErrorReadLine();
    proc.WaitForExit();

    if (proc.ExitCode != 0) {
      Log.TraceError("Error: Haxe compilation failed");
      throw new Exception("Haxe compilation failed");
    }

      // "haxe --cwd \"$(PluginDir)/Haxe/BuildTool\" compile-project.hxml -D \"EngineDir=$(EngineDir)\" -D \"ProjectDir=$(ProjectDir)\" -D \"TargetName=$(TargetName)\" -D \"TargetPlatform=$(TargetPlatform)\" -D \"TargetConfiguration=$(TargetConfiguration)\" -D \"TargetType=$(TargetType)\" -D \"ProjectFile=$(ProjectFile)\" -D \"PluginDir=$(PluginDir)\""

    return info;
  }
}

public class HaxeCompilationInfo {
  public ModuleRules rules;

  public string name;
  public string gameDir;
  public string outputDir;
  public string libPath;
  public string uprojectPath;

  public HaxeCompilationInfo(ModuleRules rules) {
    this.rules = rules;
    this.init();
  }

  private void init() {
    this.name = rules.Target.Name;
    if (this.name.EndsWith("Editor")) {
      this.name = this.name.Substring(0, this.name.Length - "Editor".Length);
    }

    List<UProjectInfo> infos = UProjectInfo.FilterGameProjects(true, this.name);
    if (infos.Count == 0) {
      Log.TraceWarning("Could not find any code project with name " + this.name);
      infos = UProjectInfo.FilterGameProjects(true, null);
    }
    if (infos.Count == 0) {
      Log.TraceWarning("Could not find any code project");
      this.gameDir = Path.GetFullPath(rules.ModuleDirectory + "/../../");
    } else {
      this.gameDir = infos[0].Folder.ToString();
    }

    string libName = null;
    switch (rules.Target.Platform) {
      case UnrealTargetPlatform.Win64:
      case UnrealTargetPlatform.Win32:
      case UnrealTargetPlatform.XboxOne:
        libName = "haxeRuntime.lib";
        break;
      default:
        libName = "libhaxeruntime.a";
        break;
    }

    this.outputDir = this.gameDir + "/Intermediate/Haxe/" + this.name + "-" + this.rules.Target.Platform + "-" + this.rules.Target.Configuration;
    if (this.rules.Target.Type == TargetType.Editor) {
      this.outputDir += "-Editor";
    }

    foreach (string file in Directory.GetFileSystemEntries(this.gameDir)) {
      if (file.ToLowerInvariant().EndsWith(".uproject")) {
        this.uprojectPath = file;
        break;
      }
    }

    this.libPath = this.outputDir + "/" + libName;
  }
}
