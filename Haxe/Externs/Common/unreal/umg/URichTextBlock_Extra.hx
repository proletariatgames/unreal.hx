package unreal.umg;

@:glueCppIncludes("Components/RichTextBlock.h")
extern class URichTextBlock_Extra
{
	private function UpdateStyleData() : Void;
	@:expr({ return this.Text.copy(); }) public function GetText():FText;
	#if proletariat
	public function Refresh() : Void;
	#end
}
