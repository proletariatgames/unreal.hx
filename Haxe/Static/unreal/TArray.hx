package unreal;

#if (!bake_externs && !macro)
import unreal.helpers.HaxeHelpers;
using unreal.CoreAPI;
#end

#if macro
import haxe.macro.Expr;
import haxe.macro.Context;
using haxe.macro.Tools;

private typedef TArrayImpl<T> = Dynamic;
#end

@:forward abstract TArray<T>(TArrayImpl<T>) from TArrayImpl<T> to TArrayImpl<T> {
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
    return this.get_Item(index);
  }

  @:arrayAccess
  public inline function set(index:Int, v:T) : T {
    this.set_Item(index, v);
    return v;
  }

  public inline function iterator() return new TArrayIterator<T>(this);

  public inline function pop(allowShrinking:Bool = true) : T {
    return this.Pop(allowShrinking);
  }


  public inline function push(obj:T) : Void {
    this.Push(obj);
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

  public inline function empty() : Void {
    return this.Empty();
  }

  public function indexOf(obj:T) : Int {
    for(i in 0...length) {
      if (get(i).equals(obj)) {
        return i;
      }
    }
    return -1;
  }

  public function find(fn:T->Bool) : Null<T> {
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
    for (i in 0...this.Num()) {
      if (funct(this.get_Item(i))) {
        return true;
      }
    }
    return false;
  }

  public function toArray() : Array<T> {
    return [for(i in 0...this.Num()) this.get_Item(i)];
  }

  public function mapToArray<A>(funct:T->A) : Array<A> {
    return [for(i in 0...this.Num()) funct(this.get_Item(i))];
  }

  public function filterToArray(funct:T->Bool) : Array<T> {
    return [for(i in 0...this.Num()) if (funct(this.get_Item(i))) this.get_Item(i)];
  }
#end

  macro public static function create(?tParam:Expr) : Expr {
    return macro unreal.TArrayImpl.create($tParam);
  }

  macro public function map(eThis:Expr, funct:Expr) : Expr {
    var type = Context.typeof(funct).follow();
    var returnType =  switch(type) {
      case TFun(_, ret): ret.toComplexType();
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
}

class TArrayIterator<T> {
  public var ar:TArray<T>;
  public var idx:Int;
  public inline function new(ar:TArray<T>) {
    this.ar = ar;
    this.idx = 0;
  }

  public inline function hasNext() : Bool {
    return this.idx < this.ar.Num();
  }

  public inline function next() : T {
    return this.ar.get_Item(this.idx++);
  }
}
