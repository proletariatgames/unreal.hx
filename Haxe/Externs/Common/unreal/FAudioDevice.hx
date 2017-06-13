package unreal;

@:glueCppIncludes("AudioDevice.h")
@:noCreate @:noCopy
@:uextern extern class FAudioDevice extends unreal.FExec {
  /**
   * Sets a sound class override in the given sound mix.
   */
  function SetSoundMixClassOverride(InSoundMix:USoundMix, InSoundClass:USoundClass, Volume:Float32, Pitch:Float32, FadeInTime:Float32, bApplyToChildren:Bool) : Void;
}
