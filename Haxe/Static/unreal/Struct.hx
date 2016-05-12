package unreal;

abstract Struct(VariantPtr) to VariantPtr {
#if !cppia
  inline
#end
  public function dispose():Void {
#if (!bake_externs && !macro)
    if (this.isObject()) {
      ( this.getDynamic() : unreal.Wrapper ).dispose();
    }
#end
  }

#if !cppia
  inline
#end
  public function isDisposed():Bool {
#if (!bake_externs && !macro)
    if (this.isObject()) {
      return ( this.getDynamic() : unreal.Wrapper ).isDisposed();
    }
#end
    return false;
  }
}
