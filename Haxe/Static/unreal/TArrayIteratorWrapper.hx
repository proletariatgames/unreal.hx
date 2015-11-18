package unreal;

private typedef NativeIterator<T> = TIndexedContainerIterator<TArray<T>,T,Int32>

@:forward abstract TArrayIteratorWrapper<T>(NativeIterator<T>) from NativeIterator<T> to NativeIterator<T> {
  public inline function new(native:NativeIterator<T>) this = native;

  public inline function iterator() return new NativeIteratorWrapper<T>(this);
}

private class NativeIteratorWrapper<T> {
  var it:NativeIterator<T>;
  public inline function new(it:NativeIterator<T>) {
    this.it = it;
  }

  public inline function hasNext() return !this.it.op_Not();
  public inline function next() : T {
    var val = this.it.op_Dereference();
    this.it.op_Increment();
    return val;
  }
}

