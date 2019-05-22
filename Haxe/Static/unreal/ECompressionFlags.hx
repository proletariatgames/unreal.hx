package unreal;

@:uextern
@:enum abstract ECompressionFlags(Int) from Int to Int {
  /** No compression																*/
  var COMPRESS_None					= 0x00;
  /** Compress with ZLIB															*/
  var COMPRESS_ZLIB 					= 0x01;
  /** Compress with GZIP															*/
  var COMPRESS_GZIP					= 0x02;
  /** Compress with user defined callbacks                                        */
  var COMPRESS_Custom                 = 0x04;
  /** Prefer compression that compresses smaller (ONLY VALID FOR COMPRESSION)		*/
  var COMPRESS_BiasMemory 			= 0x10;
  /** Prefer compression that compresses faster (ONLY VALID FOR COMPRESSION)		*/
  var COMPRESS_BiasSpeed				= 0x20;
  /* Override Platform Compression (use library Compression_Method even on platforms with platform specific compression */
  var COMPRESS_OverridePlatform		= 0x40;

  @:extern inline private function t() {
    return this;
  }

  @:op(A | B) @:extern inline public function add(flag:ECompressionFlags):ECompressionFlags {
    return this | flag.t();
  }

  @:op(A & B) @:extern inline public function and(mask:ECompressionFlags):ECompressionFlags {
    return this & mask.t();
  }
}