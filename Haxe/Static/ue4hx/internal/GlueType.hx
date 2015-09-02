package ue4hx.internal;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
using haxe.macro.TypeTools;

/**
  Represents a type whose glue code will be generated
 **/
@:forward abstract GlueType(GlueTypeInfo) from GlueTypeInfo
{
  inline function new(obj)
    this = obj;

  public static function get(type:Type, pos:Position):GlueType
  {
    var name = null,
        args = null,
        isUObj = false;

    while(true)
    {
      switch(type)
      {
        case TInst(i,tl):
          name = i.toString();
          args = tl;
          var it = i.get();
          if (it.meta.has(':native'))
          {
            switch(it.meta.extract(':native')[0].params[0].expr) {
              case EConst(CIdent(i) | CString(i)):
                name = i;
              case _:
            };
          }
          if (it.meta.has(':uobject'))
            isUObj = true;
          break;

        case TEnum(e,tl):
          name = e.toString();
          args = tl;
          break;

        case TAbstract(a,tl):
          var at = a.get();
          if (at.meta.has(':coreType') || at.meta.has(':unrealType'))
          {
            name = a.toString();
            args = tl;
            break;
          }
          // follow it
#if haxe >= 3300
          // this is more robust than the 3.2 version, since it will also correctly
          // follow @:multiType abstracts
          type = type.followWithAbstracts(true);
#else
          type = at.type.applyTypeParameters(at.params, tl);
#end

        case TType(t,tl):
          var tt = t.get();
          if (tt.meta.has(':unrealType'))
          {
            name = t.toString();
            args = tl;
            break;
          }
          type = type.follow(true);
        case TMono(mono):
          type = mono.get();
          if (type == null)
            throw new Error('Unreal Glue: Type cannot be Unknown', pos);
        case TLazy(f):
          type = f();
        case _:
          throw new Error('Unreal Glue: Invalid type $type', pos);
      }
    }

    switch(name)
    {
    }
  }
}

typedef GlueTypeInfo = {
  cppType:String,

  ?cppUEType:String,
  ?cppHaxeType:String,

  ?declare:String,
  ?includes:Array<String>,
  ?toHaxeType:String,
  ?toUEType:String,
}
