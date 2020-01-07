package unreal;

@:glueCppIncludes("Public/UnrealClient.h")
@:uname("FViewport.FOnViewportResized")
typedef FOnViewportResized = unreal.MulticastDelegate<FOnViewportResized, PPtr<FViewport>->UInt32->Void>;
