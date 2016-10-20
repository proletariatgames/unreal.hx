package ue4hx.internal;
#if macro
import ue4hx.internal.buf.HelperBuf;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import sys.FileSystem;
import ue4hx.internal.buf.HeaderWriter;

using Lambda;
using haxe.macro.Tools;
using StringTools;
#end

class DelayedGlue {

  macro public static function getGetterSetterExpr(fieldName:String, isStatic:Bool, isSetter:Bool):haxe.macro.Expr {
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
    var fullName = (isSetter ? 'set_' : 'get_') + fieldName;
    if (Context.defined('cppia')) {
      var args = [];
      if (!isStatic) {
        args.push(macro this);
      }
      if (isSetter) {
        args.push(macro value);
      }
      var helper = TypeRef.fromBaseType(cls, pos).getScriptGlueType();
      return { expr:ECall(macro (cast std.Type.resolveClass($v{helper.getClassPath(true)}) : Dynamic).$fullName, args), pos: pos };
    }

    // var ctx = !isStatic && !TypeConv.get(Context.getLocalType(), pos).data.match(CUObject(_)) ? [ "parent" => "this" ] : null;
    var ctx = new ConvCtx();
    var tconv = TypeConv.get(field.type, pos);

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
    if (cls.meta.has(':uscript')) {
      var toFlag = ret;
      if (isSetter) {
        toFlag = macro { $ret; value; };
      }
      flagCurrentField(fullName, cls, isStatic, toFlag);
    }
    return ret;
  }

  macro public static function getSuperExpr(fieldName:String, targetFieldName:String, args:Array<haxe.macro.Expr>):haxe.macro.Expr {
    return getSuperExprImpl(fieldName, targetFieldName, args, false);
  }

  macro public static function getNativeCall(fieldName:String, isStatic:Bool, args:Array<haxe.macro.Expr>):haxe.macro.Expr {
    return getNativeCallImpl(fieldName, isStatic, args, false);
  }

#if macro
  private static function getSuperExprImpl(fieldName:String, targetFieldName:String, args:Array<haxe.macro.Expr>, script:Bool):haxe.macro.Expr {
    var clsRef = Context.getLocalClass(),
        cls = clsRef.get(),
        pos = Context.currentPos();
    // make sure that the super field was not already defined in haxe code
    var sup = cls.superClass;
    while (sup != null) {
      var scls = sup.t.get();
      if (scls.meta.has(':uextern')) break;
      for (sfield in scls.fields.get()) {
        if (sfield.name == fieldName) {
          // this field was already defined in a Haxe class; just use normal super
          return { expr:ECall(macro @:pos(pos) super.$fieldName, args), pos:pos };
        }
      }
      sup = scls.superClass;
    }

    var superClass = cls.superClass;
    if (superClass == null)
      throw new Error('Unreal Glue Generation: Field calls super but no superclass was found', pos);
    var field = findField(superClass.t.get(), fieldName, false);
    if (field == null)
      throw new Error('Unreal Glue Generation: Field calls super but no field was found on super class', pos);
    var fargs = null, fret = null;
    switch(Context.follow(field.type)) {
    case TFun(targs,tret):
      var argn = 0;
      // TESTME: add test for super.call(something, super.call(other))
      fargs = [ for (arg in targs) { name:'__usuper_arg' + argn++, type:TypeConv.get(arg.t, pos) } ];
      fret = TypeConv.get(tret, pos);
    case _: throw 'assert';
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
    if (Context.defined('cppia')) {
      var args = [macro this].concat(args);
      var helper = TypeRef.fromBaseType(cls, pos).getScriptGlueType();
      var ret = { expr:ECall(macro (cast std.Type.resolveClass($v{helper.getClassPath(true)}) : Dynamic).$targetFieldName, args), pos: pos };
      if (!fret.haxeType.isVoid()) {
        var rtype = fret.haxeType.toComplexType();
        ret = macro ( $ret : $rtype );
      }
      return ret;
    }

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
    if (cls.meta.has(':uscript') && !script) {
      var expr = getSuperExprImpl(fieldName, targetFieldName, [for (arg in origArgs) macro $i{arg.name} ], true);
      flagCurrentField(targetFieldName, cls, false, expr);
    }
    return ret;
  }

  private static function getNativeCallImpl(fieldName:String, isStatic:Bool, args:Array<haxe.macro.Expr>, script:Bool):haxe.macro.Expr {
    var clsRef = Context.getLocalClass(),
        cls = clsRef.get(),
        pos = Context.currentPos();
    if (Context.defined('cppia')) {
      var args = isStatic ? args : [macro this].concat(args);
      var helper = TypeRef.fromBaseType(cls, pos).getScriptGlueType();
      return { expr:ECall(macro (cast std.Type.resolveClass($v{helper.getClassPath(true)}) : Dynamic).$fieldName, args), pos: pos };
    }

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
      fret = TypeConv.get(tret, pos);
    case _: throw 'assert';
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

    if (cls.meta.has(':uscript') && !script) {
      var args = [ for (arg in origArgs) macro $i{arg.name} ];
      var expr = getNativeCallImpl(fieldName, isStatic, args, true);
      flagCurrentField(fieldName, cls, isStatic, expr);
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

  private static function flagCurrentField(meth:String, cl:ClassType, isStatic:Bool, expr:Expr) {
    var field = findField(cl, meth, isStatic);
    if (field == null) throw new Error('assert: no field $meth on current class ${cl.name}', Context.currentPos());
    field.meta.add(':ugluegenerated', [expr], cl.pos);
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
        var dglue = new DelayedGlue(cls,pos,local);
        dglue.build();

        cls.meta.add(':ueGluePath', [macro $v{ glue.getClassPath() }], cls.pos );
        cls.meta.add(':glueHeaderClass', [macro $v{'\t\tinline static void uhx_dummy_field() { }\n'}], cls.pos);

        var path = switch(cls.kind) {
          case KAbstractImpl(a):
            TypeRef.fromBaseType(a.get(), pos).getClassPath();
          case _:
            type.getClassPath();
        }
        Globals.cur.gluesToGenerate = Globals.cur.gluesToGenerate.add(path);
        if (cls.meta.has(':uscript')) {
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
        nativeCalls = new Map(),
        methodPtrs = new Map();
    for (prop in MacroHelpers.extractStrings( parent.meta, ':uproperties' )) {
      uprops[prop] = null;
    }
    for (scall in MacroHelpers.extractStrings( parent.meta, ':usupercalls' )) {
      // if the field was already overriden in a previous Haxe declaration,
      // we should not build the super call
      if (!ignoreSupers.exists(scall)) {
        superCalls[scall] = null;
      }
    }
    for (ncall in MacroHelpers.extractStrings( parent.meta, ':unativecalls' )) {
      if (!ignoreSupers.exists(ncall)) {
        nativeCalls[ncall] = null;
      }
    }
    for (methodPtr in MacroHelpers.extractStrings( parent.meta, ':umethodptrs' )) {
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

    for (scall in superCalls) {
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
    if (Globals.cur.glueTargetModule != null && !abs.meta.has(':uextension')) {
      abs.meta.add(':utargetmodule', [macro $v{Globals.cur.glueTargetModule}], abs.pos);
      abs.meta.add(':uextension', [], abs.pos);
    }
    var info = GlueInfo.fromBaseType(abs);
    var uname = info.uname.getClassPath(),
        nameWithout = info.uname.withoutPrefix().getClassPath();
    var headerPath = info.getHeaderPath(true),
        cppPath = info.getCppPath(false);
    if (sys.FileSystem.exists(cppPath)) {
      sys.FileSystem.deleteFile(cppPath);
    }

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
        if (supFields[field.name]) {
          if (aSup.meta.has(':uextern')) {
            throw new Error('Unreal Glue: overriding an extern function in a ustruct is not supported', field.pos);
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

    var targetModule = MacroHelpers.extractStrings(abs.meta, ':umodule')[0];
    if (targetModule == null) {
      targetModule = Globals.cur.module;
    }

    var ustruct = abs.meta.extract(':ustruct')[0];
    if (ustruct != null) {
      writer.buf.add('USTRUCT(');
      if (ustruct.params != null) {
        var first = true;
        for (param in ustruct.params) {
          if (first) first = false; else writer.buf.add(', ');
          writer.buf.add(param.toString().replace('[','(').replace(']',')'));
        }
      }
      writer.buf.add(')\n');
    } else {
      writer.buf.add('USTRUCT()\n');
    }
    writer.buf.add('struct ${targetModule.toUpperCase()}_API ${uname} $extendsStr\n{\n');
    writer.buf.add('\tGENERATED_USTRUCT_BODY()\n\n');
    for (prop in uprops) {
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

      var uname = MacroHelpers.extractStrings(prop.field.meta, ":uname")[0];
      if (uname == null) uname = prop.field.name;
      var cppType = prop.type.ueType.getCppType(null) + '';
      if (prop.type.data.match(CEnum(EExternal,_))) {
        cppType = 'TEnumAsByte< $cppType >';
      }
      writer.buf.add('\t${cppType} $uname;\n\n');
    }
    writer.buf.add('};\n');

    writer.close(info.targetModule);
    if (!abs.meta.has(':ufiledependency')) {
      abs.meta.add(':ufiledependency', [macro $v{nameWithout + '@' + info.targetModule}], abs.pos);
    }
  }

  private function writeDelegateDefinition(abs:AbstractType) {
    var info = GlueInfo.fromBaseType(abs, Globals.cur.module);
    var uname = info.uname.getClassPath(),
        nameWithout = info.uname.withoutPrefix().getClassPath();
    var headerPath = info.getHeaderPath(true);
    var writer = new HeaderWriter(headerPath);

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
    for (inc in incs) {
      writer.include(inc);
    }

    writer.include('$nameWithout.generated.h');
    var type = parent.name;
    var isDynamicDelegate = switch(type) {
      case 'BaseDynamicMulticastDelegate', 'BaseDynamicDelegate': true;
      default: false;
    }

    var declMacro = switch (type) {
      case 'BaseDelegate': 'DECLARE_DELEGATE';
      case 'BaseDynamicDelegate': 'DECLARE_DYNAMIC_DELEGATE';
      case 'BaseEvent': 'DECLARE_EVENT';
      case 'BaseMulticastDelegate': 'DECLARE_MULTICAST_DELEGATE';
      case 'BaseDynamicMulticastDelegate': 'DECLARE_DYNAMIC_MULTICAST_DELEGATE';
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

    writer.buf.add('$declMacro$retStr$argStr$constStr(');

    if (!ret.haxeType.isVoid()) {
      writer.buf.add('${ret.ueType.getCppType()}, ');
    }
    writer.buf.add(uname);

    var paramNames = MacroHelpers.extractStrings(abs.meta, ':uParamName');
    for (i in 0...args.length) {
      var arg = args[i];
      writer.buf.add(', ${arg.ueType.getCppType()}');
      if (isDynamicDelegate) {
        var paramName = paramNames[i] != null ? paramNames[i] : 'arg$i';
        writer.buf.add(', $paramName');
      }
    }
    writer.buf.add(');\n\n\n');

    writer.buf.add('// added as workaround for UHT, otherwise it won\'t recognize this file.\n');
    writer.buf.add('UCLASS() class U${uname}__Dummy : public UObject { GENERATED_BODY() };');
    writer.close(info.targetModule);
    abs.meta.add(':ufiledependency', [macro $v{nameWithout + "@" + Globals.cur.module}], abs.pos);
  }

  private function handleProperty(field:ClassField, isStatic:Bool) {
    var type = field.type,
        propTConv = TypeConv.get(type, field.pos);
    if (field.meta.has(':impl')) {
      isStatic = false;
    }

    var uname = MacroHelpers.extractStrings(field.meta, ':uname')[0];
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
        args: (mode == 'get' ? [] : [{ name:'value', t:tconv }]),
        ret: (mode == 'set' ? TypeConv.get(Context.getType('Void'), field.pos) : tconv),
        flags: Property | Final | HaxePrivate | (isStatic ? Static : None) | (isStructProp ? StructProperty : None),
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
    var args = [ for (arg in args) { name:arg.name, t:TypeConv.get(arg.t, field.pos) } ],
        ret = TypeConv.get(ret, field.pos);

    var uname = MacroHelpers.extractStrings(field.meta, ':uname')[0];
    if (uname == null)
      uname = field.name;

    var meth = new GlueMethod({
      name: field.name,
      uname: uname,
      args: args,
      ret: ret,
      flags: (field.meta.has(':final') ? Final : None) | (isStatic ? Static : None),
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
    var uname = MacroHelpers.extractStrings(superField.meta, ':uname')[0];
    if (uname == null)
      uname = superField.name;
    var args = null, ret = null;
    switch( Context.follow(superField.type) ) {
      case TFun(targs, tret):
        args = [ for (arg in targs) { name:arg.name, t:TypeConv.get(arg.t, field.pos) } ];
        ret = TypeConv.get(tret, field.pos);
      case _:
        throw 'assert';
    }
    var meth = new GlueMethod({
      name: field.name,
      uname: uname,
      args: args,
      ret: ret,
      flags: Final | ForceNonVirtual | (superField.isPublic ? None : CppPrivate),
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

#end
}
