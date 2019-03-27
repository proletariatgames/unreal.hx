package unreal;
import unreal.*;

@:glueCppIncludes('UObject/UObjectGlobals.h')
@:uname('FCoreUObjectDelegates.FPreLoadMapDelegate')
typedef FPreLoadMapDelegate = MulticastDelegate<FPreLoadMapDelegate, Const<PRef<FString>>->Void>;

@:glueCppIncludes('UObject/UObjectGlobals.h')
@:uname('FCoreUObjectDelegates.FPostLoadMapDelegate')
typedef FPostLoadMapDelegate = MulticastDelegate<FPostLoadMapDelegate, UWorld->Void>;

@:glueCppIncludes('UObject/UObjectGlobals.h')
@:uextern extern class FCoreUObjectDelegates {
#if WITH_EDITOR

  // Called when an asset is loaded
  public static var OnAssetLoaded:FCoreDelegateOnAssetLoaded;
#end

#if (UE_VER < 4.19)
  // Called before garbage collection
  public static var PreGarbageCollect:FSimpleMulticastDelegate;

  // Called after garbage collection
  public static var PostGarbageCollect:FSimpleMulticastDelegate;

  public static var PostLoadMap:FSimpleMulticastDelegate;
#else
  public static function GetPreGarbageCollectDelegate():PRef<FSimpleMulticastDelegate>;

  public static function GetPostGarbageCollect():PRef<FSimpleMulticastDelegate>;
#end

#if (UE_VER >= 4.21)
  public static var PreGarbageCollectConditionalBeginDestroy:FSimpleMulticastDelegate;

  public static var PostGarbageCollectConditionalBeginDestroy:FSimpleMulticastDelegate;
#end

  public static var PreLoadMap:FPreLoadMapDelegate;

  public static var PostLoadMapWithWorld:FPostLoadMapDelegate;
}

#if WITH_EDITOR

@:glueCppIncludes('UObject/UObjectGlobals.h')
@:uname('FCoreUObjectDelegates.FOnAssetLoaded')
typedef FCoreDelegateOnAssetLoaded = MulticastDelegate<FCoreDelegateOnAssetLoaded, UObject->Void>;
#end
