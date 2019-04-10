package uhx.compiletime;
import uhx.compiletime.types.GlueMethod;
import uhx.compiletime.types.TypeConv;
import uhx.compiletime.types.TypeRef;
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;
using uhx.compiletime.tools.MacroHelpers;
using haxe.macro.Tools;

class TemplateBuild
{
  public static function make(functionName:String, definedTypePath:String, ethis:Expr, args:Array<Expr>):Expr
  {
    var pos = Context.currentPos();
    var typeRef = TypeRef.parse(definedTypePath);

    var isStatic = false;
    var ecur = ethis;
    switch(ethis)
    {
    case null | macro null:
      ethis = null;
      // if we're not sent a `this` expression, the function is static
      isStatic = true;
      ecur = Context.parse(definedTypePath, pos);
    case _:
    }
    // we generate a `_uhx_type` function that provides a typing helper
    var typedFunctionName = functionName + '_uhx_type';
    var typeExpr = macro @:pos(pos) $ecur.$typedFunctionName;
    typeExpr = { expr:ECall(typeExpr, args), pos: pos };
    // if the macro was called in an expression where ithe expected type is known
    // (e.g. var x:SomeType<AParam> = myMacro()), get that expected type so we can force it to type correctly
    var expected:Type = Context.getExpectedType();
    var expectedComplex = expected == null ? null : expected.toComplexType();
    if (expectedComplex != null)
    {
      typeExpr = { expr:ECheckType(typeExpr, expectedComplex), pos:pos };
    }
    if (Context.defined('UHX_DISPLAY'))
    {
      // if we're in display mode, we just want to return something that types correctly
      return typeExpr;
    }
    // type it. If the expression can't be typed, this will bubble the typing error
    var typed = getCall(Context.typeExpr(typeExpr));
    switch(typed.expr)
    {
    case TCall({ expr:TField(et_this, fa), t:funcType }, targs):
      var tparams = [];
      var cf:ClassField = null;
      switch(fa)
      {
      case FInstance(_,params,field):
        cf = field.get();
        // if the field is non-static, the class type parameters also need to be taken into consideration
        tparams = [ for (param in params) TypeConv.get(param, pos) ];
      case FStatic(_,field):
        cf = field.get();
      case _:
        throw new Error('TemplateBuild: Invalid field access $fa', pos);
      }

      // get function type params
      var monos = [for (param in cf.params) Context.typeof(macro null)];
      var typeWithMonos = cf.type.applyTypeParameters(cf.params, monos);
      if (!Context.unify(typeWithMonos, funcType)) {
        throw new Error('TemplateBuild: Assertion failed: ${functionName} doesn\'t unify with its generic type', pos);
      }
      for (mono in monos)
      {
        tparams.push(TypeConv.get(mono, pos));
      }
      if (tparams.length == 0)
      {
        throw new Error('TemplateBuild: The function ${functionName} is not a generic function!', pos);
      }

      // get the suffix based on the type parameters
      var suffix = getSuffixForTypes(tparams, pos);
      var target = new TypeRef(['uhx','templates'], typeRef.name + '_' + functionName + '_' + suffix);
      var type = null;
      try
      {
        type = Context.getType(target.toString());
      }
      catch(e:Dynamic)
      {
        // create the type if it doesn't exist
        var fargs = [];
        var fret = null;
        switch(Context.follow(funcType))
        {
        case TFun(args,ret):
          for (arg in args.slice(cf.params.length))
          {
            fargs.push({ name:arg.name, t:TypeConv.get(arg.t, pos), opt:arg.opt ? macro null : null });
          }
          fret = TypeConv.get(ret, pos);
        case _:
          throw 'assert';
        }

        var metas = cf.meta.get();
        var sig = UhxMeta.getStaticMetas(metas) + 'run(' + [for (arg in fargs) arg.t.ueType.getCppType()].join(',') + '):' + fret.ueType.getCppType();
        if (!Context.defined('cppia'))
        {
          var flags:MethodFlags = MNone;
          if (isStatic)
          {
            flags |= Static;
          }
          if (!cf.isPublic)
          {
            flags |= CppPrivate;
          }

          var uname = MacroHelpers.extractStrings(cf.meta, ':uname')[0];
          var def:MethodDef = {
            name: 'run',
            uname: uname != null ? uname : functionName,
            args: fargs,
            ret: fret,
            flags: flags,
            doc: cf.doc,
            meta: metas,
            params: [ for (p in cf.params) { name:p.name, t:TypeConv.get(p.t, pos) } ],
            specialization: { types:tparams, genericFunction:functionName },
            pos: pos
          };
          var glue = target.getGlueHelperType();
          var type = Context.getType(definedTypePath);
          switch(Context.follow(type))
          {
          case TInst(c,tl):
            type = TInst(c, [ for (p in c.get().params) p.t ]);
          case TAbstract(a,tl):
            type = TAbstract(a, [ for (p in a.get().params) p.t ]);
          case _:
            throw 'assert: Unknown type $type for $definedTypePath. Expected class or abstract';
          }
          var classPos = cf.pos;
          function changePos(e:Expr)
          {
            e.pos = classPos;
            e.iter(changePos);
          }

          var ret = new GlueMethod(def, type, glue);
          var cls = macro class {
          };
          cls.pack = target.pack;
          cls.name = target.name;
          var field = ret.getField();
          switch(field.field.kind)
          {
            case FFun(fn):
              changePos(fn.expr);
            case _:
          }
          cls.fields.push(field.field);
          cls.meta = [{ name:UhxMeta.UGenerated, params:[macro $v{sig}], pos:pos }];
          cls.pos = classPos;
          if (field.glue != null)
          {
            var glueCls = macro class {
            };
            glueCls.pack = glue.pack;
            glueCls.name = glue.name;
            glueCls.isExtern = true;
            glueCls.meta = [{ name:':unrealGlue', params:[], pos:pos }];
            cls.meta.push({ name:':ueGluePath', params:[macro $v{glue.getClassPath()}], pos:pos });
            glueCls.fields.push(field.glue);
            Context.defineType(glueCls);
          }
          Globals.cur.hasUnprocessedTypes = true;
          Context.defineType(cls);
        } else {
          if (!Globals.cur.compiledScriptGluesExists(target.toString() + ":" + sig)) {
            var tparamsString = [for (tparam in tparams) tparam.haxeType.toString() ].join(', ');
            Context.warning('UHXERR: The templated function $functionName<$tparamsString> from $target was not compiled into static, or it was compiled with a different signature. A full C++ compilation is required', pos);
          }
          // cppia just needs to check the types
          var args:Array<FunctionArg> = [];
          if (!isStatic)
          {
            args.push({ name:'uhx_this', type:TypeConv.get(et_this.t, pos).haxeType.toComplexType(), opt:false });
          }
          for (i in 0...tparams.length)
          {
            var tparam = tparams[i];
            args.push({ name:'TP_$i', type:new TypeRef(['unreal'], 'TypeParam', [tparam.haxeType]).toComplexType(), opt: true });
          }
          for (arg in fargs)
          {
            args.push({ name:arg.name, type:arg.t.haxeType.toComplexType() });
          }
          var field:Field = {
            name:"run",
            kind: FFun({
              args:args,
              ret: fret.haxeType.toComplexType(),
              expr:null
            }),
            access:[AStatic],
            pos:pos
          };
          var cls = macro class {};
          cls.fields.push(field);
          cls.pack = target.pack;
          cls.name = target.name;
          cls.isExtern = true;
          Globals.cur.hasUnprocessedTypes = true;
          Context.defineType(cls);
        }
        type = Context.getType(target.toString());
      }
      var field = Context.parse(target.toString() + '.run', pos);
      var callArgs = [];
      if (ethis != null)
      {
        callArgs.push(ethis);
      }
      for (arg in args)
      {
        callArgs.push(arg);
      }
      return { expr:ECall(field, callArgs), pos:pos };
    case r:
      throw 'assert';
    }
    return null;
  }

  private static function getSuffixForTypes(params:Array<TypeConv>, pos:Position)
  {
    return [for (p in params) p.toShortString()].join('__');
  }

  private static function getCall(t:TypedExpr):TypedExpr
  {
    return switch(t.expr) {
      case TCall(_):
        t;
      case _:
        var ret = null;
        function iter(e:TypedExpr)
        {
          switch(e.expr)
          {
            case TCall(_):
              ret = e;
            case _:
              e.iter(iter);
          }
        }
        iter(t);
        ret;
    }
  }
}