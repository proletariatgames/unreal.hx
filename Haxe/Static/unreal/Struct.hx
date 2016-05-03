package unreal;

abstract Struct(VariantPtr) to VariantPtr {
  inline public function dispose():Void {
#if (!bake_externs && !macro)
    if (this.isObject()) {
      ( this.getDynamic() : unreal.Wrapper ).dispose();
    }
#end
  }
}
