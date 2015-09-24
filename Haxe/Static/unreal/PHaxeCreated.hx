package unreal;

/**
  `HaxeCreated` refers to a type that was created and owned by Haxe.
  Unless it is converted to a shared pointer, its lifetime will be entirely defined by Haxe
 **/
@:unrealType
@:forward abstract PHaxeCreated<T>(T) to T {
  @:extern inline private function new(val)
    this = val;

  public function toWeakPtr():TWeakPtr<T> {
    // rewrap
    return null;
  }

  public function toSharedPtr():TSharedPtr<T> {
    // rewrap
    return null;
  }

  public function toSharedRef():TSharedRef<T> {
    // rewrap
    return null;
  }
}
