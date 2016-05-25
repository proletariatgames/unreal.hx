package unreal.editor;
import unreal.*;

@:glueCppIncludes('Editor.h')
@:uextern extern class FEditorDelegates {
  public static var OnAssetPreImport:FOnAssetPreImport;
  public static var OnAssetPostImport:FOnAssetPostImport;

  /** Called when the CurrentLevel is switched to a new level.  Note that this event won't be fired for temporary
    changes to the current level, such as when copying/pasting actors. */
  public static var NewCurrentLevel:FSimpleMulticastDelegate;

  /** Called when properties of an actor have changed */
  public static var ActorPropertiesChange:FSimpleMulticastDelegate;

  /** Called when the editor needs to be refreshed */
  public static var RefreshEditor:FSimpleMulticastDelegate;

  /** called when all browsers need to be refreshed */
  public static var RefreshAllBrowsers:FSimpleMulticastDelegate;

  /** called when the level browser need to be refreshed */
  // public static var RefreshLevelBrowser:FSimpleMulticastDelegate;

  /** called when the layer browser need to be refreshed */
  public static var RefreshLayerBrowser:FSimpleMulticastDelegate;

  /** called when the primitive stats browser need to be refreshed */
  public static var RefreshPrimitiveStatsBrowser:FSimpleMulticastDelegate;

  /** Called when an action is performed which interacts with the content browser;
   *  load any selected assets which aren't already loaded */
  public static var LoadSelectedAssetsIfNeeded:FSimpleMulticastDelegate;

  /** Called when load errors are about to be displayed */
  public static var DisplayLoadErrors:FSimpleMulticastDelegate;
}

@:glueCppIncludes('Editor.h')
@:uname('FEditorDelegates.FOnAssetPreImport')
typedef FOnAssetPreImport = MulticastDelegate<FOnAssetPreImport, UFactory->UClass->UObject->Const<PRef<FName>>->Const<TCharStar>->Void>;

@:glueCppIncludes('Editor.h')
@:uname('FEditorDelegates.FOnAssetPostImport')
typedef FOnAssetPostImport = MulticastDelegate<FOnAssetPostImport, UFactory->UObject->Void>;
