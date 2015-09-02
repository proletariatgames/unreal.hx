package ue4hx.internal;

class TypeRef
{
  public var pack(default,null):Array<String>;
  public var name(default,null):String;
  public var params(default,null):Array<TypeRef>;

  public function new(?pack, name, ?params)
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

  public function getGlueType():TypeRef
  {
    var newPack = pack.copy();
    if (pack[0] == 'unreal')
    {
      newPack.insert(1, 'glue');
    } else {
      newPack.unshift('glue'); newPack.unshift('unreal');
    }
    return new TypeRef(newPack, name);
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
