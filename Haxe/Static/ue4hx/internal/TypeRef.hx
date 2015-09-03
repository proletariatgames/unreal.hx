package ue4hx.internal;
import haxe.macro.Expr;

/**
  Represents a fully qualified type reference. In Haxe terminology,
  this should be the equivalent of a fully qualified ComplexType
 **/
class TypeRef
{
  public var pack(default,null):Array<String>;
  public var name(default,null):String;
  public var params(default,null):Array<TypeRef>;

  public function new(?pack:Array<String>, name:String, ?params:Array<TypeRef>)
  {
    if (pack == null) pack = [];
    if (params == null) params = [];
    this.pack = pack;
    this.name = name;
    this.params = params;
  }

  public static function parseRefName(name:String)
  {
    var pack = name.split('.');
    return new TypeRef(pack, pack.pop());
  }

  public function getGlueHelperType():TypeRef
  {
    var newPack = pack.copy();
    if (pack[0] == 'unreal') {
      newPack.insert(1, 'glue');
    } else {
      newPack.unshift('glue'); newPack.unshift('unreal');
    }
    return new TypeRef(newPack, name);
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
      name: this.name,
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

  public function getRefName():String
  {
    return if (pack.length == 0)
      name;
    else
      pack.join('.') + '.' + name;
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
