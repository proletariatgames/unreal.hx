package unreal;
#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import uhx.compiletime.types.TypeConv;

using haxe.macro.Tools;
using Lambda;
#end

@:forward
abstract PtrMacros<T>(PtrBase<T>) {
  macro public function get(ethis:Expr):ExprOf<T> {
    var t = getType(Context.typeof(ethis));
    switch(t.data) {
      case CBasic(info):
        switch(info.haxeType.name) {
        case 'Bool' | 'Int' | 'Int8' | 'Int16' | 'Int64' | 'Float' | 'Float32' |
             'UInt' | 'UInt8' | 'UInt16' | 'UInt64':
          var funcName = 'get' + info.haxeType.name;
          return macro (cast $ethis : unreal.AnyPtr).$funcName(0);
        case _:
          throw new Error('PtrMacros: Type ${info.haxeType} is not supported', ethis.pos);
        }
      case CUObject(_):
        var type = t.haxeType.toComplexType();
        return macro (cast ((cast $ethis : unreal.AnyPtr).getPointer(0).getUObject(0)) : $type);
      case CStruct(_):
        var type = t.haxeType.toComplexType();
        var isPointer = t.modifiers != null && (t.modifiers.has(Ref) || t.modifiers.has(Ptr));
        if (isPointer) {
          return macro (cast ((cast $ethis : unreal.AnyPtr).getPointer(0).getStruct(0)) : $type);
        }
        return macro (cast ((cast $ethis : unreal.AnyPtr).getStruct(0)) : $type);
      case CEnum(_):
        var strthis = ethis.toString();
        return Context.parse(t.glueToHaxe('(cast $strthis : unreal.AnyPtr).getInt(0)', null), Context.currentPos());
      case _:
        throw new Error('PtrMacros: Type ${t.haxeType} is not supported', ethis.pos);
    }
  }

  macro public function set(ethis:Expr, val:ExprOf<T>):Expr {
    var t = getType(Context.typeof(ethis));
    switch(t.data) {
      case CBasic(info):
        switch(info.haxeType.name) {
        case 'Bool' | 'Int' | 'Int8' | 'Int16' | 'Int64' | 'Float' | 'Float32' |
             'UInt' | 'UInt8' | 'UInt16' | 'UInt64':
          var funcName = 'set' + info.haxeType.name;
          return macro (cast $ethis : unreal.AnyPtr).$funcName(0, $val);
        case _:
          throw new Error('PtrMacros: Type ${info.haxeType} is not supported', ethis.pos);
        }
      case CUObject(_):
        return macro (cast $ethis : unreal.AnyPtr).setUObject(0, $val);
      case CStruct(_):
        var isPointer = t.modifiers != null && (t.modifiers.has(Ref) || t.modifiers.has(Ptr));
        if (isPointer) {
          return macro (cast $ethis : unreal.AnyPtr).setPointer(0, uhx.internal.HaxeHelpers.getUnderlyingPointer($val));
        }
        var type = t.haxeType.toComplexType();
        try {
          Context.typeof(macro (null : $type).assign(null));
        } catch(e:Dynamic) {
          throw new Error('PtrMacros: Type ${t.haxeType} was not compiled with `assign` support.', ethis.pos);
        }
        return macro (cast ((cast $ethis : unreal.AnyPtr).getStruct(0)) : $type).assign($val);
      case CEnum(_):
        // return macro (cast $ethis : unreal.AnyPtr).setInt(0, );
        var strthis = ethis.toString();
        var strval = val.toString();
        return Context.parse('(cast $strthis : unreal.AnyPtr).setInt(0, ${t.haxeToGlue(strval, null)})', Context.currentPos());
      case _:
        throw new Error('PtrMacros: Type ${t.haxeType} is not supported', ethis.pos);
    }
  }

  // macro public function addOffset(ethis:Expr, offset:ExprOf<Int>):ExprOf<PtrMacros<T>> {
  // }
#if macro

  public static function createStackHelper(isRef:Bool):Expr {
    var t = Context.getExpectedType();
    var name = isRef ? "Ref" : "Ptr";
    if (t == null) {
      throw new Error('PtrMacros: Unable to determine the type of $name. The type must be typed explicitly', Context.currentPos());
    }
    var conv = getType(t),
        pos = Context.currentPos();
    var useSize = switch(conv.data) {
      case CBasic(_) | CSpecial(_) | CUObject(_) | CEnum(_) | CPtr(_):
        true;
      case CStruct(_):
        conv.modifiers != null && (conv.modifiers.has(Ref) || conv.modifiers.has(Ptr));
      case _:
        false;
    };
    if (useSize) {
        var size = switch(conv.data) {
          case CBasic(info) | CSpecial(info):
            switch(info.haxeType.name) {
              case 'Bool' | 'Int' | 'UInt' | 'Float32':
                macro 4;
              case 'Int8' | 'UInt8':
                macro 1;
              case 'Int16' | 'UInt16':
                macro 2;
              case 'Int64' | 'UInt64' | 'Float':
                macro 8;
              case 'UIntPtr' | 'IntPtr' | 'AnyPtr':
                macro uhx.internal.Helpers.pointerSize;
              case _:
                throw new Error('PtrMacros: Type ${info.haxeType} is not supported', pos);
            }
          case CEnum(_):
            // we don't know its size, so just make it be always as much as it can
            macro 8;
          case CUObject(_) | CPtr(_) | CStruct(_):
            macro uhx.internal.Helpers.pointerSize;
          case _:
            throw 'assert';
        };
        if (Context.defined('cppia')) {
          return macro @:mergeBlock {
            var ret = uhx.internal.Helpers.createPodWrapper($size);
            cast ret.getPointer();
          };
        } else {
          return macro cast uhx.ue.RuntimeLibrary.allocaZeroed($size);
        }
    } else {
      switch(conv.data) {
      case CStruct(_):
        var tpath = conv.haxeType.toTypePath();
        return macro @:mergeBlock {
          var ret = new $tpath();
          cast uhx.internal.HaxeHelpers.getUnderlyingPointer(ret);
        };
      case _:
        throw new Error("PtrMacros: Unsupported type : " + t, pos);
      }
    }
  }

  private static function getType(t:Type):TypeConv {
    switch(t) {
      case TAbstract(_,[t]):
        return TypeConv.get(t, Context.currentPos());
      case _:
        throw new Error("PtrMacros: Invalid type: " + t + ". Expected it to be a PtrMacros", Context.currentPos());
    }
  }

#else

  inline public function isNull() {
    return this == cast 0;
  }

  inline public function isNotNull() {
    return this != cast 0;
  }

#end
}
