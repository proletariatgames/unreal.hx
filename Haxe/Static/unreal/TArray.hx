package unreal;

#if (!bake_externs && !macro)
import uhx.StructInfo;
using unreal.CoreAPI;
#end

#if macro
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;
using haxe.macro.Tools;

private typedef TArrayImpl<T> = Dynamic;
#end

@:keep
@:forward abstract TArray<T>(TArrayImpl<T>) from TArrayImpl<T> to TArrayImpl<T> #if !bake_externs to unreal.Struct to unreal.VariantPtr #end {
#if (!bake_externs && !macro)

  public var length(get,never):Int;

  inline public function new(arr:TArrayImpl<T>) {
    this = arr;
  }

  private inline function get_length() {
    return this.Num();
  }

  @:arrayAccess
  public inline function get(index:Int) {
    return getChecked(index);
  }

  @:arrayAccess
  public inline function set(index:Int, v:T) : T {
    return setChecked(index, v);
  }

  public inline function getChecked(index:Int) {
    #if debug
    if (!isValidIndex(index)) {
      throwAssert('Index $index out of bounds (num=${this.Num()})');
    }
    #end
    return this.get_Item(index);
  }

  public inline function setChecked(index:Int, v:T) : T {
    #if debug
    if (!isValidIndex(index)) {
      throwAssert('Index $index out of bounds (num=${this.Num()})');
    }
    #end
    this.set_Item(index, v);
    return v;
  }

  inline function throwAssert(s:String) : Void
  {
      throw '$s\n${haxe.CallStack.toString(haxe.CallStack.callStack())}';
  }

  public inline function isValidIndex(index:Int) : Bool
  {
    return index >= 0 && index < this.Num();
  }

  public inline function iterator() return new TArrayIterator<T>(this);

  public inline function pop(allowShrinking:Bool = true) : T {
    return this.Pop(allowShrinking);
  }


  public inline function push(obj:T) : Void {
    this.Push(obj);
  }

  public inline function Append(other:TArray<T>) : Void
  {
    for (element in other)
    {
      this.Push(element);
    }
  }

  public inline function addZeroed(count:Int) : Int {
    return this.AddZeroed(count);
  }

  public inline function setNumUninitialized(arraySize:Int) : Void {
    this.SetNumUninitialized(arraySize);
  }

  public inline function insert(item:T, index:Int) : Int {
    return this.Insert(item, index);
  }

  public inline function remove(item:T) : Void {
    var index = indexOf(item);
    if (index >= 0) removeAt(index);
  }

  public inline function removeAt(index:Int, count:Int = 1, allowShrinking:Bool = true) : Void {
    this.RemoveAt(index, count, allowShrinking);
  }

  /** Removes any elements that pass the supplied filter, like an in-place filter().
   *  @return The number of elements removed.
   **/
  public inline function removeIf(fn:T->Bool, allowShrinking:Bool = true) : Int
  {
    var numRemoved = 0;
    var i = 0;
    while (i < this.Num())
    {
      if (fn(get(i)))
      {
        removeAt(i, 1, allowShrinking);
        ++numRemoved;
        continue;
      }
      ++i;
    }
    return numRemoved;
  }

  public inline function empty() : Void {
    return this.Empty();
  }

  public inline function reset() : Void {
    return this.Reset();
  }

  public function indexOf(obj:T) : Int {
    var len = length;
    if (len == 0) return -1;

    var normalCompare = obj == null || Std.is(obj, UObject);
    if (!normalCompare) {
      switch(Type.typeof(obj)) {
      case TNull | TInt | TFloat | TBool | TEnum(_):
        normalCompare = true;
      case _:
      }
    }

    var compare:cpp.Function<cpp.RawConstPointer<StructInfo>->UIntPtr->UIntPtr->Bool, cpp.abi.Abi> = null,
        info:cpp.ConstPointer<StructInfo> = null,
        size = 0;

    if (!normalCompare) {
      var thisInfo:cpp.Pointer<cpp.ConstPointer<StructInfo>> = cpp.ConstPointer.fromRaw((@:privateAccess this.getTemplateStruct()).info.ptr.genericParams).reinterpret();
      if (thisInfo == null) {
        normalCompare = true;
      } else {
        info = thisInfo.at(0);
        compare = cast info.ptr.equals;
        size = cast info.ptr.size;
        normalCompare = untyped __cpp__('{0}.call == 0', compare);
      }
    }

    if (normalCompare) {
      for (i in 0...len) {
        if (get(i) == obj) {
          return i;
        }
      }
    } else {
      var vptr:VariantPtr = cast obj,
          obj:UIntPtr = vptr.getUnderlyingPointer();

      var data = this.GetData();
      for(i in 0...len) {
        if (compare.call(info.get_raw(), data, obj)) {
          return i;
        }
        data += size;
      }
    }
    return -1;
  }

  public function findIndexOf(fn:T->Bool) : Int {
    var length = this.Num();
    for (i in 0...length) {
      var el = get(i);
      if (fn(el)) {
        return i;
      }
    }
    return -1;
  }

  public function find(fn:T->Bool) : Null<T> {
    var length = this.Num();
    for (i in 0...length) {
      var el = get(i);
      if (fn(el)) {
        return el;
      }
    }
    return null;
  }

  public inline function has(el:T) : Bool {
    return indexOf(el) >= 0;
  }

  public function exists(funct:T->Bool) : Bool {
    var len = this.Num();
    for (i in 0...len) {
      if (funct(this.get_Item(i))) {
        return true;
      }
    }
    return false;
  }

  public function toArray() : Array<T> {
    var len = this.Num();
    return [for(i in 0...len) this.get_Item(i)];
  }

  public function mapToArray<A>(funct:T->A) : Array<A> {
    var len = this.Num();
    return [for(i in 0...len) funct(getChecked(i))];
  }

  public function filterToArray(funct:T->Bool) : Array<T> {
    var len = this.Num();
    return [for(i in 0...len) if (funct(getChecked(i))) getChecked(i)];
  }

  public function count(fn:T->Bool) : Int {
    var cnt = 0;
    var len = this.Num();
    for (i in 0...len) {
      if (fn(getChecked(i))) {
        ++cnt;
      }
    }
    return cnt;
  }

  public function sort(fn:T->T->Int):Void {
    var len = this.Num();
    if (len == 0) {
      return;
    }
    var arr = toArray();

    var first = arr[0];
    // arr[0] will never be null if the underlying type is a struct
    var isRef = first != null && (Std.is(first, unreal.Wrapper) || untyped __cpp__('{0}->__GetHandle() != 0', first)); // __GetHandle hack to work around Std.is(cpp.Pointer), which doesn't work
    quicksort(arr, 0, arr.length -1, fn, isRef);
  }

  private function quicksort( arr:Array<T>, lo : Int, hi : Int, f : T -> T -> Int, isRef:Bool ) : Void
  {
    var i = lo, j = hi;
    var p = arr[(i + j) >> 1];
    while ( i <= j )
    {
      var tmp;
      while ( i < hi && (tmp = arr[i]) != p && f(tmp, p) < 0 ) i++;
      while ( j > lo && (tmp = arr[j]) != p && f(tmp, p) > 0 ) j--;
      if ( i <= j )
      {
        this.Swap(i,j);
        if (!isRef) {
          var t = arr[i];
          arr[i++] = arr[j];
          arr[j--] = t;
        } else {
          i++;
          j--;
        }
      }
    }

    if( lo < j ) {
      quicksort( arr, lo, j, f, isRef );
    }
    if( i < hi ) {
      quicksort( arr, i, hi, f, isRef );
    }
  }
#end

  macro public static function create(?tParam:Expr) : Expr {
    return macro unreal.TArrayImpl.create($tParam);
  }

  macro public static function createNew(?tParam:Expr) : Expr {
    return macro unreal.TArrayImpl.createNew($tParam);
  }

  macro public function copyCreate(self:Expr, ?tParam:Expr) : Expr {
    return macro unreal.TArrayImpl.copyCreate($tParam, $self);
  }

  macro public function map(eThis:Expr, funct:Expr) : Expr {
    var type = Context.typeof(funct).follow();
    var returnType =  switch(type) {
      case TFun(_, ret):
        if (isKnownType(ret)) {
          ret.toComplexType();
        } else {
          throw new Error('The return type of the function must be known. Make sure it\'s fully typed', funct.pos);
        }
      default: throw new Error('funct must be a function', funct.pos);
    }

    return macro {
      var tmp:unreal.TArray<$returnType> = unreal.TArrayImpl.create();
      for (value in $eThis) {
        tmp.Push($funct(value));
      }
      tmp;
    };
  }

  macro public function filter(eThis:Expr, funct:Expr) : Expr {
    var type = Context.typeof(funct).follow();
    var returnType =  switch(type) {
      case TFun([arg],_):
        if (isKnownType(arg.t)) {
          arg.t.toComplexType();
        } else {
          throw new Error('The return type of the function must be known. Make sure it\'s fully typed', funct.pos);
        }
      default: throw new Error('funct must be a function', funct.pos);
    }

    return macro {
      var tmp:unreal.TArray<$returnType> = unreal.TArrayImpl.create();
      for (value in $eThis) {
        if ($funct(value)) {
          tmp.Push(value);
        }
      }
      tmp;
    };
  }

  macro public static function fromIterable(params:Array<Expr>) : Expr {
    var array, tparam;
    if (params.length == 1) {
      tparam = null;
      array = params[0];
    } else {
      tparam = params[0];
      array = params[1];
    }
    var createStatement = switch(tparam) {
      case null | { expr: EConst(CIdent('null')) }:
        var type = Context.typeof(macro @:pos(array.pos) $array.iterator().next());
        if (!isKnownType(type)) {
          throw new Error('The full type of the iterable must be known. Make sure it\'s fully typed', array.pos);
        }
        var tparam = type.toComplexType();
        macro unreal.TArrayImpl.create(new unreal.TypeParam<$tparam>());
      case _:
        macro unreal.TArrayImpl.create($tparam);
    };
    return macro @:pos(array.pos) {
      var ret = $createStatement;
      for (value in $array) {
        ret.push(value);
      }
      ret;
    }
  }
#if macro
  private static function isKnownType(t:Type):Bool {
    switch(Context.follow(t)) {
    case TMono(_):
      return false;
    case TAbstract(_.get() => a,tl) if (!a.meta.has(':coreType')):
#if (haxe_ver >= 3.3)
      // this is more robust than the 3.2 version, since it will also correctly
      // follow @:multiType abstracts
      return isKnownType(t.followWithAbstracts(false));
#else
      return isKnownType(a.type.applyTypeParameters(a.params, tl));
#end
    case _:
      return true;
    }
  }
#end
}

class TArrayIterator<T> {
  public var ar:TArray<T>;
  public var idx:Int;
  public var num:Int;
  public inline function new(ar:TArray<T>) {
    this.ar = ar;
    this.idx = 0;
    this.num = ar.Num();
  }

  public inline function hasNext() : Bool {
    return this.idx < this.num;
  }

  public inline function next() : T {
    #if debug
    if (this.num != this.ar.Num()) {
      throw 'Iterator invalidated: array size changed';
    }
    #end
    return this.ar.get_Item(this.idx++);
  }
}
