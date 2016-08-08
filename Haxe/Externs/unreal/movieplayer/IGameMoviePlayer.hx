package unreal.movieplayer;

@:umodule("MoviePlayer")
@:glueCppIncludes("MoviePlayer.h")
@:noCopy @:noEquals @:noClass @:uextern extern class IGameMoviePlayer {

  @:global
  public static function GetMoviePlayer() : TSharedPtr<IGameMoviePlayer>;

  @:global
  public static function IsMoviePlayerEnabled() : Bool;

  /** Passes in a slate loading screen UI, movie paths, and any additional data. */
  public function SetupLoadingScreen(InLoadingScreenAttributes:Const<PRef<FLoadingScreenAttributes>>) : Void;
  
  /** 
   * Starts playing the movie given the last FLoadingScreenAttributes passed in
   * @return true of a movie started playing.
   */
  public function PlayMovie() : Bool;

  /** 
   * Stops the currently playing movie, if any.
   */
  public function StopMovie() : Void;
  
  /** Call only on the game thread. Spins this thread until the movie stops. */
  public function WaitForMovieToFinish() : Void;

  /** Called from to check if the game thread is finished loading. */
  @:thisConst
  public function IsLoadingFinished() : Bool;

  /** True if the loading screen is currently running (i.e. PlayMovie but no WaitForMovieToFinish has been called). */
  @:thisConst
  public function IsMovieCurrentlyPlaying() : Bool;

}
