package unreal;

@:glueCppIncludes("Misc/Compression.h")
@:uextern extern class FCompression {
  /**
   * Thread-safe abstract compression routine to query memory requirements for a compression operation.
   *
   * @param	Flags						Flags to control what method to use and optionally control memory vs speed
   * @param	UncompressedSize			Size of uncompressed data in bytes
   * @param	BitWindow					Bit window to use in compression
   * @return The maximum possible bytes needed for compression of data buffer of size UncompressedSize
   */
  static function CompressMemoryBound( Flags:ECompressionFlags, UncompressedSize:Int, BitWindow:Int = 15):Int;

  /**
   * Thread-safe abstract compression routine. Compresses memory from uncompressed buffer and writes it to compressed
   * buffer. Updates CompressedSize with size of compressed data. Compression controlled by the passed in flags.
   *
   * @param	Flags						Flags to control what method to use and optionally control memory vs speed
   * @param	CompressedBuffer			Buffer compressed data is going to be written to
   * @param	CompressedSize	[in/out]	Size of CompressedBuffer, at exit will be size of compressed data
   * @param	UncompressedBuffer			Buffer containing uncompressed data
   * @param	UncompressedSize			Size of uncompressed data in bytes
   * @param	BitWindow					Bit window to use in compression
   * @return true if compression succeeds, false if it fails because CompressedBuffer was too small or other reasons
   */
  static function CompressMemory( Flags:ECompressionFlags, CompressedBuffer:AnyPtr, CompressedSize:Ref<Int>, UncompressedBuffer:Const<AnyPtr>, UncompressedSize:Int, BitWindow:Int = 15 ):Bool;

  /**
   * Thread-safe abstract decompression routine. Uncompresses memory from compressed buffer and writes it to uncompressed
   * buffer. UncompressedSize is expected to be the exact size of the data after decompression.
   *
   * @param	Flags						Flags to control what method to use to decompress
   * @param	UncompressedBuffer			Buffer containing uncompressed data
   * @param	UncompressedSize			Size of uncompressed data in bytes
   * @param	CompressedBuffer			Buffer compressed data is going to be read from
   * @param	CompressedSize				Size of CompressedBuffer data in bytes
   * @param	bIsSourcePadded		Whether the source memory is padded with a full cache line at the end
   * @return true if compression succeeds, false if it fails because CompressedBuffer was too small or other reasons
   */
  static function UncompressMemory( Flags:ECompressionFlags, UncompressedBuffer:AnyPtr, UncompressedSize:Int, CompressedBuffer:Const<AnyPtr>, CompressedSize:Int, bIsSourcePadded:Bool = false, BitWindow:Int = 15 ):Bool;

  /**
  * Verifies if the passed in value represents valid compression flags
  * @param InCompressionFlags Value to test
  */
  static function VerifyCompressionFlagsValid(InCompressionFlags:Int):Bool;
}