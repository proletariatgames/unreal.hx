package unreal.umg;

import unreal.slatecore.*;

extern class UScrollBox_Extra {
	public function GetViewFraction() : Float32;

	public function GetWidgetScrollOffset(WidgetToFind : UWidget, @:opt("IntoView") ScrollDestination : unreal.slate.EDescendantScrollDestination) : Float32;
}
