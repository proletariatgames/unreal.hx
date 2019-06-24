package unreal;

private typedef NativeIterator<T> = TIndexedContainerIterator<Const<TArray<T>>,Const<T>,Int32>

@:forward abstract TConstArrayIteratorWrapper<T>(NativeIterator<T>) from NativeIterator<T> to NativeIterator<T> {
  public inline function new(native:NativeIterator<T>) this = native;

  public inline function iterateAndDispose(fn:T->Void) {
#if !bake_externs
    for (value in iterator()) {
      fn(value);
    }
    // we must dispose right after use, otherwise the destructor might assert depending on the time the GC runs
    this.dispose();
#end
  }

  public inline function iterator() return new NativeIteratorWrapper<T>(this);
}

private class NativeIteratorWrapper<T> {
  var it:NativeIterator<T>;
  #if !LIVE_RELOAD_BUILD
  inline
  #end
  public function new(it:NativeIterator<T>) {
    this.it = it;
  }

  #if !LIVE_RELOAD_BUILD
  inline
  #end
  public function hasNext() return !this.it.op_Not();

  #if !LIVE_RELOAD_BUILD
  inline
  #end
  public function next() : T {
    var val = this.it.op_Dereference();
    this.it.op_Increment();
    return val;
  }
}


