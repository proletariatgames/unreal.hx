package unreal;
#if macro
import haxe.macro.Expr;

private typedef Underlying = Dynamic;
#elseif bake_externs
private typedef Underlying = Dynamic;

#else
private typedef Underlying = AnyPtr;
#end

@:forward(addOffset,getStruct,getBool,getFloat,getFloat32,getInt16,getInt8,getInt64,getInt,getUObject,asUIntPtr,
          setBool,setFloat,setFloat32,setInt16,setInt8,setInt,setInt64,setUObject,
          getUInt16,getUInt8,getUInt,setUInt64,setUInt16,setUInt8,setUInt64)
abstract PtrBase<T>(Underlying) {
}
