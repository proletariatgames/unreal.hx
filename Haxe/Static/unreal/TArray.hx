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

  public function pop(allowShrinking:Bool = true) : T {
    return this.Pop(allowShrinking);
  }


  public function push(obj:T) : Void {
    this.Push(obj);
  }

  public function addZeroed(count:Int) : Int {
    return this.AddZeroed(count);
  }


  public function setNumUninitialized(arraySize:Int) : Void {
    this.SetNumUninitialized(arraySize);
  }

  public function insert(item:T, index:Int) : Int {
    return this.Insert(item, index);
  }

  public function removeAt(index:Int, count:Int = 1, allowShrinking:Bool = true) : Void {
    this.RemoveAt(index, count, allowShrinking);
  }

  public function empty() : Void {
    return this.Empty();
  }


  public function find(obj:T) : Int {
    for(i in 0...length) {
      if (get(i).equals(obj)) {
        return i;
      }
    }
    return -1;
  }

  public function toArray() : Array<T> {
    return [for(i in 0...this.Num()) this.get_Item(i)];
  }

  public function mapToArray<A>(funct:T->A) : Array<A> {
    return [for(i in 0...this.Num()) funct(this.get_Item(i))];
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