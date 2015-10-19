package unreal;

@:glueCppIncludes("Engine.h")
@:uextern extern class APlayerCameraManager extends AActor {
  var DefaultFOV:Float32;
  var ViewPitchMin:Float32;
  var ViewPitchMax:Float32;
  //TODO: Can't access because protected?
  //var bAlwaysApplyModifiers:Int32 = 1;
  function UpdateCamera(DeltaTime:Float32) : Void;
}
