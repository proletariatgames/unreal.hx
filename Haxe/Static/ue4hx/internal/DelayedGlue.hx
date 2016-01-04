package ue4hx.internal;
import ue4hx.internal.buf.HelperBuf;
#if macro
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
  macro public static function getGlueType():haxe.macro.Expr {
    var cls = Context.getLocalClass().get(),
        pos = Context.currentPos();
    var ret = getGlueType_impl(cls, pos);
    return Context.parse(ret, pos);
  }

  macro public static function getGetterSetterExpr(fieldName:String, isStatic:Bool, isSetter:Bool):haxe.macro.Expr {
    var cls = Context.getLocalClass().get(),
        pos = Context.currentPos();
    var field = cls.findField(fieldName, isStatic);
    if (field == null) throw 'assert';
    var old = Globals.cur.currentFeature;
    Globals.cur.currentFeature = 'keep'; // these fields will always be kept

    var ctx = !isStatic && !TypeConv.get(Context.getLocalType(), pos).isUObject ? [ "parent" => "this" ] : null;
    var tconv = TypeConv.get(field.type, pos);
    var glueExpr = new HelperBuf() << getGlueType_impl(cls, pos);
    glueExpr << '.' << (isSetter ? 'set_' : 'get_') << fieldName << '(';
    if (!isStatic) {
      var thisConv = TypeConv.get( Context.getLocalType(), pos, "unreal.PExternal");
      glueExpr << thisConv.haxeToGlue('this', ctx);
      if (isSetter)
        glueExpr << ', ';
    }
    var expr = if (isSetter) {
      (glueExpr << tconv.haxeToGlue('value', ctx)).toString() + ')';
    } else {
      tconv.glueToHaxe( glueExpr.toString() + ')', ctx );
    }

    Globals.cur.currentFeature = old;
    return Context.parse(expr, pos);
  }

  macro public static function getSuperExpr(fieldName:String, args:Array<haxe.macro.Expr>):haxe.macro.Expr {
    var cls = Context.getLocalClass().get(),
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
    var field = superClass.t.get().findField(fieldName, false);
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

    var glueExpr = getGlueType_impl(cls, pos);
    var expr = glueExpr + '.' + fieldName + '(' + [ for (arg in fargs) arg.type.haxeToGlue(arg.name, null) ].join(',') + ')';
    if (!fret.haxeType.isVoid())
      expr = fret.glueToHaxe(expr, null);
    block.push(Context.parse(expr, pos));

    Globals.cur.currentFeature = old;
    if (block.length == 1)
      return block[0];
    else
      return { expr:EBlock(block), pos: pos };
  }

  macro public static function getNativeCall(fieldName:String, isStatic:Bool, args:Array<haxe.macro.Expr>):haxe.macro.Expr {
    var cls = Context.getLocalClass().get(),
        pos = Context.currentPos();
    var old = Globals.cur.currentFeature;
    Globals.cur.currentFeature = 'keep'; // these fields will always be kept

    var field = cls.findField(fieldName, isStatic);
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

    var glueExpr = getGlueType_impl(cls, pos);
    var expr = glueExpr + '.' + fieldName + '(' + [ for (arg in fargs) arg.type.haxeToGlue(arg.name, null) ].join(',') + ')';
    if (!fret.haxeType.isVoid())
      expr = fret.glueToHaxe(expr, null);
    block.push(Context.parse(expr, pos));

    Globals.cur.currentFeature = old;
    if (block.length == 1) {
      return block[0];
    } else {
      return { expr:EBlock(block), pos: pos };
    }
  }

#if macro
  private static function getGlueType_impl(cls:ClassType, pos:Position) {
    var type = TypeRef.fromBaseType(cls, pos);
    var glue = type.getGlueHelperType();
    var path = glue.getClassPath();
    if (!Globals.cur.builtGlueTypes.exists(path)) {
      var old = Globals.cur.currentFeature;
      Globals.cur.currentFeature = 'keep'; // these fields will always be kept
      // This is needed since while building a delayed glue, we may trigger
      // another macro that will try to build the glue once again (since no glue was built yet)
      // We must only build the last build call; all others will be built after this one
      var dglue = new DelayedGlue(cls,pos);
      Globals.cur.buildingGlueTypes[path] = dglue;
      dglue.build();
      if (Globals.cur.buildingGlueTypes[path] == dglue) {
        cls.meta.add(':ueGluePath', [macro $v{ glue.getClassPath() }], cls.pos );
        Globals.cur.gluesToGenerate = Globals.cur.gluesToGenerate.add(type.getClassPath());
      }
      Globals.cur.builtGlueTypes[path] = true;
      Globals.cur.buildingGlueTypes[path] = null;
      Globals.cur.currentFeature = old;
    }

    return path;
  }

  var cls:ClassType;
  var pos:Position;
  var typeRef:TypeRef;
  var thisConv:TypeConv;
  var buildFields:Array<Field>;
  var firstExternSuper:TypeConv;
  var gluePath:String;

  public function new(cls, pos) {
    this.cls = cls;
    this.pos = pos;
  }

  inline private function shouldContinue() {
    return Globals.cur.buildingGlueTypes[ this.gluePath ] == this;
  }

  public function build() {
    var cls = this.cls;
    this.typeRef = TypeRef.fromBaseType( cls, this.pos );
    this.thisConv = TypeConv.get( Context.getLocalType(), this.pos, 'unreal.PExternal' );
    this.buildFields = [];
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

    if (!this.shouldContinue())
      return;
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

    if (cls.meta.has(":uhxdelegate")) {
      writeDelegateDefinition(cls);
    } else if (cls.meta.has(":ustruct")) {
      writeStructDefinition(cls);
    }

    for (field in cls.fields.get()) {
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
      if (!this.shouldContinue())
        return;
    }

    for (ncall in nativeCalls) {
      this.handleNativeCall(ncall.cf, ncall.isStatic);
      if (!this.shouldContinue())
        return;
    }

    for (uprop in uprops) {
      this.handleProperty(uprop.cf, uprop.isStatic);
      if (!this.shouldContinue())
        return;
    }

    for (methodPtr in methodPtrs) {
      this.handleMethodPointer(methodPtr);
      if (!this.shouldContinue())
        return;
    }

    if (!this.shouldContinue())
      return;

    var glue = this.typeRef.getGlueHelperType();
    var glueHeaderIncludes = new IncludeSet(),
        glueCppIncludes = new IncludeSet();
    this.thisConv.getAllCppIncludes(glueCppIncludes);
    this.thisConv.getAllHeaderIncludes(glueHeaderIncludes);
    // var glueHeaderIncludes = this.thisConv.glueHeaderIncludes;
    // var glueCppIncludes = this.thisConv.glueCppIncludes;

    if (glueHeaderIncludes.length > 0)
      cls.meta.add(':glueHeaderIncludes', [ for (inc in glueHeaderIncludes) macro $v{inc} ], this.pos);
    if (glueCppIncludes.length > 0)
      cls.meta.add(':glueCppIncludes', [ for (inc in glueCppIncludes) macro $v{inc} ], this.pos);

    if (!this.shouldContinue())
      return;

    Globals.cur.cachedBuiltTypes.push(glue.getClassPath());
    var meta:Metadata = [
      { name:':unrealGlue', pos:this.pos },
    ];
    if (Globals.cur.haxeTargetModule != null) {
      meta.push({ name:':utargetmodule', params:[macro $v{Globals.cur.haxeTargetModule}], pos:this.pos });
    }
    Context.defineType({
      pack: glue.pack,
      name: glue.name,
      pos: this.pos,
      meta: meta,
      isExtern: true,
      kind: TDClass(),
      fields: this.buildFields,
    });
    Context.getType(glue.getClassPath());
  }

  private function writeStructDefinition(cls:ClassType) {
    if (Globals.cur.haxeTargetModule != null && !cls.meta.has(':uextension')) {
      cls.meta.add(':utargetmodule', [macro $v{Globals.cur.haxeTargetModule}], cls.pos);
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
    cls.meta.add(':ufiledependency', [macro $v{uname}], cls.pos);
  }

  private function writeDelegateDefinition(cls:ClassType) {
    var info = GlueInfo.fromBaseType(cls);
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
    cls.meta.add(':ufiledependency', [macro $v{uname}], cls.pos);
  }

  private function handleProperty(field:ClassField, isStatic:Bool) {
    var type = field.type,
        propTConv = TypeConv.get(type, field.pos);

    var glue = this.typeRef.getGlueHelperType();
    var headerDef = new HelperBuf(),
        cppDef = new HelperBuf();
    var uname = MacroHelpers.extractStrings(field.meta, ':uname')[0];
    if (uname == null)
      uname = field.name;
    for (mode in ['get','set']) {
      var tconv = propTConv;
      var isStructProp = !propTConv.isUObject && propTConv.ownershipModifier == 'unreal.PStruct';
      if (isStructProp && mode == 'get') {
        tconv = TypeConv.get(type, field.pos, 'unreal.PExternal');
      }

      var ret = null;
      if (mode == 'get') {
        ret = tconv;
      } else {
        ret = TypeConv.get(Context.getType('Void'), field.pos);
      }
      headerDef << 'public: static ' << ret.glueType.getCppType() << ' ' << mode << '_' << field.name + '(';
      cppDef << ret.glueType.getCppType() << ' ' << glue.getCppClass() << '_obj::' << mode << '_' << field.name << '(';

      if (!isStatic) {
        var thisDef = this.thisConv.glueType.getCppType() + ' self';
        headerDef << thisDef;
        cppDef << thisDef;
      }

      if (mode == 'set') {
        var comma = isStatic ? '' : ', ';
        headerDef << comma << tconv.glueType.getCppType() << ' value';
        cppDef << comma << tconv.glueType.getCppType() << ' value';
      }
      headerDef << ');\n';
      cppDef << ') {\n\t';

      var cppBody = new HelperBuf();
      if (isStatic) {
        cppBody << this.thisConv.ueType.getCppClass() << '::' << uname;
      } else {
        cppBody << this.thisConv.glueToUe('self', null) << '->' << uname;
      }

      if (mode == 'get')
        cppDef << 'return ' << tconv.ueToGlue((isStructProp ? '&' : '') + cppBody.toString(), null) << ';\n}\n';
      else
        cppDef << cppBody.toString() << ' = ' << tconv.glueToUe('value', null) << ';\n}\n';

      var args:Array<FunctionArg> = if (isStatic)
        [];
      else
        [{ name:'self', type:this.thisConv.haxeGlueType.toComplexType() }];
      if (mode == 'set')
        args.push({ name:'value', type:tconv.haxeGlueType.toComplexType() });
      this.buildFields.push({
        name: mode + '_' + field.name,
        access: [APublic,AStatic],
        kind: FFun({
          args: args,
          ret: ret.haxeGlueType.toComplexType(),
          expr: null
        }),
        pos:field.pos
      });
    }
    // add the remaining metadata
    var allTypes = [this.thisConv, propTConv];
    var metas = getMetaDefinitions(headerDef.toString(), cppDef.toString(), allTypes, field.pos);
    for (meta in metas) {
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

    var selfArg = isStatic ? [] : [{name:'self', type:this.thisConv.haxeGlueType.toComplexType()}];

    this.buildFields.push({
      name: externName,
      access: [APublic,AStatic],
      kind: FFun({
        args: selfArg.concat([ for (arg in args) { name: arg.name, type: arg.type.haxeGlueType.toComplexType() } ]),
        ret: ret.haxeGlueType.toComplexType(),
        expr: null
      }),
      pos: field.pos
    });
  }

  private function handleMethodPointer(field:ClassField) {
    var externName = field.name;
    var methodName = '_get_${externName}_methodPtr';

    var glue = this.typeRef.getGlueHelperType();
    var clsField = this.cls.statics.get().find(function (f) return f.name == methodName);
    if (clsField == null) {
      throw 'assert: can\'t find $methodName';
    }

    var headerDef = '\n\t\tstatic void* $methodName();';
    var cppDef = 'void* ${glue.getCppClass()}_obj::$methodName() {\n\treturn (void*)${this.thisConv.ueType.getCppClass()}::_get_${externName}_methodPtr;\n}\n';
    var metas:Metadata = [
      { name: ':glueHeaderCode', params:[macro $v{headerDef}], pos: field.pos },
      { name: ':glueCppCode', params:[macro $v{cppDef}], pos: field.pos },
    ];

    for (meta in metas) {
      clsField.meta.add(meta.name, meta.params, meta.pos);
    }

    this.buildFields.push({
      name: methodName,
      access: [APublic, AStatic],
      kind: FFun({
       args : [],
       ret : macro :cpp.RawPointer<cpp.Void>,
       expr :null
      }),
      pos: field.pos
    });
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

    this.buildFields.push({
      name: externName,
      access: [APublic,AStatic],
      kind: FFun({
        args: [
            { name: 'self', type: this.thisConv.haxeGlueType.toComplexType() }
          ].concat([ for (arg in args) { name: arg.name, type: arg.type.haxeGlueType.toComplexType() } ]),
        ret: ret.haxeGlueType.toComplexType(),
        expr: null
      }),
      pos: field.pos
    });
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
