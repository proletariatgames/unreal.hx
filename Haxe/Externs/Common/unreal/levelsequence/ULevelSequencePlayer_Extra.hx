package unreal.levelsequence;

extern class ULevelSequencePlayer_Extra
{

	/**
	 * Create a new level sequence player.
	 *
	 * @param WorldContextObject Context object from which to retrieve a UWorld.
	 * @param LevelSequence The level sequence to play.
	 * @param Settings The desired playback settings
	 * @param OutActor The level sequence actor created to play this sequence.
	 */
	public static function CreateLevelSequencePlayer(
		WorldContextObject:UObject,
		LevelSequence:ULevelSequence,
		Settings:unreal.moviescene.FMovieSceneSequencePlaybackSettings,
		OutActor:unreal.Ref<ALevelSequenceActor>
	):ULevelSequencePlayer;

}
