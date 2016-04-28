package unreal;

@:enum abstract WrapperFlags(Int) from Int {
  /// first 0xf mask - not a bit field, but a normal enum

  /**
    Tells whether this object needs a finalizer. Will be cleared off when `dispose` is called
   **/
  // var NeedsFinalizer = 0x100;

  inline public function getPointerOffset():Int {
    return this & 0xFF;
  }

  inline public function getFinalizerOffset():Int {
    return (this & 0xFF00) >> 8;
  }

  public function addPointerOffset(offset:Int):WrapperFlags {
    if (offset > 0xff || offset < 0) {
      throw 'Offset overflow/underflow: $offset';
    }
    return (this & ~0xFF) | offset;
  }

  public function addFinalizerOffset(offset:Int):WrapperFlags {
    if (offset > 0xff || offset < 0) {
      throw 'Offset overflow/underflow: $offset';
    }
    return (this & ~0xFF00) | (offset << 8);
  }

  /**
    Returns whether this wrapper needs to call `getPointer()`, or if the PointerOffset can be used
   **/
  inline public function needsFunctionCall():Bool {
    return getPointerOffset() == 0;
  }

  public static function fromPointerOffset(offset:Int):WrapperFlags {
    if (offset > 0xff || offset < 0) {
      throw 'Offset overflow/underflow: $offset';
    }
    return offset;
  }

  @:op(A|B) inline public function add(flags:WrapperFlags):WrapperFlags {
    return this | (flags & 0xFFFFFF00);
  }

  @:op(A&B) inline public function maskWith(mask:WrapperFlags):WrapperFlags {
    return this & (mask | 0xFF);
  }

  @:op(~A) inline public function not():WrapperFlags {
    return ~this;
  }

  inline public function hasAll(flags:WrapperFlags):Bool {
    var flags = flags & 0xFFFFFF00;
    return this & flags == flags;
  }

  inline public function hasAny(flags:WrapperFlags):Bool {
    var flags = flags & 0xFFFFFF00;
    return this & flags != 0;
  }
}
