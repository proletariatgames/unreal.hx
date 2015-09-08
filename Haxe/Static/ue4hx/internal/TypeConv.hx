package ue4hx.internal;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
using haxe.macro.TypeTools;
using StringTools;

/**
  Represents a Haxe type whose glue code will be generated. Contains all the information
  on how to generate the glue code for the type

  @see TypeConvInfo
 **/
@:forward abstract TypeConv(TypeConvInfo) from TypeConvInfo
{
  public var haxeGlueType(get,never):TypeRef;
  public var glueType(get,never):TypeRef;

  inline function new(obj)
    this = obj;

  public function haxeToGlue(expr:String)
  {
    if (this.haxeToGlueExpr == null)
      return expr;
    return this.haxeToGlueExpr.replace('%',expr);
  }

  public function glueToHaxe(expr:String)
  {
    if (this.glueToHaxeExpr == null)
      return expr;
    return this.glueToHaxeExpr.replace('%',expr);
  }

  public function glueToUe(expr:String) {
    if (this.glueToUeExpr == null)
      return expr;
    return this.glueToUeExpr.replace('%', expr);
  }

  public function ueToGlue(expr:String) {
    if (this.ueToGlueExpr == null)
      return expr;
    return this.ueToGlueExpr.replace('%', expr);
  }

  private function get_haxeGlueType():TypeRef {
    return this.haxeGlueType != null ? this.haxeGlueType : this.haxeType;
  }

  private function get_glueType():TypeRef {
    return this.glueType != null ? this.glueType : this.ueType;
  }

  public static function get(type:Type, pos:Position):TypeConv
  {
    var name = null,
        args = null,
        meta = null;

    // we'll loop until we find a type we're interested in
    // when found, we'll get its name, type parameters and
    // if it's a class, its meta too
    while(true) {
      switch(type) {
      case TInst(i,tl):
        name = i.toString();
        args = tl;
        var it = i.get();
        meta = it.meta;
        var native = getMetaString(meta, ':native');
        if (native != null)
          name = native;
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
#if (haxe_ver >= 3.3)
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

    // if we have it defined as a basic (special) type, use it
    var basic = basicTypes[name];
    if (basic != null) return basic;

    var typeRef = TypeRef.parseRefName( name );
    if (meta != null && meta.has(':uobject')) {
      return {
        haxeType: typeRef,
        ueType: new TypeRef(['cpp'], 'RawPointer', [new TypeRef(typeRef.name)]),
        haxeGlueType: voidStar,
        glueType: voidStar,

        glueCppIncludes: getMetaArray(meta, ':glueCppIncludes'),

        haxeToGlueExpr: '%.wrapped',
        glueToHaxeExpr: typeRef.getRefName() + '.${typeRef.name}_Wrap.wrap(cpp.Pointer.fromRaw( cast % ))',
        glueToUeExpr: '( (::${typeRef.name} *) % )'
      };
    }

    throw new Error('Unreal Glue: Type $name is not supported', pos);
  }

  static function getMetaArray(meta:MetaAccess, name:String):Null<Array<String>>
  {
    if (meta == null) return null;
    var extracted = meta.extract(name);
    if (extracted == null || extracted.length == 0)
      return null;
    var ret = [];
    for (entry in extracted) {
      if (entry.params != null) {
        for (param in entry.params) {
          switch(param.expr)
          {
          case EConst(CString(s) | CIdent(s)):
            ret.push(s);
          case _:
            throw new Error('Unreal Glue: Unexpected non-string expression at meta $name', param.pos);
          }
        }
      }
    }

    return ret;
  }

  static function getMetaString(meta:MetaAccess, name:String):Null<String>
  {
    if (meta == null) return null;
    var extracted = meta.extract(name);
    if (extracted == null || extracted.length == 0 || extracted[0].params == null)
      return null;
    switch(extracted[0].params[0].expr) {
    case EConst(CString(s) | CIdent(s)):
      return s;
    case _:
      throw new Error('Unreal Glue: Unexpected non-string expression at meta $name', extracted[0].params[0].pos);
    }
  }

  static var voidStar(default,null) = new TypeRef(['cpp'],'RawPointer', [new TypeRef(['cpp'],'Void')]);

  static var basicTypes:Map<String, TypeConvInfo> = {
    var infos:Array<TypeConvInfo> = [
      {
        ueType: new TypeRef('bool'),
        haxeType: new TypeRef('Bool'),
      },
      {
        ueType: new TypeRef('void'),
        haxeType: new TypeRef('Void')
      },
      // FString
      {
        haxeType: new TypeRef(['unreal'],'FString'),
        ueType: new TypeRef('FString'),
        haxeGlueType: voidStar,
        glueType: voidStar,

        glueCppIncludes:['Engine.h', '<unreal/helpers/HxcppRuntime.h>'],
        glueHeaderIncludes:['<hxcpp.h>'],

        ueToGlueExpr:'::unreal::helpers::HxcppRuntime::constCharToString(TCHAR_TO_UTF8( *(%) ))',
        glueToUeExpr:'::FString( UTF8_TO_TCHAR(::unreal::helpers::HxcppRuntime::stringToConstChar(%)) )',
        haxeToGlueExpr:'unreal.helpers.HaxeHelpers.stringToPointer( % )',
        glueToHaxeExpr:'unreal.helpers.HaxeHelpers.pointerToString( % )'
      },
      // FText
      {
        haxeType: new TypeRef(['unreal'],'FText'),
        ueType: new TypeRef('FText'),
        haxeGlueType: voidStar,
        glueType: voidStar,

        glueCppIncludes:['Engine.h', '<unreal/helpers/HxcppRuntime.h>'],
        glueHeaderIncludes:['<hxcpp.h>'],

        ueToGlueExpr:'::unreal::helpers::HxcppRuntime::constCharToString(TCHAR_TO_UTF8( *((%).ToString()) ))',
        glueToUeExpr:'::FText::FromString( ::FString(UTF8_TO_TCHAR(::unreal::helpers::HxcppRuntime::stringToConstChar(%)) ))',
        haxeToGlueExpr:'unreal.helpers.HaxeHelpers.stringToPointer( % )',
        glueToHaxeExpr:'unreal.helpers.HaxeHelpers.pointerToString( % )'
      },
    ];
    var ret = new Map();
    for (info in infos)
    {
      ret[info.haxeType.getRefName()] = info;
    }
    ret;
  };
}

typedef TypeConvInfo = {
  /**
    Represents the Haxe-side type
   **/
  public var haxeType:TypeRef;
  /**
    Represents the UE-side type (e.g. `FString` on case of FString)
   **/
  public var ueType:TypeRef;

  /**
    Represents the type in the glue helper as seen by Haxe. Again in the `FString` example,
    its `haxeGlueType` will be `cpp.ConstCharStar`.

    If null, this will be the same as `haxeType`
   **/
  @:optional public var haxeGlueType:Null<TypeRef>;
  /**
    Represents the actual glue type. Normally, it will be the same as the ueType;
    However, in some special cases, it will be different.
    One classic case where it is different is `FString`: While `ueType` is the
    actual `FString` type, its `glueType` will be `const char *`

    If null, this will be the same as `ueType`
   **/
  @:optional public var glueType:Null<TypeRef>;
  // @:optional public var glueHelperType:TypeRef;

  /**
    Represents the public includes that can be included in the glue header
    These can only be includes that are safe to be included in both UE4 and hxcpp sides
   **/
  @:optional public var glueHeaderIncludes:Null<Array<String>>;
  /**
    Represents the private includes to the glue cpp files. These can be UE4 includes,
    since the CPP file is only compiled by the UE4 side
   **/
  @:optional public var glueCppIncludes:Null<Array<String>>;

  /**
    Gets the wrapping expression from UE type to the glue Type
    e.g. on `FString` this would be what transforms `FString` into `const char *`
   **/
  @:optional public var ueToGlueExpr:Null<String>;
  /**
    Gets the wrapping expression from hxcpp `glueType` to UE4.
    e.g. on `FString` this would be `FString( UTF8_TO_TCHAR(%) )`
   **/
  @:optional public var glueToUeExpr:Null<String>;
  /**
    Gets the wrapping expression from Haxe type to the glue type
   **/
  @:optional public var haxeToGlueExpr:Null<String>;
  /**
    Gets the wrapping expression from the Glue type to the Haxe type
   **/
  @:optional public var glueToHaxeExpr:Null<String>;
}
