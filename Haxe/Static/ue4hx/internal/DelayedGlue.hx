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
    var field = findField(cls, fieldName, isStatic);
    if (field == null) throw 'assert';
    var old = Globals.cur.currentFeature;
    Globals.cur.currentFeature = 'keep'; // these fields will always be kept
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

    var ctx = !isStatic && !TypeConv.get(Context.getLocalType(), pos).isUObject ? [ "parent" => "this" ] : null;
    var tconv = TypeConv.get(field.type, pos);

    var glueType = getGlueType(clsRef, pos);
    var glueExpr = new HelperBuf();

    glueExpr << 'untyped __cpp__("${glueType.getCppClass()}::';
    glueExpr << (isSetter ? 'set_' : 'get_') << fieldName << '(';

    var args = new HelperBuf();
    var narg = 0;
    if (!isStatic) {
      var thisConv = TypeConv.get( Context.getLocalType(), pos, "unreal.PExternal");
      args << ', ' << thisConv.haxeToGlue('this', ctx);
      glueExpr << '{${narg++}}';
    }
    if (isSetter) {
      args << ', ' << tconv.haxeToGlue('value', ctx);
      glueExpr << (narg > 0 ? ', ' : '') << '{${narg++}}';
    }

    glueExpr << ')"' << args << ')';

    // dummy call to make hxcpp include the correct header if needed
    var expr ='{ $glueType.uhx_dummy_field(); ' +
      (isSetter ? glueExpr.toString() : tconv.glueToHaxe( glueExpr.toString(), ctx)) + '; }';

    Globals.cur.currentFeature = old;
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
    var old = Globals.cur.currentFeature;
    Globals.cur.currentFeature = 'keep'; // these fields will always be kept

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

    glueExpr << 'untyped __cpp__("' << glueType.getCppClass() << '::' << fieldName << '(';
    var idx = 0;
    glueExpr.mapJoin(fargs, function (_) return '{${idx++}}');
    glueExpr << ')"';
    if (fargs.length > 0) {
      glueExpr << ', ';
    }
    glueExpr.mapJoin(fargs, function(arg) return arg.type.haxeToGlue(arg.name, null));
    glueExpr << ')';

    var expr = glueExpr.toString();
    if (!fret.haxeType.isVoid())
      expr = fret.glueToHaxe(expr, null);

    // dummy call to make hxcpp include the correct header if needed
    block.push(Context.parse(glueType.toString() + '.uhx_dummy_field()', pos));
    block.push(Context.parse(expr, pos));

    Globals.cur.currentFeature = old;
    var ret = if (block.length == 1)
      block[0];
    else
      { expr:EBlock(block), pos: pos };
    if (cls.meta.has(':uscript')) {
      flagCurrentField(targetFieldName, cls, false, ret);
    }
    return ret;
  }

  macro public static function getNativeCall(fieldName:String, isStatic:Bool, args:Array<haxe.macro.Expr>):haxe.macro.Expr {
    var clsRef = Context.getLocalClass(),
        cls = clsRef.get(),
        pos = Context.currentPos();
    var old = Globals.cur.currentFeature;
    Globals.cur.currentFeature = 'keep'; // these fields will always be kept
    if (Context.defined('cppia')) {
      var args = isStatic ? args : [macro this].concat(args);
      var helper = TypeRef.fromBaseType(cls, pos).getScriptGlueType();
      return { expr:ECall(macro (cast std.Type.resolveClass($v{helper.getClassPath(true)}) : Dynamic).$fieldName, args), pos: pos };
    }

    var field = findField(cls, fieldName, isStatic);
    if (field == null)
      throw new Error('Unreal Glue Generation: Field calls native but no field was found with that name ($fieldName)', pos);
    var fargs = null, fret = null;
    switch(Context.follow(field.type)) {
    case TFun(targs,tret):
      var argn = 0;
      // TESTME: add test for super.call(something, super.call(other))
      fargs = [ for (arg in targs) { name:'__unative_arg' + argn++, type:TypeConv.get(arg.t, pos) } ];
      fret = TypeConv.get(tret, pos);
    case _: throw 'assert';
    }
    if (fargs.length != args.length)
      throw new Error('Unreal Glue Generation: super.$fieldName number of arguments differ from super. Expected ${fargs.length}; got ${args.length}', pos);
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
    glueExpr.mapJoin(fargs, function(_) return '{${idx++}}');
    glueExpr << ')"';
    if (fargs.length > 0) {
      glueExpr << ', ';
    }
    glueExpr.mapJoin(fargs, function(arg) return arg.type.haxeToGlue(arg.name, null));
    glueExpr << ')';

    var expr = glueExpr.toString();
    if (!fret.haxeType.isVoid())
      expr = fret.glueToHaxe(expr, null);
    // dummy call to make hxcpp include the correct header if needed
    block.push(Context.parse(glueType.toString() + '.uhx_dummy_field()', pos));
    block.push(Context.parse(expr, pos));

    Globals.cur.currentFeature = old;
    var ret = if (block.length == 1) {
      block[0];
    } else {
      { expr:EBlock(block), pos: pos };
    };

    if (cls.meta.has(':uscript')) {
      flagCurrentField(fieldName, cls, isStatic, ret);
    }
    return ret;
  }

#if macro
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
        var old = Globals.cur.currentFeature;
        Globals.cur.currentFeature = 'keep'; // these fields will always be kept

        var cls = clsRef.get();
        var dglue = new DelayedGlue(cls,pos,local);
        dglue.build();

        cls.meta.add(':ueGluePath', [macro $v{ glue.getClassPath() }], cls.pos );
        cls.meta.add(':glueHeaderClass', [macro $v{'\t\tstatic void uhx_dummy_field() { }\n'}], cls.pos);

        Globals.cur.gluesToGenerate = Globals.cur.gluesToGenerate.add(type.getClassPath());
        if (cls.meta.has(':uscript')) {
          Globals.cur.scriptGlues.push(type.getClassPath());
        }
        Globals.cur.currentFeature = old;
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
    this.typeRef = TypeRef.fromBaseType( cls, this.pos );
    this.thisConv = TypeConv.get( this.type, this.pos, 'unreal.PExternal' );
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
    for (prop in MacroHelpers.extractStrings( cls.meta, ':uproperties' )) {
      uprops[prop] = null;
    }
    for (scall in MacroHelpers.extractStrings( cls.meta, ':usupercalls' )) {
      // if the field was already overriden in a previous Haxe declaration,
      // we should not build the super call
      if (!ignoreSupers.exists(scall))
        superCalls[scall] = null;
    }
    for (ncall in MacroHelpers.extractStrings( cls.meta, ':unativecalls' )) {
      if (!ignoreSupers.exists(ncall)) {
        nativeCalls[ncall] = null;
      }
    }
    for (methodPtr in MacroHelpers.extractStrings( cls.meta, ':umethodptrs' )) {
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
    this.thisConv.getAllCppIncludes(glueCppIncludes);
    this.thisConv.getAllHeaderIncludes(glueHeaderIncludes);
    // var glueHeaderIncludes = this.thisConv.glueHeaderIncludes;
    // var glueCppIncludes = this.thisConv.glueCppIncludes;

    cls.meta.add(':glueHeaderIncludes', [ for (inc in glueHeaderIncludes) macro $v{inc} ], this.pos);
    cls.meta.add(':glueCppIncludes', [ for (inc in glueCppIncludes) macro $v{inc} ], this.pos);

    if (cls.meta.has(":uhxdelegate")) {
      writeDelegateDefinition(cls);
    } else if (cls.meta.has(":ustruct")) {
      writeStructDefinition(cls);
    }

    Globals.cur.cachedBuiltTypes.push(glue.getClassPath());

    // unfortunately this is necessary to make sure that our own version with all metadatas is the final one
    // (see haxe's `encode_meta` source code to understand why this is needed)
    cls.meta.add(':dummy',[],cls.pos);
  }

  private function writeStructDefinition(cls:ClassType) {
    if (Globals.cur.glueTargetModule != null && !cls.meta.has(':uextension')) {
      cls.meta.add(':utargetmodule', [macro $v{Globals.cur.glueTargetModule}], cls.pos);
      cls.meta.add(':uextension', [], cls.pos);
    }
    var info = GlueInfo.fromBaseType(cls);
    var uname = info.uname.join('.');
    var headerPath = info.getHeaderPath(true);

    var writer = new HeaderWriter(headerPath);
    writer.buf.add(NativeGlueCode.prelude);

    var uprops = [];
    for (field in cls.fields.get()) {
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
        var scls = cls.superClass != null ? cls.superClass.t.get() : null;
        while (scls != null) {
          if (scls.fields.get().exists(function(f) return f.name == field.name)) {
            if (scls.isExtern || scls.meta.has(':uextern')) {
              throw new Error('Unreal Glue: overriding an extern function in a ustruct is not supported', field.pos);
            }
            break;
          }
          scls = scls.superClass != null ? scls.superClass.t.get() : null;
        }
      }
    }

    for (prop in uprops) {
      if (!prop.type.forwardDeclType.isNever() && prop.type.forwardDecls != null) {
        for (fwd in prop.type.forwardDecls) {
          writer.forwardDeclare(fwd);
        }
      } else {
        if (prop.type.glueCppIncludes != null) {
          for (include in prop.type.glueCppIncludes) {
            writer.include(include);
          }
        }
      }
    }

    var extendsStr = '';
    if (cls.superClass != null && cls.superClass.t.get().name != "UnrealStruct") {
      var tconv = TypeConv.get( TInst(cls.superClass.t, cls.superClass.params), cls.pos );
      extendsStr = ': public ' + tconv.ueType.getCppClass();

      // we're using the ueType so we'll include the glueCppIncludes
      var includes = new IncludeSet();
      tconv.getAllCppIncludes( includes );
      for (include in includes) {
        writer.include(include);
      }
    }

    writer.include('$uname.generated.h');

    var targetModule = MacroHelpers.extractStrings(cls.meta, ':umodule')[0];
    if (targetModule == null) {
      targetModule = Globals.cur.module;
    }

    var ustruct = cls.meta.extract(':ustruct')[0];
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
      writer.buf.add('\t${prop.type.ueType.getCppType(null)} $uname;\n\n');
    }
    writer.buf.add('};\n');

    writer.close(info.targetModule);
    if (!cls.meta.has(':ufiledependency')) {
      cls.meta.add(':ufiledependency', [macro $v{uname + '@' + info.targetModule}], cls.pos);
    }
  }

  private function writeDelegateDefinition(cls:ClassType) {
    var info = GlueInfo.fromBaseType(cls, Globals.cur.module);
    var uname = info.uname.join('.');
    var headerPath = info.getHeaderPath(true);
    var writer = new HeaderWriter(headerPath);
    writer.buf.add(NativeGlueCode.prelude);

    var fnType = cls.superClass.params[0];
    var args, ret;
    switch(Context.follow(fnType)) {
    case TFun(a,r):
      args = [ for (arg in a) TypeConv.get(arg.t, cls.pos) ];
      ret = TypeConv.get(r, cls.pos);
    case _:
      throw new Error('Invalid argument for delegate ${cls.interfaces[0].t.get().name}', cls.pos);
    }

    for (arg in args.concat([ret])) {
      if (!arg.forwardDeclType.isNever() && arg.forwardDecls != null) {
        for (fwd in arg.forwardDecls) {
          writer.forwardDeclare(fwd);
        }
      } else {
        if (arg.glueCppIncludes != null) {
          for (include in arg.glueCppIncludes) {
            writer.include(include);
          }
        }
      }
    }

    writer.include('$uname.generated.h');
    var type = cls.superClass.t.get().name;
    var isDynamicDelegate = switch(type) {
      case 'DynamicMulticastDelegate', 'DynamicDelegate': true;
      default: false;
    }

    var declMacro = switch (type) {
      case 'Delegate': 'DECLARE_DELEGATE';
      case 'DynamicDelegate': 'DECLARE_DYNAMIC_DELEGATE';
      case 'Event': 'DECLARE_EVENT';
      case 'MulticastDelegate': 'DECLARE_MULTICAST_DELEGATE';
      case 'DynamicMulticastDelegate': 'DECLARE_DYNAMIC_MULTICAST_DELEGATE';
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
      default: throw new Error('Cannot declare a delegate with more than 8 parameters', cls.pos);
    }

    var retStr = ret.haxeType.isVoid() ? "" : "_RetVal";
    var constStr = cls.meta.has(':thisConst') ? "_Const" : "";

    // TODO: Support "payload" variables?

    writer.buf.add('$declMacro$retStr$argStr$constStr(');

    if (!ret.haxeType.isVoid()) {
      writer.buf.add('${ret.ueType.getCppType()}, ');
    }
    writer.buf.add(uname);

    var paramNames = MacroHelpers.extractStrings(cls.meta, ':uParamName');
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
    cls.meta.add(':ufiledependency', [macro $v{uname + "@" + Globals.cur.module}], cls.pos);
  }

  private function handleProperty(field:ClassField, isStatic:Bool) {
    var type = field.type,
        propTConv = TypeConv.get(type, field.pos);

    var uname = MacroHelpers.extractStrings(field.meta, ':uname')[0];
    if (uname == null)
      uname = field.name;
    var gms = [];
    for (mode in ['get','set']) {
      var tconv = propTConv;
      var isStructProp = !propTConv.isUObject && propTConv.ownershipModifier == 'unreal.PStruct';
      if (isStructProp && mode == 'get') {
        tconv = TypeConv.get(type, field.pos, 'unreal.PExternal');
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
      }, this.type, false);
      gms.push(gm);
    }
    gms[0].headerCode += '\n\t\t' + gms[1].headerCode;
    gms[0].cppCode += '\n\t\t' + gms[1].cppCode;

    for (meta in gms[0].getFieldMeta(false)) {
      field.meta.add(meta.name, meta.params, meta.pos);
    }
  }

  private function handleNativeCall(field:ClassField, isStatic:Bool) {
    var uname = MacroHelpers.extractStrings(field.meta, ':uname')[0];
    if (uname == null)
      uname = field.name;
    var ctx = null;
    var args = null, ret = null;
    switch( Context.follow(field.type) ) {
      case TFun(targs, tret):
        args = [ for (arg in targs) { name:arg.name, type:TypeConv.get(arg.t, field.pos) } ];
        ret = TypeConv.get(tret, field.pos);
      case _:
        throw 'assert';
    }

    var glue = this.typeRef.getGlueHelperType();
    var externName = field.name;
    var headerDef = new HelperBuf(),
        cppDef = new HelperBuf();
    headerDef << 'static ' << ret.glueType.getCppType() << ' ' << externName << '(';
    cppDef << ret.glueType.getCppType() << ' ' << glue.getCppClass() << '_obj::' << externName << '(';
    var thisDef = thisConv.glueType.getCppType() + ' self';
    if (!isStatic) {
      headerDef << thisDef;
      cppDef << thisDef;
    }

    if (args.length > 0) {
      var argsDef = [ for (arg in args) arg.type.glueType.getCppType() + ' ' + arg.name ].join(', ');
      headerDef << ', ' << argsDef;
      cppDef << ', ' << argsDef;
    }
    headerDef << ');';
    cppDef << ') {\n\t';

    // CPP signature to call a virtual function non-virtually: ref->::path::to::Type::field(arg1,arg2,...,argn)
    {
      var cppBody = new HelperBuf();
      if (uname == "new") {
        cppBody << "new " << this.thisConv.ueType.getCppClass();
      } else {
        if (isStatic)
          cppBody << this.thisConv.ueType.getCppClass() << '::';
        else
          cppBody << this.thisConv.glueToUe('self', null) << '->';
      }
      if (uname != "new") {
        cppBody << uname;
      }
      cppBody << '(';
      cppBody.mapJoin(args, function(arg) return arg.type.glueToUe(arg.name, ctx));
      cppBody << ')';
      if (!ret.haxeType.isVoid())
        cppDef << 'return ' << ret.ueToGlue(cppBody.toString(), null) << ';\n}';
      else
        cppDef << cppBody << ';\n}';
    }

    var allTypes = [ for (arg in args) arg.type ];
    allTypes.push(ret);

    var metas = getMetaDefinitions(headerDef.toString(), cppDef.toString(), allTypes, field.pos);
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

    var headerDef = '\n\t\tstatic void* $methodName();';
    var cppDef = 'void* ${glue.getCppClass()}_obj::$methodName() {\n\treturn (void*)${this.thisConv.ueType.getCppClass()}::_get_${externName}_methodPtr;\n}\n';
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
    var ctx = null;
    var args = null, ret = null;
    switch( Context.follow(superField.type) ) {
      case TFun(targs, tret):
        args = [ for (arg in targs) { name:arg.name, type:TypeConv.get(arg.t, field.pos) } ];
        ret = TypeConv.get(tret, field.pos);
      case _:
        throw 'assert';
    }

    var glue = this.typeRef.getGlueHelperType();
    var externName = field.name;
    var headerDef = new HelperBuf(),
        cppDef = new HelperBuf();
    headerDef << 'static ' << ret.glueType.getCppType() << ' ' << externName << '(';
    cppDef << ret.glueType.getCppType() << ' ' << glue.getCppClass() << '_obj::' << externName << '(';
    var thisDef = thisConv.glueType.getCppType() + ' self';
    headerDef << thisDef;
    cppDef << thisDef;

    if (args.length > 0) {
      var argsDef = [ for (arg in args) arg.type.glueType.getCppType() + ' ' + arg.name ].join(', ');
      headerDef << ', ' << argsDef;
      cppDef << ', ' << argsDef;
    }
    headerDef << ');';
    cppDef << ') {\n\t';

    // CPP signature to call a virtual function non-virtually: ref->::path::to::Type::field(arg1,arg2,...,argn)
    {
      var cppBody = new HelperBuf() << this.thisConv.glueToUe('self', null) << '->' << this.firstExternSuper.ueType.getCppClass() << '::' << uname << '(';
      cppBody.mapJoin(args, function(arg) return arg.type.glueToUe(arg.name, ctx));
      cppBody << ')';
      if (!ret.haxeType.isVoid())
        cppDef << 'return ' << ret.ueToGlue(cppBody.toString(), null) << ';\n}';
      else
        cppDef << cppBody << ';\n}';
    }

    var allTypes = [ for (arg in args) arg.type ];
    allTypes.push(ret);

    var metas = getMetaDefinitions(headerDef.toString(), cppDef.toString(), allTypes, field.pos);
    for (meta in metas) {
      field.meta.add(meta.name, meta.params, meta.pos);
    }
  }

  private static function getMetaDefinitions(headerDef:String, cppDef:String, allTypes:Array<TypeConv>, pos:Position):Metadata {
    var headerIncludes = new IncludeSet();
    var cppIncludes = new IncludeSet();
    for (t in allTypes) {
      headerIncludes.append(t.glueHeaderIncludes);
      cppIncludes.append(t.glueCppIncludes);
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
