package ue4hx.internal;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import ue4hx.internal.buf.HelperBuf;

using haxe.macro.TypeTools;
using Lambda;
using StringTools;

/**
  Represents a Haxe type whose glue code will be generated. Contains all the information
  on how to generate the glue code for the type

  @see TypeConvInfo
 **/
@:forward abstract TypeConv(TypeConvInfo) from TypeConvInfo to TypeConvInfo
{
  public var haxeGlueType(get,never):TypeRef;
  public var glueType(get,never):TypeRef;

  inline function new(obj)
    this = obj;

  inline function underlying()
    return this;

  public function hasTypeParams():Bool {
    return this.isTypeParam || (this.args != null && this.args.exists(function(v) return v.hasTypeParams()));
  }

  public function haxeToGlue(expr:String, ctx:Map<String,String>)
  {
    if (this.haxeToGlueExpr == null)
      return expr;
    return expand(this.haxeToGlueExpr, expr, ctx);
  }

  public function glueToHaxe(expr:String, ctx:Map<String,String>)
  {
    if (this.glueToHaxeExpr == null)
      return expr;
    return expand(this.glueToHaxeExpr, expr, ctx);
  }

  public function glueToUe(expr:String, ctx:Map<String,String>) {
    if (this.glueToUeExpr == null)
      return expr;
    return expand(this.glueToUeExpr, expr, ctx);
  }

  public function ueToGlue(expr:String, ctx:Map<String,String>) {
    if (this.ueToGlueExpr == null)
      return expr;
    return expand(this.ueToGlueExpr, expr, ctx);
  }

  public function getAllCppIncludes(map:IncludeSet) {
    map.append( this.glueCppIncludes );
    if (this.args != null) {
      for (arg in this.args) {
        arg.getAllCppIncludes(map);
      }
    }
  }

  public function getAllHeaderIncludes(map:IncludeSet) {
    map.append( this.glueHeaderIncludes );
    if (this.args != null) {
      for (arg in this.args) {
        arg.getAllHeaderIncludes(map);
      }
    }
  }

  static function expand(expr:String, ethis:String, ctx:Map<String,String>) {
    var buf = new StringBuf();
    var i = -1, len = expr.length;
    while(++i < len) {
      switch(expr.fastCodeAt(i)) {
      case '%'.code:
        buf.add(ethis);
      case '$'.code:
        var next = expr.fastCodeAt(i+1);
        if (next == '$'.code) {
          i++;
          buf.addChar('$'.code);
        } else {
          var start = i;
          while (++i < len) {
            var chr = expr.fastCodeAt(i);
            if (!((chr >= 'a'.code && chr <= 'z'.code) || (chr >= 'A'.code && chr <= 'Z'.code)))
              break;
          }
          var data = ctx == null ? null : ctx[expr.substring(start + 1,i)];
          buf.add(data);
        }
      case chr:
        buf.addChar(chr);
      }
    }
    return buf.toString();
  }

  private static function typeIsUObject(t:Type) {
    var uobject = Globals.cur.uobject;
    if (uobject == null) {
      Globals.cur.uobject = uobject = Context.getType('unreal.UObject');
    }
    return Context.unify(t, uobject);
  }

  private function get_haxeGlueType():TypeRef {
    return this.haxeGlueType != null ? this.haxeGlueType : this.haxeType;
  }

  private function get_glueType():TypeRef {
    return this.glueType != null ? this.glueType : this.ueType;
  }

  private static function getTypeCtx(type:Type, pos:Position):TypeConvCtx {
    // we'll loop until we find a type we're interested in
    // when found, we'll get its name, type parameters and
    // if it's a class, its meta too
    var originalType = null;
    while(true) {
      switch(type) {
      case TInst(iref,tl):
        var it = iref.get();
        var name = iref.toString();
        var native = getMetaString(it.meta, ':native');
        if (native != null)
          name = native;
        return {
          name: name,
          args: tl,
          meta: it.meta,

          isInterface: it.isInterface,
          superClass: it.superClass,
          baseType: it,
          isUObject: TypeConv.typeIsUObject(type) || (it.isInterface && it.meta.has(':uextern')),
          originalType: originalType,
          isTypeParam: it.kind.match(KTypeParameter(_)),
        };

      case TEnum(eref,tl):
        var e = eref.get();
        return {
          name: eref.toString(),
          args: tl,
          meta: e.meta,
          isEnum: true,

          baseType: e,
          originalType: originalType
        }

      case TAbstract(aref,tl):
        var at = aref.get();
        if (at.meta.has(':coreType') || at.meta.has(':unrealType'))
        {
          return {
            name: aref.toString(),
            args: tl,
            meta: at.meta,
            isEnum: at.meta.has(':enum'),
            isAbstract: true,

            baseType: at,
            isBasic: true,
            originalType: originalType
          }
        }
        if (originalType == null)
          originalType = TypeRef.fromType(type, pos);
        // follow it
#if (haxe_ver >= 3.3)
        // this is more robust than the 3.2 version, since it will also correctly
        // follow @:multiType abstracts
        type = type.followWithAbstracts(true);
#else
        type = at.type.applyTypeParameters(at.params, tl);
#end

      case TType(tref,tl):
        var t = tref.get();
        if (t.meta.has(':unrealType'))
        {
          return {
            name: tref.toString(),
            args: tl,
            meta: t.meta,

            isBasic: true,
            originalType: originalType
          }
        }
        type = type.follow(true);
      case TMono(mono):
        type = mono.get();
        if (type == null) {
          throw 'assert';
          throw new Error('Unreal Glue: Type cannot be Unknown', pos);
        }
      case TLazy(f):
        type = f();
      case TFun(_):
        return {
          name: "function",
          args: [],
          meta: null,
          isFunction: true,
          isBasic : false,
          originalType : originalType
        };
      case _:
        throw new Error('Unreal Glue: Invalid type $type', pos);
      }
    }
    throw 'assert';
  }

  private static function isPOwnership(ctx:TypeConvCtx) {
    if (!ctx.isBasic)
      return false;
    switch (ctx.name) {
    case 'unreal.PHaxeCreated' | 'unreal.PExternal' | 'unreal.PStruct' |
         'unreal.TSharedPtr' | 'unreal.TThreadSafeSharedPtr' |
         'unreal.TSharedRef' | 'unreal.TThreadSafeSharedRef' |
         'unreal.TWeakPtr' | 'unreal.TThreadSafeWeakPtr' |
         'unreal.PRef':
      return true;
    case 'ue4hx.internal.PHaxeCreatedDef' | 'ue4hx.internal.PExternalDef' | 'ue4hx.internal.PStructDef' |
         'ue4hx.internal.PRefDef':
      ctx.name = 'unreal.' + ctx.name.split('.').pop().substr(0,-3);
      return true;
    case _:
      return false;
    }
  }

  public static function get(type:Type, pos:Position, ?ownershipOverride:String = null, registerTParam=true):TypeConv {
    var ctx = getTypeCtx(type, pos);
    if (ctx.name == 'unreal.Const') {
      var ret = Reflect.copy(_get(ctx.args[0], pos, ownershipOverride, registerTParam));
      if (ret.ueToGlueExpr != null) {
        ret.ueToGlueExpr = ret.ueToGlueExpr.replace("%", "const_cast<" + ret.ueType.getCppType() + ">( % )");
        ret.ueType = ret.ueType.withConst(true);
      }
      return ret;
    } else {
      return _get(type, pos, ownershipOverride, registerTParam);
    }
  }

  private static function _get(type:Type, pos:Position, ?ownershipOverride:String = null, registerTParam=true):TypeConvInfo
  {

    var ctx = getTypeCtx(type, pos);
    var ownershipModifier = null;
    if (isPOwnership(ctx)) {
      // TODO: cleanup so it plays nicely when more modifiers are added (e.g. Const, etc)
      ownershipModifier = ctx;
      ctx = getTypeCtx(ctx.args[0], pos);
      var has = isPOwnership(ctx);
      while(isPOwnership(ctx))
        ctx = getTypeCtx(ctx.args[0], pos);
      // if (isPOwnership(ctx))
      //   throw new Error('Unreal Glue: You cannot use two pointer modifiers in the same type (${ownershipModifier.name}<${ctx.name}<>>)', pos);
    }

    var name = ctx.name,
        args = ctx.args,
        meta = ctx.meta,
        superClass = ctx.superClass;
    var baseType = ctx.baseType;
    var isBasic = ctx.isBasic,
        isUObject = ctx.isUObject;
    var modf = ownershipOverride;
    if (modf == null) {
      if (ownershipModifier != null) {
        modf = ownershipModifier.name;
      }
    }

    // this helper function will handle `modf` (`ownershipModifier`)
    // on types that don't have a special way to handle it
    // FIXME: implement this to get basic types working
    // inline function wrapOwnership(info:TypeConvInfo):TypeConvInfo {
    //   if (modf != null) {
    //     switch (modf) {
    //     // TODO: (we need temp vars to make this work :(
    //     // case 'unreal.PExternal' | 'unreal.PHaxeCreated':
    //     //   info.ueType = new TypeRef(['cpp'], 'RawPointer', [info.ueType]);
    //     //   if (info.ueToGlueExpr != null)
    //     //     info.ueToGlueExpr = '&(' + info.ueToGlueExpr + ')';
    //     //   if (info.glueToUeExpr != null
    //     case 'unreal.PRef':
    //       // if (info.ueType.name == 'RawPointer') {
    //         // info.ueType = new TypeRef(['cpp'], 'Reference', info.ueType.params);
    //       // } else {
    //         info.ueType = new TypeRef(['cpp'], 'Reference', [info.ueType]);
    //       // }
    //     case _:
    //     }
    //   }
    //   return info;
    // }
    // if we have it defined as a basic (special) type, use it
    var basic = basicTypes[name];
    if (basic != null) return basic;

    //
    // Handle lambdas
    //

    if (ctx.isFunction) {
      var fnArgs = null, fnRet = null;
      switch (type) {
      case TFun(args, ret):
        fnArgs = args.map(function(a) return get(a.t, pos));
        fnRet = get(ret, pos);

        if (!fnRet.haxeType.isVoid() && fnRet.isBasic == true && fnRet.ownershipModifier == 'unreal.PRef' || fnRet.ownershipModifier == 'unreal.PRefDef') {
          throw new Error('Unreal Glue: Function lambda types that return a reference to a basic type are not supported', pos);
        }

        #if !bake_externs
          // We need to ensure that all types have TypeParamGlue built in order for LambdaBinder to work
          for (i in 0...fnArgs.length) {
            if (!fnArgs[i].hasTypeParams()) {
              TypeParamBuild.ensureTypeConvBuilt(args[i].t, fnArgs[i], pos, Globals.cur.currentFeature);
            }
          }
          if (!fnRet.haxeType.isVoid()) {
            if (!fnRet.hasTypeParams()) {
              TypeParamBuild.ensureTypeConvBuilt(ret, fnRet, pos, Globals.cur.currentFeature);
            }
          }
        #end
      default:
        throw 'assert';
      }
      var glueToUeExpr = new HelperBuf();
      var binderTypeParams = fnArgs.copy();
      if (!fnRet.haxeType.isVoid()) {
        binderTypeParams.unshift(fnRet);
      }

      var binderClass = fnRet.haxeType.isVoid()
        ? (binderTypeParams.length > 0 ? 'LambdaBinderVoid' : 'LambdaBinderVoidVoid')
        : 'LambdaBinder';
      var binderTypeRef = new TypeRef(binderClass, binderTypeParams.map(function(tp) return tp.ueType));
      glueToUeExpr << binderTypeRef.getCppType();
      glueToUeExpr << '(%)';

      var haxeTypeRef = new TypeRef(
        (
          fnArgs.length > 0
            ? fnArgs.map(function(arg) return arg.haxeType.toString()).join('->')
            : 'Void'
        )
        + '->' + fnRet.haxeType.getClassPath()
      );

      var ret:TypeConvInfo = {
        ueType: binderTypeRef,
        haxeType: haxeTypeRef,
        haxeGlueType: voidStar,
        glueType: voidStar,

        glueCppIncludes: IncludeSet.fromUniqueArray(['<LambdaBinding.h>']),
        haxeToGlueExpr:'unreal.helpers.HaxeHelpers.dynamicToPointer( % )',
        glueToHaxeExpr:'unreal.helpers.HaxeHelpers.pointerToDynamic( % )',
        glueToUeExpr: glueToUeExpr.toString(),
        isBasic: false,
        isFunction: true,
        functionArgs: fnArgs,
        functionRet: fnRet,
        baseType: baseType,
      };
      return ret;
    }

    if (name == 'unreal.TSubclassOf') {
      var ofType = TypeConv.get(args[0], pos);
      var ueType = if (ofType.ueType.isPointer())
        ofType.ueType.params[0];
      else
        ofType.ueType;
      if (ofType.isInterface) {
        ueType = new TypeRef(ueType.pack, "U" + ueType.name.substr(1), ueType.params);
      }
      var ret = TypeConv.get( Context.follow(type), pos );
      ret.haxeType = new TypeRef(['unreal'], 'TSubclassOf', [ofType.haxeType]);
      ret.glueCppIncludes.add("UObject/ObjectBase.h");
      ret.args = [ofType];
      if (ofType.forwardDecls != null) {
        ret.forwardDecls = ret.forwardDecls.concat( ofType.forwardDecls );
      }
      ret.glueCppIncludes.append(ofType.glueCppIncludes);
      switch (ret.forwardDeclType) {
      case null | Never:
        // do nothing; we already are set to never
      case Templated(base):
        ret.forwardDeclType = Templated(base.concat(['UObject/ObjectBase.h']));
      case _:
        ret.forwardDeclType = Templated(IncludeSet.fromUniqueArray(['UObject/ObjectBase.h']));
      }

      ret.ueType = new TypeRef('TSubclassOf', [ueType]);
      ret.ueToGlueExpr = '( (UClass *) % )';
      ret.glueToUeExpr = '( (${ret.ueType.getCppType()}) ' + ret.glueToUeExpr + ' )';
      return ret;
    } else if (name == 'unreal.MethodPointer') {
      if (args.length != 2) {
        throw new Error('MethodPointer requires two type params: the class and the function signature', pos);
      }

      var cppMethodType = new HelperBuf();
      var className = switch (args[0]) {
        case TInst(cls, _):
          var cls = cls.get();
          cls.meta.has(':uname') ? MacroHelpers.extractStrings(cls.meta, ':uname')[0] : cls.name;
        default: throw new Error('MethodPointer expects first param to be a class', pos);
      };

      var retArgs = null;
      switch (args[1]) {
      case TFun(fnArgs, fnRet):
        var fnRet = get(fnRet, pos);
        var fnArgs = retArgs = fnArgs.map(function(arg) return get(arg.t, pos));
        cppMethodType << 'MemberFunctionTranslator<$className, ${fnRet.ueType.getCppType()}';
        if (fnArgs.length > 0) cppMethodType << ', ';
        cppMethodType.mapJoin(fnArgs, function(arg) return arg.ueType.getCppType().toString());
        cppMethodType << '>::Translator';
      default:
        throw new Error('MethodPointer expects second param to be a function type', pos);
      }

      var ret:TypeConvInfo = {
        ueType: voidStar,
        haxeType: new TypeRef(['cpp'],'Pointer', [new TypeRef([],'Dynamic')]),
        haxeGlueType: voidStar,
        haxeToGlueExpr: 'untyped (%).rawCast()',
        glueToUeExpr: '(($cppMethodType)%)()',
        glueCppIncludes: IncludeSet.fromUniqueArray(['<LambdaBinding.h>']),
        isBasic: false,
        isMethodPointer: true,
        baseType: baseType,
        args: retArgs,
      };
      return ret;
    }

    if (name == 'unreal.TWeakObjectPtr' || name == 'unreal.TAutoWeakObjectPtr') {
      var ofType = TypeConv.get(args[0], pos);
      var ueType = if (ofType.ueType.isPointer())
        ofType.ueType.params[0];
      else
        ofType.ueType;
      var ret = TypeConv.get( Context.follow(type), pos );
      ret.haxeType = new TypeRef(['unreal'], name.split('.')[1], [ofType.haxeType]);
      ret.glueCppIncludes.add("UObject/WeakObjectPtrTemplates.h");
      ret.forwardDecls = ret.forwardDecls.concat( ofType.forwardDecls );
      ret.glueCppIncludes.append( ofType.glueCppIncludes );
      ret.args = [ofType];
      switch (ret.forwardDeclType) {
      case null | Never:
        // do nothing; we already are set to never
      case Templated(base):
        ret.forwardDeclType = Templated(base.concat(['UObject/WeakObjectPtrTemplates.h']));
      case _:
        ret.forwardDeclType = Templated(IncludeSet.fromUniqueArray(['UObject/WeakObjectPtrTemplates.h']));
      }

      ret.ueType = new TypeRef(name.split('.')[1], [ueType]);
      ret.ueToGlueExpr = '( %.Get() )';
      ret.glueToUeExpr = '( (${ret.ueType.getCppType()}) ' + ret.glueToUeExpr + ' )';
      return ret;
    }

    var typeRef = baseType != null ? TypeRef.fromBaseType(baseType, pos) : TypeRef.parseClassName( name );
    var convArgs = null;
    if (args != null && args.length > 0) {
      convArgs = [ for (arg in args) TypeConv.get(arg, pos) ];
      typeRef = typeRef.withParams([ for (arg in convArgs) arg.haxeType ]);
      if (baseType != null && registerTParam) {
        var shouldAdd = true;
        for (arg in convArgs) {
          if (arg.hasTypeParams()) {
            shouldAdd = false;
            break;
          }
        }
        if (shouldAdd)
          Globals.cur.typeParamsToBuild = Globals.cur.typeParamsToBuild.add({ base:baseType, args:convArgs, pos:pos, feature: Globals.cur.currentFeature });
      }
    }
    // FIXME: check conversion and maybe add cast if needed
    var originalTypeRef = ctx.originalType == null ? typeRef : ctx.originalType;
    var refName = new TypeRef(typeRef.name);
    if (meta != null && meta.has(':uname')) refName = TypeRef.parseClassName(getMetaString(meta, ':uname'));
    if (typeRef.params.length > 0) {
      var isTypeName = ctx.meta != null && ctx.meta.has(':typeName');
      refName = refName.withParams( [ for (arg in convArgs) arg.isUObject == true && isTypeName ? arg.ueType.withoutPointer() : arg.ueType ] );
    }

    // Handle uenums declared in haxe
    if (ctx.isEnum && meta != null && (meta.has(':uenum') || (ctx.isAbstract && meta.has(':enum'))) && !meta.has(':uextern')) {
      if (ctx.isAbstract) {
        return {
          haxeType: originalTypeRef,
          ueType: refName,
          haxeGlueType: new TypeRef("Int"),
          glueType: new TypeRef("Int"),

          glueCppIncludes: IncludeSet.fromUniqueArray(getMetaArray(meta, ':glueCppIncludes')),
          glueHeaderIncludes: IncludeSet.fromUniqueArray(['<hxcpp.h>']),

          glueToUeExpr: '( (${refName.getCppType()}) % )',
          ueToGlueExpr : '( (int) % )',
          args: convArgs,
          isEnum: true,
          baseType: baseType,
        };
      } else {
        return {
          haxeType: originalTypeRef,
          ueType: refName,
          haxeGlueType: new TypeRef("Int"),
          glueType: new TypeRef("Int"),

          glueCppIncludes: IncludeSet.fromUniqueArray(['${refName.name}.h']),
          glueHeaderIncludes: IncludeSet.fromUniqueArray(['<hxcpp.h>']),

          haxeToGlueExpr: '{ var temp = %; if (temp == null) { throw "null $originalTypeRef passed to UE"; } Type.enumIndex(temp);}',
          glueToHaxeExpr: 'Type.createEnumIndex($originalTypeRef, %)',
          glueToUeExpr: '( (${refName.getCppType()}) % )',
          ueToGlueExpr : '( (int) % )',
          args: convArgs,
          isEnum: true,
          baseType: baseType,
        };
      }
    }

    if (meta != null && (meta.has(':uextern') || meta.has(':ustruct'))) {
      if (isUObject) {
        var ret:TypeConvInfo = {
          haxeType: originalTypeRef,
          ueType: new TypeRef(['cpp'], 'RawPointer', [refName]),
          haxeGlueType: voidStar,
          glueType: voidStar,

          isUObject: true,

          glueCppIncludes: IncludeSet.fromUniqueArray(getMetaArray(meta, ':glueCppIncludes')),

          haxeToGlueExpr: '@:privateAccess %.getWrapped().rawCast()',
          glueToHaxeExpr: typeRef.getClassPath() + '.wrap( cast (%) )',
          glueToUeExpr: '( (${refName.getCppType()} *) % )',
          ownershipModifier: modf,
          args: convArgs,

          forwardDeclType: ForwardDeclEnum.Always,
          forwardDecls: [refName.getForwardDecl()],
          baseType: baseType,
        };
        if (ctx.isInterface) {
          ret.haxeToGlueExpr = '@:privateAccess (cast % : unreal.UObject).getWrapped().rawCast()';
          ret.glueToHaxeExpr = 'cast(unreal.UObject.wrap( cast (%) ), ${originalTypeRef})';
          ret.ueToGlueExpr = 'Cast<UObject>( % )';
          ret.glueToUeExpr = 'Cast<${refName.getCppType()}>( (UObject *) % )';
          ret.glueCppIncludes.add('Templates/Casts.h');
          ret.isInterface = true;
        }

        if (modf == 'unreal.PRef') {
          ret.ueType = new TypeRef(['cpp'], 'Reference', [ret.ueType]);
          ret.haxeToGlueExpr = '@:privateAccess (cast % : unreal.UObject).getWrappedAddr().rawCast()';
          ret.glueToUeExpr = '(static_cast<${refName.getCppType()} *&> (*( (${refName.getCppType()} **) % )))';
        }
        return ret;
      } else if (ctx.isEnum) {
        var conv = new TypeRef(typeRef.pack, typeRef.name + '_EnumConv', typeRef.moduleName != null ? typeRef.moduleName : typeRef.name, typeRef.params);
        return {
          haxeType: originalTypeRef,
          ueType: refName,
          haxeGlueType: new TypeRef("Int"),
          glueType: new TypeRef("Int"),

          glueCppIncludes: IncludeSet.fromUniqueArray(getMetaArray(meta, ':glueCppIncludes')),
          haxeToGlueExpr: conv.getClassPath() + '.unwrap(%)',
          glueToHaxeExpr: conv.getClassPath() + '.wrap(%)',
          glueToUeExpr: '( (${refName.getCppType()}) % )',
          ueToGlueExpr: '( (int) (${refName.getCppType()}) % )',
          args: convArgs,
          isEnum: true,
          baseType: baseType,
        };
      } else {
        // non uobject
        var cppIncludes = IncludeSet.fromUniqueArray(getMetaArray(meta, ':glueCppIncludes'));
        var headerIncludes = IncludeSet.fromUniqueArray(['<unreal/helpers/UEPointer.h>']);
        if (cppIncludes.length == 0) {
          Context.warning('Unreal Glue Code: glueCppIncludes missing for $typeRef', pos);
        }
        var ueType = refName;
        var forwardDecls = [],
            declType = ForwardDeclEnum.Always;
        var addMyForward = true;
        if (convArgs != null) {
          var myIncludes = cppIncludes.copy();
          declType = ForwardDeclEnum.Templated(myIncludes);
          addMyForward = false;
          for (arg in convArgs) {
            cppIncludes.append(arg.glueCppIncludes);
            if (!arg.isTypeParam) {
              // TArray types can be forward declared, so add an exception here
              switch (arg.forwardDeclType) {
              case null | Never:
                declType = ForwardDeclEnum.Never;
              case Templated(incs):
                myIncludes.append(incs);
              case _:
                if (arg.forwardDecls == null) {
                  forwardDecls.push(arg.ueType.getForwardDecl());
                } else {
                  for (decl in arg.forwardDecls)
                    forwardDecls.push(decl);
                }
              }
            }
          }
        }

        // don't add forward declarations for non-UOBjects
        // TODO proper forward declaration for structs (vs. classes)
        switch (declType) {
          case Templated(_):
            // do nothing
          case _:
            declType = ForwardDeclEnum.Never;
        }

        if (addMyForward)
          forwardDecls.push(ueType.getForwardDecl());
        var ret:TypeConvInfo = {
          haxeType: originalTypeRef,
          ueType: new TypeRef(['cpp'], 'RawPointer', [ueType]),
          haxeGlueType: uePointer,
          glueType: uePointer,

          glueCppIncludes: cppIncludes.add('<OPointers.h>'),
          glueHeaderIncludes:IncludeSet.fromUniqueArray(['<unreal/helpers/UEPointer.h>']),

          haxeToGlueExpr: '@:privateAccess %.getWrapped().get_raw()',
          glueToHaxeExpr: typeRef.getClassPath() + '.wrap( cast (%), $$parent )',
          glueToUeExpr: '( (${ueType.getCppType()} *) (::unreal::helpers::UEPointer::getPointer(%)) )',
          ownershipModifier: modf,
          args: convArgs,

          forwardDeclType: declType,
          forwardDecls: forwardDecls,
          baseType: baseType,
        };
        if (originalTypeRef != typeRef)
          ret.glueToHaxeExpr = '( cast ' + ret.glueToHaxeExpr + ' : ${originalTypeRef} )';
        if (modf == null) {
          // By default, all non-UObject types are treated as PStruct
          ret.ownershipModifier = modf = 'unreal.PStruct';
        } else {
          ret.haxeType = TypeRef.parseClassName(modf, [originalTypeRef]);
        }

        switch (modf) {
          case 'unreal.PExternal':
            ret.ueToGlueExpr = 'PExternal<${ueType.getCppType()}>::wrap( % )';
          case 'unreal.PHaxeCreated':
            ret.ueToGlueExpr = 'PHaxeCreated<${ueType.getCppType()}>::wrap( % )';
            ret.glueToHaxeExpr = '@:privateAccess new unreal.PHaxeCreated(' + ret.glueToHaxeExpr + ')';
          case 'unreal.PStruct':
            ret.ueToGlueExpr = 'new PStruct<${ueType.getCppType()}>( % )';
            // ret.glueToHaxeExpr = '@:privateAccess new unreal.PStruct(' + ret.glueToHaxeExpr + ')';
            ret.glueToUeExpr = '(*(' + ret.glueToUeExpr + '))';
            ret.ueType = ret.ueType.params[0];
            if (ret.forwardDeclType == Always)
              ret.forwardDeclType = ForwardDeclEnum.AsFunction;
          case 'unreal.TSharedPtr':
            ret.ueType = new TypeRef('TSharedPtr',[ueType]);
            ret.ueToGlueExpr = 'PSharedPtr<${ueType.getCppType()}>::wrap( % )';
            ret.glueToUeExpr = '( (PSharedPtr<${ueType.getCppType()}> *) %->toSharedPtr() )->value';
            ret.glueToHaxeExpr = '( cast ' + ret.glueToHaxeExpr + ' : unreal.TSharedPtr<${typeRef}> )';
          case 'unreal.TThreadSafeSharedPtr':
            ret.ueType = new TypeRef('TSharedPtr',[ueType, new TypeRef(['ESPMode'], 'ThreadSafe')]);
            ret.ueToGlueExpr = 'PSharedPtr<${ueType.getCppType()}, ESPMode::ThreadSafe>::wrap( % )';
            ret.glueToUeExpr = '( (PSharedPtr<${ueType.getCppType()}, ESPMode::ThreadSafe> *) %->toSharedPtrTS() )->value';
            ret.glueToHaxeExpr = '( cast ' + ret.glueToHaxeExpr + ' : unreal.TThreadSafeSharedPtr<${typeRef}> )';
          case 'unreal.TSharedRef':
            ret.ueType = new TypeRef('TSharedRef',[ueType]);
            ret.ueToGlueExpr = 'new PSharedRef<${ueType.getCppType()}>( % )';
            ret.glueToUeExpr = '( (PSharedRef<${ueType.getCppType()}> *) %->toSharedRef() )->value';
            ret.glueToHaxeExpr = '( cast ' + ret.glueToHaxeExpr + ' : unreal.TSharedRef<${typeRef}> )';
          case 'unreal.TThreadSafeSharedRef':
            ret.ueType = new TypeRef('TSharedRef',[ueType, new TypeRef(['ESPMode'], 'ThreadSafe')]);
            ret.ueToGlueExpr = 'new PSharedRef<${ueType.getCppType()}, ESPMode::ThreadSafe>( % )';
            ret.glueToUeExpr = '( (PSharedRef<${ueType.getCppType()}, ESPMode::ThreadSafe> *) %->toSharedRefTS() )->value';
            ret.glueToHaxeExpr = '( cast ' + ret.glueToHaxeExpr + ' : unreal.TThreadSafeSharedRef<${typeRef}> )';
          case 'unreal.TWeakPtr':
            ret.ueType = new TypeRef('TWeakPtr',[ueType]);
            ret.ueToGlueExpr = 'PWeakPtr<${ueType.getCppType()}>::wrap( % )';
            ret.glueToUeExpr = '( (PWeakPtr<${ueType.getCppType()}> *) %->toWeakPtr() )->value';
            ret.glueToHaxeExpr = '( cast ' + ret.glueToHaxeExpr + ' : unreal.TWeakPtr<${typeRef}> )';
          case 'unreal.TThreadSafeWeakPtr':
            ret.ueType = new TypeRef('TWeakPtr',[ueType, new TypeRef(['ESPMode'], 'ThreadSafe')]);
            ret.ueToGlueExpr = 'PWeakPtr<${ueType.getCppType()}, ESPMode::ThreadSafe>::wrap( % )';
            ret.glueToUeExpr = '( (PWeakPtr<${ueType.getCppType()}, ESPMode::ThreadSafe> *) %->toWeakPtrTS() )->value';
            ret.glueToHaxeExpr = '( cast ' + ret.glueToHaxeExpr + ' : unreal.TThreadSafeWeakPtr<${typeRef}> )';
          case 'unreal.PRef':
            @:privateAccess ret.ueType.name = 'Reference';
            ret.ueToGlueExpr = 'new PExternal<${ueType.getCppType()}>( &(%) )';
            ret.glueToUeExpr = '*(' + ret.glueToUeExpr + ')';
          case _:
            throw 'assert: $modf';
        }

        if (typeRef.params.length > 0) {
          ret.glueCppIncludes.add('<' + typeRef.getGlueHelperType().getClassPath().replace('.','/') + '_UE.h>');
          var isTypeName = ctx.meta != null && ctx.meta.has(':typeName');
          ret.ueToGlueExpr = 'new ' + typeRef.getGlueHelperType().getCppClass() + '_UE_obj<' +
            [ for (param in args) {
              var conv = TypeConv.get(param, pos);
              if (isTypeName && conv.isUObject == true)
                conv.ueType.getCppClass();
              else
                conv.ueType.getCppType().toString();
            }].join(',') +
          '>(' + ret.ueToGlueExpr + ')';
        }
        return ret;
      }
    }

    // check if extends @:uextern
    var uextension = false;
    if (ctx.isUObject) {
      while (superClass != null) {
        var cur = superClass.t.get();
        if (cur.meta.has(':uextern')) {
          uextension = true;
          break;
        }
        superClass = cur.superClass;
      }
    }

    if (uextension) {
      var glueCppIncludes = IncludeSet.fromUniqueArray(getMetaArray(meta, ':glueCppIncludes'));
      glueCppIncludes.add('<unreal/helpers/HxcppRuntime.h>');
      #if !bake_externs
      var mod = getMetaArray(meta, ':utargetmodule');
      var module = mod == null ? null : mod[0];
      if (module == null) {
        module = Globals.cur.haxeTargetModule;
      }
      var dir = Globals.cur.haxeRuntimeDir;
      if (module != null)
        dir = dir + '/../$module';

      glueCppIncludes.add('$dir/Generated/Public/${refName.withoutPrefix().name}.h');
      #end
      var ret:TypeConvInfo = {
        haxeType: typeRef,
        ueType: new TypeRef(['cpp'], 'RawPointer', [refName]),
        haxeGlueType: voidStar,
        glueType: voidStar,

        isUObject: true,

        glueCppIncludes: glueCppIncludes.add('<unreal/helpers/UEPointer.h>'),

        haxeToGlueExpr: 'unreal.helpers.HaxeHelpers.dynamicToPointer(%)',
        glueToHaxeExpr: '( unreal.helpers.HaxeHelpers.pointerToDynamic(%) : ${typeRef.getClassPath()})',
        ueToGlueExpr: '::unreal::helpers::UEPointer::getGcRef(%)',
        glueToUeExpr: '((::${refName.getCppType()} *) ::unreal::helpers::HxcppRuntime::getWrapped( % ))',
        ownershipModifier: modf,

        forwardDeclType: ForwardDeclEnum.Always,
        forwardDecls: [refName.getForwardDecl()],
        baseType: baseType,
      };

      if (modf == 'unreal.PRef') {
        ret.ueType = new TypeRef(['cpp'], 'Reference', [ret.ueType]);
        ret.glueToUeExpr =
          '(static_cast<${refName.getCppType()} *&> (*( (${refName.getCppType()} **) ::unreal::helpers::HxcppRuntime::getWrappedRef( % ) )))';
      }

      return ret;
    }
    if (isBasic)
      return {
        ueType: typeRef,
        haxeType: typeRef,
        glueHeaderIncludes:IncludeSet.fromUniqueArray(['<hxcpp.h>']),
        isBasic: true,
        args: convArgs,
        baseType: baseType,
      };

    if (ctx.isTypeParam) {
      var haxeType = new TypeRef(typeRef.name),
          ueType = new TypeRef(['cpp'], 'RawPointer', [haxeType]);
      var isRef = false;
      if (modf != null) {
        // HACK: work around Haxe issue #4591. Change back to use modf itself when fixed
        switch(modf) {
        case 'unreal.PStruct':
          haxeType = new TypeRef(['ue4hx','internal'], 'PStructDef', [haxeType]);
          ueType = haxeType;
        case 'unreal.PHaxeCreated':
          haxeType = new TypeRef(['ue4hx','internal'], 'PHaxeCreatedDef', [haxeType]);
        case 'unreal.PExternal':
          haxeType = new TypeRef(['ue4hx','internal'], 'PExternalDef', [haxeType]);
        case 'unreal.PRef':
          // we'll use haxeToUePtr
          isRef = true;
          ueType = haxeType;
          haxeType = new TypeRef(['ue4hx','internal'], 'PRefDef', [haxeType]);
        case _:
          ueType = new TypeRef( modf.split('.').pop(), [haxeType] );
          haxeType = TypeRef.parseClassName( modf, [haxeType] );
        }
      } else {
        ueType = ueType.params[0];
      }
      var ret:TypeConvInfo = {
        ueType: ueType,
        haxeType: haxeType,
        glueType: voidStar,
        haxeGlueType: voidStar,

        glueCppIncludes: IncludeSet.fromUniqueArray(['<TypeParamGlue.h>']),

        ueToGlueExpr: 'TypeParamGlue<${ueType.getCppType()}>::ueToHaxe( % )',
        glueToUeExpr: 'TypeParamGlue<${ueType.getCppType()}>::haxeToUe( % )',
        haxeToGlueExpr: 'unreal.helpers.HaxeHelpers.dynamicToPointer( % )',
        glueToHaxeExpr: '(unreal.helpers.HaxeHelpers.pointerToDynamic( % ) : ${haxeType.toString()})',
        args: convArgs,
        isTypeParam: true,
        ownershipModifier: modf,
        baseType: baseType,
      };
      if (isRef) {
        ret.ueToGlueExpr = 'TypeParamGluePtr<${ueType.getCppType()}>::ueToHaxeRef( % )';
        ret.glueToUeExpr = 'TypeParamGluePtr<${ueType.getCppType()}>::haxeToUePtr( % )';
      }
      return ret;
    }
    throw new Error('Unreal Glue: Type $name is not supported', pos);
  }

  static function getMetaArray(meta:MetaAccess, name:String):Null<Array<String>>
  {
    if (meta == null) return null;
    var extracted = meta.extract(name);
    if (extracted == null || extracted.length == 0)
      return null;
    var ret = [];
    for (entry in extracted) {
      if (entry.params != null) {
        for (param in entry.params) {
          switch(param.expr)
          {
          case EConst(CString(s) | CIdent(s)):
            ret.push(s);
          case _:
            throw new Error('Unreal Glue: Unexpected non-string expression at meta $name', param.pos);
          }
        }
      }
    }

    return ret;
  }

  static function getMetaString(meta:MetaAccess, name:String):Null<String>
  {
    if (meta == null) return null;
    var extracted = meta.extract(name);
    if (extracted == null || extracted.length == 0 || extracted[0].params == null)
      return null;
    switch(extracted[0].params[0].expr) {
    case EConst(CString(s) | CIdent(s)):
      return s;
    case _:
      throw new Error('Unreal Glue: Unexpected non-string expression at meta $name', extracted[0].params[0].pos);
    }
  }

  static var voidStar(default,null) = new TypeRef(['cpp'],'RawPointer', [new TypeRef(['cpp'],'Void')]);
  static var uePointer(default,null) = new TypeRef(['cpp'],'RawPointer', [new TypeRef(['unreal','helpers'],'UEPointer')]);

  static var basicTypes:Map<String, TypeConvInfo> = {
    var basicConvert = [
      "cpp.Float32" => "float",
      "cpp.Float64" => "double",
      "Float" => "double",
      "cpp.Int16" => "int16",
      "cpp.Int32" => "int32",
      "Int" => "int32",
      "cpp.Int8" => "int8",
      "cpp.UInt16" => "uint16",
      "cpp.UInt8" => "uint8"
    ];

    var infos:Array<TypeConvInfo> = [
      {
        ueType: new TypeRef('bool'),
        haxeType: new TypeRef('Bool'),
        isBasic: true,
      },
      {
        ueType: new TypeRef('void'),
        haxeType: new TypeRef('Void'),
        isBasic: true,
      },
      {
        ueType: new TypeRef('uint32'),
        haxeType: new TypeRef(['unreal'],'FakeUInt32'),
        haxeGlueType: new TypeRef(['cpp'],'Int32'),
        glueType: new TypeRef(['cpp'], 'Int32'),

        haxeToGlueExpr: 'cast (%)',
        glueToHaxeExpr: 'cast (%)',
        isBasic: true,
      },
      {
        ueType: new TypeRef('uint64'),
        haxeType: new TypeRef(['unreal'],'FakeUInt64'),
        haxeGlueType: new TypeRef(['ue4hx','internal'], 'Int64Glue'),
        glueType: new TypeRef(['cpp'], 'Int64'),

        haxeToGlueExpr: 'cast (%)',
        glueToHaxeExpr: 'cast (%)',
        isBasic: true,
      },
      {
        ueType: new TypeRef('int64'),
        haxeType: new TypeRef(['unreal'],'Int64'),
        haxeGlueType: new TypeRef(['ue4hx','internal'], 'Int64Glue'),
        glueType: new TypeRef(['cpp'], 'Int64'),

        haxeToGlueExpr: 'cast (%)',
        glueToHaxeExpr: 'cast (%)',
        isBasic: true,
      },
      {
        ueType: new TypeRef('void'),
        haxeType: new TypeRef('Void'),
        isBasic: true,
      },
      {
        ueType: voidStar,
        haxeType: voidStar,
        isBasic: true,
      },
      // TCharStar
      {
        haxeType: new TypeRef(['unreal'],'TCharStar'),
        ueType: new TypeRef(['cpp'], 'RawPointer', [new TypeRef('TCHAR')]),
        haxeGlueType: voidStar,
        glueType: voidStar,

        glueCppIncludes:IncludeSet.fromUniqueArray(['Engine.h', '<unreal/helpers/HxcppRuntime.h>']),
        glueHeaderIncludes:IncludeSet.fromUniqueArray(['<hxcpp.h>']),

        ueToGlueExpr:'::unreal::helpers::HxcppRuntime::constCharToString(TCHAR_TO_UTF8( % ))',
        glueToUeExpr:'UTF8_TO_TCHAR(::unreal::helpers::HxcppRuntime::stringToConstChar(%))',
        haxeToGlueExpr:'unreal.helpers.HaxeHelpers.dynamicToPointer( % )',
        glueToHaxeExpr:'(unreal.helpers.HaxeHelpers.pointerToDynamic( % ) : String)',
        isBasic: false,
      },
    ];
    infos = infos.concat([ for (key in basicConvert.keys()) {
      ueType: TypeRef.parseClassName(basicConvert[key]),
      glueType: TypeRef.parseClassName(key),
      haxeType: TypeRef.parseClassName(key),
      glueHeaderIncludes:IncludeSet.fromUniqueArray(['<hxcpp.h>']),
      isBasic: true
    }]);
    var ret = new Map();
    for (info in infos)
    {
      ret[info.haxeType.getClassPath()] = info;
    }
    ret;
  };
}

typedef TypeConvInfo = {
  /**
    Represents the Haxe-side type
   **/
  public var haxeType:TypeRef;
  /**
    Represents the UE-side type (e.g. `FString` on case of FString)
   **/
  public var ueType:TypeRef;

  /**
    Represents the type in the glue helper as seen by Haxe. Again in the `FString` example,
    its `haxeGlueType` will be `cpp.ConstCharStar`.

    If null, this will be the same as `haxeType`
   **/
  @:optional public var haxeGlueType:Null<TypeRef>;
  /**
    Represents the actual glue type. Normally, it will be the same as the ueType;
    However, in some special cases, it will be different.
    One classic case where it is different is `FString`: While `ueType` is the
    actual `FString` type, its `glueType` will be `const char *`

    If null, this will be the same as `ueType`
   **/
  @:optional public var glueType:Null<TypeRef>;
  // @:optional public var glueHelperType:TypeRef;

  /**
    Represents the public includes that can be included in the glue header
    These can only be includes that are safe to be included in both UE4 and hxcpp sides
   **/
  @:optional public var glueHeaderIncludes:Null<IncludeSet>;
  /**
    Represents the private includes to the glue cpp files. These can be UE4 includes,
    since the CPP file is only compiled by the UE4 side
   **/
  @:optional public var glueCppIncludes:Null<IncludeSet>;

  /**
    Gets the wrapping expression from UE type to the glue Type
    e.g. on `FString` this would be what transforms `FString` into `const char *`
   **/
  @:optional public var ueToGlueExpr:Null<String>;
  /**
    Gets the wrapping expression from hxcpp `glueType` to UE4.
    e.g. on `FString` this would be `FString( UTF8_TO_TCHAR(%) )`
   **/
  @:optional public var glueToUeExpr:Null<String>;
  /**
    Gets the wrapping expression from Haxe type to the glue type
   **/
  @:optional public var haxeToGlueExpr:Null<String>;
  /**
    Gets the wrapping expression from the Glue type to the Haxe type
   **/
  @:optional public var glueToHaxeExpr:Null<String>;

  /**
    Tells whether the type refers to a UObject type
   **/
  @:optional public var isUObject:Bool;

  /**
    Tells whether the type is a basic type
   **/
  @:optional public var isBasic:Bool;
  @:optional public var isEnum:Bool;

  @:optional public var ownershipModifier:String;

  @:optional public var args:Array<TypeConv>;
  @:optional public var params:Array<String>;

  @:optional public var isTypeParam:Bool;
  @:optional public var isFunction:Bool;
  @:optional public var isMethodPointer:Bool;
  @:optional public var isInterface:Bool;
  @:optional public var functionArgs:Array<TypeConvInfo>;
  @:optional public var functionRet:TypeConvInfo;

  // forward declaration
  @:optional public var forwardDeclType:ForwardDecl;
  @:optional public var forwardDecls:Array<String>;

  @:optional public var baseType:BaseType;
}

typedef TypeConvCtx = {
  name:String,
  args:Array<Type>,
  meta:MetaAccess,

  ?isInterface:Bool,
  ?superClass:Null<{ t : Ref<ClassType>, params : Array<Type> }>,
  ?baseType:Null<BaseType>,
  ?isBasic:Bool,
  ?isUObject:Bool,
  ?isEnum:Bool,
  ?isFunction:Bool,
  ?isAbstract:Bool,

  ?originalType:TypeRef,
  ?isTypeParam:Bool,
}

enum ForwardDeclEnum {
  Never;
  AsFunction;
  Templated(mainIncludes:IncludeSet);
  Always;
}

@:forward
abstract ForwardDecl(ForwardDeclEnum) from ForwardDeclEnum to ForwardDeclEnum {
  @:extern inline public function isNever() {
    return this == null || this == Never;
  }
}
