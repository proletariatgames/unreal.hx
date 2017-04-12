package unreal;

@:glueCppIncludes("HAL/UnrealMemory.h")
@:uextern extern class FMemory {
  static function Memmove(dest:AnyPtr, src:ConstAnyPtr, count:IntPtr):AnyPtr;
  static function Memcmp(buf1:ConstAnyPtr, buf2:ConstAnyPtr, count:IntPtr):Int32;
  static function Memset(dest:AnyPtr, chr:UInt8, count:IntPtr):AnyPtr;
  static function Memcpy(dest:AnyPtr, src:ConstAnyPtr, count:IntPtr):AnyPtr;
  static function Memswap(ptr1:AnyPtr, ptr2:AnyPtr, size:IntPtr):Void;
  static function Memzero(dest:AnyPtr, size:IntPtr):AnyPtr;

  static function Malloc(count:IntPtr, alignment:FakeUInt32=0):AnyPtr;
  static function Realloc(original:AnyPtr, count:IntPtr, alignment:FakeUInt32=0):AnyPtr;
  static function Free(original:AnyPtr):Void;

  static function GPUMalloc(count:IntPtr, alignment:FakeUInt32=0):AnyPtr;
  static function GPURealloc(original:AnyPtr, count:IntPtr, alignment:FakeUInt32=0):AnyPtr;
  static function GPUFree(original:AnyPtr):Void;

  static function GetAllocSize(original:AnyPtr):IntPtr;
}
