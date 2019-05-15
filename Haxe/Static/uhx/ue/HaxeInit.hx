package uhx.ue;

@:include("HaxeInit.h")
extern class HaxeInit {
	@:native("uhx_needs_wrap") public static function needsWrap():Bool;

	@:native("uhx_end_wrap") public static function endWrap():Void;
}
