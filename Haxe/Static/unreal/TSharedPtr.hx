package unreal;

@:unrealType
@:forward abstract TSharedPtr<T>(T) {
  public static function MakeShareable<T>(value:HaxeCreated<T>):TSharedPtr<T> {
    // TODO MACRO?
    return null;
  }

  public function toSharedRef():TSharedRef<T> {
    return null;
  }

  @:to public function toWeakPtr():TWeakPtr<T> {
    return null;
  }
}
