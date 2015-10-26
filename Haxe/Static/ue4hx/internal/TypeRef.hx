package ue4hx.internal;
import ue4hx.internal.buf.HelperBuf;
import haxe.macro.Expr;
import haxe.macro.Type;

using StringTools;

/**
  Represents a fully qualified type reference. In Haxe terminology,
  this should be the equivalent of a fully qualified ComplexType.

  This provides some helpers to use the same type in both C++ as Haxe
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

  inline public function withPack(pack:Array<String>):TypeRef {
    return new TypeRef(pack, this.name, this.moduleName, this.params);
  }
  inline public function withParams(params:Array<TypeRef>):TypeRef {
    return new TypeRef(this.pack, this.name, this.moduleName, params);
  }

  public function withoutPrefix():TypeRef {
    switch [this.pack, this.name] {
      case [ ['cpp'], 'RawPointer' ]:
        return params[0].withoutPrefix();
      case _:
    }

    if (this.name.length > 1 && this.name.charAt(1).toUpperCase() == this.name.charAt(1)) {
      switch(name.charCodeAt(0)) {
      case 'U'.code | 'A'.code | 'F'.code | 'T'.code:
        return new TypeRef(this.pack, this.name.substr(1), this.params);
      }
    }
    return this;
  }

  public function getForwardDecl() {
    if (this.isPointer())
      return params[0].getForwardDecl();

    var ret = new HelperBuf();
    for (pack in this.pack) {
      ret << 'namespace $pack {\n';
    }
    if (this.params.length > 0) {
      ret << 'template<';
      var idx = 0;
      ret.mapJoin(this.params, function(_) return 'class T{idx++}');
      ret << '>\n';
    }
    ret << 'class ${this.name};\n';
    for (pack in this.pack) {
      ret << '}\n';
    }
    return ret.toString();
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

  public static function parseClassName(name:String, ?withParams:Array<TypeRef>, parseModule=false)
  {
    var pack = name.split('.');
    var name = pack.pop();
    var last = pack[pack.length-1];
    var module = null;
    if (parseModule && last != null && (last.charCodeAt(0) >= 'A'.code && last.charCodeAt(0) <= 'Z'.code)) {
      module = pack.pop();
    }
    return new TypeRef(pack, name, module, withParams);
  }

  public static function parse(type:String) {
    var idx = -1;
    function parseSub() {
      var start = idx + 1;
      var len = type.length,
          tparams = [];
      var hasParams = false;
      while (++idx < len) {
        switch (type.fastCodeAt(idx)) {
        case ' '.code if (start == idx):
          start = idx + 1;
          continue;
        case '<'.code:
          hasParams =true;
          break;
        case '>'.code | ','.code | ' '.code:
          break;
        case chr if ( (chr >= 'a'.code && chr <= 'z'.code) || (chr >= 'A'.code && chr <= 'Z'.code) || chr == '_'.code || chr == '.'.code || (chr >= '0'.code && chr <= '9'.code) ):
          // do nothing
        case chr:
          throw 'Unexpected character ${String.fromCharCode(chr)} at $idx for "$type"';
        }
      }

      var last = idx,
          first = true;
      if (hasParams) {
        while (idx < len) {
          var wasFirst = first;
          first = false;
          // parse params
          switch(type.fastCodeAt(idx)) {
            case '<'.code:
              if (!wasFirst)
                throw 'Unexpected character < at $idx for "$type"';
              tparams.push(parseSub());
            case ','.code:
              tparams.push(parseSub());
            case ' '.code:
              // ignore
              idx++;
            case '>'.code:
              idx++;
              break;
            case chr:
              throw 'Unexpected character ${String.fromCharCode(chr)} at $idx for "$type"';
          }
        }
      }

      return parseClassName(type.substring(start,last), tparams, true);
    }
    var ret = parseSub();
    if (idx != type.length) throw 'Unexpected ending: "${type.substr(idx)}" for "$type"';
    return ret;
  }

  public function applyParams(originalParams:Array<String>, appliedParams:Array<TypeRef>) {
    var idx = originalParams.indexOf(this.name);
    if (idx >= 0 && this.pack.length == 0 && this.moduleName == null)
      return appliedParams[idx];
    else if (this.params.length > 0)
      return this.withParams([ for (p in params) p.applyParams(originalParams, appliedParams) ]);
    else
      return this;
  }

  public function getGlueHelperType():TypeRef
  {
    var newPack = [ for (pack in this.pack) '_' + pack ],
        name = this.name;
    newPack.unshift('_pvt');
    return new TypeRef(newPack, name + '_Glue');
  }

  public function getExposeHelperType():TypeRef {
    var newPack = [ for (pack in this.pack) '_' + pack ],
        name = this.name;
    newPack.unshift('_pvt');
    return new TypeRef(newPack, name + '_Expose');
  }

  public function getTypeParamType():TypeRef {
    var newPack = [ for (pack in this.pack) '_' + pack ],
        name = new StringBuf();
    newPack.unshift('_pvt');
    var buf = this.getReducedPath();
    buf.add('_TypeParam');

    return new TypeRef(newPack, buf.toString());
  }

  public function getReducedPath(?buf:StringBuf):StringBuf {
    if (buf == null) buf = new StringBuf();
    buf.add(this.name);
    if (this.params != null) {
      for (param in this.params) {
        buf.add('__');
        param.getReducedPath(buf);
      }
    }
    return buf;
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
    case [ ['cpp'], 'Reference' ]:
      params[0].getCppType(buf);
      buf.add('&');
    case [ ['cpp'], 'ConstCharStar' ]:
      buf.add('const char *');
    case [ [] | ['cpp'], 'Void' | 'void' ]:
      buf.add('void');
    case [ [], 'Bool' | 'bool' ]:
      buf.add('bool');
    case _:
      buf.add(this.pack.join('::'));
      if (this.pack.length > 0)
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

  public function getCppClass():String {
    return switch [this.pack, this.name] {
    case [ ['cpp'], 'RawPointer' ]:
      params[0].getCppClass();
    case _:
      this.getCppType(null).toString();
    }
  }

  public function getCppClassName():String {
    return switch [this.pack, this.name] {
      case [ ['cpp'], 'RawPointer' ]:
        params[0].getCppClassName();
      case _:
        this.name;
    }
  }

  public function withoutModule():TypeRef {
    return if (this.moduleName == null)
      this;
    else
      new TypeRef(this.pack, this.name, this.params);
  }

  public function getClassPath(discardModule=false):String
  {
    var name = if (discardModule || this.moduleName == null)
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

  public function isPointer():Bool {
    return switch [ this.pack, this.name ] {
      case [ ['cpp'], 'RawPointer' | 'RawConstPointer' | 'Pointer' | 'ConstPointer' ]:
        true;
      case _:
        false;
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
    var t = getClassPath();
    if (params.length > 0)
    {
      return t + '<' + [ for( p in params) p.toString() ].join(', ') + '>';
    } else {
      return t;
    }
  }
}
