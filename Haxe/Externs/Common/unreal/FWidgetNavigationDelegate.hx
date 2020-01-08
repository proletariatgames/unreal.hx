package unreal;

#if proletariat
@:glueCppIncludes("UMG.h")
@:umodule("UMG")
typedef FWidgetNavigationDelegate = unreal.Delegate<FWidgetNavigationDelegate, unreal.slatecore.EUINavigation->unreal.umg.UWidget>;

#end