package unreal.umg;

import unreal.moviescene.EMovieScenePlayerStatus;
import unreal.slatecore.*;
import unreal.umg.*;

@:glueCppIncludes("UserWidget.h", "Animation/UMGSequencePlayer.h")
extern class UUMGSequencePlayer_Extra {

	public function GetAnimation() : UWidgetAnimation;

	public function Play(StartAtTime:Float32, InNumLoopsToPlay:Int32, InPlayMode:EUMGSequencePlayMode, InPlaybackSpeed:Float32) : Void;

	public function PlayTo(StartAtTime:Float32, EndAtTime:Float32, InNumLoopsToPlay:Int32, InPlayMode:EUMGSequencePlayMode, InPlaybackSpeed:Float32) : Void;

	public function Pause() : Void;

	public function Stop() : Void;

	#if proletariat
	public function Skip() : Void;
	#end

	public function Reverse() : Void;

	public function SetNumLoopsToPlay(InNumLoopsToPlay:Int32) : Void;

	public function SetPlaybackSpeed(PlaybackSpeed:Float32) : Void;

	public function GetPlaybackStatus() : EMovieScenePlayerStatus;

	public function IsPlayingForward() : Bool;
}
