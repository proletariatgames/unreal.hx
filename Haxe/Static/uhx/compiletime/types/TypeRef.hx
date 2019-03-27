package uhx.compiletime.types;
import uhx.compiletime.tools.HelperBuf;
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
  public var flags(default, null):TypeFlags;

  public function new(?pack:Array<String>, name:String, ?moduleName:String, ?params:Array<TypeRef>, ?flags:TypeFlags)
  {
    if (pack == null) pack = [];
    if (params == null) params = [];
    if (flags == null) flags = None;
    this.pack = pack;
    this.name = name;
    this.moduleName = moduleName;
    this.params = params;
    this.flags = flags;
  }

  inline public function with(?pack:Array<String>, ?name:String, ?moduleName:String, ?params:Array<TypeRef>, ?flags:TypeFlags) {
    return new TypeRef(pack != null ? pack : this.pack, name != null ? name : this.name, moduleName != null ? moduleName : this.moduleName, params != null ? params : this.params, flags != null ? flags : this.flags);
  }
  inline public function withPack(pack:Array<String>):TypeRef {
    return new TypeRef(pack, this.name, this.moduleName, this.params, this.flags);
  }
  inline public function withParams(params:Array<TypeRef>):TypeRef {
    return new TypeRef(this.pack, this.name, this.moduleName, params, this.flags);
  }
  inline public function withConst(setConst:Bool) {
    return new TypeRef(this.pack, this.name, this.moduleName, params, setConst ? (this.flags | Const) : (this.flags.without(Const)));
  }

  public function leafWithConst(setConst:Bool) {
    if (this.params.length > 0) {
      return new TypeRef(pack,name,moduleName,[for (param in this.params) param.leafWithConst(setConst) ],flags);
    } else {
      return this.withConst(setConst);
    }
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
        return new TypeRef(this.pack, this.name.substr(1), this.params, this.flags);
      }
    }
    return this;
  }

  public function withoutPointer(?andReference:Bool=false):TypeRef {
    switch [this.pack, this.name] {
      case [ ['cpp'], 'RawPointer' ]:
        return params[0].withoutPointer();
      case [ ['cpp'], 'Reference' ] if(andReference):
        return params[0].withoutPointer();
      case _:
        return this;
    }
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
    var kind:ClassKind = untyped ct.kind;
    if (kind != null) {
      switch(kind) {
      case KAbstractImpl(a):
        return fromBaseType(a.get(), params, pos);
      case _:
      }
    }
    var mod = ct.module.split('.').pop();
    var params = (params == null ? [ for (param in ct.params) new TypeRef(param.name) ] : [ for (p in params) fromType(p, pos) ]);
    if (mod != ct.name)
      return new TypeRef(ct.pack, ct.name, mod, params);
    else
      return new TypeRef(ct.pack, ct.name, params);
  }

  public static function fastClassPath(ct:BaseType):String {
    var mod = ct.module;
    if (ct.pack.length != 0) {
      var name = '.' + ct.name;
      if (mod.endsWith(name)) {
        return mod.substr(0,mod.length-name.length) + name;
      }
    } else {
      if (mod == ct.name) {
        return ct.name;
      }
    }
    return mod + '.' + ct.name;
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
          var it = i.get();
          switch(it.kind) {
          case KAbstractImpl(a):
            t = TAbstract(a, [ for (param in a.get().params) param.t ]);
          case KTypeParameter(_):
            return new TypeRef(it.name);
          case _:
            base = it;
            params = tl;
          }
        case TEnum(e,tl):
          base = e.get();
          params = tl;
        case TType(t,tl):
          base = t.get();
          params = tl;
        case TAnonymous(_):
          throw new Error('Unreal Glue: Anonymous type not supported', pos);
        case TFun(a,r):
          var all = [ for (arg in a) fromType(arg.t, pos) ];
          all.push(fromType(r, pos));
          return new TypeRef(['haxe'],'Function','Constraints',all);
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

  private static function getSafePack(name:String) {
    if (name.charAt(0).toLowerCase() != name.charAt(0)) {
      return '_hx_$name';
    } else {
      return '_' + name;
    }
  }
  public function getGlueHelperType():TypeRef
  {
    return new TypeRef(['uhx','glues'], name + '_Glue');
  }

  public function getScriptGlueType():TypeRef
  {
    return new TypeRef(['uhx','glues'], name + '_GlueScript');
  }

  public function getExposeHelperType():TypeRef {
    return new TypeRef(['uhx','expose'], name + '_Expose');
  }

  public function getLastName():String {
    if (this.params.length == 0) {
      return this.name;
    } else {
      return this.params[0].getLastName();
    }
  }

  public function getReducedPath(?buf:StringBuf):StringBuf {
    if (buf == null) buf = new StringBuf();
    if (this.pack[0] != 'cpp') {
      for (p in this.pack) {
        buf.add(p);
        buf.add('_');
      }
    }
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
      case [ [], 'Void' | 'void' ]:
        true;
      case _:
        false;
    }
  }

  public function withoutAnyConst():TypeRef {
    return new TypeRef(this.pack, this.name, this.moduleName, [ for (param in this.params) param.withoutAnyConst() ], this.flags.without(Const));
  }

  public function toComplexType():ComplexType {
    if (moduleName == 'Constraints' && params.length > 0 && name == 'Function' && pack[0] == 'haxe') {
      var args = [ for (arg in params) arg.toComplexType() ],
          ret = args.pop();
      return TFunction(args, ret);
    }

    return TPath(toTypePath());
  }

  inline public function toTypePath():TypePath {
    return {
      pack: this.pack,
      name: this.moduleName == null ? this.name : this.moduleName,
      sub: this.moduleName == null ? null : this.name,
      params: [ for (p in params) TPType(p.toComplexType()) ]
    };
  }

  public function getCppType(?buf:StringBuf, ?ignoreConst=false, ?ignoreParams=false, ?recursiveIgnore=false):StringBuf {
    if (buf == null)
      buf = new StringBuf();

    var handledConst = false;
    // TODO implement more complex const handling, since C++ const is a bear
    switch [this.pack, this.name] {
    case [ ['cpp'], 'RawPointer' ]:
      params[0].getCppType(buf, ignoreConst);
      buf.add(' *');
    case [ ['cpp'], 'Reference' ]:
      if (!ignoreConst && flags.hasAny(Const) && !params[0].isPointer()) {
        handledConst = true;
        buf.add('const ');
      }
      params[0].getCppType(buf, ignoreConst);
      buf.add('&');
    case [ ['cpp'], 'ConstCharStar' ]:
      buf.add('const char *');
    case [ [] | ['cpp'], 'Void' | 'void' ]:
      buf.add('void');
    case [ [], 'Bool' | 'bool' ]:
      buf.add('bool');
    case _:
      if (!ignoreConst && flags.hasAny(Const)) {
        handledConst = true;
        buf.add('const ');
      }
      buf.add(this.pack.join('::'));
      if (this.pack.length > 0)
        buf.add('::');
      buf.add(this.name);

      if (params.length > 0 && !ignoreParams) {
        buf.add('<');
        var first = true;
        for (param in params) {
          if (first) first = false; else buf.add(', ');
          param.getCppType(buf, ignoreConst && recursiveIgnore);
        }
        buf.add('>');
      }
    }

    if (!handledConst && !ignoreConst && flags.hasAny(Const)) {
      buf.add(' const');
    }
    return buf;
  }

  public function getCppClass(?ignoreParams=false):String {
    return switch [this.pack, this.name] {
    case [ ['cpp'], 'RawPointer' ]:
      params[0].getCppClass();
    case _:
      this.getCppType(null, false, ignoreParams).toString();
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
    if (moduleName == 'Constraints' && params.length > 0 && name == 'Function' && pack[0] == 'haxe') {
      if (params.length == 1) {
        return 'Void->' + params[0];
      } else {
        return params.join('->');
      }
    }

    var t = getClassPath();
    if (params.length > 0)
    {
      return t + '<' + [ for( p in params) p.toString() ].join(', ') + '>';
    } else {
      return t;
    }
  }
}

@:enum abstract TypeFlags(Int) from Int {
  var None = 0;
  var Const = 1;

  inline private function t() {
    return this;
  }

  @:op(A|B) inline public function add(f:TypeFlags):TypeFlags {
    return this | f.t();
  }

  inline public function hasAll(flag:TypeFlags):Bool {
    return this & flag.t() == flag.t();
  }

  inline public function hasAny(flag:TypeFlags):Bool {
    return this & flag.t() != 0;
  }

  inline public function without(flags:TypeFlags):TypeFlags {
    return this & ~(flags.t());
  }
}
