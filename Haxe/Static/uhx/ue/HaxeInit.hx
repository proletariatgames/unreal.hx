package uhx.ue;

@:include("HaxeInit.h")
extern class HaxeInit {
	@:native("uhx_needs_wrap") public static function needsWrap():Bool;
}
