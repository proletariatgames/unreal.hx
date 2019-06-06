package unreal;

@:glueCppIncludes("GenericApplication.h")
@:uextern extern class FModifierKeysState {
  @:uname('.ctor') public static function createWithValues(bIsLeftShiftDown:Bool, bIsRightShiftDown:Bool, bIsLeftControlDown:Bool, bIsRightControlDown:Bool, bIsLeftAltDown:Bool, bIsRightAltDown:Bool, bIsLeftCommandDown:Bool, bIsRightCommandDown:Bool, bAreCapsLocked:Bool) : FModifierKeysState;
}
