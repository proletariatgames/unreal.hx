package unreal;

@:glueCppIncludes('Serialization/BitWriter.h')
@:noCopy @:noEquals
@:uextern extern class FBitWriter extends FArchive
{
	/**
	 * Constructor using known size the buffer needs to be
	 */
	public function new(MaxBits:Int64, bAllowResize:Bool=false);

	public function SerializeBits( Src:AnyPtr, LengthBits:Int64 ) : Void;

	/**
	 * Serializes a compressed integer - Value must be < Max
	 *
	 * @param Value		The value to serialize, must be < Max
	 * @param Max		The maximum allowed value - good to aim for power-of-two
	 */
	public function SerializeInt(Value:Ref<UInt32>, Max:UInt32) : Void;
	/**
	 * Serializes the specified Value, but does not bounds check against ValueMax;
	 * instead, it will wrap around if the value exceeds ValueMax (this differs from SerializeInt, which clamps)
	 *
	 * @param Value		The value to serialize
	 * @param ValueMax	The maximum value to write; wraps Value if it exceeds this
	 */
	public function WriteIntWrapped(Value:UInt32, ValueMax:UInt32) : Void;

	public function WriteBit( In:UInt8 ) : Void;

	public function GetData() : Ptr<UInt8>;
	public function GetBuffer() : PPtr<Const<TArray<UInt8>>>;

	/**
	 * Returns the number of bytes written.
	 */
	@:thisConst
	public function GetNumBytes() : Int64;
	/**
	 * Returns the number of bits written.
	 */
	@:thisConst
	public function GetNumBits() : Int64;

	/**
	 * Returns the number of bits the buffer supports.
	 */
	@:thisConst
	public function GetMaxBits() : Int64;

	/**
	 * Resets the bit writer back to its initial state
	 */
	public function Reset() : Void;

	public function WriteAlign() : Void;
}