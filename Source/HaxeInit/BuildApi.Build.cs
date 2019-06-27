using Tools.DotNETCommon;
using System.Collections.Generic;
using System.Reflection;
using System.Diagnostics;
using System;
using System.IO;
using UnrealBuildTool;

public class BaseModuleRules : ModuleRules {
  private static Dictionary<string, bool> firstRunMap = new Dictionary<string, bool>();

  public BaseModuleRules(ReadOnlyTargetRules target) : base(target) {
    this.internalInit(target);
    this.init();
    this.run();
  }

  public static System.Type getType(string name) {
    System.Type ret = System.Type.GetType(name);
    if (ret == null) {
			foreach (Assembly t2 in AppDomain.CurrentDomain.GetAssemblies()) {
        ret = t2.GetType(name);
        if (ret != null) {
          break;
        }
      }
    }
    return ret;
  }

  virtual protected void init() {
  }

  virtual protected void internalInit(ReadOnlyTargetRules target) {
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
  public BaseTargetRules(TargetInfo target) : base(target) {
    this.init(target);

    List<string> moduleNames = new List<string>();
    this.setupBinaries(moduleNames);
    foreach (string module in moduleNames) {
      ExtraModuleNames.Add(module);
    }
  }

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

  /**
    This used to be optional, as PreBuildSteps were being used to compile Haxe without the need
    of Build.cs. However, there are multiple issues with PreBuildSteps currently (see UE-47634)
    so this is needed. You can still disable this, but make sure to compile Haxe yourself before
    if you choose to do so.
   **/
  public bool forceHaxeCompilation;

  public HaxeConfigOptions options = new HaxeConfigOptions();

  public HaxeModuleRules(ReadOnlyTargetRules target) : base(target) {
    PCHUsage = ModuleRules.PCHUsageMode.UseExplicitOrSharedPCHs;
  }

  override protected void internalInit(ReadOnlyTargetRules target) {
    this.forceHaxeCompilation = true;
  }

  static bool isSkipBuild() {
    foreach (string arg in Environment.GetCommandLineArgs()) {
      if (String.Compare(arg, "-SkipBuild", StringComparison.OrdinalIgnoreCase) == 0) {
        return true;
      }
    }
    return false;
  }

  static bool isGeneratingProjectFiles() {
    System.Type t = getType("UnrealBuildTool.ProjectFileGenerator");
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

  static void resetCachedDirectory(string path) {
    System.Type t = getType("UnrealBuildTool.DirectoryItem");
    if (t == null) {
      Log.TraceWarning("Cannot find DirectoryItem");
      return;
    }
    MethodInfo m = t.GetMethod("GetItemByPath");
    if (m == null) {
      Log.TraceWarning("Cannot find GetItemByPath");
      return;
    }
    object dirItem = m.Invoke(null, new object[]{path});
    if (dirItem == null) {
      Log.TraceWarning("Cannot gather dirItem for path " + path);
      return;
    }
    MethodInfo reset = t.GetMethod("ResetCachedInfo");
    if (reset == null) {
      Log.TraceWarning("Cannot find ResetCachedInfo");
      return;
    }
    reset.Invoke(dirItem, new object[]{});
  }

  override protected void run() {
    if (disabled) {
      Log.TraceInformation("Compiling without Haxe support");
    }

    if (!manualDependencies) {
      if (Target.Type != TargetType.Program) {
        // these are all dependencies on an empty unreal.hx project -
        // most of them are because of types that reference other modules
        // without DCE enabled, we can't get past this
        this.PublicDependencyModuleNames.AddRange(new string[] {
          "Core",
          "CoreUObject",
          "Engine",
          "InputCore",
          "SlateCore"
         });
        if (Target.Type == TargetType.Editor) {
          this.PrivateDependencyModuleNames.Add("UnrealEd");
        }
      } else {
        this.PrivateDependencyModuleNames.AddRange(new string[] {
          "Core",
          "Projects", // for IPluginManager
        });
        // for RequiredProgramMainCPPInclude.h
        string engineDir = Path.GetFullPath("..");
        PublicIncludePaths.AddRange(
          new string[] {
            engineDir + "/Source/Runtime/Launch/Public",
            engineDir + "/Source/Runtime/Launch/Private",
          }
        );
      }
    }

    HaxeCompilationInfo info = setupHaxeTarget(this, this.forceHaxeCompilation, this.options);
    if (!manualDependencies) {
      string modulesPath = info.outputDir + "/Data/modules.txt";
      string curName = this.GetType().Name;
      if (!File.Exists(modulesPath)) {
        Log.TraceInformation("Could not find module definition at " + modulesPath);
      } else {
        foreach (string dep in File.ReadAllText(modulesPath).Trim().Split('\n')) {
          if (dep != curName && dep != "") {
            this.PrivateDependencyModuleNames.Add(dep);
          }
        }
      }
    }
    string definesPath = info.outputDir + "/Data/defines.txt";
    if (!File.Exists(definesPath)) {
      Log.TraceInformation("Could not find defines file at " + definesPath);
    } else {
      foreach (string def in File.ReadAllText(definesPath).Trim().Split('\n')) {
        if (def != "") {
          this.PublicDefinitions.Add(def);
        }
      }
    }

    foreach (string path in PublicIncludePaths) {
      if (Path.IsPathRooted(path) && !Directory.Exists(path)) {
        Directory.CreateDirectory(path);
      }
    }
    foreach (string path in PrivateIncludePaths) {
      if (Path.IsPathRooted(path) && !Directory.Exists(path)) {
        Directory.CreateDirectory(path);
      }
    }
  }

  private static bool addedGenerateFilesHook = false;

  public static HaxeCompilationInfo setupHaxeTarget(ModuleRules rules, bool forceHaxeCompilation, HaxeConfigOptions options) {
    rules.PublicIncludePaths.Add(Path.Combine(rules.ModuleDirectory, "Generated"));
    rules.PublicIncludePaths.Add(Path.Combine(rules.ModuleDirectory, "Generated/Public"));
    rules.PublicIncludePaths.Add(Path.Combine(rules.ModuleDirectory, "Generated/TemplateExport"));
    rules.PublicIncludePaths.Add(Path.Combine(rules.ModuleDirectory, "Generated/Shared"));

    HaxeCompilationInfo info = new HaxeCompilationInfo(rules);
    rules.PublicAdditionalLibraries.Add(info.libPath);
    rules.PublicIncludePaths.Add(Path.Combine(info.outputDir, "Generated/Public"));
    rules.PublicIncludePaths.Add(Path.Combine(info.outputDir, "Generated/Shared"));
    rules.PrivateIncludePaths.Add(Path.Combine(info.outputDir, "Generated/Private"));
    rules.PublicIncludePaths.Add(Path.Combine(info.outputDir, "Template/Shared"));
    rules.PublicIncludePaths.Add(Path.Combine(info.outputDir, "Template/Public"));
    rules.PrivateIncludePaths.Add(Path.Combine(info.outputDir, "Template/Private"));

    Log.TraceInformation("BuildApi.Build.cs: Using Haxe");
    rules.PublicDefinitions.Add("WITH_HAXE=1");
    rules.PublicDefinitions.Add("HXCPP_EXTERN_CLASS_ATTRIBUTES=");
    rules.PublicDefinitions.Add("MAY_EXPORT_SYMBOL=");

    if (options != null && options.haxeInstallPath != null) {
      string haxePath = System.IO.Path.Combine(info.gameDir, options.haxeInstallPath);
      Environment.SetEnvironmentVariable("HAXEPATH", haxePath);
      Environment.SetEnvironmentVariable("PATH", haxePath + System.IO.Path.PathSeparator + Environment.GetEnvironmentVariable("PATH"));
    }
    if (options != null && options.haxelibPath != null) {
      string libPath = System.IO.Path.Combine(info.gameDir, options.haxelibPath);
      Environment.SetEnvironmentVariable("HAXELIB_PATH", libPath);
    }
    if (options != null && options.noDynamicObjects) {
      rules.PublicDefinitions.Add("NO_DYNAMIC_UCLASS=1");
    } else {
      rules.PublicDefinitions.Add("NO_DYNAMIC_UCLASS=0");
    }


    #if UE_4_22_OR_LATER
    ReadOnlyBuildVersion version = rules.Target.Version;
    #else
    BuildVersion version = BuildVersion.ReadDefault();
    #endif
    rules.PublicDefinitions.Add("UE_VER=" + version.MajorVersion + version.MinorVersion);

    switch (rules.Target.Platform) {
      case UnrealTargetPlatform.Win64:
      case UnrealTargetPlatform.Win32:
        rules.PublicDefinitions.Add("HX_WINDOWS");
        break;
      case UnrealTargetPlatform.Mac:
        rules.PublicDefinitions.Add("HX_MACOS");
        break;
      case UnrealTargetPlatform.Linux:
        rules.PublicDefinitions.Add("HX_LINUX");
        break;
      case UnrealTargetPlatform.Android:
        rules.PublicDefinitions.Add("HX_ANDROID");
        break;
      case UnrealTargetPlatform.IOS:
        rules.PublicDefinitions.Add("IPHONE");
        rules.PublicDefinitions.Add("IPHONEOS");
        break;
      case UnrealTargetPlatform.HTML5:
        rules.PublicDefinitions.Add("EMSCRIPTEN");
        break;
      default:
        break;
        // XboxOne, PS4
    }

    bool generatingProjectFiles = isGeneratingProjectFiles();
    bool skipBuild = isSkipBuild();
    if (forceHaxeCompilation) {
      if (!skipBuild && !generatingProjectFiles) {
        System.Diagnostics.Stopwatch sw = new System.Diagnostics.Stopwatch();
        sw.Start();
        callHaxe(rules, info, options, true, null);
        Log.TraceInformation("Haxe call executed in " + sw.Elapsed);
        #if UE_4_22_OR_LATER
        resetCachedDirectory(rules.ModuleDirectory);
        #endif
        // make sure the Build.cs file is called every time
        forceNextRun(rules, info);
      } else {
        if (skipBuild) {
          Log.TraceInformation("-SkipBuild detected: Skipping Haxe build");
        }
      }

      if (generatingProjectFiles && !addedGenerateFilesHook && rules.Target.Type != TargetType.Program) {
        addedGenerateFilesHook = true;
        AppDomain.CurrentDomain.ProcessExit += delegate(object sender, EventArgs e) {
          callHaxe(rules, info, options, false, "GenerateProjectFiles");
        };
      }
    } else if (skipBuild) {
      Environment.SetEnvironmentVariable("UE_SKIP_BUILD", "1");
    }

    rules.ExternalDependencies.Add(info.pluginPath + "/Source/HaxeInit/BuildApi.Build.cs");
    if (Directory.Exists(info.gameDir + "/Intermediate/Haxe")) {
      foreach (string dir in Directory.EnumerateDirectories(info.gameDir + "/Intermediate/Haxe")) {
        if (File.Exists(dir + "/Data/modules.txt")) {
          rules.ExternalDependencies.Add(dir + "/Data/modules.txt");
        }
      }
    }
    rules.ExternalDependencies.Add(info.outputDir + "/Data/modules.txt");
    rules.ExternalDependencies.Add(info.outputDir + "/Data/defines.txt");

    return info;
  }

  protected static void forceNextRun(ModuleRules rules, HaxeCompilationInfo info) {
    // take off this option once UE-47634 is fixed
    rules.ExternalDependencies.Add(info.pluginPath + "/Inexistent path to force BuildApi.Build.cs to compile Haxe");
  }

  public static void callHaxe(ModuleRules rules, HaxeCompilationInfo info, HaxeConfigOptions options, bool throwOnError, string command) {
    Log.TraceInformation("Calling Haxe");
    string engineDir = Path.GetFullPath("..");

    string cserver = Environment.GetEnvironmentVariable("HAXE_COMPILATION_SERVER");
    if (cserver != null) {
      Environment.SetEnvironmentVariable("HAXE_COMPILATION_SERVER", null);
      Environment.SetEnvironmentVariable("HAXE_COMPILATION_SERVER_DEFER", cserver);
    }
    Environment.SetEnvironmentVariable("COMPILING_WITH_BUILD_CS", "1");

    Process proc = new Process();
    proc.StartInfo.CreateNoWindow = true;
    proc.StartInfo.UseShellExecute = false;
    proc.StartInfo.FileName = "haxe";
    proc.StartInfo.Arguments = "--cwd \"" + info.pluginPath + "/Haxe/BuildTool\" compile-project.hxml " + HaxeConfigOptions.escapeString("EngineDir", engineDir) +
        " " + HaxeConfigOptions.escapeString("ProjectDir", info.gameDir) + " " + HaxeConfigOptions.escapeString("TargetName", rules.Target.Name) + " " + HaxeConfigOptions.escapeString("TargetPlatform", rules.Target.Platform + "") +
        " " + HaxeConfigOptions.escapeString("TargetConfiguration", rules.Target.Configuration + "") + " " + HaxeConfigOptions.escapeString("TargetType", rules.Target.Type + "") + " " + HaxeConfigOptions.escapeString("ProjectFile", info.uprojectPath) +
        " " + HaxeConfigOptions.escapeString("PluginDir", info.pluginPath) + " " + HaxeConfigOptions.escapeString("RootDir", info.rootDir) + " -D UE_BUILD_CS" + (options == null ? "" : options.getOptionsString());
    if (command != null) {
      proc.StartInfo.Arguments += " -D \"Command=" + command + "\"";
    }
    Log.TraceInformation("Calling the build tool with arguments " + proc.StartInfo.Arguments);

    proc.StartInfo.RedirectStandardOutput = true;
    proc.StartInfo.RedirectStandardError = true;
    proc.OutputDataReceived += (sender, args) => { if (args != null && args.Data != null) Log.TraceInformation(args.Data); };
    proc.ErrorDataReceived += (sender, args) => { if (args != null && args.Data != null) Log.TraceInformation(args.Data); };
    proc.Start();
    proc.BeginOutputReadLine();
    proc.BeginErrorReadLine();
    proc.WaitForExit();

    if (proc.ExitCode != 0) {
      Log.TraceError("Error: Haxe compilation failed");
      if (throwOnError) {
        throw new Exception("Haxe compilation failed");
      }
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
  public string pluginPath;
  public string rootDir;

  public HaxeCompilationInfo(ModuleRules rules) {
    this.rules = rules;
    this.init();
  }

  public static bool IsCodeProject(FileReference ProjectFile)
  {
    DirectoryReference ProjectDirectory = ProjectFile.Directory;

    // Check if it's a code project
    DirectoryReference SourceFolder = DirectoryReference.Combine(ProjectDirectory, "Source");
    DirectoryReference IntermediateSourceFolder = DirectoryReference.Combine(ProjectDirectory, "Intermediate", "Source");
    return DirectoryReference.Exists(SourceFolder) || DirectoryReference.Exists(IntermediateSourceFolder);
  }

  static List<FileReference> FilterGameProjects(bool bOnlyCodeProjects, string GameNameFilter)
  {
    List<FileReference> Filtered = new List<FileReference>();
    #if UE_4_22_OR_LATER
    var ProjectFiles = NativeProjects.EnumerateProjectFiles();
    #else
    var ProjectFiles = UProjectInfo.AllProjectFiles;
    #endif

    foreach (FileReference ProjectFile in ProjectFiles)
    {
      if (!bOnlyCodeProjects || IsCodeProject(ProjectFile))
      {
        if (string.IsNullOrEmpty(GameNameFilter) || ProjectFile.GetFileNameWithoutAnyExtensions() == GameNameFilter)
        {
          Filtered.Add(ProjectFile);
        }
      }
    }
    return Filtered;
  }

  static string getRootDir() {
    System.Type t = BaseModuleRules.getType("UnrealBuildTool.UnrealBuildTool");
    if (t != null) {
      FieldInfo f = t.GetField("RootDirectory");
      if (f != null) {
        return f.GetValue(null) + "";
      }
      PropertyInfo p = t.GetProperty("RootDirectory");
      if (p != null) {
        return p.GetValue(null) + "";
      }
    }
    return null;
  }

  private void init() {
    this.name = rules.Target.Name;
    if (this.name.EndsWith("Editor")) {
      this.name = this.name.Substring(0, this.name.Length - "Editor".Length);
    } else if (this.name.EndsWith("Server")) {
      this.name = this.name.Substring(0, this.name.Length - "Server".Length);
    }

    List<FileReference> projectFiles = FilterGameProjects(true, this.name);
    if (projectFiles.Count == 0) {
      Log.TraceWarning("Could not find any code project with name " + this.name);
      projectFiles = FilterGameProjects(true, null);
    }
    if (projectFiles.Count == 0) {
      Log.TraceWarning("Could not find any code project");
      this.gameDir = Path.GetFullPath(rules.ModuleDirectory + "/../../");
    } else {
      this.gameDir = projectFiles[0].Directory.FullName;
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
    string haxeInitPath = RulesCompiler.GetFileNameFromType(typeof(HaxeInit));
    this.pluginPath = Path.GetFullPath(haxeInitPath + "/../../..");
    this.rootDir = getRootDir();
  }
}

public class HaxeConfigOptions {
  /**
    If using a custom Haxe path, specify it here
  **/
  public string haxeInstallPath;

  /**
    If using a custom haxelib path, specify it here
  **/
  public string haxelibPath;

  /**
    Whether to disable dynamic cppia uobjects. In case this is true, any cppia change that results in a
    ufunction/uproperty being changed/added must be recompiled
  **/
  public bool noDynamicObjects;

  public HaxeConfigOptions() {
  }

  public static string escapeString(string name, string s) {
    if (s == null) {
      return "";
    }
    if (!s.Contains(" "))
    {
      return "-D " + name + "=" + s;
    }
    // take off any trailing \
    while (s[s.Length - 1] == '\\')
    {
      s = s.Substring(0, s.Length - 1);
    }

    // Windows doesn't need to escape \
    if (!(System.Environment.OSVersion.Platform + "").StartsWith("Win"))
    {
      s = s.Replace("\\", "\\\\");
    }
    return " -D \"" + name + "=" + s.Replace("\"","\\\"").Replace("\n","\\n") + "\"";
  }

  private static string escapeBool(string name, bool b) {
    if (!b) {
      return "";
    }
    return " -D \"" + name;
  }

  public string getOptionsString() {
    return escapeString("haxeInstallPath", haxeInstallPath) +
           escapeString("haxelibPath", haxelibPath) +
           escapeBool("noDynamicObjects", noDynamicObjects);
  }
}