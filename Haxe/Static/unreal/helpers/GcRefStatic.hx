package unreal.helpers;

@:uexpose @:keep class GcRefStatic {

  public static function init():UIntPtr {
    return HaxeHelpers.dynamicToPointer( GcRoot.create(null) );
  }

  public static function get(root:UIntPtr):UIntPtr {
    return HaxeHelpers.dynamicToPointer( getRoot(root).value );
  }

  @:void public static function set(root:UIntPtr, val:UIntPtr):Void {
    getRoot(root).value = HaxeHelpers.pointerToDynamic(val);
  }

  @:void public static function destruct(root:UIntPtr):Void {
    getRoot(root).destruct();
  }

  @:extern inline private static function getRoot(root:UIntPtr):GcRoot {
    return HaxeHelpers.pointerToDynamic(root);
  }
}

