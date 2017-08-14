package unreal;
import cpp.Pointer;
import cpp.UInt8;
import haxe.io.Bytes;
import haxe.io.BytesData;

@:keep @:ustatic class ByteArray {
  public var ptr(default, null):Pointer<UInt8>;
  public var length(default, null):Int;

  /**
    optional GC counterpart
   **/
  var m_bytes:BytesData;

  public function new(ptr, len, ?bytes) {
    this.ptr = ptr;
    this.length = len;
    m_bytes = bytes;
  }

  public static function alloc(size:Int):ByteArray {
    var bytes = Bytes.alloc(size).getData();
    var ptr = Pointer.arrayElem(bytes, 0);
    return new ByteArray(ptr.reinterpret(), size, bytes);
  }

  public function asAnyPtr():AnyPtr {
    return untyped __cpp__('( (unreal::UIntPtr) {0} )', this.ptr.raw);
  }

  #if !cppia inline #end public function get(i:Int):Int {
    return ptr.at(i);
  }

  #if !cppia inline #end public function set(i:Int, v:Int):Void {
    ptr.setAt(i, v);
  }

  public function incBy(amount:Int):ByteArray {
    ptr.incBy(amount);
    return this;
  }

  public function toBytes():Bytes {
    var ret = Bytes.alloc(this.length),
        ptr = this.ptr;
    for (i in 0...ret.length) {
      ret.set(i, ptr.at(i));
    }
    return ret;
  }
}
