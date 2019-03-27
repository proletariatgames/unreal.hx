package unreal;

@:glueCppIncludes('Serialization/BitReader.h')
@:noCopy @:noEquals
@:uextern extern class FBitReader extends FArchive
{
	public function new(Src:Ptr<UInt8>, CountBits:Int64);

	public function SerializeInt(OutValue:Ref<UInt32>, ValueMax:UInt32) : Void;
	public function ReadInt(Max:UInt32) : UInt32;
	public function ReadBit() : UInt8;

	public function GetData() : Ptr<UInt8>;
	public function GetBuffer() : Const<PRef<TArray<UInt8>>>;
	public function GetDataPosChecked() : Ptr<UInt8>;
	public function GetBytesLeft() : UInt32;
	public function GetBitsLeft() : UInt32;
	public function GetNumBytes() : UInt64;
	public function GetNumBits() : UInt64;
	public function GetPosBits() : UInt64;
	public function EatByteAlign() : Void;
}