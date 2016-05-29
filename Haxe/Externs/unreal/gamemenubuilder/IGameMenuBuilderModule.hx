package unreal.gamemenubuilder;

@:glueCppIncludes("GameMenuBuilderModule.h")
@:umodule("GameMenuBuilder")
@:uextern extern class IGameMenuBuilderModule {
  public static function Get():PRef<IGameMenuBuilderModule>;
}
