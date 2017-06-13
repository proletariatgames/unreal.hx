package unreal.movieplayer;

@:umodule("MoviePlayer")
@:glueCppIncludes("MoviePlayer.h")
@:uextern extern class FLoadingScreenAttributes {
   @:uname('.ctor') public static function create():FLoadingScreenAttributes;

   /** The widget to be displayed on top of the movie or simply standalone if there is no movie. */
   public var WidgetLoadingScreen : TSharedPtr<SWidget>;

   /** The movie paths local to the game's Content/Movies/ directory we will play. */
   public var MoviePaths : TArray<FString>;

   /** The minimum time that a loading screen should be opened for. */
   public var MinimumLoadingScreenDisplayTime : Float32;

   /** If true, the loading screen will disappear as soon as all movies are played and loading is done. */
   public var bAutoCompleteWhenLoadingCompletes : Bool;

   /** If true, movies can be skipped by clicking the loading screen as long as loading is done. */
   public var bMoviesAreSkippable : Bool;

   /** If true, movie playback continues until Stop is called. */
   public var bWaitForManualStop : Bool;

   /** True if there is either a standalone widget or any movie paths or both. */
   @:thisConst
   public function IsValid() : Bool;

   /** Creates a simple test loading screen widget. */
   public static function NewTestLoadingScreenWidget() : TSharedRef<SWidget>;
}
