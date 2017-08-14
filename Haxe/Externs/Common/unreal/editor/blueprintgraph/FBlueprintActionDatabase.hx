package unreal.editor.blueprintgraph;

@:glueCppIncludes("BlueprintActionDatabase.h")
@:umodule("BlueprintGraph", "Kismet")
@:noCopy
@:uextern extern class FBlueprintActionDatabase {
  static function Get():PRef<FBlueprintActionDatabase>;

  /**
   * Populates the action database from scratch. Loops over every known class
   * and records a set of node-spawners associated with each.
   */
  function RefreshAll():Void;

  /**
   * Populates the action database with all level script actions from all active editor worlds.
   */
  function RefreshWorlds():Void;

  /**
   * Finds the database entry for the specified class and wipes it,
   * repopulating it with a fresh set of associated node-spawners.
   *
   * @param  Class	The class entry you want rebuilt.
   */
  function RefreshClassActions(Class:Const<UClass>):Void;

  /**
   * Finds the database entry for the specified asset and wipes it,
   * repopulating it with a fresh set of associated node-spawners.
   *
   * @param  AssetObject	The asset entry you want rebuilt.
   */
  function RefreshAssetActions(AssetObject:Const<UObject>):Void;

  /**
   * Updates all component related actions
   */
  function RefreshComponentActions():Void;

  /**
   * Finds the database entry for the specified class and wipes it. The entry
   * won't be rebuilt, unless RefreshAssetActions() is explicitly called after.
   *
   * @param  AssetObject
   * @return True if an entry was found and removed.
   */
  function ClearAssetActions(AssetObject:Const<UObject>):Bool;

  /**
   * Finds the database entry for the specified unloaded asset and wipes it.
   * The entry won't be rebuilt, unless RefreshAssetActions() is explicitly called after.
   *
   * @param ObjectPath	Object's path to lookup into the database
   */
  function ClearUnloadedAssetActions(ObjectPath:FName):Void;

  /**
   * Moves the unloaded asset actions from one location to another
   *
   * @param SourceObjectPath	The object path that the data can currently be found under
   * @param TargetObjectPath	The object path that the data should be moved to
   */
  function MoveUnloadedAssetActions(SourceObjectPath:FName, TargetObjectPath:FName):Void;
}
