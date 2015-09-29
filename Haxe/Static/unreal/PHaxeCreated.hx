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
    return cast self.rewrap( cpp.Pointer.fromRaw( self.wrapped.ptr.toSharedPtr() ) );
  }

  @:impl public static function toWeakPtr<T : Wrapper>(self:T):TWeakPtr<T> {
    return cast self.rewrap( cpp.Pointer.fromRaw( self.wrapped.ptr.toWeakPtr() ) );
  }

  @:impl public static function toSharedRef<T : Wrapper>(self:T):TSharedRef<T> {
    return cast self.rewrap( cpp.Pointer.fromRaw( self.wrapped.ptr.toSharedRef() ) );
  }
}
