package unreal;

@:glueCppIncludes("AudioDevice.h")
@:uextern extern class FAudioDevice extends unreal.FExec {
  var SoundClasses:TMap<USoundClass,FSoundClassProperties>;
}
