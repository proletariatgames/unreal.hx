package haxe.crypto;
import haxe.io.Bytes;
import unreal.*;

class Sha256
{
	public static function encode(s:String):String
	{
		var Ret = doEncode(Bytes.ofString(s));
		return hex(Ret);
	}

	static function hex(Arr:Array<Int>) {
		var Str = "";
		for (Num in Arr) {
			Str += StringTools.hex(Num, 8);
		}
		return Str.toLowerCase();
	}

	static function doEncode(Data:Bytes):Array<Int>
	{
		var Output = new uhx.FSha256Output();
		uhx.FSha256.Sha256(ByteArray.fromBytesData(Data.getData()), Data.length, Output);
		var RetVal = [];
		for (I in 0...8)
		{
			RetVal[I] = Output.Hash.getInt(I * 4);
		}
		return RetVal;
	}

	public static function make(B:Bytes):Bytes
	{
		var H = doEncode(B);
		var Out = haxe.io.Bytes.alloc(32);
		var P = 0;
		for (i in 0...8) {
			Out.set(P++, H[i] >>> 24);
			Out.set(P++, (H[i] >> 16) & 0xFF);
			Out.set(P++, (H[i] >> 8) & 0xFF);
			Out.set(P++, H[i] & 0xFF);
		}
		return Out;
	}
}
