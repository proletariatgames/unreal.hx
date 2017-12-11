package unreal;

extern class FAudioDevice_Extra {
	/**
	* Sets a sound class override in the given sound mix.
	*/
	function PushSoundMixModifier(SoundMix:USoundMix, bIsPassive:Bool, bIsRetrigger:Bool) : Void;

	/**
	* Sets a sound class override in the given sound mix.
	*/
	function PopSoundMixModifier(InSoundMix:USoundMix, bIsPassive:Bool) : Void;
}
