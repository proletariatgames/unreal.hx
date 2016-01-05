package unreal.helpers;

private typedef VoidPtr = cpp.RawPointer<cpp.Void>;

@:uexpose @:keep class GcRefStatic {

  public static function init():VoidPtr {
    return HaxeHelpers.dynamicToPointer( GcRoot.create(null) );
  }

  public static function get(root:VoidPtr):VoidPtr {
    return HaxeHelpers.dynamicToPointer( getRoot(root).value );
  }

  @:void public static function set(root:VoidPtr, val:VoidPtr):Void {
    getRoot(root).value = HaxeHelpers.pointerToDynamic(val);
  }

  @:void public static function destruct(root:VoidPtr):Void {
    getRoot(root).destruct();
  }

  @:extern inline private static function getRoot(root:VoidPtr):GcRoot {
    return HaxeHelpers.pointerToDynamic(root);
  }
}

