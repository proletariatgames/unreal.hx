package unreal;
import cpp.Pointer;

@:unrealType
@:forward
abstract AnyPtr(cpp.Pointer<Dynamic>) from cpp.Pointer<Dynamic> to cpp.Pointer<Dynamic> {
  @:op(A+B) public function addOffset(offset:Int):AnyPtr {
    var bytearr:Pointer<UInt8> = this.reinterpret();
    return bytearr.add(offset).reinterpret();
  }

#if !bake_externs
  public function getUObject(at:Int):UObject {
    return UObject.wrap(at == 0 ? this : this.add(at));
  }

  public static function fromUObject(obj:UObject):AnyPtr {
    return @:privateAccess obj.getWrapped().reinterpret();
  }

  public static function fromStruct(obj:Wrapper):AnyPtr {
    return @:privateAccess cpp.Pointer.fromRaw(cast obj.getWrapped().ptr.getPointer());
  }

  public static function fromNull():AnyPtr {
    return null;
  }
#end
}
