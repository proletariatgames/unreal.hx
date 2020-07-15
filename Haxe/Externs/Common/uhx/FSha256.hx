package uhx;
import unreal.*;

@:glueCppIncludes("uhx/utils/Sha256.h")
@:uextern
extern class FSha256
{
	static function Sha256(Message:Const<ByteArray>, Len:UInt32, Out:PRef<FSha256Output>):Void;
}
