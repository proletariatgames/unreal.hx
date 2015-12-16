package unreal.editor;
import unreal.*;

@:glueCppIncludes('Editor.h')
@:uextern extern class FEditorDelegates {
  public static var OnAssetPreImport:FOnAssetPreImport;
  public static var OnAssetPostImport:FOnAssetPostImport;
}

@:glueCppIncludes('Editor.h')
@:uname('FEditorDelegates.FOnAssetPreImport')
@:uextern extern class FOnAssetPreImport extends MulticastDelegate<UFactory->UClass->UObject->Const<PRef<FName>>->Const<TCharStar>->Void> {}

@:glueCppIncludes('Editor.h')
@:uname('FEditorDelegates.FOnAssetPostImport')
@:uextern extern class FOnAssetPostImport extends MulticastDelegate<UFactory->UObject->Void> {}
