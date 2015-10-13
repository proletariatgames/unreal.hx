package ue4hx.internal;
#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

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

    var ctx = !isStatic && !TypeConv.get(Context.getLocalType(), pos).isUObject ? [ "parent" => "this" ] : null;
    var tconv = TypeConv.get(field.type, pos);
    var glueExpr = new HelperBuf() + getGlueType_impl(cls, pos);
    glueExpr += '.' + (isSetter ? 'set_' : 'get_') + fieldName + '(';
    if (!isStatic) {
      var thisConv = TypeConv.get( Context.getLocalType(), pos );
      glueExpr += thisConv.haxeToGlue('this', ctx);
      if (isSetter)
        glueExpr += ', ';
    }
    var expr = if (isSetter) {
      (glueExpr + tconv.haxeToGlue('value', ctx)).toString() + ')';
    } else {
      tconv.glueToHaxe( glueExpr.toString() + ')', ctx );
    }

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
    if (block.length == 1)
      return block[0];
    else
      return { expr:EBlock(block), pos: pos };
  }

  macro public static function getNativeCall(fieldName:String, isStatic:Bool, args:Array<haxe.macro.Expr>):haxe.macro.Expr {
    var cls = Context.getLocalClass().get(),
        pos = Context.currentPos();

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
    if (block.length == 1)
      return block[0];
    else
      return { expr:EBlock(block), pos: pos };
  }

#if macro
  private static function getGlueType_impl(cls:ClassType, pos:Position) {
    var type = TypeRef.fromBaseType(cls, pos);
    var glue = type.getGlueHelperType();
    var path = glue.getClassPath();
    if (!Globals.current.builtGlueTypes.exists(path)) {
      // This is needed since while building a delayed glue, we may trigger
      // another macro that will try to build the glue once again (since no glue was built yet)
      // We must only build the last build call; all others will be built after this one
      var dglue = new DelayedGlue(cls,pos);
      Globals.current.buildingGlueTypes[path] = dglue;
      dglue.build();
      if (Globals.current.buildingGlueTypes[path] == dglue)
        cls.meta.add(':ueGluePath', [macro $v{ glue.getClassPath() }], cls.pos );
      Globals.current.builtGlueTypes[path] = true;
      Globals.current.buildingGlueTypes[path] = null;
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
    return Globals.current.buildingGlueTypes[ this.gluePath ] == this;
  }

  public function build() {
    var cls = this.cls;
    this.typeRef = TypeRef.fromBaseType( cls, this.pos );
    this.thisConv = TypeConv.get( Context.getLocalType(), this.pos );
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
        nativeCalls = new Map();
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
      if (!ignoreSupers.exists(ncall))
        nativeCalls[ncall] = null;
    }

    for (field in cls.fields.get()) {
      if (uprops.exists(field.name)) {
        uprops[field.name] = { cf:field, isStatic:false };
      } else if (superCalls.exists(field.name)) {
        superCalls[field.name] = field;
      } else if (nativeCalls.exists(field.name)) {
        nativeCalls[field.name] = { cf:field, isStatic:false };
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
      if (superField == null) throw 'assert';
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
    if (!this.shouldContinue())
      return;

    var glue = this.typeRef.getGlueHelperType();
    var glueHeaderIncludes = this.thisConv.glueHeaderIncludes;
    var glueCppIncludes = this.thisConv.glueCppIncludes;

    if (glueHeaderIncludes != null && glueHeaderIncludes.length > 0)
      cls.meta.add(':glueHeaderIncludes', [ for (inc in glueHeaderIncludes) macro $v{inc} ], this.pos);
    if (glueCppIncludes != null && glueCppIncludes.length > 0)
      cls.meta.add(':glueCppIncludes', [ for (inc in glueCppIncludes) macro $v{inc} ], this.pos);

    if (!this.shouldContinue())
      return;
    Context.defineType({
      pack: glue.pack,
      name: glue.name,
      pos: this.pos,
      meta: [
        { name:':unrealGlue', pos:this.pos },
      ],
      isExtern: true,
      kind: TDClass(),
      fields: this.buildFields,
    });
    Context.getType(glue.getClassPath());
  }

  private function handleProperty(field:ClassField, isStatic:Bool) {
    var type = field.type,
        tconv = TypeConv.get(type, field.pos);
    var glue = this.typeRef.getGlueHelperType();
    var headerDef = new HelperBuf(),
        cppDef = new HelperBuf();
    for (mode in ['get','set']) {
      var ret = null;
      if (mode == 'get') {
        ret = tconv;
      } else {
        ret = TypeConv.get(Context.getType('Void'), field.pos);
      }
      headerDef = headerDef + 'public: static ' + ret.glueType.getCppType() + ' ' + mode + '_' + field.name + '(';
      cppDef = cppDef + ret.glueType.getCppType() + ' ' + glue.getCppClass() + '_obj::' + mode + '_' + field.name + '(';

      if (!isStatic) {
        var thisDef = this.thisConv.glueType.getCppType() + ' self';
        headerDef += thisDef;
        cppDef += thisDef;
      }

      if (mode == 'set') {
        var comma = isStatic ? '' : ', ';
        headerDef = headerDef + comma + tconv.glueType.getCppType() + ' value';
        cppDef = cppDef + comma + tconv.glueType.getCppType() + ' value';
      }
      headerDef += ');\n';
      cppDef += ') {\n\t';

      var cppBody = new HelperBuf();
      if (isStatic) {
        cppBody = cppBody + this.thisConv.ueType.getCppClass() + '::' + field.name;
      } else {
        cppBody = cppBody + this.thisConv.glueToUe('self', null) + '->' + field.name;
      }

      if (mode == 'get')
        cppDef = cppDef + 'return ' + tconv.ueToGlue(cppBody.toString(), null) + ';\n}\n';
      else
        cppDef = cppDef + cppBody.toString() + ' = ' + tconv.glueToUe('value', null) + ';\n}\n';

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
    var allTypes = [this.thisConv, tconv];
    var metas = getMetaDefinitions(headerDef.toString(), cppDef.toString(), allTypes, field.pos);
    for (meta in metas) {
      field.meta.add(meta.name, meta.params, meta.pos);
    }
  }

  private function handleNativeCall(field:ClassField, isStatic:Bool) {
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
    headerDef = headerDef + 'static ' + ret.glueType.getCppType() + ' ' + externName + '(';
    cppDef = cppDef + ret.glueType.getCppType() + ' ' + glue.getCppClass() + '_obj::' + externName + '(';
    var thisDef = thisConv.glueType.getCppType() + ' self';
    headerDef += thisDef;
    cppDef += thisDef;

    if (args.length > 0) {
      var argsDef = [ for (arg in args) arg.type.glueType.getCppType() + ' ' + arg.name ].join(', ');
      headerDef = headerDef + ', ' + argsDef;
      cppDef = cppDef + ', ' + argsDef;
    }
    headerDef += ');';
    cppDef += ') {\n\t';

    // CPP signature to call a virtual function non-virtually: ref->::path::to::Type::field(arg1,arg2,...,argn)
    {
      var cppBody = new HelperBuf();
      if (isStatic)
        cppBody += this.thisConv.ueType.getCppClass() + '::';
      else
        cppBody += this.thisConv.glueToUe('self', null) + '->';
      cppBody += field.name + '(';
      cppBody.mapJoin(args, function(arg) return arg.type.glueToUe(arg.name, ctx));
      cppBody += ')';
      if (!ret.haxeType.isVoid())
        cppDef = cppDef + 'return ' + ret.ueToGlue(cppBody.toString(), null) + ';\n}';
      else
        cppDef = cppDef + cppBody + ';\n}';
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

  private function handleSuperCall(field:ClassField, superField:ClassField) {
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
    headerDef = headerDef + 'static ' + ret.glueType.getCppType() + ' ' + externName + '(';
    cppDef = cppDef + ret.glueType.getCppType() + ' ' + glue.getCppClass() + '_obj::' + externName + '(';
    var thisDef = thisConv.glueType.getCppType() + ' self';
    headerDef += thisDef;
    cppDef += thisDef;

    if (args.length > 0) {
      var argsDef = [ for (arg in args) arg.type.glueType.getCppType() + ' ' + arg.name ].join(', ');
      headerDef = headerDef + ', ' + argsDef;
      cppDef = cppDef + ', ' + argsDef;
    }
    headerDef += ');';
    cppDef += ') {\n\t';

    // CPP signature to call a virtual function non-virtually: ref->::path::to::Type::field(arg1,arg2,...,argn)
    {
      var cppBody = new HelperBuf() + this.thisConv.glueToUe('self', null) + '->' + this.firstExternSuper.ueType.getCppClass() + '::' + superField.name + '(';
      cppBody.mapJoin(args, function(arg) return arg.type.glueToUe(arg.name, ctx));
      cppBody += ')';
      if (!ret.haxeType.isVoid())
        cppDef = cppDef + 'return ' + ret.ueToGlue(cppBody.toString(), null) + ';\n}';
      else
        cppDef = cppDef + cppBody + ';\n}';
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
    var headerIncludes = [ for (t in allTypes) if(t.glueHeaderIncludes != null) for (inc in t.glueHeaderIncludes) inc => inc ];
    var cppIncludes = [ for (t in allTypes) if(t.glueCppIncludes != null) for (inc in t.glueCppIncludes) inc => inc ];

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
