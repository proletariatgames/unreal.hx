package ue4hx.internal;
import haxe.macro.Expr;
import haxe.macro.Type;

/**
  Represents a fully qualified type reference. In Haxe terminology,
  this should be the equivalent of a fully qualified ComplexType
 **/
class TypeRef
{
  public var pack(default,null):Array<String>;
  public var name(default,null):String;
  public var params(default,null):Array<TypeRef>;
  public var moduleName(default,null):Null<String>;

  public function new(?pack:Array<String>, name:String, ?moduleName:String, ?params:Array<TypeRef>)
  {
    if (pack == null) pack = [];
    if (params == null) params = [];
    this.pack = pack;
    this.name = name;
    this.moduleName = moduleName;
    this.params = params;
  }

  public static function fromBaseType(ct:BaseType, ?params:Array<Type>, pos:Position):TypeRef {
    var mod = ct.module.split('.').pop();
    var params = (params == null ? [ for (param in ct.params) new TypeRef(param.name) ] : [ for (p in params) fromType(p, pos) ]);
    if (mod != ct.name)
      return new TypeRef(ct.pack, ct.name, mod, params);
    else
      return new TypeRef(ct.pack, ct.name, params);
  }

  public static function fromType(t:Type, pos:Position):TypeRef {
    while (true) {
      var base:BaseType = null,
          params = null;
      switch(t) {
        case TAbstract(a,tl):
          base = a.get();
          params = tl;
        case TInst(i,tl):
          base = i.get();
          params = tl;
        case TEnum(e,tl):
          base = e.get();
          params = tl;
        case TType(t,tl):
          base = t.get();
          params = tl;
        case TAnonymous(_):
          throw new Error('Unreal Glue: Anonymous type not supported', pos);
        case TFun(_,_):
          throw new Error('Unreal Glue: Function type not supported', pos);
        case TMono(mono):
          t = mono.get();
        case TLazy(lazy):
          t = lazy();
        case TDynamic(_) | null:
          throw new Error('Unreal Glue: Dynamic type not supported', pos);
      }
      if (base != null)
        return fromBaseType(base, params, pos);
    }
  }

  public static function parseRefName(name:String)
  {
    var pack = name.split('.');
    return new TypeRef(pack, pack.pop());
  }

  public function getGlueHelperType():TypeRef
  {
    var newPack = this.pack.copy(),
        name = this.name;
    if (pack[0] == 'unreal') {
      newPack.insert(1, '_pvt');
    } else {
      newPack.unshift('_pvt');
    }
    return new TypeRef(newPack, name + '_Glue');
  }

  public function isVoid() {
    return switch[ pack, name ] {
      case [ [], 'Void' ]:
        true;
      case _:
        false;
    }
  }

  public function toComplexType():ComplexType {
    return TPath({
      pack: this.pack,
      name: this.moduleName == null ? this.name : this.moduleName,
      sub: this.moduleName == null ? null : this.name,
      params: [ for (p in params) TPType(p.toComplexType()) ]
    });
  }

  public function getCppType(?buf:StringBuf):StringBuf {
    if (buf == null)
      buf = new StringBuf();

    switch [this.pack, this.name] {
    case [ ['cpp'], 'RawPointer' ]:
      params[0].getCppType(buf);
      buf.add(' *');
    case [ ['cpp'], 'ConstCharStar' ]:
      buf.add('const char *');
    case [ [] | ['cpp'], 'Void' | 'void' ]:
      buf.add('void');
    case [ [], 'Bool' | 'bool' ]:
      buf.add('bool');
    case _:
      buf.add('::');
      buf.add(this.pack.join('::'));
      if (this.pack.length != 0)
        buf.add('::');
      buf.add(this.name);

      if (params.length > 0) {
        buf.add('<');
        var first = true;
        for (param in params) {
          if (first) first = false; else buf.add(', ');
          param.getCppType(buf);
        }
        buf.add('>');
      }
    }
    return buf;
  }

  public function getCppRefName():String {
    return switch [this.pack, this.name] {
    case [ ['cpp'], 'RawPointer' ]:
      params[0].getCppRefName();
    case _:
      this.getCppType().toString();
    }
  }

  public function getRefName():String
  {
    var name = if (this.moduleName == null)
      this.name;
    else
      this.moduleName + '.' + this.name;

    return if (this.pack.length == 0)
      name;
    else
      this.pack.join('.') + '.' + name;
  }

  public function toReflective():TypeRef {
    return switch [ this.pack, this.name ] {
    case [ ['cpp'], 'RawPointer' | 'RawConstPointer' ]:
      var params = switch [this.params[0].pack, this.params[0].name] {
      case [ ['cpp'], 'Void' ]:
        [ new TypeRef('Dynamic') ];
      case _:
        this.params;
      };

      new TypeRef(['cpp'], this.name.substr(3), params);
    case _:
      this;
    }
  }

  public function isReflective():Bool {
    return switch [ this.pack, this.name ] {
    case [ ['cpp'], 'RawPointer' | 'RawConstPointer' ]:
      false;
    case _:
      true;
    };
  }

  public function toString()
  {
    var t = getRefName();
    if (params.length > 0)
    {
      return t + '<' + [ for( p in params) p.toString() ].join(', ') + '>';
    } else {
      return t;
    }
  }
}
