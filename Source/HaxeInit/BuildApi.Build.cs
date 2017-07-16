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

  override protected void run() {
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
    if (!manualDependencies) {
      string modulesPath = info.outputDir + "/Data/modules.txt";
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
    rules.PublicIncludePaths.Add(Path.Combine(rules.ModuleDirectory, "Generated/TemplateExport"));

    HaxeCompilationInfo info = new HaxeCompilationInfo(rules);
    rules.PublicAdditionalLibraries.Add(info.libPath);
    rules.PublicIncludePaths.Add(Path.Combine(info.outputDir, "Generated/Public"));
    rules.PrivateIncludePaths.Add(Path.Combine(info.outputDir, "Generated/Private"));
    rules.PublicIncludePaths.Add(Path.Combine(info.outputDir, "Template/Shared"));
    rules.PublicIncludePaths.Add(Path.Combine(info.outputDir, "Template/Public"));
    rules.PrivateIncludePaths.Add(Path.Combine(info.outputDir, "Template/Private"));

    Log.TraceInformation("Using Haxe");
    rules.Definitions.Add("WITH_HAXE=1");
    rules.Definitions.Add("HXCPP_EXTERN_CLASS_ATTRIBUTES=");
    rules.Definitions.Add("MAY_EXPORT_SYMBOL=");

    BuildVersion version;
    if (BuildVersion.TryRead("../Build/Build.version", out version)) {
      rules.Definitions.Add("UE_VER=" + version.MajorVersion + version.MinorVersion);
    } else {
      Log.TraceError("Cannot read build.version");
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

    string skipTxt = info.gameDir + "/Intermediate/Haxe/skip.txt";
    string skip = File.Exists(skipTxt) ? File.ReadAllText(skipTxt).Trim() : "0";
    if (skip != "1") {
      callHaxe(rules, info);
    } else if (skip == "fail") {
      File.WriteAllText(skipTxt, "0");
      throw new Exception("Editor Haxe compilation failed");
    } else {
      if (File.Exists(skipTxt)) {
        File.WriteAllText(skipTxt, "0");
      }
    }

    return info;
  }

  // This is not called at the moment - as Haxe is getting called as a PreBuildScript
  public static void callHaxe(ModuleRules rules, HaxeCompilationInfo info) {
    Log.TraceInformation("Calling Haxe");

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
    Log.TraceInformation("Calling the build tool with arguments " + proc.StartInfo.Arguments);
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
  }
}

public class HaxeCompilationInfo {
  public ModuleRules rules;

  public string name;
  public string gameDir;
  public string outputDir;
  public string buildName;
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

    string platform = this.rules.Target.Platform + "";
    switch (rules.Target.Platform) {
      case UnrealTargetPlatform.Win64:
      case UnrealTargetPlatform.Win32:
        platform = "Win";
        break;
      default:
        libName = "libhaxeruntime.a";
        break;
    }
    string config = this.rules.Target.Configuration + "";
    if (config == "DebugGame") {
      config = "Development";
    }
    this.buildName = this.name + "-" + platform + "-" + config + "-" + this.rules.Target.Type;
    this.outputDir = this.gameDir + "/Intermediate/Haxe/" + this.buildName;

    foreach (string file in Directory.GetFileSystemEntries(this.gameDir)) {
      if (file.ToLowerInvariant().EndsWith(".uproject")) {
        this.uprojectPath = file;
        break;
      }
    }

    this.libPath = this.outputDir + "/" + libName;
  }
}
