package unreal.umg;

#if proletariat
/**
  @param bIsHovered

**/
@:glueCppIncludes("UMG.h", "Public/Components/CheckBox.h")
@:uParamName("bIsHovered")
@:umodule("UMG")
typedef FOnCheckBoxHoveredStateChanged = unreal.DynamicMulticastDelegate<FOnCheckBoxHoveredStateChanged, Bool->Void>;
#end

@:glueCppIncludes("Components/CheckBox.h")
extern class UCheckBox_Extra {
	#if proletariat
	public var OnHoverStateChanged : unreal.umg.FOnCheckBoxHoveredStateChanged;
	#end
}
