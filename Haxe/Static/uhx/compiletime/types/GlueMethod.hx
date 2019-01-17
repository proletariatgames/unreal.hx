package uhx.compiletime.types;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import uhx.compiletime.tools.CodeFormatter;
import uhx.compiletime.tools.HelperBuf;
import uhx.compiletime.tools.IncludeSet;

using StringTools;
using Lambda;

using haxe.macro.Tools;
using uhx.compiletime.tools.MacroHelpers;

class GlueMethod {
  ///////////////////////
  /// input parameters
  ///////////////////////
  public var meth(default, null):MethodDef;
  /** the TypeConv where the glue function is defined **/
  public var type(default, null):Type;
  public var isTemplatedThis(default, null):Bool;
  public var glueType:TypeRef;
  public var firstExternSuper:TypeConv;

  ///////////////////////
  /// output parameters
  ///////////////////////
  public var haxeCode:Array<String>;
  public var headerCode:String;
  public var ueHeaderCode:String;
  public var cppCode:String;
  var thisConv(default, null):TypeConv;
  var cppIncludes(default, null):IncludeSet;
  var headerIncludes(default, null):IncludeSet;
  var glueArgs(default, null):Array<{ name:String, t:TypeConv, opt:Null<Expr> }>;
  var cppArgs(default, null):Array<{ name:String, t:TypeConv, opt:Null<Expr> }>;
  var haxeArgs(default, null):Array<{ name:String, t:TypeConv, opt:Null<Expr> }>;
  var glueRet(default, null):TypeConv;
  var retHaxeType(default, null):TypeRef;
  var op(default, null):String;
  var thisRef:TypeRef;

  ///////////////////////
  /// shared parameters
  ///////////////////////
  var isGlueStatic:Bool;
  var templated:Bool;
  var ctx:ConvCtx;

  public function new(meth:MethodDef, type:Type, ?glueType:TypeRef, ?isTemplatedThis:Bool, ?firstExternSuper:TypeConv) {
    this.meth = meth;
    this.type = type;
    this.thisConv = TypeConv.get(type,meth.pos,meth.specialization != null).withModifiers([Ptr]);
    this.firstExternSuper = firstExternSuper;
    this.thisRef = TypeRef.fromType(type, meth.pos);
    if (glueType == null)
      glueType = thisRef.getGlueHelperType();
    this.glueType = glueType;
    this.cppIncludes = new IncludeSet();
    this.headerIncludes = new IncludeSet();
    if (isTemplatedThis == null) {
      isTemplatedThis = thisRef.params.length > 0 && meth.specialization == null;
    }
    this.isTemplatedThis = isTemplatedThis;
    if (this.meth.name == 'new') {
      if (this.meth.meta.hasMeta(':uname')) {
        this.meth.uname = '.ctor';
      }
      this.meth.ret = this.thisConv;
    }

    if (meth.flags.hasAny(Static) && meth.specialization != null && meth.specialization.types.length > 0) {
      switch(meth.uname) {
        case 'new' | '.ctor':
        case _:
          switch(thisConv.data) {
          case CStruct(type,flags,info,params):
            if (params != null && params.length > 0) {
              var sParams = meth.specialization.types.slice(0,params.length),
                  methParams = meth.specialization.types.slice(params.length);
              this.thisConv = thisConv.withData(CStruct(type,flags,info,sParams));
              if (methParams.length > 0) {
                meth.specialization = { types:methParams, genericFunction:meth.specialization.genericFunction };
              } else {
                meth.specialization = null;
              }
            }
          case _:
          }
      }
    }

    this.process();
  }

  private function getReflectiveCode() {
    var isStatic = meth.flags.hasAny(Static);
    if (meth.flags.hasAny(UnrealReflective)) {
      var isProp = meth.flags.hasAny(Property);
      var isUObj = this.thisConv.data.match(CUObject(_));
      if (isProp) {
        var isSetter = meth.name.startsWith('set_');
        if (isSetter) {
          if (isUObj) {
            return [
              'unreal.ReflectAPI.bpSetField(this, "${meth.uname}", ${meth.args[0].name});',
              'return ${meth.args[0].name};',
            ];
          } else {
            return [
              'unreal.ReflectAPI.structSetField(this, uhx_structData, "${meth.uname}", ${meth.args[0].name});',
              'return ${meth.args[0].name};',
            ];
          }
        } else {
          if (isUObj) {
            return [
              'return unreal.ReflectAPI.bpGetField(this, "${meth.uname}");',
            ];
          } else {
            return [
              'return unreal.ReflectAPI.structGetField(this, uhx_structData, "${meth.uname}");',
            ];
          }
        }
      } else {
        var thisObj = isStatic ? 'StaticClass().GetDefaultObject()' : 'this';
        var argNames = [ for (arg in meth.args) arg.name ];
        var args = argNames.length == 0 ? 'null' : ('[' + argNames.join(", ") + ']');
        var ret = [
          'unreal.ReflectAPI.callMethod($thisObj, "${meth.uname}", $args);'
        ];
        if (!meth.ret.haxeType.isVoid()) {
          ret[0] = 'return ' + ret[0];
        }
        return ret;
      }
    } else if (isStatic && meth.name == 'StaticClass') {
      var uname = thisConv.ueType.withoutPointer(true).getCppType().toString();
      return [
        'return uhx.runtime.UReflectionGenerator.getUClass("${uname.substr(1)}");'
      ];
    } else if (isStatic && meth.name == 'StaticStruct') {
      var uname = thisConv.ueType.withoutPointer(true).getCppType().toString();
      return [
        'return uhx.runtime.UReflectionGenerator.getUStruct("${uname.substr(1)}");'
      ];
    }
    return null;
  }

  private function process() {
    var meth = this.meth;
    if (meth.meta == null) {
      meth.meta = [];
    }

    var isStatic = meth.flags.hasAny(Static);
    var isProp = meth.flags.hasAny(Property);
    var haxeArgs = this.haxeArgs = meth.args;
    var isNoTemplate = meth.flags.hasAny(NoTemplate);
    this.retHaxeType = isNoTemplate && meth.ret.tparamName != null ? new TypeRef(meth.ret.tparamName) : meth.ret.haxeType;
    if (Context.defined('cppia')) {
      var refl = getReflectiveCode();
      if (refl != null) {
        this.haxeCode = refl;
        return;
      } else {
        this.haxeCode = ['throw "The function ${meth.name} was not compiled into Unreal.hx. C++ recompilation is needed";'];
        return;
      }
    }

    var ctx = new ConvCtx();
    this.ctx = ctx;

    var glueArgs = this.glueArgs = haxeArgs;
    var isGlueStatic = this.isGlueStatic = !this.isTemplatedThis || isStatic;

    if (!isStatic) {
      // CLEANUP use 'this' directly?
      var name = meth.specialization != null ? 'self' : 'this';
      glueArgs = this.glueArgs = glueArgs.copy();
      glueArgs.unshift({ name: name, t: this.thisConv, opt:null });
    }

    var isSetter = isProp && meth.name.startsWith('set_');
    this.glueRet = isSetter ? voidType : meth.ret;
    var isVoid = this.glueRet.haxeType.isVoid();

    this.templated = meth.params != null && meth.params.length > 0;

    /// glue header code
    var cppArgDecl = new HelperBuf();
    cppArgDecl.mapJoin(this.glueArgs, function(arg) return arg.t.glueType.getCppType() + ' ' + escapeCpp(arg.name, true));
    var glueHeaderCode = new HelperBuf();

    if (this.templated && !isNoTemplate) {
      glueHeaderCode << 'template<';
      glueHeaderCode.mapJoin(meth.params, function(p) return 'class $p');
      glueHeaderCode << '>\n\t';
    }
    if (isGlueStatic) {
      glueHeaderCode << 'static ';
    }
    glueHeaderCode << '${this.glueRet.glueType.getCppType()} ${escapeGlue(meth.name)}(' << cppArgDecl + ')';

    var baseGlueHeaderCode = null;
    if (this.isTemplatedThis && !isStatic) {
      baseGlueHeaderCode = 'virtual ' + glueHeaderCode.toString() + ' = 0;';
      glueHeaderCode << ' override';
    }

    this.cppArgs = meth.args;
    var glueCppBody = new HelperBuf();
    // get cpp body - might change `cppArgs`, `retHaxeType` and `op`
    glueCppBody << this.getCppBody();

    if ((this.templated || meth.specialization != null) && !isNoTemplate) {
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
      localDerivedClassBody << '\ttypedef ${this.meth.ret.ueType.getCppType()} (${this.thisConv.ueType.getCppClass()}::*UHXGLUEFN) (';
      var first = true;
      for (arg in this.cppArgs) {
        if (first) {
          first = false;
        } else {
          localDerivedClassBody << ', ';
        }
        localDerivedClassBody << arg.t.ueType.getCppType().toString();
      }
      localDerivedClassBody << ');\n';
      var staticCppArgDecl = [ for ( arg in this.glueArgs ) arg.t.glueType.getCppType() + ' ' + '_s_' + escapeCpp(arg.name, true) ].join(', ');
      localDerivedClassBody << '\t\tpublic:\n\t\t\tstatic ${this.glueRet.glueType.getCppType()} static_${meth.name}(${staticCppArgDecl}) {\n\t\t\t\t'
        << staticCppVars.toString()
        << staticCppBody.toString()
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
    if (this.templated && !isNoTemplate) {
      glueCppCode << 'template<';
      glueCppCode.mapJoin(meth.params, function(p) return 'class $p');
      glueCppCode << '>\n\t';
    }

    if (this.isTemplatedThis && !isStatic) {
      glueHeaderCode << ' {\n\t\t\t$glueCppBodyVars;\n\t\t}';
    } else {
      glueHeaderCode << ';';
      glueCppCode <<
        this.glueRet.glueType.getCppType().toString() <<
        ' ${this.glueType.getCppType()}_obj::${escapeGlue(meth.name)}(' << cppArgDecl << ') {' <<
          '\n\t' << glueCppBodyVars << ';\n}';
    }

    var allTypes = [ for (arg in this.glueArgs) arg.t ];
    allTypes.push(meth.ret);

    inline function addMeta(name:String) {
      meth.meta.push({ name:name, pos:meth.pos });
    }

    if (!this.templated || isNoTemplate) {
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
      cppIncludes.add('<uhx/TypeTraits.h>');
    }

    for (type in allTypes) {
      type.collectUeIncludes( cppIncludes );
      type.collectGlueIncludes( headerIncludes );
    }

    if (this.templated && !isNoTemplate) {
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

    if (this.templated && !isNoTemplate) {
      if (!isVoid) {
        this.haxeCode = ['return cast null;'];
      } else {
        this.haxeCode = ['return;'];
      }
    } else {
      var body = null;
      var haxeBodyCall = if (this.isTemplatedThis && !isStatic) {
        body = 'var thisDataPointer:cpp.ConstPointer<${this.glueType}> =cpp.ConstPointer.fromRaw((@:privateAccess this.getTemplateStruct()).info.ptr.genericImplementation).reinterpret();';
        'thisDataPointer.ptr.${escapeGlue(meth.name)}';
      } else {
        '${this.glueType}.${escapeGlue(meth.name)}';
      };
      this.haxeCode = [];
      if (this.meth.uname != '.equals') {
        for (arg in meth.args) {
          switch(arg.t.data) {
            case CStruct(_) if(!arg.t.hasModifier(Ref) && !arg.t.hasModifier(Ptr) && arg.opt == null):
              haxeCode.push('if (${arg.name} == null) uhx.internal.HaxeHelpers.nullDeref("${arg.name}");');
            case _:
          }
        }
      }

      for (i in 0...this.glueArgs.length) {
        var arg = this.glueArgs[i],
            optional = getOptional(arg.t, arg.opt);
        if (optional == null) {
          this.haxeCode.push('var uhx_arg_$i:${arg.t.haxeGlueType.toString()} = ${arg.t.haxeToGlue(arg.name, this.ctx)};');
        } else {
          this.haxeCode.push('var uhx_arg_$i:${arg.t.haxeGlueType.toString()} = ${arg.t.haxeToGlue('${arg.name} != null ? (${arg.name}) : ($optional)', this.ctx)};');
        }
      }
      var haxeBody =
        '$haxeBodyCall(' +
          [ for (i in 0...this.glueArgs.length) 'uhx_arg_$i' ].join(', ') +
        ')';
      if (meth.flags.hasAny(Property) && meth.name.startsWith('set_')) {
        this.haxeCode = this.haxeCode.concat([haxeBody + ';' , 'return value;']);
      } else if (!isVoid) {
        this.haxeCode = this.haxeCode.concat(['return ' + meth.ret.glueToHaxe(haxeBody, this.ctx) + ';']);
      } else {
        this.haxeCode = this.haxeCode.concat([haxeBody + ';']);
      }

      if (body != null) {
        this.haxeCode.unshift(body);
      }
    }
  }

  private static function parseDefault(str:String):Map<String, String> {
    var parenRegex=~/\(?([^\)]+)\)?/;
    if (parenRegex.match(str)) {
      var ret = new Map();
      var data = parenRegex.matched(1);
      var i = 0;
      for (val in data.split(',')) {
        var set = val.trim().split('=');
        if (set.length == 1) {
          ret['arg${i++}'] = set[0];
        } else {
          ret[set[0]] = set[1];
        }
      }
      return ret;
    }

    return null;
  }

  private function getOptional(t:TypeConv, opt:Null<Expr>) {
    if (opt == null) {
      return null;
    }
    switch(opt.expr) {
    case EConst(CIdent(name = "null") | CString(name = "None")):
      switch(t.data) {
      case CStruct(_,_,info,_):
        switch(info.ueType.name) {
        case 'FString' | 'FText':
          return '("" : unreal.${info.ueType.name})';
        case 'FName':
          return 'unreal.FName.None';
        case _:
        }
      case CEnum(_) if (name == "None"):
        return '(' + name + ' : ' + t.haxeType.toString() + ')';
      case _:
      }
      return 'null';
    case EConst(CString(s)):
      switch(t.data) {
      case CStruct(_,_,info,_):
        switch(info.ueType.name) {
        case 'FString' | 'FText' | 'FName':
          return '(' + opt.toString() + ' : unreal.${info.ueType.name})';
        case 'FLinearColor':
          var def = parseDefault(s);
          if (def != null) {
            var r = def['R'], g = def['G'], b = def['B'], a = def['A'];
            if (r != null && g != null && b != null && a != null) {
              return 'unreal.FLinearColor.createWithValues($r,$g,$b,$a)';
            }
          }
          return null;
        case 'FVector2D':
          var def = parseDefault(s);
          if (def != null) {
            var x = def['X'], y = def['Y'];
            if (x != null && y != null) {
              return 'unreal.FVector2D.createWithValues($x,$y)';
            }
          }
          return null;
        case 'FVector':
          var def = parseDefault(s);
          if (def != null) {
            var x = def['X'], y = def['Y'], z = def['Z'];
            if (x == null && y == null && z == null) {
              x = def['arg0'];
              y = def['arg1'];
              z = def['arg2'];
            }
            if (x != null && y != null && z != null) {
              return 'unreal.FVector.createWithValues($x,$y,$z)';
            }
          }
          return null;
        case 'FRotator':
          var def = parseDefault(s);
          if (def != null) {
            var pitch = def['arg0'], yaw = def['arg1'], roll = def['arg2'];
            if (pitch != null && yaw != null && roll != null) {
              return 'unreal.FRotator.createWithValues($pitch,$yaw,$roll)';
            }
          }
          return null;
        case name:
          Context.warning('Unsupported optional value $s for type ${t.haxeType}', meth.pos);
          return null;
        }
      case CEnum(_):
        return '(' + s + ' : ' + t.haxeType.toString() + ')';
      case _:
        Context.warning('Unrecognized optional value $s for type ${t.haxeType}', meth.pos);
      }
    case _:
      return '(' + opt.toString() + ' : ' + t.haxeType.toString() + ')';
    }
    return null;
  }

  private static function isUObjectPointer(type:TypeConv) {
    if (!type.data.match(CUObject(_))) {
      return false;
    }
    return type.ueType.isPointer();
  }

  private function shouldCheckPointer() {
    return !this.meth.flags.hasAny(Static);
  }

  private function genCppCall(body:String, prefix:String, outVars:HelperBuf) {
    if (this.meth.meta != null && this.meth.meta.hasMeta(':glueCppBody')) {
      return body;
    }

    var cppArgTypes = [];
    for (arg in this.cppArgs) {
      if (arg.t.data.match(CTypeParam(_)) && arg.t.hasModifier(Ref)) {
        var prefixedArgName = prefix + arg.name;
        outVars << 'auto ${prefixedArgName}_t = ${arg.t.glueToUe(${prefixedArgName}, this.ctx)};\n\t\t\t';
        cppArgTypes.push('*(${prefixedArgName}_t.getPointer())');
      } else {
        cppArgTypes.push(arg.t.glueToUe(prefix+escapeCpp(arg.name, this.isGlueStatic || this.isTemplatedThis), this.ctx));
      }
    }

    var isStructProp = this.meth.flags.hasAll(StructProperty);
    var isGetter = this.meth.name.startsWith('get_');
    if (isStructProp && isGetter) {
      body = '&($body)';
    } else if (this.meth.flags.hasAny(Property) && isGetter && isUObjectPointer(meth.ret)) {
      body = 'const_cast< ${meth.ret.ueType.getCppType()} >( $body )';
    }

    if (this.meth.uname == '.ctor' && this.meth.flags.hasAny(Static)) {
      return 'return ' + this.glueRet.ueToGlueCtor( cppArgTypes.join(', '), [ for (arg in cppArgs) arg.t ], this.ctx );
    } else if (this.meth.uname == '.mkWrapper') {
      return 'return ' + this.glueRet.ueToGlueCtor( cppArgTypes.join(', '), [], this.ctx, true );
    } else if (this.meth.flags.hasAny(Property)) {
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
    } else if (meth.uname == '.equals') {
      // these variables are guaranteed to have this name - see getCppBody
      outVars << 'if (self == other) { return true; }';
      outVars << 'if (self.isNull() || other.isNull()) { return false; }';
      body += '(' + cppArgTypes.join(', ') + ')';
    } else {
      body += '(' + cppArgTypes.join(', ') + ')';
    }
    var gcFree = this.meth.meta.hasMeta(':gcFree');
    if (gcFree) {
      cppIncludes.add('<uhx/expose/HxcppRuntime.h>');
      outVars << '::uhx::expose::HxcppRuntime::enterGCFreeZone();';
    }
    if (!this.glueRet.haxeType.isVoid()) {
      if (gcFree) {
        outVars << meth.ret.ueType.getCppType() + ' hx_gc_free_ret = $body;';
        outVars << '::uhx::expose::HxcppRuntime::exitGCFreeZone();';
        body = 'return ' + this.glueRet.ueToGlue('hx_gc_free_ret', this.ctx);
      } else {
        body = 'return ' + this.glueRet.ueToGlue(body, this.ctx);
      }
    } else if (gcFree) {
      body = '($body, ::uhx::expose::HxcppRuntime::exitGCFreeZone())';
    }
    return body;
  }

  private function getFunctionCallParams():String {
    var params = new HelperBuf();
    if (this.templated) {
      params << '<';
      params.mapJoin(meth.params, function(param) return param.t.tparamName != null ? (param.t.tparamName + ' : ' + param.t.haxeType) : param.name);
      params << '>';
    } else if (this.meth.specialization != null && !this.isTemplatedThis) {
      var useTypeName = this.meth.meta != null && this.meth.meta.hasMeta(':typeName');
      params << '<';
      params.mapJoin(this.meth.specialization.types, function (tconv) return {
        if (useTypeName) // || (tconv.data.match(CUObject(_)))) // FIXME - we don't have PStruct anymore && tconv.ownershipModifier == 'unreal.PStruct'))
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
    if (this.meth.meta != null && this.meth.meta.hasMeta(':glueCppBody')) {
      var ret = MacroHelpers.extractStringsFromMetadata(meth.meta, ':glueCppBody')[0];
      if (ret != null) {
        return ret;
      }
    }

    return if (this.meth.flags.hasAny(Static)) {
      switch (meth.uname) {
        case 'new':
          'new ' + meth.ret.ueType.getCppClass(true); // parameters will be set by the static call already
        case '.ctor' | '.ctor.struct':
          meth.ret.ueType.getCppClass(true); // parameters will be set by the static call already
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
     var self = if (!isGlueStatic && !this.isTemplatedThis)
        { name: 'this', t: this.thisConv };
      else
        { name:escapeCpp(this.glueArgs[0].name, true), t: glueArgs[0].t };

      switch(meth.uname) {
        case 'get_Item' | 'set_Item':
          this.op = '[';
          '(*' + self.t.glueToUe(self.name, this.ctx) + ')';
        case '.equals':
          var thisType = this.thisConv.withModifiers(null);
          this.cppArgs = [{ name:'this', t:thisType, opt:null}, { name:'other', t:thisType, opt:null }];
          if (this.meth.meta == null) this.meth.meta = [];
          // this.meth.meta.push({ name:':op', params:[macro A == B], pos:meth.pos});
          'uhx::TypeTraits::Equals<${thisType.ueType.getCppType()}>::isEq';
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
          this.cppArgs = [{ name:'this', t:this.thisConv.withModifiers(null), opt:null }];
          'new ' + this.thisConv.ueType.getCppClass();
        case '.copyStruct':
          this.cppArgs = [{ name:'this', t:this.thisConv.withModifiers(null), opt:null }];
          ''; // we are already going to dereference it, which will be enough to invoke the copy constructor
        case '.assign':
          var thisType = this.thisConv.withModifiers(null);
          this.cppArgs = [{ name:'this', t:thisType, opt:null }, {name:'val', t:thisType, opt:null}];
          'uhx::TypeTraits::Assign<${thisType.ueType.getCppType()}>::doAssign';
        case _ if(meth.flags.hasAny(CppPrivate)):
          if (meth.flags.hasAny(Property)) {
            '(((_staticcall_${meth.name}*)(' + self.t.glueToUe('_s_' + self.name, this.ctx) + '))->' + meth.uname + ')';
          } else {
            // For protected external functions we need to use a
            // local derived class with a static function that lets the wrapper
            // call the protected function.
            // See PROTECTED METHOD CALL comments farther down the code.
            if (meth.flags.hasAny(ForceNonVirtual) && this.firstExternSuper != null) {
              // if we are calling a virtual type non-virtually, we have to cast the type
              // to a type it really isn't. But since the call is non-virtual, and the expected type
              // is not the type we are casting to, this should work correctly
              var baseClass = this.firstExternSuper.ueType.getCppClass();
              '( ((_staticcall_${meth.name} *)' + self.t.glueToUe('_s_' + self.name, this.ctx) + ')->$baseClass::' + meth.uname + ')';
            } else {
              '(' + self.t.glueToUe('_s_' + self.name, this.ctx) + '->*((UHXGLUEFN) &_staticcall_${meth.name}::' + meth.uname + '))';
            }
          }
        case _ if(meth.flags.hasAny(ForceNonVirtual)):
          var superConv = this.firstExternSuper;
          if (superConv == null) {
            superConv = this.thisConv;
          }
          self.t.glueToUe(self.name, this.ctx) + '->' + superConv.ueType.getCppClass() + '::' + meth.uname;
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

  private static function escapeGlue(ident:String) {
    return ident == 'new' ? 'glueNew' : ident;
  }

  public function getFieldMeta(?includeExisting:Bool=false) {
    var meta = null;
    if (includeExisting && meth.meta != null) {
      meta = meth.meta.copy();
    } else {
      meta = [];
    }

    meta.push({ name:':glueCppIncludes', params:[for (inc in this.cppIncludes) macro $v{inc}], pos:meth.pos });
    meta.push({ name:':glueHeaderIncludes', params:[for (inc in this.headerIncludes) macro $v{inc}], pos:meth.pos });
    if (this.headerCode != null && !meta.hasMeta(':glueHeaderCode')) {
      meta.push({ name:':glueHeaderCode', params:[macro $v{this.headerCode}], pos:meth.pos });
    }
    if (this.cppCode != null && !meta.hasMeta(':cppCode')) {
      meta.push({ name:':glueCppCode', params:[macro $v{this.cppCode}], pos:meth.pos });
    }
    if (this.ueHeaderCode != null && !meta.hasMeta(':ueHeaderCode')) {
      meta.push({ name: ':ueHeaderCode', params:[macro $v{this.ueHeaderCode}], pos:meth.pos });
    }

    return meta;
  }

  public function getField():{ field:Field, glue:Null<Field> } {
    var meta = getFieldMeta(true);

    var glue:Field = null;
    var isNoTemplate = meth.flags.hasAny(NoTemplate);
    if (!this.templated || isNoTemplate) {
      var acc:Array<Access> = [APublic];

      if (this.isGlueStatic)
        acc.push(AStatic);

      glue = {
        name: escapeGlue(meth.name),
        access: acc,
        pos: meth.pos,
        kind: FFun({
          args: [ for (arg in this.glueArgs) { name:escapeCpp(arg.name, true), type: arg.t.haxeGlueType.toComplexType() } ],
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
    if (meth.flags.hasAny(Static) && meth.name != 'new') {
      acc.push(AStatic);
    } else if (meth.flags.hasAny(HaxeOverride)) {
      acc.push(AOverride);
    }
    var block = this.haxeCode;

    var args = this.getArgs();
    var code = this.haxeCode.join('\n');
    if (shouldCheckPointer()) {
      var checkCompl = this.thisConv.data.match(CUObject(_)) ? 'Object' : '';
      code = 'uhx.internal.HaxeHelpers.check${checkCompl}Pointer(this, "${meth.name}");\n' + code;
    }
    var expr = block != null ? Context.parse('{' + code + '}', meth.pos) : null;
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
        params: (meth.params != null ? [ for (param in meth.params) { name: param.name, constraints: param.t.tparamName != null ? [param.t.haxeType.toComplexType()] : null } ] : null)
      })
    };

    return { glue: glue, field: field };
  }

  private function getArgs():Array<MethodArg> {
    var meth = this.meth;
    if (meth.uname == '.equals')
      return [ { name:this.haxeArgs[0].name, type: this.thisConv.haxeType } ];
    var args:Array<MethodArg> = [ for (arg in this.haxeArgs) { name:arg.name, type: arg.t.haxeType, opt:arg.opt != null } ];
    if (meth.params != null) {
      var helpers:Array<MethodArg> = [];
      for (param in meth.params) {
        var name = param.name + '_TP';
        helpers.push({ name:name, opt:true, type: new TypeRef(['unreal'], 'TypeParam', [new TypeRef(param.name)]) });
      }
      args = helpers.concat(args);
    }
    return args;
  }

  public function getFieldString(buf:CodeFormatter, glue:CodeFormatter):Void {
    buf << new Comment(meth.doc);
    var meta = this.meth.meta;
    if (meth.specialization != null || !meta.hasMeta(':glueCppIncludes')) {
      buf << '@:glueCppIncludes(';
      buf.foldJoin(this.cppIncludes, function(inc:String, buf:CodeFormatter) return buf << '"' << new Escaped(inc) << '"');
      buf << ')' << new Newline();
    }

    if (meth.specialization != null || !meta.hasMeta(':glueHeaderIncludes')) {
      buf << '@:glueHeaderIncludes(';
      buf.foldJoin(this.headerIncludes, function(inc:String, buf:CodeFormatter) return buf << '"' << new Escaped(inc) << '"');
      buf << ')' << new Newline();
    }
    if (this.headerCode != null && !meta.hasMeta(':glueHeaderCode')) {
      buf << '@:glueHeaderCode("' << new Escaped(this.headerCode) << '")' << new Newline();
    }
    if (this.cppCode != null && !meta.hasMeta(':glueCppCode')) {
      buf << '@:glueCppCode("' << new Escaped(this.cppCode) << '")' << new Newline();
    }
    if (this.ueHeaderCode != null && !meta.hasMeta(':ueHeaderCode')) {
      buf << '@:ueHeaderCode("' << new Escaped(this.ueHeaderCode) << '")' << new Newline();
    }

    if (this.haxeCode != null && this.cppCode != null && !meth.flags.hasAny(UnrealReflective) && meth.name != 'StaticClass') {
      var thisType = thisRef.getClassPath().replace('.','_');
      buf << '#if (!UHX_DISPLAY && cppia)' << new Newline();
      buf << '@:deprecated("UHXERR: The field '
          << meth.name
          << ' was not compiled into the latest C++ compilation. Please perform a full C++ compilation.")' << new Newline();
      buf << '#end' << new Newline();
    }

    buf << meth.meta;

    /// glue
    var isNoTemplate = meth.flags.hasAny(NoTemplate);
    if ((!this.templated || isNoTemplate) && this.glueArgs != null) {
      var st = '';
      if (this.isGlueStatic)
        st = 'static';
      glue.add('public $st function ${escapeGlue(meth.name)}(');
      glue.add([ for (arg in this.glueArgs) escapeCpp(arg.name, this.isGlueStatic || this.isTemplatedThis) + ':' + arg.t.haxeGlueType.toString() ].join(', '));
      glue.add('):' + this.glueRet.haxeGlueType + ';\n');
    }

    if (meth.flags.hasAny(HaxePrivate)) {
      buf << 'private ';
    } else {
      buf << 'public ';
    }
    if (meth.flags.hasAny(Static) && meth.name != 'new') {
      buf << 'static ';
    } else if (meth.flags.hasAny(HaxeOverride)) {
      buf << 'override ';
    }

    buf << 'function ' << meth.name;
    if (meth.params != null && meth.params.length > 0) {
      buf << '<';
      buf.mapJoin(meth.params, function(param) return param.t.tparamName != null ? (param.t.tparamName + ' : ' + param.t.haxeType.toString()) : param.name);
      buf << '>';
    }
    buf << '(';
    buf.mapJoin(this.getArgs(), function(arg) return (arg.opt ? '?' : '') + arg.name + ' : ' + arg.type.toString());
    buf << ') : ' << this.retHaxeType.toString();
    if (this.haxeCode == null) {
      buf << ';';
    } else {
      buf << new Begin(' {');
        if (shouldCheckPointer()) {
          var checkCompl = this.thisConv.data.match(CUObject(_)) ? 'Object' : '';
          buf << '#if (debug || UHX_CHECK_POINTER)' << new Newline();
          buf << 'uhx.internal.HaxeHelpers.check${checkCompl}Pointer(this, "${meth.name}");' << new Newline();
          buf << '#end' << new Newline();
        }

        var refl = this.getReflectiveCode();
        buf << '#if cppia' << new Newline();
        if (refl != null) {
          for (expr in refl) {
            buf << expr << new Newline();
          }
        } else {
          buf << 'throw "The function ${meth.name} was not compiled into Unreal.hx. C++ recompilation is needed";';
        }
        buf << new Newline() << '#else' << new Newline();

        for (expr in this.haxeCode) {
          buf << expr << new Newline();
        }
        buf << new Newline() << '#end' << new Newline();
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
  args:Array<{ name:String, t:TypeConv, opt:Null<Expr> }>,

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
  ?params:Array<{ name:String, t:TypeConv }>,

  /**
    if the method is a templated method, sets the specializatin of it
   **/
  ?specialization:{ types:Array<TypeConv>, genericFunction:String },

  pos: Position,
}

@:enum abstract MethodFlags(Int) from Int {
  var MNone = 0x0;
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
  /** method is a ufunction / uproperty **/
  var UnrealReflective = 0x100;
  /** method was declared as inline **/
  var Inline = 0x200;
  /** even though this is a generic function definition, make the glue for it as if it was not **/
  var NoTemplate = 0x400;

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
