package unreal;

@:glueCppIncludes("Engine.h")
extern class FStreamableManager_Extra {

  @:uname('new')
  public static function create() : PHaxeCreated<FStreamableManager>;

  public function RequestAsyncLoad(TargetsToStream : Const<TArray<FStringAssetReference>>, Callback:Void -> Void, Priority:Int32) : Void;

  @:uname('RequestAsyncLoad')
  public function RequestAsyncLoad_Single(TargetsToStream : Const<FStringAssetReference>, Callback:Void -> Void, Priority:Int32) : Void;

}
