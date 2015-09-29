package unreal;

/**
  `HaxeCreated` refers to a type that was created and owned by Haxe.
  Unless it is converted to a shared pointer, its lifetime will be entirely defined by Haxe.
  Otherwise, it will lose ownership and its lifetime will be determined by the shared pointer
 **/
@:unrealType
@:access(unreal.Wrapper)
@:forward abstract PHaxeCreated<T>(T) to T {
  @:extern inline private function new(val)
    this = val;

  @:extern inline private function underlying() {
    return this;
  }

  @:impl public static function toSharedPtr<T : Wrapper>(self:T):TSharedPtr<T> {
    var ptr = cpp.Pointer.fromRaw( self.wrapped.ptr.toSharedPtr() );
    if (ptr != self.wrapped) {
      self.wrapped.destroy();
      // this reference will now be a TSharedPtr
      self.wrapped = ptr;
    }
    return cast self;
  }

  @:impl public static function toSharedRef<T : Wrapper>(self:T):TSharedRef<T> {
    var ptr = cpp.Pointer.fromRaw( self.wrapped.ptr.toSharedRef() );
    if (ptr != self.wrapped) {
      self.wrapped.destroy();
      // this reference will now be a TSharedRef
      self.wrapped = ptr;
    }
    return cast self;
  }
}
