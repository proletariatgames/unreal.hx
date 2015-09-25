package unreal;

/**
  `HaxeCreated` refers to a type that was created and owned by Haxe.
  Unless it is converted to a shared pointer, its lifetime will be entirely defined by Haxe
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
    // var wrapped:cpp.RawPointer<unreal.helpers.UEPointer> = @:privateAccess self.wrapped;
    // return cast self.rewrap( untyped __cpp__('{0}->toSharedPtr()', wrapped) );
  }

  public function toWeakPtr():TWeakPtr<T> {
    // rewrap
    return null;
  }

  // public function toSharedPtr():TSharedPtr<T> {
  //   // rewrap
  //   return null;
  // }

  public function toSharedRef():TSharedRef<T> {
    // rewrap
    return null;
  }
}
