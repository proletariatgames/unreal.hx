package unreal;
import unreal.*;

@:glueCppIncludes('UObject/UObjectGlobals.h')
@:uname('FCoreUObjectDelegates.FPreLoadMapDelegate')
typedef FPreLoadMapDelegate = MulticastDelegate<FPreLoadMapDelegate, Const<PRef<FString>>->Void>;

@:glueCppIncludes('UObject/UObjectGlobals.h')
@:uextern extern class FCoreUObjectDelegates {
#if WITH_EDITOR

  // Called when an asset is loaded
  public static var OnAssetLoaded:FCoreDelegateOnAssetLoaded;
#end

  // Called before garbage collection
  public static var PreGarbageCollect:FSimpleMulticastDelegate;

  // Called after garbage collection
  public static var PostGarbageCollect:FSimpleMulticastDelegate;

  public static var PreLoadMap:FPreLoadMapDelegate;

  public static var PostLoadMap:FSimpleMulticastDelegate;
}

#if WITH_EDITOR

@:glueCppIncludes('UObject/UObjectGlobals.h')
@:uname('FCoreUObjectDelegates.FOnAssetLoaded')
typedef FCoreDelegateOnAssetLoaded = MulticastDelegate<FCoreDelegateOnAssetLoaded, UObject->Void>;
#end
