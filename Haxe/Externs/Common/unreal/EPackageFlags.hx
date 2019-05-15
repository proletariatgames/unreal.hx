package unreal;

@:glueCppIncludes("UObject/ObjectMacros.h")
@:uname("EPackageFlags")
@:uextern extern enum EPackageFlags
{
	PKG_None;
	PKG_NewlyCreated;
	PKG_ClientOptional;
	PKG_ServerSideOnly;
	PKG_CompiledIn;
	PKG_ForDiffing;
	PKG_EditorOnly;
	PKG_Developer;
	PKG_ContainsMapData;
	PKG_Need;
	PKG_Compiling;
	PKG_ContainsMap;
	PKG_RequiresLocalizationGather;
	PKG_DisallowLazyLoading;
	PKG_PlayInEditor;
	PKG_ContainsScript;
	PKG_DisallowExport;
	PKG_ReloadingForCooker;
	PKG_FilterEditorOnly;
}
