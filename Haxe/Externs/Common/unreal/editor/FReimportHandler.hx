package unreal.editor;

@:glueCppIncludes("EditorReimportHandler.h")
@:uextern extern class FReimportHandler {
  @:uname(".ctor") public static function create():FReimportHandler;
  @:uname("new") public static function createNew():POwnedPtr<FReimportHandler>;

  function CanReimport(obj:UObject, outFilenames:PRef<TArray<FString>>):Bool;
  function SetReimportPaths(obk:UObject, newReimportPaths:Const<PRef<TArray<FString>>>):Void;
}
