package unreal.helpers;

@:headerClassCode('\t\tGcRef() { this->init(); };\n\n\t\t~GcRef() { this->destruct(); };\n')
@:uexpose @:keep class GcRef {
  public var ref(default,null):cpp.RawPointer<cpp.Void>;

  @:extern inline private function getRoot():GcRoot {
    return HaxeHelpers.pointerToDynamic(this.ref);
  }

  @:final @:nonVirtual @:void private function init() {
    this.ref = HaxeHelpers.dynamicToPointer( GcRoot.create(null) );
  }

  @:final @:nonVirtual @:void public function set(dyn:cpp.RawPointer<cpp.Void>) {
    getRoot().value = HaxeHelpers.pointerToDynamic(dyn);
  }

  @:final @:nonVirtual public function get():cpp.RawPointer<cpp.Void> {
    return HaxeHelpers.dynamicToPointer(getRoot().value);
  }

  @:final @:nonVirtual @:void public function destruct() {
    getRoot().destruct();
  }
}
