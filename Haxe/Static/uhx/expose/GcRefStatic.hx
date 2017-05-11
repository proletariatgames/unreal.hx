package uhx.expose;
import unreal.*;

@:uexpose @:keep class GcRefStatic {

  public static function init():UIntPtr {
    return uhx.internal.HaxeHelpers.dynamicToPointer( uhx.internal.GcRoot.create(null) );
  }

  public static function get(root:UIntPtr):UIntPtr {
    return uhx.internal.HaxeHelpers.dynamicToPointer( getRoot(root).value );
  }

  @:void public static function set(root:UIntPtr, val:UIntPtr):Void {
    getRoot(root).value = uhx.internal.HaxeHelpers.pointerToDynamic(val);
  }

  @:void public static function destruct(root:UIntPtr):Void {
    getRoot(root).destruct();
  }

  @:extern inline private static function getRoot(root:UIntPtr):uhx.internal.GcRoot {
    return uhx.internal.HaxeHelpers.pointerToDynamic(root);
  }
}
