package unreal;

extern class FAudioDevice_Extra {
	/**
	 * Push a SoundMix onto the Audio Device's list.
	 *
	 * @param SoundMix The SoundMix to push.
	 * @param bIsPassive Whether this is a passive push from a playing sound.
	 */
	function PushSoundMixModifier(SoundMix:USoundMix, ?bIsPassive:Bool=false, ?bIsRetrigger:Bool=false) : Void;

	/**
	 * Pop a SoundMix from the Audio Device's list.
	 *
	 * @param SoundMix The SoundMix to pop.
	 * @param bIsPassive Whether this is a passive pop from a sound finishing.
	 */
	function PopSoundMixModifier(InSoundMix:USoundMix, ?bIsPassive:Bool=false) : Void;
}
