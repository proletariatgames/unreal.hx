package unreal;
import unreal.*;

@:glueCppIncludes('UObject/UObjectGlobals.h')
@:uextern extern class FCoreUObjectDelegates {
#if WITH_EDITOR

  // Called when an asset is loaded
  public static var OnAssetLoaded:FOnAssetLoaded;
#end

  // Called before garbage collection
  public static var PreGarbageCollect:FSimpleMulticastDelegate;

  // Called after garbage collection
  public static var PostGarbageCollect:FSimpleMulticastDelegate;

  public static var PreLoadMap:FSimpleMulticastDelegate;

  public static var PostLoadMap:FSimpleMulticastDelegate;
}

#if WITH_EDITOR

@:glueCppIncludes('UObject/UObjectGlobals.h')
@:uname('FCoreUObjectDelegates.FOnAssetLoaded')
typedef FOnAssetLoaded = MulticastDelegate<FOnAssetLoaded, UObject->Void>;
#end
