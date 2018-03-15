package unreal.landscape;

extern class ALandscapeProxy_Extra {
  function UpdateGrass(Cameras:Const<PRef<TArray<FVector>>>, bForceSync:Bool = false):Void;
}