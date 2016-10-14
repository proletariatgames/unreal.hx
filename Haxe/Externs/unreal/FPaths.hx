package unreal;

@:glueCppIncludes('Misc/Paths.h')
@:uextern extern class FPaths {
  /**
   * Should the "saved" directory structures be rooted in the user dir or relative to the "engine/game"
   */
  public static function ShouldSaveToUserDir():Bool;

  /**
   * Returns the directory the application was launched from (useful for commandline utilities)
   */
  public static function LaunchDir():FString;

  /**
   * Returns the base directory of the "core" engine that can be shared across
   * several games or across games & mods. Shaders and base localization files
   * e.g. reside in the engine directory.
   *
   * @return engine directory
   */
  public static function EngineDir():FString;

  /**
   * Returns the root directory for user-specific engine files. Always writable.
   *
   * @return root user directory
   */
  public static function EngineUserDir():FString;

  /**
   * Returns the root directory for user-specific engine files which can be shared between versions. Always writable.
   *
   * @return root user directory
   */
  public static function EngineVersionAgnosticUserDir():FString;

  /**
   * Returns the content directory of the "core" engine that can be shared across
   * several games or across games & mods.
   *
   * @return engine content directory
   */
  public static function EngineContentDir():FString;

  /**
   * Returns the directory the root configuration files are located.
   *
   * @return root config directory
   */
  public static function EngineConfigDir():FString;

  /**
   * Returns the intermediate directory of the engine
   *
   * @return content directory
   */
  public static function EngineIntermediateDir():FString;

  /**
   * Returns the saved directory of the engine
   *
   * @return Saved directory.
   */
  public static function EngineSavedDir():FString;

  /**
   * Returns the plugins directory of the engine
   *
   * @return Plugins directory.
   */
  public static function EnginePluginsDir():FString;

  /**
   * Returns the root directory of the engine directory tree
   *
   * @return Root directory.
   */
  public static function RootDir():FString;

  /**
   * Returns the base directory of the current game by looking at FApp::GetGameName().
   * This is usually a subdirectory of the installation
   * root directory and can be overridden on the command line to allow self
   * contained mod support.
   *
   * @return base directory
   */
  public static function GameDir():FString;

  /**
   * Returns the root directory for user-specific game files.
   *
   * @return game user directory
   */
  public static function GameUserDir():FString;

  /**
   * Returns the content directory of the current game by looking at FApp::GetGameName().
   *
   * @return content directory
   */
  public static function GameContentDir():FString;

  /**
   * Returns the directory the root configuration files are located.
   *
   * @return root config directory
   */
  public static function GameConfigDir():FString;

  /**
   * Returns the saved directory of the current game by looking at FApp::GetGameName().
   *
   * @return saved directory
   */
  public static function GameSavedDir():FString;

  /**
   * Returns the intermediate directory of the current game by looking at FApp::GetGameName().
   *
   * @return intermediate directory
   */
  public static function GameIntermediateDir():FString;

  /**
   * Returns the plugins directory of the current game by looking at FApp::GetGameName().
   *
   * @return plugins directory
   */
  public static function GamePluginsDir():FString;

  /**
   * Returns the directory the engine uses to look for the source leaf ini files. This
   * can't be an .ini variable for obvious reasons.
   *
   * @return source config directory
   */
  public static function SourceConfigDir():FString;

  /**
   * Returns the directory the engine saves generated config files.
   *
   * @return config directory
   */
  public static function GeneratedConfigDir():FString;

  /**
   * Returns the directory the engine stores sandbox output
   *
   * @return sandbox directory
   */
  public static function SandboxesDir():FString;

  /**
   * Returns the directory the engine uses to output profiling files.
   *
   * @return log directory
   */
  public static function ProfilingDir():FString;

  /**
   * Returns the directory the engine uses to output screenshot files.
   *
   * @return screenshot directory
   */
  public static function ScreenShotDir():FString;

  /**
   * Returns the directory the engine uses to output BugIt files.
   *
   * @return screenshot directory
   */
  public static function BugItDir():FString;

  /**
   * Returns the directory the engine uses to output user requested video capture files.
   *
   * @return Video capture directory
   */
  public static function VideoCaptureDir():FString;

  /**
   * Returns the directory the engine uses to output logs. This currently can't
   * be an .ini setting as the game starts logging before it can read from .ini
   * files.
   *
   * @return log directory
   */
  public static function GameLogDir():FString;

  /**
   * @return The directory for automation save files
   */
  public static function AutomationDir():FString;

  /**
   * @return The directory for automation save files that are meant to be deleted every run
   */
  public static function AutomationTransientDir():FString;

  /**
   * @return The directory for automation log files.
   */
  public static function AutomationLogDir():FString;

  /**
   * @return The directory for local files used in cloud emulation or support
   */
  public static function CloudDir():FString;

  /**
   * @return The directory that contains subfolders for developer-specific content
   */
  public static function GameDevelopersDir():FString;

  /**
   * @return The directory that contains developer-specific content for the current user
   */
  public static function GameUserDeveloperDir():FString;

  /**
   * @return The directory for temp files used for diff'ing
   */
  public static function DiffDir():FString;

  /**
   * Returns a list of engine-specific localization paths
   */
  public static function GetEngineLocalizationPaths():Const<PRef<TArray<FString>>>;

  /**
   * Returns a list of editor-specific localization paths
   */
  public static function GetEditorLocalizationPaths():Const<PRef<TArray<FString>>>;

  /**
   * Returns a list of property name localization paths
   */
  public static function GetPropertyNameLocalizationPaths():Const<PRef<TArray<FString>>>;

  /**
   * Returns a list of tool tip localization paths
   */
  public static function GetToolTipLocalizationPaths():Const<PRef<TArray<FString>>>;

  /**
   * Returns a list of game-specific localization paths
   */
  public static function GetGameLocalizationPaths():Const<PRef<TArray<FString>>>;

  /**
   * Returns the saved directory that is not game specific. This is usually the same as
   * EngineSavedDir().
   *
   * @return saved directory
   */
  public static function GameAgnosticSavedDir():FString;

  /**
   * @return The directory where engine source code files are kept
   */
  public static function EngineSourceDir():FString;

  /**
   * @return The directory where game source code files are kept
   */
  public static function GameSourceDir():FString;

  /**
   * @return The directory where feature packs are kept
   */
  public static function FeaturePackDir():FString;

  /**
   * Checks whether the path to the project file, if any, is set.
   *
   * @return true if the path is set, false otherwise.
   */
  public static function IsProjectFilePathSet():Bool;

  /**
   * Gets the path to the project file.
   *
   * @return Project file path.
   */
  public static function GetProjectFilePath():Const<PRef<FString>>;


  /**
   * Converts a relative path name to a fully qualified name relative to the process BaseDir().
   */
  public static function ConvertRelativePathToFull(inPath:Const<PRef<FString>>):FString;

  /**
   * Combine file paths
   */
  @:uname("Combine")
  public static function CombineTwo(path1:TCharStar, path2:TCharStar):FString;

  /**
   * Combine file paths
   */
  @:uname("Combine")
  public static function CombineThree(path1:TCharStar, path2:TCharStar, path3:TCharStar):FString;

  /**
   * Combine file paths
   */
  @:uname("Combine")
  public static function CombineFour(path1:TCharStar, path2:TCharStar, path3:TCharStar, part4:TCharStar):FString;

  /**
   * Combine file paths
   */
  @:uname("Combine")
  public static function CombineFive(path1:TCharStar, path2:TCharStar, path3:TCharStar, part4:TCharStar, part5:TCharStar):FString;

  /** @return true if this file was found, false otherwise */
  public static function FileExists(InPath:Const<PRef<FString>>):Bool;

  /** @return true if this directory was found, false otherwise */
  public static function DirectoryExists(InPath:Const<PRef<FString>>):Bool;


}
