package unreal.helpers;

@:headerClassCode('\t\tGcRef() { this->init(); };\n\n\t\t~GcRef() { this->destruct(); };\n')
@:uexpose @:keep class GcRef {
  public var ref(default,null):cpp.RawPointer<cpp.Void>;

  @:extern inline private function getRoot():GcRoot {
    return HaxeHelpers.pointerToDynamic(this.ref);
  }

  private function init() {
    this.ref = HaxeHelpers.dynamicToPointer( GcRoot.create(null) );
  }

  public function set(dyn:cpp.RawPointer<cpp.Void>) {
    getRoot().value = HaxeHelpers.pointerToDynamic(dyn);
  }

  public function destruct() {
    var root = getRoot();
    root.value = null;
    root.destruct();
  }
}

@:final private class GcRoot {
  private static var root(default, null):GcRoot = new GcRoot(null,null);

  private var last:GcRoot;
  private var next:GcRoot;
  public var value:Dynamic;

  private function new(value:Dynamic, next:GcRoot) {
    this.value = value;
    this.next = next;
    if (next == null) {
#if (debug || assertations)
      if (root != null)
        throw 'GcRoot assert: root is not null';
#end
      // add a sibling
      new GcRoot(null, this);
    } else {
      this.last = next.last;
      next.last = this;
    }
  }

  public static function create(value:Dynamic):GcRoot {
#if (debug || assertations)
    if (root == null) throw 'GcRoot assert: root is null';
#end
    return new GcRoot(value,root);
  }

  public function destruct() {
    this.last.next = this.next;
    this.next.last = this.last;
  }
}
