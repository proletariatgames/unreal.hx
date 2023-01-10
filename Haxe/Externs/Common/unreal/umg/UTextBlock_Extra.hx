package unreal.umg;

@:glueCppIncludes("Components/TextBlock.h")
extern class UTextBlock_Extra {
  #if proletariat
  public function SetConvertCase(InConvertCase:unreal.slatecore.ETextConvertCaseMode) : Void;
	#end
}