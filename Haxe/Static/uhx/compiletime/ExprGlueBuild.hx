package uhx.compiletime;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import uhx.compiletime.tools.HelperBuf;
import uhx.compiletime.tools.HeaderWriter;
import uhx.compiletime.tools.*;
import uhx.compiletime.types.*;
import sys.FileSystem;

using haxe.macro.Tools;
using Lambda;
using StringTools;
using uhx.compiletime.tools.MacroHelpers;

/**
  Builds glue code outside of the extern baker pass - by being called as a macro (called by uhx.internal.DelayedGlue, from NeedsGlueBuild)
 **/
class ExprGlueBuild {
  public static function getGetterSetterExpr(fieldName:String, isStatic:Bool, isSetter:Bool, isDynamic:Bool, fieldUName:String):Expr {
    var clsRef = Context.getLocalClass(),
        cls = clsRef.get(),
        pos = Context.currentPos();

    var abs = switch(cls.kind) {
      case KAbstractImpl(a):
        a;
      case _:
        null;
    };

    var field = findField(cls, fieldName, isStatic || abs != null);
    if (field == null) throw 'assert';
    var tconv = TypeConv.get(field.type, pos);

    var fullName = (isSetter ? 'set_' : 'get_') + fieldName;
    inline function getSig() {
      return (field.meta == null ? '' :UhxMeta.getStaticMetas(field.meta.get())) + fullName + ':' + tconv.ueType.getCppType();
    }

    if (Context.defined('cppia')) {
      if (isDynamic) {
        var staticPropName = 'uhx__prop_${fieldName}';
        var propCheck = macro
          if ($i{staticPropName} == null) {
            $i{staticPropName} = unreal.ReflectAPI.getUPropertyFromClass(this.GetClass(), $v{fieldUName});
          };
        if (isSetter) {
          return macro {
            $propCheck;
            unreal.ReflectAPI.setProperty(this, $i{staticPropName}, value);
          };
        } else {
          return macro {
            $propCheck;
            unreal.ReflectAPI.getProperty(this, $i{staticPropName});
          };
        }
      } else {
        var sig = getSig();
        if (!Globals.cur.compiledScriptGluesExists(clsRef.toString() + ':' +sig) && !Context.defined('display')) {
          Context.warning('UHXERR: The field $fullName from $clsRef was not compiled into static, or it was compiled with a different signature. A full C++ compilation is required', Context.currentPos());
        }
      }
      var args = [];
      if (!isStatic) {
        args.push(macro this);
      }
      if (isSetter) {
        args.push(macro value);
      }
      var helper = TypeRef.fromBaseType(cls, pos).getScriptGlueType();
      var resolver = macro (cast std.Type.resolveClass($v{helper.getClassPath(true)}) : Dynamic);
      if (cls.meta.has(':hasGlueScriptGetter')) {
        resolver = macro uhx_glueScript;
      }
      return { expr:ECall(macro $resolver.$fullName, args), pos: pos };
    }

    // var ctx = !isStatic && !TypeConv.get(Context.getLocalType(), pos).data.match(CUObject(_)) ? [ "parent" => "this" ] : null;
    var ctx = new ConvCtx();

    var glueType = getGlueType(clsRef, pos);
    var glueExpr = new HelperBuf(),
        glueBlock = new HelperBuf();

    var args = [];
    var narg = 0;
    if (!isStatic) {
      var thisConv = TypeConv.get( Context.getLocalType(), pos ).withModifiers([Ptr]);
      args.push(narg);
      glueBlock << 'var tmp${narg++} = ' << thisConv.haxeToGlue('this', ctx) << ';\n';
    }
    if (isSetter) {
      args.push(narg);
      glueBlock << 'var tmp${narg++} = ' << tconv.haxeToGlue('value', ctx) << ';\n';
    }

    glueExpr << 'untyped __cpp__("${glueType.getCppClass()}::';
    glueExpr << (isSetter ? 'set_' : 'get_') << fieldName << '(';

    glueExpr.mapJoin(args, function(i) return '{$i}');

    glueExpr << ')"';
    if (args.length != 0) {
      glueExpr << ', ';
    } else {
      glueExpr << ' ';
    }

    glueExpr.mapJoin(args, function(i) return 'tmp$i');
    glueExpr << ')';

    // dummy call to make hxcpp include the correct header if needed
    var expr ='{ $glueType.uhx_dummy_field(); ' +
      glueBlock.toString() +
      (isSetter ? glueExpr.toString() : tconv.glueToHaxe( glueExpr.toString(), ctx)) + '; }';

    var ret = Context.parse(expr, pos);
    var meta = cls.meta;
    switch(cls.kind) {
    case KAbstractImpl(a):
      meta = a.get().meta;
    case _:
    }
    if (meta.has(UhxMeta.UScript)) {
      var toFlag = ret;
      if (isSetter) {
        toFlag = macro { $ret; value; };
      }
      var sig = getSig();
      flagCurrentField(fullName, cls, isStatic, toFlag, sig);
    }
    return ret;
  }

  public static function checkClass() {
    var clsRef = Context.getLocalClass(),
        cls = clsRef.get();

    if (cls.meta.has(':uclass') && (Context.defined('cppia') || Context.defined('WITH_CPPIA'))) {
      var sig = UhxMeta.getStaticMetas(cls.meta.get()) + '@Class';
      if (Context.defined('cppia')) {
        if (!Globals.cur.compiledScriptGluesExists(clsRef.toString() + ':$sig')) {
          Context.warning('UHXERR: The class ${clsRef} was not compiled into static, or it was compiled with different metadata', cls.pos);
        }
      } else {
        cls.meta.add(UhxMeta.UCompiled, [macro $v{sig}], cls.pos);
      }
    }
  }

  public static function checkCompiled(fieldName:String, type:Type, pos:Position, isStatic:Bool):Void {
    var clsRef = Context.getLocalClass();
    switch(Context.follow(type)) {
    case TFun(args,ret):
      var sig = '$fieldName(' + [for (arg in args) TypeConv.get(arg.t, pos).ueType.getCppType()].join(',') + '):' + TypeConv.get(ret, pos).ueType.getCppType();
      var cls = clsRef.get();
      var field = findField(cls, fieldName, isStatic);
      if (field == null) {
        Context.warning('Field $fieldName was not found in $clsRef', pos);
      } else {
        if (field.meta != null) {
          sig = UhxMeta.getStaticMetas(field.meta.get()) + sig;
        }
      }
      if (Context.defined('cppia')) {
        if (!Globals.cur.compiledScriptGluesExists(clsRef.toString() + ":" + sig)) {
          Context.warning('UHXERR: The function $fieldName from $clsRef was not compiled into static, or it was compiled with a different signature. A full C++ compilation is required', pos);
        }
      } else {
        cls.meta.add(UhxMeta.UCompiled, [macro $v{sig}], pos);
      }
    case _:
    }
  }

  public static function getSuperExpr(fieldName:String, targetFieldName:String, args:Array<Expr>, script:Bool):Expr {
    var clsRef = Context.getLocalClass(),
        cls = clsRef.get(),
        pos = Context.currentPos();
    inline function checkSuper(superField:ClassField) {
      for (meta in superField.meta.extract(':ufunction')) {
        for (meta in meta.params) {
          if (UExtensionBuild.ufuncBlueprintOverridable(meta) && !UExtensionBuild.ufuncBlueprintNativeEvent(meta)) {
            throw new Error('Unreal Glue Generation: This super call "$fieldName" cannot be called, since its parent function is an unimplemented BlueprintImplementableEvent', pos);
          }
        }
      }
    }

    // make sure that the eluper field was not already defined in haxe code
    var sup = cls.superClass;
    while (sup != null) {
      var scls = sup.t.get();
      if (scls.meta.has(':uextern')) break;
      for (sfield in scls.fields.get()) {
        if (sfield.name == fieldName) {
          checkSuper(sfield);
          // this field was already defined in a Haxe class; just use normal super
          return { expr:ECall(macro @:pos(pos) super.$fieldName, args), pos:pos };
        }
      }
      sup = scls.superClass;
    }
    var superClass = cls.superClass;
    if (superClass == null) {
      throw new Error('Unreal Glue Generation: Field calls super but no superclass was found', pos);
    }
    var field = sup == null ? null : findField(sup.t.get(), fieldName, false);
    if (field == null) {
      throw new Error('Unreal Glue Generation: Field calls super but no field was found on super class', pos);
    }
    checkSuper(field);
    var fargs = null, fret = null;
    switch(Context.follow(field.type)) {
    case TFun(targs,tret):
      var argn = 0;
      // TESTME: add test for super.call(something, super.call(other))
      fargs = [ for (arg in targs) { name:'__usuper_arg' + argn++, type:TypeConv.get(arg.t, pos) } ];
      fret = TypeConv.get(tret, pos);
    case _: throw 'assert';
    }
    var sig = Context.defined('cppia') || Context.defined('WITH_CPPIA') ?
      'super.$fieldName(' + [for (arg in fargs) arg.type.ueType.getCppType()].join(',') + '):' + fret.ueType.getCppType() :
      null;
    if (Context.defined('cppia')) {
      var sigCheck = clsRef.toString() + ':' + sig;
      if (!Globals.cur.compiledScriptGluesExists(sigCheck) && !Context.defined('display')) {
        Context.warning('UHXERR: The super call of $fieldName from $clsRef was not compiled into static, or it was compiled with a different signature. A full C++ compilation is required', Context.currentPos());
      }
      var args = [macro this].concat(args);
      var helper = TypeRef.fromBaseType(cls, pos).getScriptGlueType();
      var resolver = macro (cast std.Type.resolveClass($v{helper.getClassPath(true)}) : Dynamic);
      if (cls.meta.has(':hasGlueScriptGetter')) {
        resolver = macro uhx_glueScript;
      }
      var ret = { expr:ECall(macro $resolver.$targetFieldName, args), pos: pos };
      if (!fret.haxeType.isVoid()) {
        var rtype = fret.haxeType.toComplexType();
        ret = macro ( $ret : $rtype );
      }
      return ret;
    }

    var origArgs = switch(Context.follow(findField(cls, fieldName, false).type)) {
      case TFun(args,_): args;
      case _: throw 'assert';
    }
    if (fargs.length != args.length)
      throw new Error('Unreal Glue Generation: super.$fieldName number of arguments differ from super. Expected ${fargs.length}; got ${args.length}', pos);
    var argn = 0;
    var block = [ for (arg in args) {
      var name = '__usuper_arg' + argn++;
      macro var $name = $arg;
    } ];
    fargs.unshift({ name:'this', type: TypeConv.get(Context.getLocalType(), pos) });

    var glueType = getGlueType(clsRef, pos);
    var glueExpr = new HelperBuf();
    var idx = 0;
    for (arg in fargs) {
      block.push(Context.parse('var tmp${idx++} = ' + arg.type.haxeToGlue(arg.name, null), pos));
    }

    idx = 0;
    glueExpr << 'untyped __cpp__("' << glueType.getCppClass() << '::' << fieldName << '(';
    glueExpr.mapJoin(fargs, function (_) return '{${idx++}}');
    glueExpr << ')"';
    if (fargs.length > 0) {
      glueExpr << ', ';
    }

    idx = 0;
    glueExpr.mapJoin(fargs, function(arg) return 'tmp${idx++}');
    glueExpr << ')';

    var expr = glueExpr.toString();
    if (!fret.haxeType.isVoid()) {
      expr = '( ' + fret.glueToHaxe(expr, null) + ' : ${fret.haxeType} )';
    }

    // dummy call to make hxcpp include the correct header if needed
    block.push(Context.parse(glueType.toString() + '.uhx_dummy_field()', pos));
    block.push(Context.parse(expr, pos));

    var ret = if (block.length == 1)
      block[0];
    else
      { expr:EBlock(block), pos: pos };
    var meta = cls.meta;
    switch(cls.kind) {
    case KAbstractImpl(a):
      meta = a.get().meta;
    case _:
    }
    if (meta.has(':uscript') && !script) {
      var expr = getSuperExpr(fieldName, targetFieldName, [for (arg in origArgs) macro $i{arg.name} ], true);
      flagCurrentField(targetFieldName, cls, false, expr, sig);
    }
    return ret;
  }

  public static function getNativeCall(fieldName:String, isStatic:Bool, args:Array<Expr>, script:Bool):Expr {
    var clsRef = Context.getLocalClass(),
        cls = clsRef.get(),
        pos = Context.currentPos();

    var abs = switch(cls.kind) {
      case KAbstractImpl(a):
        a;
      case _:
        null;
    };

    var field = findField(cls, fieldName, isStatic || abs != null);
    if (field == null)
      throw new Error('Unreal Glue Generation: Field calls native but no field was found with that name ($fieldName)', pos);
    var fargs = null, fret = null,
        origArgs = null;
    switch(Context.follow(field.type)) {
    case TFun(targs,tret):
      origArgs = targs;
      var argn = 0;
      // TESTME: add test for super.call(something, super.call(other))
      if (abs != null && !isStatic) {
        targs.shift();
      }
      fargs = [ for (arg in targs) { name:'__unative_arg' + argn++, type:TypeConv.get(arg.t, pos) } ];
      switch(Context.follow(tret)) {
      case TMono(_):
        Context.warning('Unreal Type: No return type was set for function $fieldName. Assuming void', field.pos);
        fret = Globals.cur.voidTypeConv;
      case _:
        fret = TypeConv.get(tret, pos);
      }
    case _: throw 'assert';
    }

    var sig = Context.defined('cppia') || Context.defined('WITH_CPPIA') ?
      (field.meta == null ? '' : UhxMeta.getStaticMetas(field.meta.get())) + fieldName + '(' + [for (arg in fargs) arg.type.ueType.getCppType()].join(',') + '):' + fret.ueType.getCppType() : null;
    if (Context.defined('cppia')) {
      // only check if they are not special fields
      if (fieldName != 'StaticClass' && fieldName != 'CPPSize' && fieldName != 'setupFunction') {
        var name = fieldName;
        if (name.startsWith('_get_') && name.endsWith('_methodPtr')) {
          name = name.substring('_get_'.length, name.length - '_methodPtr'.length);
        }
        var sigCheck = clsRef.toString() + ':' + sig;
        if (!Globals.cur.compiledScriptGluesExists(sigCheck) && !Context.defined('display')) {
          Context.warning('UHXERR: The native call of $name from $clsRef was not compiled into static, or it was compiled with a different signature. A full C++ compilation is required', Context.currentPos());
        }
      }

      var args = isStatic ? args : [macro this].concat(args);
      var helper = TypeRef.fromBaseType(cls, pos).getScriptGlueType();
      var resolver = macro (cast std.Type.resolveClass($v{helper.getClassPath(true)}) : Dynamic);
      if (cls.meta.has(':hasGlueScriptGetter')) {
        resolver = macro uhx_glueScript;
      }
      return { expr:ECall(macro $resolver.$fieldName, args), pos: pos };
    }
    if (fargs.length != args.length) {
      throw new Error('Unreal Glue Generation: $fieldName number of call arguments differ from declaration. Expected ${fargs.length}; got ${args.length}', pos);
    }

    var argn = 0;
    var block = [ for (arg in args) {
      var name = '__unative_arg' + argn++;
      macro var $name = $arg;
    } ];
    if (!isStatic)
      fargs.unshift({ name:'this', type: TypeConv.get(Context.getLocalType(), pos) });

    var glueType = getGlueType(clsRef, pos);
    var glueExpr = new HelperBuf();

    glueExpr << 'untyped __cpp__("' << glueType.getCppClass() << '::' << fieldName << '(';
    var idx = 0;
    for (arg in fargs) {
      block.push(Context.parse('var tmp${idx++} = ' + arg.type.haxeToGlue(arg.name, null), pos));
    }
    idx = 0;
    glueExpr.mapJoin(fargs, function(_) return '{${idx++}}');
    glueExpr << ')"';
    if (fargs.length > 0) {
      glueExpr << ', ';
    }
    idx = 0;
    glueExpr.mapJoin(fargs, function(arg) return 'tmp${idx++}');
    glueExpr << ')';

    var expr = glueExpr.toString();
    if (!fret.haxeType.isVoid())
      expr = fret.glueToHaxe(expr, null);
    // dummy call to make hxcpp include the correct header if needed
    block.push(Context.parse(glueType.toString() + '.uhx_dummy_field()', pos));
    block.push(Context.parse(expr, pos));

    var ret = if (block.length == 1) {
      block[0];
    } else {
      { expr:EBlock(block), pos: pos };
    };

    var meta = cls.meta;
    switch(cls.kind) {
    case KAbstractImpl(a):
      meta = a.get().meta;
    case _:
    }
    if (meta.has(':uscript') && !script) {
      var args = [ for (arg in origArgs) macro $i{arg.name} ];
      var expr = getNativeCall(fieldName, isStatic, args, true);
      flagCurrentField(fieldName, cls, isStatic, expr, sig);
    }
    return ret;
  }

  private static function findField(cls:ClassType, field:String, isStatic:Bool, ?cur:ClassField) {
    var name = cls.pack.join('.') + '.' + cls.name;
    var fields = Globals.cur.cachedFields[name];
    if (fields == null) {
      Globals.cur.cachedFields[name] = fields = new Map();
    }
    var f = fields[field];
    if (f == null) {
      if (cur != null) {
        f = cur;
      } else {
        f = cls.findField(field, isStatic);
      }
      fields[field] = f;
    }
    return f;
  }

  private static function flagCurrentField(meth:String, cl:ClassType, isStatic:Bool, expr:Expr, sig:String) {
    var field = findField(cl, meth, isStatic || cl.kind.match(KAbstractImpl(_)));
    if (field == null) throw new Error('assert: no field $meth on current class ${cl.name}', Context.currentPos());
    field.meta.add(':ugluegenerated', [expr, macro $v{sig}], cl.pos);
  }

  private static function getGlueType(clsRef:Ref<ClassType>, pos:Position) {
    var cls = clsRef.get();
    var type = TypeRef.fromBaseType(cls, pos);
    var glue = type.getGlueHelperType();
    var path = glue.getClassPath();
    if (!Globals.cur.builtGlueTypes.exists(path)) {
      // ensure this only runs once
      Globals.cur.builtGlueTypes[path] = true;

      var meta:Metadata = [
        { name:':unrealGlue', pos:pos },
      ];
      var fields = (macro class {
        static function uhx_dummy_field():Void;
      }).fields;
      Globals.cur.hasUnprocessedTypes = true;
      Context.defineType({
        pack: glue.pack,
        name: glue.name,
        pos: pos,
        meta: meta,
        isExtern: true,
        kind: TDClass(),
        fields: fields,
      });

      var local = Context.getLocalType();
      // delay the actual processing for after the macro has finished
      Globals.cur.delays = Globals.cur.delays.add(function() {

        var cls = clsRef.get();
        // make sure all fields are built
        for (field in cls.fields.get().concat(cls.statics.get())) {
          Context.follow(field.type);
        }
        var cls = clsRef.get();
        var dglue = new ExprGlueBuild(cls,pos,local);
        dglue.build();

        cls.meta.add(':ueGluePath', [macro $v{ glue.getClassPath() }], cls.pos );
        cls.meta.add(':glueHeaderClass', [macro $v{'\t\tinline static void uhx_dummy_field() { }\n'}], cls.pos);

        var meta = cls.meta;
        var path = switch(cls.kind) {
          case KAbstractImpl(a):
            var a = a.get();
            meta = a.meta;
            TypeRef.fromBaseType(a, pos).getClassPath();
          case _:
            type.getClassPath();
        }
        Globals.cur.gluesToGenerate = Globals.cur.gluesToGenerate.add(path);
        if (meta.has(':uscript')) {
          Globals.cur.scriptGlues = Globals.cur.scriptGlues.add(type.getClassPath());
        }
      });
    }

    return glue;
  }

  var cls:ClassType;
  var pos:Position;
  var typeRef:TypeRef;
  var thisConv:TypeConv;
  var firstExternSuper:TypeConv;
  var firstExternSuperClass:ClassType;
  var gluePath:String;
  var type:Type;

  public function new(cls, pos, type) {
    this.cls = cls;
    this.pos = pos;
    this.type = type;
  }

  public function build() {
    var cls = this.cls;
    var parentAbstract:AbstractType = null;
    var parent:BaseType = switch(cls.kind) {
      case KAbstractImpl(a):
        parentAbstract = a.get();
      case _:
        cls;
    };
    this.typeRef = TypeRef.fromBaseType( cls, this.pos );
    this.thisConv = TypeConv.get( this.type, this.pos ).withModifiers([Ptr]);
    this.gluePath = this.typeRef.getGlueHelperType().getClassPath();

    var allSuperFields = new Map();
    var ignoreSupers = new Map();
    this.firstExternSuper = null;
    {
      var scls = cls.superClass;
      while (scls != null) {
        var tsup = scls.t.get();
        if (tsup.meta.has(':uextern') && firstExternSuper == null) {
          firstExternSuperClass = scls.t.get();
          firstExternSuper = TypeConv.get(TInst(scls.t, scls.params), cls.pos);
        }
        if (firstExternSuper == null) {
          for (field in tsup.fields.get())
            ignoreSupers[field.name] = true;
        } else {
          for (field in tsup.fields.get())
            allSuperFields[field.name] = field;
        }
        scls = tsup.superClass;
      }
    }

    // TODO: clean up those references with a better interface
    var uprops = new Map(),
        superCalls = new Map(),
        superCallsPos = new Map(),
        nativeCalls = new Map(),
        methodPtrs = new Map();
    for (prop in parent.meta.extractStrings(':uproperties' )) {
      uprops[prop] = null;
    }
    for (escall in parent.meta.extract(':usupercalls' )) {
      for (escall in escall.params) {
        var scall = switch(escall.expr) {
          case EConst(CString(s) | CIdent(s)):
            s;
          case _:
            throw 'assert';
        };
        // if the field was already overriden in a previous Haxe declaration,
        // we should not build the super call
        if (!ignoreSupers.exists(scall)) {
          superCalls[scall] = null;
          superCallsPos[scall] = escall.pos;
        }
      }
    }
    for (ncall in parent.meta.extractStrings(':unativecalls' )) {
      if (!ignoreSupers.exists(ncall)) {
        nativeCalls[ncall] = null;
      }
    }
    for (methodPtr in parent.meta.extractStrings(':umethodptrs' )) {
      methodPtrs[methodPtr] = null;
    }

    for (field in cls.fields.get()) {
      var field = findField(cls, field.name, false, field);
      if (uprops.exists(field.name)) {
        uprops[field.name] = { cf:field, isStatic:false };
      } else if (superCalls.exists(field.name)) {
        superCalls[field.name] = field;
      } else if (nativeCalls.exists(field.name)) {
        nativeCalls[field.name] = { cf:field, isStatic:false };
      }
      if (methodPtrs.exists(field.name)) {
        methodPtrs[field.name] = field;
      }
    }

    for (field in cls.statics.get()) {
      var field = findField(cls, field.name, true, field);
      if (uprops.exists(field.name)) {
        uprops[field.name] = { cf:field, isStatic:true };
      } else if (nativeCalls.exists(field.name)) {
        nativeCalls[field.name] = { cf:field, isStatic:true };
      }
    }

    for (key in superCalls.keys()) {
      var scall = superCalls[key];
      if (scall == null) {
        var pos = superCallsPos[key];
        throw new Error('Unreal Glue Generation: super is called for ' + key + ' but it is not an overridden field', pos);
      }
      // use a previous declaration to not force build typed expressions just yet
      var superField = allSuperFields[scall.name];
      if (superField == null) throw new Error('Unreal Glue Generation: super is called for ' + scall.name + ' but no superclass definition exists', scall.pos);
      this.handleSuperCall(scall, superField);
    }

    for (ncall in nativeCalls) {
      this.handleNativeCall(ncall.cf, ncall.isStatic);
    }

    for (uprop in uprops) {
      this.handleProperty(uprop.cf, uprop.isStatic);
    }

    for (methodPtr in methodPtrs) {
      this.handleMethodPointer(methodPtr);
    }

    var glue = this.typeRef.getGlueHelperType();
    var glueHeaderIncludes = new IncludeSet(),
        glueCppIncludes = new IncludeSet();
    this.thisConv.collectUeIncludes(glueCppIncludes);
    this.thisConv.collectGlueIncludes(glueHeaderIncludes);
    // var glueHeaderIncludes = this.thisConv.glueHeaderIncludes;
    // var glueCppIncludes = this.thisConv.glueCppIncludes;

    parent.meta.add(':glueHeaderIncludes', [ for (inc in glueHeaderIncludes) macro $v{inc} ], this.pos);
    parent.meta.add(':glueCppIncludes', [ for (inc in glueCppIncludes) macro $v{inc} ], this.pos);

    if (parent.meta.has(":uhxdelegate")) {
      writeDelegateDefinition(parentAbstract);
    } else if (parent.meta.has(":ustruct")) {
      writeStructDefinition(parentAbstract);
    }

    Globals.cur.cachedBuiltTypes.push(glue.getClassPath());

    // unfortunately this is necessary to make sure that our own version with all metadatas is the final one
    // (see haxe's `encode_meta` source code to understand why this is needed)
    cls.meta.add(':dummy',[],cls.pos);
  }

  private function writeStructDefinition(abs:AbstractType) {
    if (!abs.meta.has(':uextension')) {
      abs.meta.add(':uextension', [], abs.pos);
    }
    var typeRef = TypeRef.fromBaseType(abs, abs.pos),
        uname = MacroHelpers.getUName(abs),
        nameWithout = uname.substr(1),
        headerPath = GlueInfo.getExportHeaderPath(nameWithout, true);

    var writer = new HeaderWriter(headerPath);
    var cls = abs.impl.get();

    var uprops = [],
        supFields = new Map();
    var tlSup = [ for (param in abs.params) param.t ],
        aSup = abs;
    var firstSuper = null,
        firstSuperTl = null;
    while (true) {
      switch(Context.follow(aSup.type.applyTypeParameters(aSup.params, tlSup))) {
        case TAbstract(a,tl):
          switch(a.toString()) {
            case 'unreal.Struct' | 'unreal.VariantPtr':
              break;
            case _:
              tlSup = tl;
              aSup = a.get();
              if (firstSuper == null) {
                firstSuper = a;
                firstSuperTl = tl;
              }
          }
        case _:
          break;
      }
      for (field in aSup.impl.get().statics.get()) {
        if (field.meta.has(':impl')) {
          supFields[field.name] = true;
        }
      }
    }

    for (field in cls.statics.get()) {
      if (!field.meta.has(':impl')) continue;
      if (field.kind.match(FVar(_))) {
        if (field.meta.has(':uproperty')) {
          uprops.push({field:field, type:TypeConv.get(field.type, field.pos)});
        } else {
          throw new Error('Unreal Glue: Only uproperty fields are supported', field.pos);
        }
      } else {
        if (field.meta.has(':ufunction')) {
          throw new Error('Unreal Glue: ufunctions are not supported on ustructs', field.pos);
        }
        // we can only override non-extern functions
        if (field.name != '_new'  && field.name != 'copy' && field.name != 'copyNew' && supFields[field.name]) {
          if (aSup.meta.has(':uextern')) {
            throw new Error('Unreal Glue: overriding an extern function (${field.name}) in a ustruct is not supported', field.pos);
          }
        }
      }
    }

    var fwds = new Map(),
        incs = new IncludeSet(),
        dummyIncs = new IncludeSet();
    for (prop in uprops) {
      prop.type.collectUeIncludes( incs, fwds, dummyIncs );
    }

    writer.include("CoreMinimal.h");
    for (fwd in fwds) {
      writer.forwardDeclare( fwd );
    }
    for (inc in incs) {
      writer.include(inc);
    }

    var extendsStr = '';
    if (firstSuper != null) {
      var tconv = TypeConv.get( TAbstract(firstSuper, firstSuperTl), abs.pos );
      extendsStr = ': public ' + tconv.ueType.getCppClass();

      // we're using the ueType so we'll include the glueCppIncludes
      var includes = new IncludeSet();
      tconv.collectUeIncludes( includes );
      for (include in includes) {
        writer.include(include);
      }
    }

    writer.include('$nameWithout.generated.h');

    var targetModule = abs.meta.extractStrings(':umodule')[0];
    if (targetModule == null) {
      targetModule = Globals.cur.module;
    }

    var ustruct = abs.meta.extract(':ustruct')[0];
    if (ustruct == null || ustruct.params == null) {
      ustruct = {name:':ustruct', params:[], pos:abs.pos};
    }
    if (abs.doc != null) {
      writer.buf.add('/**\n${abs.doc.replace('**/','')}\n**/\n');
    }
    var align = abs.meta.extract(':ualign');
    var alignment:Null<Int> = null;
    if (align != null && align[0] != null && align[0].params != null && align[0].params.length > 0)
    {
      switch(align[0].params[0].expr)
      {
        case EConst(CInt(i)):
          alignment = Std.parseInt(i);
        case _:
          throw new Error('Bad @:ualign argument: ${align[0].params[0]}', align[0].params[0].pos);
      }
    }
    if (alignment == null)
    {
      var needsAlignmentOverride = uprops.length > 0;
      for (prop in uprops) {
        switch(prop.type.ueType.getCppType(null).toString())
        {
          case 'bool' | 'uint8' | 'int8' | 'char' | 'unsigned char':
          case _:
            needsAlignmentOverride = false;
            break;
        }
      }
      if (needsAlignmentOverride)
      {
        alignment = 8;
      }
    }
    if (alignment != null)
    {
      writer.buf.add('#ifndef UHT_WORKAROUND\nMS_ALIGN($alignment)\n#endif\n'); // UHT doesn't like MS_ALIGN/GCC_ALIGN
    }
    writer.buf.add('USTRUCT(');
    if (ustruct.params != null) {
      var first = true;
      for (param in ustruct.params) {
        if (first) first = false; else writer.buf.add(', ');
        writer.buf.add(param.toString().replace('[','(').replace(']',')'));
      }
    }
    writer.buf.add(')\n');
    writer.buf.add('struct ${targetModule.toUpperCase()}_API ${uname} $extendsStr\n{\n');
    writer.buf.add('\tGENERATED_USTRUCT_BODY()\n\n');
    for (prop in uprops) {
      if (prop.field.doc != null) {
        writer.buf.add('/**\n${prop.field.doc.replace('**/','')}\n**/\n\t');
      }
      writer.buf.add('\tUPROPERTY(');
      var first = true;
      for (meta in prop.field.meta.extract(':uproperty')) {
        if (meta.params != null) {
          for (param in meta.params) {
            if (first) first = false; else writer.buf.add(', ');
            writer.buf.add(param.toString().replace('[','(').replace(']',')'));
          }
        }
      }
      writer.buf.add(')\n');

      var uname = prop.field.meta.extractStrings(":uname")[0];
      if (uname == null) uname = prop.field.name;
      var cppType = prop.type.ueType.getCppType(null) + '';
      if (prop.type.data.match(CEnum(EExternal,_))) {
        cppType = 'TEnumAsByte< $cppType >';
      }
      writer.buf.add('\t${cppType} $uname;\n\n');
    }
    writer.buf.add('}');
    if (alignment != null)
    {
      writer.buf.add('\n#ifndef UHT_WORKAROUND\nGCC_ALIGN($alignment)\n#endif\n'); // UHT doesn't like MS_ALIGN/GCC_ALIGN
    }
    writer.buf.add(';');

    writer.close(Globals.cur.module);
    abs.meta.add(':ufiledependency', [macro "ExportHeader", macro $v{nameWithout}], abs.pos);
  }

  private function writeDelegateDefinition(abs:AbstractType) {
    var uname = MacroHelpers.getUName(abs),
        nameWithout = uname.substr(1),
        tref = TypeRef.fromBaseType(abs, abs.pos),
        headerPath = GlueInfo.getExportHeaderPath(nameWithout, true);
    var writer = new HeaderWriter(headerPath);

    var typeRef = TypeRef.fromBaseType(abs, abs.pos);
    var parent = null;
    var fnType = switch(abs.type) {
      case TAbstract(a,[fn]):
        parent = a.get();
        fn;
      case _:
        throw 'assert';
    }
    var args, ret;
    switch(Context.follow(fnType)) {
    case TFun(a,r):
      args = [ for (arg in a) TypeConv.get(arg.t, abs.pos) ];
      ret = TypeConv.get(r, abs.pos);
    case _:
      throw new Error('Invalid argument for delegate ${parent.name}', abs.pos);
    }

    var fwds = new Map(),
        incs = new IncludeSet(),
        dummyIncs = new IncludeSet();
    for (arg in args.concat([ret])) {
      arg.collectUeIncludes( incs, fwds, dummyIncs );
    }
    for (fwd in fwds) {
      writer.forwardDeclare( fwd );
    }
    writer.include("CoreMinimal.h");
    for (inc in incs) {
      writer.include(inc);
    }

    writer.include('$nameWithout.generated.h');
    var type = parent.name;
    var isDynamicDelegate = switch(type) {
      case 'BaseDynamicMulticastDelegate', 'BaseDynamicDelegate': true;
      default: false;
    }

    var isDynamic = false;
    var declMacro = switch (type) {
      case 'BaseDelegate': 'DECLARE_DELEGATE';
      case 'BaseDynamicDelegate': isDynamic = true; 'DECLARE_DYNAMIC_DELEGATE';
      case 'BaseEvent': 'DECLARE_EVENT';
      case 'BaseMulticastDelegate': 'DECLARE_MULTICAST_DELEGATE';
      case 'BaseDynamicMulticastDelegate': isDynamic = true; 'DECLARE_DYNAMIC_MULTICAST_DELEGATE';
      default: throw 'assert';
    }

    var argStr = switch (args.length) {
      case 0: "";
      case 1: "_OneParam";
      case 2: "_TwoParams";
      case 3: "_ThreeParams";
      case 4: "_FourParams";
      case 5: "_FiveParams";
      case 6: "_SixParams";
      case 7: "_SevenParams";
      case 8: "_EightParams";
      default: throw new Error('Cannot declare a delegate with more than 8 parameters', abs.pos);
    }

    var retStr = ret.haxeType.isVoid() ? "" : "_RetVal";
    var constStr = abs.meta.has(':thisConst') ? "_Const" : "";

    // TODO: Support "payload" variables?

    if (abs.doc != null) {
      writer.buf.add('/**\n${abs.doc.replace('**/','')}\n**/\n');
    }
    var udelegate = abs.meta.extract(':udelegate')[0];
    if (udelegate != null) {
      writer.buf.add('UDELEGATE(');
      if (udelegate.params != null) {
        var first = true;
        for (param in udelegate.params) {
          if (first) first = false; else writer.buf.add(', ');
          writer.buf.add(param.toString().replace('[','(').replace(']',')'));
        }
      }
      writer.buf.add(')\n');
    }
    writer.buf.add('$declMacro$retStr$argStr$constStr(');

    if (!ret.haxeType.isVoid()) {
      writer.buf.add('${ret.ueType.getCppType()}, ');
    }
    writer.buf.add(uname);

    var paramNames = abs.meta.extractStrings(':uParamName');
    for (i in 0...args.length) {
      var arg = args[i];
      writer.buf.add(', ${arg.ueType.getCppType()}');
      if (isDynamicDelegate) {
        var paramName = paramNames[i] != null ? paramNames[i] : 'arg$i';
        writer.buf.add(', $paramName');
      }
    }
    writer.buf.add(');\n\n\n');

    if (!Context.defined("UHX_NO_UOBJECT"))
    {
      writer.buf.add('// added as workaround for UHT, otherwise it won\'t recognize this file.\n');
      writer.buf.add('USTRUCT(Meta=(UHX_Internal=true)) struct F${uname}__Dummy { GENERATED_BODY() };');
    }
    writer.close(Globals.cur.module);
    abs.meta.add(':ufiledependency', [macro "ExportHeader", macro $v{nameWithout}], abs.pos);
  }

  private function handleProperty(field:ClassField, isStatic:Bool) {
    var type = field.type,
        propTConv = TypeConv.get(type, field.pos);
    if (field.meta.has(':impl')) {
      isStatic = false;
    }

    var uname = field.meta.extractStrings(':uname')[0];
    if (uname == null)
      uname = field.name;
    var gms = [];
    for (mode in ['get','set']) {
      var tconv = propTConv;
      var isStructProp = propTConv.isStructByVal();
      if (isStructProp && mode == 'get') {
        tconv = TypeConv.get(type, field.pos).withModifiers([Ptr]);
      }

      var gm = new GlueMethod({
        name: mode + '_' + field.name,
        uname: uname,
        args: (mode == 'get' ? [] : [{ name:'value', t:tconv, opt:null }]),
        ret: (mode == 'set' ? TypeConv.get(Context.getType('Void'), field.pos) : tconv),
        flags: Property | Final | HaxePrivate |
          (isStatic ? Static : MNone) |
          (isStructProp ? StructProperty : MNone) |
          (!field.isPublic ? CppPrivate : MNone),
        doc: field.doc,
        meta: null, // this is mostly here to join metadata. We don't need that
        pos: field.pos
      }, this.type);
      gms.push(gm);
    }
    gms[0].headerCode += '\n\t\t' + gms[1].headerCode;
    gms[0].cppCode += '\n\t\t' + gms[1].cppCode;

    for (meta in gms[0].getFieldMeta(false)) {
      field.meta.add(meta.name, meta.params, meta.pos);
    }
  }

  private function handleNativeCall(field:ClassField, isStatic:Bool) {
    var args, ret = null;
    switch(Context.follow(field.type)) {
      case TFun(targs,tret):
        args = targs;
        ret = tret;
      case _:
        throw 'assert';
    }
    if (field.meta.has(':impl')) {
      isStatic = false;
      args.shift();
    }
    var args = [ for (arg in args) { name:arg.name, t:TypeConv.get(arg.t, field.pos), opt:null } ],
        ret = TypeConv.get(ret, field.pos);

    var uname = field.meta.extractStrings(':uname')[0];
    if (uname == null)
      uname = field.name;

    var meth = new GlueMethod({
      name: field.name,
      uname: uname,
      args: args,
      ret: ret,
      flags: (field.meta.has(':final') ? Final : MNone) |
        (isStatic ? Static : MNone) |
        (!field.isPublic ? CppPrivate : MNone),
      meta: field.meta.has(':glueCppBody') ? field.meta.extract(':glueCppBody') : null,
      pos: field.pos
    }, this.type);

    var metas = meth.getFieldMeta();
    for (meta in metas) {
      field.meta.add(meta.name, meta.params, meta.pos);
    }
  }

  private function handleMethodPointer(field:ClassField) {
    var externName = field.name;
    var methodName = '_get_${externName}_methodPtr';

    var glue = this.typeRef.getGlueHelperType();
    var clsField = findField(this.cls, methodName, true);
    if (clsField == null) {
      throw 'assert: can\'t find $methodName';
    }

    var headerDef = '\n\t\tstatic unreal::UIntPtr $methodName();';
    var cppDef = 'unreal::UIntPtr ${glue.getCppClass()}_obj::$methodName() {\n\treturn (unreal::UIntPtr) (void*)${this.thisConv.ueType.getCppClass()}::_get_${externName}_methodPtr;\n}\n';
    var metas:Metadata = [
      { name: ':glueHeaderCode', params:[macro $v{headerDef}], pos: field.pos },
      { name: ':glueCppCode', params:[macro $v{cppDef}], pos: field.pos },
    ];

    if (!clsField.meta.has(':glueHeaderCode')) {
      for (meta in metas) {
        clsField.meta.add(meta.name, meta.params, meta.pos);
      }
    }
  }

  private function handleSuperCall(field:ClassField, superField:ClassField) {
    var uname = superField.meta.extractStrings(':uname')[0];
    if (uname == null)
      uname = superField.name;
    var args = null, ret = null;
    switch( Context.follow(superField.type) ) {
      case TFun(targs, tret):
        args = [ for (arg in targs) { name:arg.name, t:TypeConv.get(arg.t, field.pos), opt:null } ];
        ret = TypeConv.get(tret, field.pos);
      case _:
        throw 'assert';
    }
    if (superField.meta.has(':ufunction')) {
      for (meta in superField.meta.extract(':ufunction')) {
        for (meta in meta.params) {
          if (UExtensionBuild.ufuncBlueprintNativeEvent(meta)) {
            uname = uname + '_Implementation';
            break;
          }
        }
      }
    }
    var meth = new GlueMethod({
      name: field.name,
      uname: uname,
      args: args,
      ret: ret,
      flags: Final | ForceNonVirtual | (superField.isPublic ? MNone : CppPrivate),
      pos: field.pos
    }, this.type, null, null, this.firstExternSuper);

    var metas = meth.getFieldMeta();
    for (meta in metas) {
      field.meta.add(meta.name, meta.params, meta.pos);
    }
  }

  private static function getMetaDefinitions(headerDef:String, cppDef:String, allTypes:Array<TypeConv>, pos:Position):Metadata {
    var headerIncludes = new IncludeSet();
    var cppIncludes = new IncludeSet();
    for (t in allTypes) {
      t.collectGlueIncludes( headerIncludes );
      t.collectUeIncludes( cppIncludes );
    }

    var metas:Metadata = [
      { name: ':glueHeaderCode', params:[macro $v{headerDef}], pos: pos },
      { name: ':glueCppCode', params:[macro $v{cppDef}], pos: pos },
      { name: ':glueHeaderIncludes', params:[ for (inc in headerIncludes) macro $v{inc} ], pos: pos },
      { name: ':glueCppIncludes', params:[ for (inc in cppIncludes) macro $v{inc} ], pos: pos },
    ];
    return metas;
  }
}
