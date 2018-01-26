package uhx.ue;

@:native('PrintfHelper')
@:include("PrintfCaptureTypes.h")
extern class PrintfHelper {
	public static function getAndFlush():unreal.UIntPtr;
}