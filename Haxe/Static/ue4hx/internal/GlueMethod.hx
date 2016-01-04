package ue4hx.internal;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import ue4hx.internal.buf.CodeFormatter;
import ue4hx.internal.buf.HelperBuf;

using StringTools;
using Lambda;

using haxe.macro.Tools;
using ue4hx.internal.MacroHelpers;

class GlueMethod {
  ///////////////////////
  /// input parameters
  ///////////////////////
  public var meth(default, null):MethodDef;
  /** the TypeConv where the glue function is defined **/
  public var type(default, null):Type;
  public var isTemplatedThis(default, null):Bool;
  public var glueType:TypeRef;

  ///////////////////////
  /// output parameters
  ///////////////////////
  public var dependentTypes(default, null):Map<String, String>;
  public var needsTypeParamGlue(default, null):Bool;
  public var haxeCode:Array<String>;
  public var headerCode:String;
  public var ueHeaderCode:String;
  public var cppCode:String;
  var thisConv(default, null):TypeConv;
  var cppIncludes(default, null):IncludeSet;
  var headerIncludes(default, null):IncludeSet;
  var glueArgs(default, null):Array<{ name:String, t:TypeConv }>;
  var cppArgs(default, null):Array<{ name:String, t:TypeConv }>;
  var haxeArgs(default, null):Array<{ name:String, t:TypeConv }>;
  var glueRet(default, null):TypeConv;
  var retHaxeType(default, null):TypeRef;
  var op(default, null):String;

  ///////////////////////
  /// shared parameters
  ///////////////////////
  var isGlueStatic:Bool;
  var templated:Bool;
  var ctx:Map<String, String>;

  public function new(meth:MethodDef, type:Type, ?glueType:TypeRef, ?isTemplatedThis:Bool) {
    this.meth = meth;
    this.type = type;
    this.thisConv = TypeConv.get(type,meth.pos,'unreal.PExternal');
    if (glueType == null)
      glueType = this.thisConv.haxeType.getGlueHelperType();
    this.glueType = glueType;
    this.cppIncludes = new IncludeSet();
    this.headerIncludes = new IncludeSet();
    this.dependentTypes = new Map();
    if (isTemplatedThis == null) {
      isTemplatedThis = thisConv.haxeType.params.length > 0 && meth.specialization == null;
    }
    this.isTemplatedThis = isTemplatedThis;

    this.process();
  }

  private function process() {
    var meth = this.meth;
    if (meth.meta == null) {
      meth.meta = [];
    }

    var isStatic = meth.flags.hasAny(Static);
    var isProp = meth.flags.hasAny(Property);
    var ctx = this.ctx = isProp && !isStatic && !this.thisConv.isUObject ? [ "parent" => "this" ] : null;

    var haxeArgs = this.haxeArgs = meth.args;
    var glueArgs = this.glueArgs = haxeArgs;
    var isGlueStatic = this.isGlueStatic = !this.isTemplatedThis || isStatic;

    if (!isStatic && !this.isTemplatedThis) {
      // CLEANUP use 'this' directly?
      var name = meth.specialization != null ? 'self' : 'this';
      glueArgs = this.glueArgs = glueArgs.copy();
      glueArgs.unshift({ name: name, t: this.thisConv });
    }

    var isSetter = isProp && meth.name.startsWith('set_');
    this.glueRet = isSetter ? voidType : meth.ret;
    var isVoid = this.glueRet.haxeType.isVoid();

    this.templated = meth.params != null && meth.params.length > 0;

    /// glue header code
    var cppArgDecl = new HelperBuf();
    cppArgDecl.mapJoin(this.glueArgs, function(arg) return arg.t.glueType.getCppType() + ' ' + escapeCpp(arg.name, true));
    var glueHeaderCode = new HelperBuf();

    if (this.templated) {
      glueHeaderCode << 'template<';
      glueHeaderCode.mapJoin(meth.params, function(p) return 'class $p');
      glueHeaderCode << '>\n\t';
    }
    if (isGlueStatic) {
      glueHeaderCode << 'static ';
    }
    glueHeaderCode << '${this.glueRet.glueType.getCppType()} ${meth.name}(' << cppArgDecl + ')';

    var baseGlueHeaderCode = null;
    if (this.isTemplatedThis && !isStatic) {
      baseGlueHeaderCode = 'virtual ' + glueHeaderCode.toString() + ' = 0;';
    }

    this.cppArgs = meth.args;
    this.retHaxeType = meth.ret.haxeType;
    var glueCppBody = new HelperBuf();
    // get cpp body - might change `cppArgs`, `retHaxeType` and `op`
    glueCppBody << this.getCppBody();

    if (this.templated || meth.specialization != null) {
      glueCppBody << this.getFunctionCallParams();
    }

    var glueCppBodyVars = new HelperBuf();
    if (meth.flags.hasAny(CppPrivate)) {
      var staticCppVars = new HelperBuf(),
          staticCppBody = genCppCall(glueCppBody.toString(), '_s_', staticCppVars);
      var localDerivedClassBody = new HelperBuf();
      // On windows, we need to disable the warning 4610 that this class can never be instantiated.
      // We know that it can't, and that's just fine. But warnings are promoted to errors. so we have to disable
      // this warning during this code.
      localDerivedClassBody << "\n#if PLATFORM_WINDOWS\n#pragma warning( disable : 4510 4610 )\n#endif // PLATFORM_WINDOWS\n\t";
      localDerivedClassBody << 'class _staticcall_${meth.name} : public ${this.thisConv.ueType.getCppClass()} {\n';
      var staticCppArgDecl = [ for ( arg in this.glueArgs ) arg.t.glueType.getCppType() + ' ' + '_s_' + escapeCpp(arg.name, true) ].join(', ');
      localDerivedClassBody << '\t\tpublic:\n\t\t\tstatic ${this.glueRet.glueType.getCppType()} static_${meth.name}(${staticCppArgDecl}) {\n\t\t\t\t'
        << staticCppVars
        << staticCppBody
        << ';\n\t\t}\n'
        << '\t};\n'
        << "#if PLATFORM_WINDOWS\n#pragma warning( default : 4510 4610 )\n#endif // PLATFORM_WINDOWS\n\n\t";
        if (!this.glueRet.haxeType.isVoid()) localDerivedClassBody << 'return ';
      localDerivedClassBody << '_staticcall_${meth.name}::static_${meth.name}('
        + [ for (arg in this.glueArgs) escapeCpp(arg.name, true) ].join(', ') + ')';
      glueCppBodyVars << localDerivedClassBody;
    } else {
      glueCppBodyVars << genCppCall(glueCppBody.toString(), '', glueCppBodyVars);
    }

    var glueCppCode = new HelperBuf();
    if (this.templated) {
      glueCppCode << 'template<';
      glueCppCode.mapJoin(meth.params, function(p) return 'class $p');
      glueCppCode << '>\n\t';
    }

    if (this.isTemplatedThis && !isStatic) {
      glueHeaderCode << ' {\n\t\t\t$glueCppBodyVars;\n\t\t}';
    } else {
      glueHeaderCode << ';';
      glueCppCode <<
        this.glueRet.glueType.getCppType() <<
        ' ${this.glueType.getCppType()}_obj::${meth.name}(' << cppArgDecl << ') {' <<
          '\n\t' << glueCppBodyVars << ';\n}';
    }

    var allTypes = [ for (arg in this.glueArgs) arg.t ];
    allTypes.push(meth.ret);

    // dependent types - this is only used by the extern baker pass
    // this will add all types that are used by each templated variation of this class
    if (!this.templated && !isStatic && this.isTemplatedThis) {
      for (type in allTypes) {
        if (type.hasTypeParams()) {
          var tref = type.haxeType;
          while (tref.name == 'PRef' || tref.name == 'PRefDef') {
            if (tref.pack.length == 1 && tref.name == 'PRef' && tref.pack[0] == 'unreal') {
              tref = tref.params[0];
            } else if (tref.pack.length == 2 && tref.name == 'PRefDef' && tref.pack[0] == 'ue4hx' && tref.pack[1] == 'internal') {
              tref = tref.params[0];
            } else {
              break;
            }
          }
          var str = tref.toString();
          this.dependentTypes[str] = str;
        }
      }
    }

    inline function addMeta(name:String) {
      meth.meta.push({ name:name, pos:meth.pos });
    }

    for (t in allTypes) {
      if ( (!t.isMethodPointer && t.args != null && t.args.length > 0 && !t.hasTypeParams()) || t.isFunction ) {
        this.needsTypeParamGlue = true;
        addMeta(':needsTypeParamGlue');
        break;
      }
    }

    if (!this.templated) {
      if (!isGlueStatic && isTemplatedThis) {
        // in this case, we'll have glueHeader and ueHeaderCode - no cppCode is added
        this.headerCode = baseGlueHeaderCode;
        this.ueHeaderCode = glueHeaderCode.toString();
      } else {
        this.headerCode = glueHeaderCode.toString();
        this.cppCode = glueCppCode.toString();
      }
    }

    var headerIncludes = this.headerIncludes,
        cppIncludes = this.cppIncludes;
    if (meth.uname == '.equals') {
      cppIncludes.add('<TypeTraits.h>');
    }

    for (type in allTypes) {
      type.getAllCppIncludes(cppIncludes);
      type.getAllHeaderIncludes(headerIncludes);
    }

    if (this.templated) {
      addMeta(':generic');
    }

    if (meth.specialization != null) {
      isStatic = true;
      meth.flags |= Static;
      this.haxeArgs = this.glueArgs;
    }

    if (meth.flags.hasAny(Final)) {
      addMeta(':final');
      addMeta(':nonVirtual');
    }

    if (this.templated) {
      if (!isVoid) {
        this.haxeCode = ['return cast null;'];
      } else {
        this.haxeCode = ['return;'];
      }
    } else {
      var haxeBodyCall = if (this.isTemplatedThis && !isStatic) {
        '( cast this.wrapped : cpp.Pointer<${this.glueType}> ).ptr.${meth.name}';
      } else {
        '${this.glueType}.${meth.name}';
      };

      var haxeBody =
        '$haxeBodyCall(' +
          [ for (arg in this.glueArgs) arg.t.haxeToGlue(arg.name, this.ctx) ].join(', ') +
        ')';
      if (meth.flags.hasAny(Property) && meth.name.startsWith('set_')) {
        this.haxeCode = [haxeBody + ';' , 'return value;'];
      } else if (!isVoid) {
        this.haxeCode = ['return ' + meth.ret.glueToHaxe(haxeBody, this.ctx) + ';'];
      } else {
        this.haxeCode = [haxeBody + ';'];
      }
    }
  }

  private static function isUObjectPointer(type:TypeConv) {
    if (!type.isUObject) {
      return false;
    }
    return type.ueType.isPointer();
  }

  private function shouldCheckPointer() {
    return !this.meth.flags.hasAny(Static) && !this.thisConv.isUObject;
  }

  private function genCppCall(body:String, prefix:String, outVars:HelperBuf) {
    var cppArgTypes = [];
    for (arg in this.cppArgs) {
      if (arg.t.isTypeParam == true && (arg.t.ownershipModifier == 'unreal.PRef' || arg.t.ownershipModifier == 'ue4hx.internal.PRefDef')) {
        var prefixedArgName = prefix + arg.name;
        outVars << 'auto ${prefixedArgName}_t = ${arg.t.glueToUe(${prefixedArgName}, this.ctx)};\n\t\t\t';
        cppArgTypes.push('*(${prefixedArgName}_t.getPointer())');
      } else {
        cppArgTypes.push(arg.t.glueToUe(prefix+escapeCpp(arg.name, this.isGlueStatic), this.ctx));
      }
    }

    var isStructProp = this.meth.flags.hasAll(StructProperty);
    var isGetter = this.meth.name.startsWith('get_');
    if (isStructProp && isGetter) {
      body = '&' + body;
    } else if (this.meth.flags.hasAny(Property) && isGetter && isUObjectPointer(meth.ret)) {
      body = 'const_cast< ${meth.ret.ueType.getCppType()} >( $body )';
    }

    if (this.meth.flags.hasAny(Property)) {
      if (!isGetter) {
        body += ' = ' + cppArgTypes[cppArgTypes.length-1];
      }
    } else if (this.op == '[') {
      body += '[' + cppArgTypes[0] + ']';
      if (cppArgs.length == 2)
        body += ' = ' + cppArgTypes[1];
    } else if (this.op == '*' || this.op == '++' || this.op == '--' || this.op == '!') {
      if (cppArgs.length > 0) {
        throw new Error('Unreal Glue: unary operators must take zero arguments', meth.pos);
      }
    } else {
      body += '(' + [ for (arg in cppArgTypes) arg ].join(', ') + ')';
    }
    if (!this.glueRet.haxeType.isVoid()) {
      body = 'return ' + this.glueRet.ueToGlue(body, this.ctx);
    }
    return body;
  }

  private function getFunctionCallParams():String {
    var params = new HelperBuf();
    if (this.templated) {
      params << '<';
      params.mapJoin(meth.params, function(param) return param);
      params << '>';
    } else if (this.meth.specialization != null && !this.isTemplatedThis) {
      var useTypeName = this.meth.meta != null && this.meth.meta.hasMeta(':typeName');
      params << '<';
      params.mapJoin(this.meth.specialization.types, function (tconv) return {
        if (useTypeName || (tconv.isUObject && tconv.ownershipModifier == 'unreal.PStruct'))
          tconv.ueType.getCppClassName();
        else
          tconv.ueType.getCppType().toString();
      });
      params << '>';
    }
    return params.toString();
  }

  /**
    Gets the C++ body of this function call
    - May change `this.cppArgs`, `this.retHaxeType` and `this.op`
   **/
  private function getCppBody():String {
    return if (this.meth.flags.hasAny(Static)) {
      switch (meth.uname) {
        case 'new':
          'new ' + meth.ret.ueType.getCppClass();
        case '.ctor':
          meth.ret.ueType.getCppClass();
        case _:
          if (meth.meta.hasMeta(':global')) {
            var namespace = MacroHelpers.extractStringsFromMetadata(meth.meta, ':global')[0];
            if (namespace != null)
              '::' + namespace.replace('.','::') + '::' + meth.uname;
            else
              '::' + meth.uname;
          } else {
            this.thisConv.ueType.getCppClass() + '::' + meth.uname;
          }
      }
    } else {
     var self = if (!isGlueStatic)
        { name: 'this', t: this.thisConv };
      else
        { name:escapeCpp(this.glueArgs[0].name, true), t: glueArgs[0].t };

      switch(meth.uname) {
        case 'get_Item' | 'set_Item':
          this.op = '[';
          '(*' + self.t.glueToUe(self.name, this.ctx) + ')';
        case '.equals':
          var thisType = TypeConv.get(this.type, this.meth.pos, 'unreal.PStruct');
          this.cppArgs = [{ name:'this', t:thisType}, { name:'other', t:thisType }];
          'TypeTraits::Equals<${thisType.ueType.getCppType()}>::isEq';
        case 'op_Dereference':
          this.op = '*';
          '(**(' + self.t.glueToUe(self.name, this.ctx) + '))';
        case 'op_Increment':
          this.op = '++';
          '(++(*(' + self.t.glueToUe(self.name, this.ctx) + ')))';
        case 'op_Decrement':
          this.op = '--';
          '(--(*(' + self.t.glueToUe(self.name, this.ctx) + ')))';
        case 'op_Not':
          this.op = '!';
          '(!(*(' + self.t.glueToUe(self.name, this.ctx) + ')))';
        case '.copy':
          this.retHaxeType = this.thisConv.haxeType;
          this.cppArgs = [{ name:'this', t:TypeConv.get(this.type, this.meth.pos, 'unreal.PStruct') }];
          'new ' + this.thisConv.ueType.getCppClass();
        case '.copyStruct':
          this.retHaxeType = this.thisConv.haxeType;
          this.cppArgs = [{ name:'this', t:TypeConv.get(this.type, this.meth.pos, 'unreal.PStruct') }];
          this.thisConv.ueType.getCppClass();
        case _ if(meth.flags.hasAny(CppPrivate)):
          // For protected external functions we need to use a
          // local derived class with a static function that lets the wrapper
          // call the protected function.
          // See PROTECTED METHOD CALL comments farther down the code.
          '(' + self.t.glueToUe('_s_' + self.name, this.ctx) + '->*(&_staticcall_${meth.name}::' + meth.uname + '))';
        case _ if(meth.flags.hasAny(ForceNonVirtual)):
          self.t.glueToUe(self.name, this.ctx) + '->' + this.thisConv.ueType.getCppClass() + '::' + meth.uname;
        case _:
          self.t.glueToUe(self.name, this.ctx) + '->' + meth.uname;
      }
    }
  }

  private static function escapeCpp(ident:String, alsoThis:Bool):String {
    if (!alsoThis) {
      return ident; // for now we haven't found a problem between Haxe naming and C++
    }
    if (ident == 'this') {
      return 'self';
    }
    return ident;
  }

  public function getField():{ field:Field, glue:Null<Field> } {
    var meta = null;
    if (meth.meta == null) {
      meta = [];
    } else {
      meta = meth.meta.copy();
    }

    meta.push({ name:':glueCppIncludes', params:[for (inc in this.cppIncludes) macro $v{inc}], pos:meth.pos });
    meta.push({ name:':glueHeaderIncludes', params:[for (inc in this.headerIncludes) macro $v{inc}], pos:meth.pos });
    if (this.headerCode != null) {
      meta.push({ name:':glueHeaderCode', params:[macro $v{this.headerCode}], pos:meth.pos });
    }
    if (this.cppCode != null) {
      meta.push({ name:':glueCppCode', params:[macro $v{this.cppCode}], pos:meth.pos });
    }
    if (this.ueHeaderCode != null) {
      meta.push({ name: ':ueHeaderCode', params:[macro $v{this.ueHeaderCode}], pos:meth.pos });
    }

    var glue:Field = null;
    if (!this.templated) {
      var acc:Array<Access> = [APublic];

      if (this.isGlueStatic)
        acc.push(AStatic);

      glue = {
        name: meth.name,
        access: acc,
        pos: meth.pos,
        kind: FFun({
          args: [ for (arg in this.glueArgs) { name:arg.name, type: arg.t.haxeGlueType.toComplexType() } ],
          ret: this.glueRet.haxeGlueType.toComplexType(),
          expr: null
        })
      };
    }

    var acc = [];
    if (meth.flags.hasAny(HaxePrivate)) {
      acc.push(APrivate);
    } else {
      acc.push(APublic);
    }
    if (meth.flags.hasAny(Static)) {
      acc.push(AStatic);
    } else if (meth.flags.hasAny(HaxeOverride)) {
      acc.push(AOverride);
    }
    var block = this.haxeCode;
    if (block != null && Context.defined('UE4_CHECK_POINTER') && this.shouldCheckPointer()) {
      block = ['this.checkPointer();'].concat(block);
    }

    var args = this.getArgs();
    var expr = block != null ? Context.parse('{' + this.haxeCode.join('\n') + '}', meth.pos) : null;
    var field:Field = {
      name: meth.name,
      doc: meth.doc,
      access: acc,
      pos: meth.pos,
      meta: meta,
      kind: FFun({
        args: [ for (arg in args) { name:arg.name, opt:arg.opt, type:arg.type.toComplexType() } ],
        ret: this.retHaxeType.toComplexType(),
        expr: expr,
        params: (meth.params != null ? [ for (param in meth.params) { name: param } ] : null)
      })
    };

    return { glue: glue, field: field };
  }

  private function getArgs():Array<MethodArg> {
    var meth = this.meth;
    if (meth.uname == '.equals')
      return [ { name:this.haxeArgs[0].name, type: new TypeRef(['unreal'], 'Wrapper') } ];
    var args:Array<MethodArg> = [ for (arg in this.haxeArgs) { name:arg.name, type: arg.t.haxeType } ];
    if (meth.params != null) {
      var helpers:Array<MethodArg> = [];
      for (param in meth.params) {
        var name = param + '_TP';
        helpers.push({ name:name, opt:true, type: new TypeRef(['unreal'], 'TypeParam', [new TypeRef(param)]) });
      }
      args = helpers.concat(args);
    }
    return args;
  }

  public function getFieldString(buf:CodeFormatter, glue:CodeFormatter):Void {
    buf << new Comment(meth.doc);
    buf << '@:glueCppIncludes(';
    buf.foldJoin(this.cppIncludes, function(inc:String, buf:CodeFormatter) return buf << '"' << new Escaped(inc) << '"');
    buf << ')' << new Newline();
    buf << '@:glueHeaderIncludes(';
    buf.foldJoin(this.headerIncludes, function(inc:String, buf:CodeFormatter) return buf << '"' << new Escaped(inc) << '"');
    buf << ')' << new Newline();
    if (this.headerCode != null) {
      buf << '@:glueHeaderCode("' << new Escaped(this.headerCode) << '")' << new Newline();
    }
    if (this.cppCode != null) {
      buf << '@:glueCppCode("' << new Escaped(this.cppCode) << '")' << new Newline();
    }
    if (this.ueHeaderCode != null) {
      buf << '@:ueHeaderCode("' << new Escaped(this.ueHeaderCode) << '")' << new Newline();
    }

    buf << meth.meta;

    /// glue
    if (!this.templated) {
      var st = '';
      if (this.isGlueStatic)
        st = 'static';
      glue.add('public $st function ${meth.name}(');
      glue.add([ for (arg in this.glueArgs) escapeCpp(arg.name, this.isGlueStatic) + ':' + arg.t.haxeGlueType.toString() ].join(', '));
      glue.add('):' + this.glueRet.haxeGlueType + ';\n');
    }

    if (meth.flags.hasAny(HaxePrivate)) {
      buf << 'private ';
    } else {
      buf << 'public ';
    }
    if (meth.flags.hasAny(Static)) {
      buf << 'static ';
    } else if (meth.flags.hasAny(HaxeOverride)) {
      buf << 'override ';
    }

    buf << 'function ' << meth.name;
    if (meth.params != null && meth.params.length > 0) {
      buf << '<';
      buf.mapJoin(meth.params, function(p) return p);
      buf << '>';
    }
    buf << '(';
    buf.mapJoin(this.getArgs(), function(arg) return (arg.opt ? '?' : '') + arg.name + ' : ' + arg.type.toString());
    buf << ') : ' << this.retHaxeType.toString();
    if (this.haxeCode == null) {
      buf << ';';
    } else {
      buf << new Begin(' {');
        if (this.shouldCheckPointer()) {
          buf << '#if UE4_CHECK_POINTER'
            << new Newline() << "this.checkPointer();"
            << new Newline() << "#end"
            << new Newline();
        }
        for (expr in this.haxeCode) {
          buf << expr << new Newline();
        }
      buf << new End('}');
    }
  }

  @:isVar private static var voidType(get,null):Null<TypeConv>;

  private static function get_voidType():TypeConv {
    if (voidType == null)
      voidType = TypeConv.get(Context.getType('Void'), null);
    return voidType;
  }
}

typedef MethodDef = {
  /**
    name of this method
   **/
  name:String,

  /**
    unreal-side name of this method
   **/
  uname:String,

  /**
    function arguments
   **/
  args:Array<{ name:String, t:TypeConv }>,

  /**
    return type
   **/
  ret:TypeConv,

  flags:MethodFlags,

  /**
    function documentation, if any
   **/
  ?doc:String,

  /**
    function metadata, if any
   **/
  ?meta:Metadata,

  /**
    function type parameters, if any
   **/
  ?params:Array<String>,

  /**
    if the method is a templated method, sets the specializatin of it
   **/
  ?specialization:{ types:Array<TypeConv>, genericFunction:String },

  pos: Position,
}

@:enum abstract MethodFlags(Int) from Int {
  var None = 0x0;
  /** method is a getter or a setter **/
  var Property = 0x1;
  /** method is a struct getter or setter **/
  var StructProperty = 0x3;
  /** Haxe function is not virtual **/
  var Final = 0x4;
  /** the C++ function is private **/
  var CppPrivate = 0x8;
  /** the generated function is private **/
  var HaxePrivate = 0x10;
  /** the C++ function is static **/
  var Static = 0x20;
  /** the Haxe generated function is override (may happen in some cases - e.g. copy) **/
  var HaxeOverride = 0x40;
  /** the method is calling a forced non-virtual function (if super call, thisConv should be set to the superclass) **/
  var ForceNonVirtual = 0x80;

  inline private function t() {
    return this;
  }

  inline public function hasAny(flags:MethodFlags):Bool {
    return flags.t() & this != 0;
  }

  inline public function hasAll(flags:MethodFlags):Bool {
    return flags.t() & this == flags;
  }

  @:op(A|B) inline public function add(flag:MethodFlags):MethodFlags {
    return this | flag.t();
  }
}

typedef MethodArg = {
  name: String,
  ?opt: Bool,
  type: TypeRef
}
