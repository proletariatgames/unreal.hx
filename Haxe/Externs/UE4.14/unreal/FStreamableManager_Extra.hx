package unreal;

#if (UE_VER < 4.16)
@:glueCppIncludes("Engine.h")
extern class FStreamableManager_Extra {

  @:uname('.ctor')
  public static function create() : FStreamableManager;
  @:uname('new')
  public static function createNew() : POwnedPtr<FStreamableManager>;

  public function SynchronousLoad(TargetsToStream : Const<FStringAssetReference>) : UObject;

  public function RequestAsyncLoad(TargetsToStream : Const<TArray<FStringAssetReference>>, Callback:Void -> Void, Priority:Int32) : Void;

  @:uname('RequestAsyncLoad')
  public function RequestAsyncLoad_Single(TargetsToStream : Const<FStringAssetReference>, Callback:Void -> Void, Priority:Int32) : Void;

}

#end
