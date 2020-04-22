package unreal.significancemanager;

@:umodule("Significancemanager")
@:glueCppIncludes("SignificanceManager.h")
@:uextern extern class USignificanceManager_Extra {

  /* Returns the significance manager for the specified World. */
  static function Get(World:UWorld):USignificanceManager;
  
  /* Overridable function to update the managed objects' significance. */
  function Update(Viewpoints:unreal.TArray<unreal.Const<unreal.FTransform>>):Void;

}
