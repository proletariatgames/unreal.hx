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
// @:forward abstract TypeConv(TypeConvInfo) from TypeConvInfo to TypeConvInfo
// {
//   public var haxeGlueType(get,never):TypeRef;
//   public var glueType(get,never):TypeRef;
//
//   inline function new(obj)
//     this = obj;
//
//   inline function underlying()
//     return this;
//
//   public function hasTypeParams():Bool {
//     return this.isTypeParam || (this.args != null && this.args.exists(function(v) return v.hasTypeParams()));
//   }
//
//   public function haxeToGlue(expr:String, ctx:Map<String,String>)
//   {
//     if (this.haxeToGlueExpr == null)
//       return expr;
//     return expand(this.haxeToGlueExpr, expr, ctx);
//   }
//
//   public function glueToHaxe(expr:String, ctx:Map<String,String>)
//   {
//     if (this.glueToHaxeExpr == null)
//       return expr;
//     return expand(this.glueToHaxeExpr, expr, ctx);
//   }
//
//   public function glueToUe(expr:String, ctx:Map<String,String>) {
//     if (this.glueToUeExpr == null)
//       return expr;
//     return expand(this.glueToUeExpr, expr, ctx);
//   }
//
//   public function ueToGlue(expr:String, ctx:Map<String,String>) {
//     if (this.ueToGlueExpr == null)
//       return expr;
//     return expand(this.ueToGlueExpr, expr, ctx);
//   }
//
//   public function getAllCppIncludes(map:IncludeSet) {
//     map.append( this.glueCppIncludes );
//     if (this.args != null) {
//       for (arg in this.args) {
//         arg.getAllCppIncludes(map);
//       }
//     }
//   }
//
//   public function getAllHeaderIncludes(map:IncludeSet) {
//     map.append( this.glueHeaderIncludes );
//     if (this.args != null) {
//       for (arg in this.args) {
//         arg.getAllHeaderIncludes(map);
//       }
//     }
//   }
//
//   static function expand(expr:String, ethis:String, ctx:Map<String,String>) {
//     var buf = new StringBuf();
//     var i = -1, len = expr.length;
//     while(++i < len) {
//       switch(expr.fastCodeAt(i)) {
//       case '%'.code:
//         buf.add(ethis);
//       case '$'.code:
//         var next = expr.fastCodeAt(i+1);
//         if (next == '$'.code) {
//           i++;
//           buf.addChar('$'.code);
//         } else {
//           var start = i;
//           while (++i < len) {
//             var chr = expr.fastCodeAt(i);
//             if (!((chr >= 'a'.code && chr <= 'z'.code) || (chr >= 'A'.code && chr <= 'Z'.code)))
//               break;
//           }
//           var data = ctx == null ? null : ctx[expr.substring(start + 1,i)];
//           buf.add(data);
//         }
//       case chr:
//         buf.addChar(chr);
//       }
//     }
//     return buf.toString();
//   }
//
//   private static function typeIsUObject(t:Type) {
//     var uobject = Globals.cur.uobject;
//     if (uobject == null) {
//       Globals.cur.uobject = uobject = Context.getType('unreal.UObject');
//     }
//     return Context.unify(t, uobject);
//   }
//
//   private function get_haxeGlueType():TypeRef {
//     return this.haxeGlueType != null ? this.haxeGlueType : this.haxeType;
//   }
//
//   private function get_glueType():TypeRef {
//     return this.glueType != null ? this.glueType : this.ueType;
//   }
//
//   private static function getTypeCtx(type:Type, pos:Position):TypeConvCtx {
//     // we'll loop until we find a type we're interested in
//     // when found, we'll get its name, type parameters and
//     // if it's a class, its meta too
//     var originalType = null;
//     while(true) {
//       switch(type) {
//       case TInst(iref,tl):
//         var it = iref.get();
//         var name = iref.toString();
//         var native = getMetaString(it.meta, ':native');
//         if (native != null)
//           name = native;
//         return {
//           name: name,
//           args: tl,
//           meta: it.meta,
//
//           isInterface: it.isInterface,
//           superClass: it.superClass,
//           baseType: it,
//           isUObject: TypeConv.typeIsUObject(type) || (it.isInterface && it.meta.has(':uextern')),
//           originalType: originalType,
//           isTypeParam: it.kind.match(KTypeParameter(_)),
//         };
//
//       case TEnum(eref,tl):
//         var e = eref.get();
//         return {
//           name: eref.toString(),
//           args: tl,
//           meta: e.meta,
//           isEnum: true,
//
//           baseType: e,
//           originalType: originalType
//         }
//
//       case TAbstract(aref,tl):
//         var at = aref.get();
//         if (at.meta.has(':coreType') || at.meta.has(':unrealType'))
//         {
//           return {
//             name: aref.toString(),
//             args: tl,
//             meta: at.meta,
//             isEnum: at.meta.has(':enum'),
//             isAbstract: true,
//
//             baseType: at,
//             isBasic: true,
//             originalType: originalType
//           }
//         }
//         if (originalType == null)
//           originalType = TypeRef.fromType(type, pos);
//         // follow it
// #if (haxe_ver >= 3.3)
//         // this is more robust than the 3.2 version, since it will also correctly
//         // follow @:multiType abstracts
//         type = type.followWithAbstracts(true);
// #else
//         type = at.type.applyTypeParameters(at.params, tl);
// #end
//
//       case TType(tref,tl):
//         var t = tref.get();
//         if (t.meta.has(':unrealType'))
//         {
//           return {
//             name: tref.toString(),
//             args: tl,
//             meta: t.meta,
//
//             isBasic: true,
//             originalType: originalType
//           }
//         }
//         type = type.follow(true);
//       case TMono(mono):
//         type = mono.get();
//         if (type == null) {
//           throw 'assert';
//           throw new Error('Unreal Glue: Type cannot be Unknown', pos);
//         }
//       case TLazy(f):
//         type = f();
//       case TFun(_):
//         return {
//           name: "function",
//           args: [],
//           meta: null,
//           isFunction: true,
//           isBasic : false,
//           originalType : originalType
//         };
//       case _:
//         throw new Error('Unreal Glue: Invalid type $type', pos);
//       }
//     }
//     throw 'assert';
//   }
//
//   private static function isPOwnership(ctx:TypeConvCtx) {
//     if (!ctx.isBasic)
//       return false;
//     switch (ctx.name) {
//     case 'unreal.PHaxeCreated' | 'unreal.PPtr' | 'unreal.PStruct' |
//          'unreal.TSharedPtr' | 'unreal.TThreadSafeSharedPtr' |
//          'unreal.TSharedRef' | 'unreal.TThreadSafeSharedRef' |
//          'unreal.TWeakPtr' | 'unreal.TThreadSafeWeakPtr' |
//          'unreal.PRef':
//       return true;
//     case 'ue4hx.internal.PHaxeCreatedDef' | 'ue4hx.internal.PPtrDef' | 'ue4hx.internal.PStructDef' |
//          'ue4hx.internal.PRefDef':
//       ctx.name = 'unreal.' + ctx.name.split('.').pop().substr(0,-3);
//       return true;
//     case _:
//       return false;
//     }
//   }
//
//   public static function getScriptableUObject():TypeConv {
//     return scriptableUObject;
//   }
//
//   public static function get(type:Type, pos:Position, ?ownershipOverride:String = null, registerTParam=true):TypeConv {
//     var ctx = getTypeCtx(type, pos);
//     if (ctx.name == 'unreal.Const') {
//       var ret = Reflect.copy(_get(ctx.args[0], pos, ownershipOverride, registerTParam));
//       if (ret.ueToGlueExpr != null) {
//         ret.ueToGlueExpr = ret.ueToGlueExpr.replace("%", "const_cast<" + ret.ueType.getCppType() + ">( % )");
//       } else {
//         ret.ueToGlueExpr = "const_cast<" + ret.ueType.getCppType() + ">( % )";
//       }
//       ret.ueType = ret.ueType.withConst(true);
//       return ret;
//     } else {
//       return _get(type, pos, ownershipOverride, registerTParam);
//     }
//   }
//
//   private static function _get(type:Type, pos:Position, ?ownershipOverride:String = null, registerTParam=true):TypeConvInfo
//   {
//
//     var ctx = getTypeCtx(type, pos);
//     var ownershipModifier = null;
//     if (isPOwnership(ctx)) {
//       // TODO: cleanup so it plays nicely when more modifiers are added (e.g. Const, etc)
//       ownershipModifier = ctx;
//       ctx = getTypeCtx(ctx.args[0], pos);
//       var has = isPOwnership(ctx);
//       while(isPOwnership(ctx))
//         ctx = getTypeCtx(ctx.args[0], pos);
//       // if (isPOwnership(ctx))
//       //   throw new Error('Unreal Glue: You cannot use two pointer modifiers in the same type (${ownershipModifier.name}<${ctx.name}<>>)', pos);
//     }
//
//     var name = ctx.name,
//         args = ctx.args,
//         meta = ctx.meta,
//         superClass = ctx.superClass;
//     var baseType = ctx.baseType;
//     var isBasic = ctx.isBasic,
//         isUObject = ctx.isUObject;
//     var modf = ownershipOverride;
//     if (modf == null) {
//       if (ownershipModifier != null) {
//         modf = ownershipModifier.name;
//       }
//     }
//
//     // this helper function will handle `modf` (`ownershipModifier`)
//     // on types that don't have a special way to handle it
//     // FIXME: implement this to get basic types working
//     // inline function wrapOwnership(info:TypeConvInfo):TypeConvInfo {
//     //   if (modf != null) {
//     //     switch (modf) {
//     //     // TODO: (we need temp vars to make this work :(
//     //     // case 'unreal.PPtr' | 'unreal.PHaxeCreated':
//     //     //   info.ueType = new TypeRef(['cpp'], 'RawPointer', [info.ueType]);
//     //     //   if (info.ueToGlueExpr != null)
//     //     //     info.ueToGlueExpr = '&(' + info.ueToGlueExpr + ')';
//     //     //   if (info.glueToUeExpr != null
//     //     case 'unreal.PRef':
//     //       // if (info.ueType.name == 'RawPointer') {
//     //         // info.ueType = new TypeRef(['cpp'], 'Reference', info.ueType.params);
//     //       // } else {
//     //         info.ueType = new TypeRef(['cpp'], 'Reference', [info.ueType]);
//     //       // }
//     //     case _:
//     //     }
//     //   }
//     //   return info;
//     // }
//     // if we have it defined as a basic (special) type, use it
//     var basic = basicTypes[name];
//     if (basic != null) return basic;
//
//     //
//     // Handle lambdas
//     //
//
//     if (ctx.isFunction) {
//       var fnArgs = null, fnRet = null;
//       switch (type) {
//       case TFun(args, ret):
//         fnArgs = args.map(function(a) return get(a.t, pos));
//         fnRet = get(ret, pos);
//
//         if (!fnRet.haxeType.isVoid() && fnRet.isBasic == true && fnRet.ownershipModifier == 'unreal.PRef' || fnRet.ownershipModifier == 'unreal.PRefDef') {
//           throw new Error('Unreal Glue: Function lambda types that return a reference to a basic type are not supported', pos);
//         }
//
//         #if !bake_externs
//           // We need to ensure that all types have TypeParamGlue built in order for LambdaBinder to work
//           for (i in 0...fnArgs.length) {
//             if (!fnArgs[i].hasTypeParams()) {
//               TypeParamBuild.ensureTypeConvBuilt(args[i].t, fnArgs[i], pos, Globals.cur.currentFeature);
//             }
//           }
//           if (!fnRet.haxeType.isVoid()) {
//             if (!fnRet.hasTypeParams()) {
//               TypeParamBuild.ensureTypeConvBuilt(ret, fnRet, pos, Globals.cur.currentFeature);
//             }
//           }
//         #end
//       default:
//         throw 'assert';
//       }
//       var glueToUeExpr = new HelperBuf();
//       var binderTypeParams = fnArgs.copy();
//       if (!fnRet.haxeType.isVoid()) {
//         binderTypeParams.unshift(fnRet);
//       }
//
//       var binderClass = fnRet.haxeType.isVoid()
//         ? (binderTypeParams.length > 0 ? 'LambdaBinderVoid' : 'LambdaBinderVoidVoid')
//         : 'LambdaBinder';
//       var binderTypeRef = new TypeRef(binderClass, binderTypeParams.map(function(tp) return tp.ueType));
//       glueToUeExpr << binderTypeRef.getCppType();
//       glueToUeExpr << '(%)';
//
//       var haxeTypeRef = new TypeRef(
//         (
//           fnArgs.length > 0
//             ? fnArgs.map(function(arg) return arg.haxeType.toString()).join('->')
//             : 'Void'
//         )
//         + '->' + fnRet.haxeType.getClassPath()
//       );
//
//       var ret:TypeConvInfo = {
//         ueType: binderTypeRef,
//         haxeType: haxeTypeRef,
//         haxeGlueType: voidStar,
//         glueType: voidStar,
//
//         glueCppIncludes: IncludeSet.fromUniqueArray(['<LambdaBinding.h>']),
//         haxeToGlueExpr:'unreal.helpers.HaxeHelpers.dynamicToPointer( % )',
//         glueToHaxeExpr:'unreal.helpers.HaxeHelpers.pointerToDynamic( % )',
//         glueToUeExpr: glueToUeExpr.toString(),
//         isBasic: false,
//         isFunction: true,
//         functionArgs: fnArgs,
//         functionRet: fnRet,
//         baseType: baseType,
//       };
//       return ret;
//     }
//
//     if (name == 'unreal.TSubclassOf') {
//       var ofType = TypeConv.get(args[0], pos);
//       var ueType = if (ofType.ueType.isPointer())
//         ofType.ueType.params[0];
//       else
//         ofType.ueType;
//       if (ofType.isInterface) {
//         ueType = new TypeRef(ueType.pack, "U" + ueType.name.substr(1), ueType.params);
//       }
//       var ret = TypeConv.get( Context.follow(type), pos );
//       ret.haxeType = new TypeRef(['unreal'], 'TSubclassOf', [ofType.haxeType]);
//       ret.glueCppIncludes.add("UObject/ObjectBase.h");
//       ret.args = [ofType];
//       if (ofType.forwardDecls != null) {
//         ret.forwardDecls = ret.forwardDecls.concat( ofType.forwardDecls );
//       }
//       ret.glueCppIncludes.append(ofType.glueCppIncludes);
//       switch (ret.forwardDeclType) {
//       case null | Never:
//         // do nothing; we already are set to never
//       case Templated(base):
//         ret.forwardDeclType = Templated(base.concat(['UObject/ObjectBase.h']));
//       case _:
//         ret.forwardDeclType = Templated(IncludeSet.fromUniqueArray(['UObject/ObjectBase.h']));
//       }
//
//       ret.ueType = new TypeRef('TSubclassOf', [ueType]);
//       ret.ueToGlueExpr = '( (UClass *) % )';
//       ret.glueToUeExpr = '( (${ret.ueType.getCppType()}) ' + ret.glueToUeExpr + ' )';
//       return ret;
//     } else if (name == 'unreal.MethodPointer') {
//       if (args.length != 2) {
//         throw new Error('MethodPointer requires two type params: the class and the function signature', pos);
//       }
//
//       var cppMethodType = new HelperBuf();
//       var className = switch (args[0]) {
//         case TInst(cls, _):
//           var cls = cls.get();
//           cls.meta.has(':uname') ? MacroHelpers.extractStrings(cls.meta, ':uname')[0] : cls.name;
//         default: throw new Error('MethodPointer expects first param to be a class', pos);
//       };
//
//       var retArgs = null;
//       switch (args[1]) {
//       case TFun(fnArgs, fnRet):
//         var fnRet = get(fnRet, pos);
//         var fnArgs = retArgs = fnArgs.map(function(arg) return get(arg.t, pos));
//         cppMethodType << 'MemberFunctionTranslator<$className, ${fnRet.ueType.getCppType()}';
//         if (fnArgs.length > 0) cppMethodType << ', ';
//         cppMethodType.mapJoin(fnArgs, function(arg) return arg.ueType.getCppType().toString());
//         cppMethodType << '>::Translator';
//       default:
//         throw new Error('MethodPointer expects second param to be a function type', pos);
//       }
//
//       var ret:TypeConvInfo = {
//         ueType: voidStar,
//         haxeType: new TypeRef(['cpp'],'Pointer', [new TypeRef([],'Dynamic')]),
//         haxeGlueType: voidStar,
//         haxeToGlueExpr: 'untyped (%).rawCast()',
//         glueToUeExpr: '(($cppMethodType)%)()',
//         glueCppIncludes: IncludeSet.fromUniqueArray(['<LambdaBinding.h>']),
//         isBasic: false,
//         isMethodPointer: true,
//         baseType: baseType,
//         args: retArgs,
//       };
//       return ret;
//     }
//
//     if (name == 'unreal.TWeakObjectPtr' || name == 'unreal.TAutoWeakObjectPtr') {
//       var ofType = TypeConv.get(args[0], pos);
//       var ueType = if (ofType.ueType.isPointer())
//         ofType.ueType.params[0];
//       else
//         ofType.ueType;
//       var ret = TypeConv.get( Context.follow(type), pos );
//       ret.haxeType = new TypeRef(['unreal'], name.split('.')[1], [ofType.haxeType]);
//       ret.glueCppIncludes.add("UObject/WeakObjectPtrTemplates.h");
//       ret.forwardDecls = ret.forwardDecls.concat( ofType.forwardDecls );
//       ret.glueCppIncludes.append( ofType.glueCppIncludes );
//       ret.args = [ofType];
//       switch (ret.forwardDeclType) {
//       case null | Never:
//         // do nothing; we already are set to never
//       case Templated(base):
//         ret.forwardDeclType = Templated(base.concat(['UObject/WeakObjectPtrTemplates.h']));
//       case _:
//         ret.forwardDeclType = Templated(IncludeSet.fromUniqueArray(['UObject/WeakObjectPtrTemplates.h']));
//       }
//
//       ret.ueType = new TypeRef(name.split('.')[1], [ueType]);
//       if (ret.ueToGlueExpr == null) {
//         ret.ueToGlueExpr = '%';
//       }
//       ret.ueToGlueExpr = ret.ueToGlueExpr.replace('%', '( %.Get() )');
//       ret.glueToUeExpr = '( (${ret.ueType.getCppType()}) ' + ret.glueToUeExpr + ' )';
//       return ret;
//     }
//
//     var typeRef = baseType != null ? TypeRef.fromBaseType(baseType, pos) : TypeRef.parseClassName( name );
//     var convArgs = null;
//     if (args != null && args.length > 0) {
//       convArgs = [ for (arg in args) TypeConv.get(arg, pos) ];
//       typeRef = typeRef.withParams([ for (arg in convArgs) arg.haxeType ]);
//       if (baseType != null && registerTParam) {
//         var shouldAdd = true;
//         for (arg in convArgs) {
//           if (arg.hasTypeParams()) {
//             shouldAdd = false;
//             break;
//           }
//         }
//         if (shouldAdd)
//           Globals.cur.typeParamsToBuild = Globals.cur.typeParamsToBuild.add({ base:baseType, args:convArgs, pos:pos, feature: Globals.cur.currentFeature });
//       }
//     }
//     // FIXME: check conversion and maybe add cast if needed
//     var originalTypeRef = ctx.originalType == null ? typeRef : ctx.originalType;
//     var refName = new TypeRef(typeRef.name);
//     if (meta != null && meta.has(':uname')) refName = TypeRef.parseClassName(getMetaString(meta, ':uname'));
//     if (typeRef.params.length > 0) {
//       var isTypeName = ctx.meta != null && ctx.meta.has(':typeName');
//       refName = refName.withParams( [ for (arg in convArgs) arg.isUObject == true && isTypeName ? arg.ueType.withoutPointer() : arg.ueType ] );
//     }
//
//     // Handle uenums declared in haxe
//     if (ctx.isEnum && meta != null && (meta.has(':uenum') || (ctx.isAbstract && meta.has(':enum'))) && !meta.has(':uextern')) {
//       if (ctx.isAbstract) {
//         return {
//           haxeType: originalTypeRef,
//           ueType: refName,
//           haxeGlueType: new TypeRef("Int"),
//           glueType: new TypeRef("Int"),
//
//           glueCppIncludes: IncludeSet.fromUniqueArray(getMetaArray(meta, ':glueCppIncludes')),
//           glueHeaderIncludes: IncludeSet.fromUniqueArray(['<hxcpp.h>']),
//
//           glueToUeExpr: '( (${refName.getCppType()}) % )',
//           ueToGlueExpr : '( (int) (${refName.getCppType()}) % )',
//           args: convArgs,
//           isEnum: true,
//           baseType: baseType,
//         };
//       } else {
//         var isScript = meta.has(':uscript') || Globals.cur.scriptModules.exists(baseType.module);
//         var setType = isScript ? ' : Dynamic' : '';
//         return {
//           haxeType: originalTypeRef,
//           ueType: refName,
//           haxeGlueType: new TypeRef("Int"),
//           glueType: new TypeRef("Int"),
//
//           glueCppIncludes: IncludeSet.fromUniqueArray(['${refName.name}.h']),
//           glueHeaderIncludes: IncludeSet.fromUniqueArray(['<hxcpp.h>']),
//
//           haxeToGlueExpr: '{ var temp $setType = %; if (temp == null) { throw "null $originalTypeRef passed to UE"; } Type.enumIndex(temp);}',
//           glueToHaxeExpr: isScript ? 'Type.createEnumIndex(Type.resolveEnum("${originalTypeRef.getClassPath(true)}"), %)' : 'ue4hx.internal.UEnumHelper.createEnumIndex($originalTypeRef, %)',
//           glueToUeExpr: '( (${refName.getCppType()}) % )',
//           ueToGlueExpr : '( (int) (${refName.getCppType()}) % )',
//           args: convArgs,
//           isEnum: true,
//           baseType: baseType,
//         };
//       }
//     }
//
//     if (meta != null && (meta.has(':uextern') || meta.has(':ustruct'))) {
//       if (isUObject) {
//         var ret:TypeConvInfo = {
//           haxeType: originalTypeRef,
//           ueType: new TypeRef(['cpp'], 'RawPointer', [refName]),
//           haxeGlueType: voidStar,
//           glueType: voidStar,
//
//           isUObject: true,
//
//           glueCppIncludes: IncludeSet.fromUniqueArray(getMetaArray(meta, ':glueCppIncludes')),
//
//           haxeToGlueExpr: '@:privateAccess %.getWrapped().rawCast()',
//           glueToHaxeExpr: typeRef.getClassPath() + '.wrap( cpp.Pointer.fromRaw(cast (%)) )',
//           glueToUeExpr: '( (${refName.getCppType()} *) % )',
//           ownershipModifier: modf,
//           args: convArgs,
//
//           forwardDeclType: ForwardDeclEnum.Always,
//           forwardDecls: [refName.getForwardDecl()],
//           baseType: baseType,
//         };
//         if (ctx.isInterface) {
//           ret.haxeToGlueExpr = '@:privateAccess (cast % : unreal.UObject).getWrapped().rawCast()';
//           ret.glueToHaxeExpr = 'cast(unreal.UObject.wrap( cpp.Pointer.fromRaw(cast (%)) ), ${originalTypeRef})';
//           ret.ueToGlueExpr = 'Cast<UObject>( % )';
//           ret.glueToUeExpr = 'Cast<${refName.getCppType()}>( (UObject *) % )';
//           ret.glueCppIncludes.add('Templates/Casts.h');
//           ret.isInterface = true;
//         }
//
//         if (modf == 'unreal.PRef') {
//           ret.ueType = new TypeRef(['cpp'], 'Reference', [ret.ueType]);
//           ret.haxeToGlueExpr = '@:privateAccess (cast % : unreal.UObject).getWrappedAddr().rawCast()';
//           ret.glueToUeExpr = '(static_cast<${refName.getCppType()} *&> (*( (${refName.getCppType()} **) % )))';
//         }
//         return ret;
//       } else if (ctx.isEnum) {
//         var conv = new TypeRef(typeRef.pack, typeRef.name + '_EnumConv', typeRef.moduleName != null ? typeRef.moduleName : typeRef.name, typeRef.params);
//         return {
//           haxeType: originalTypeRef,
//           ueType: refName,
//           haxeGlueType: new TypeRef("Int"),
//           glueType: new TypeRef("Int"),
//
//           glueCppIncludes: IncludeSet.fromUniqueArray(getMetaArray(meta, ':glueCppIncludes')),
//           haxeToGlueExpr: conv.getClassPath() + '.unwrap(%)',
//           glueToHaxeExpr: conv.getClassPath() + '.wrap(%)',
//           glueToUeExpr: '( (${refName.getCppType()}) % )',
//           ueToGlueExpr: '( (int) (${refName.getCppType()}) % )',
//           args: convArgs,
//           isEnum: true,
//           baseType: baseType,
//         };
//       } else {
//         // non uobject
//         var cppIncludes = IncludeSet.fromUniqueArray(getMetaArray(meta, ':glueCppIncludes'));
//         var headerIncludes = IncludeSet.fromUniqueArray(['<UEPointer.h>']);
//         if (cppIncludes.length == 0) {
//           Context.warning('Unreal Glue Code: glueCppIncludes missing for $typeRef', pos);
//         }
//         var ueType = refName;
//         var forwardDecls = [],
//             declType = ForwardDeclEnum.Always;
//         var addMyForward = true;
//         if (convArgs != null) {
//           var myIncludes = cppIncludes.copy();
//           declType = ForwardDeclEnum.Templated(myIncludes);
//           addMyForward = false;
//           for (arg in convArgs) {
//             cppIncludes.append(arg.glueCppIncludes);
//             if (!arg.isTypeParam) {
//               // TArray types can be forward declared, so add an exception here
//               switch (arg.forwardDeclType) {
//               case null | Never:
//                 declType = ForwardDeclEnum.Never;
//               case Templated(incs):
//                 myIncludes.append(incs);
//               case _:
//                 if (arg.forwardDecls == null) {
//                   forwardDecls.push(arg.ueType.getForwardDecl());
//                 } else {
//                   for (decl in arg.forwardDecls)
//                     forwardDecls.push(decl);
//                 }
//               }
//             }
//           }
//         }
//
//         // don't add forward declarations for non-UOBjects
//         // TODO proper forward declaration for structs (vs. classes)
//         switch (declType) {
//           case Templated(_):
//             // do nothing
//           case _:
//             declType = ForwardDeclEnum.Never;
//         }
//
//         if (addMyForward)
//           forwardDecls.push(ueType.getForwardDecl());
//         var ret:TypeConvInfo = {
//           haxeType: originalTypeRef,
//           ueType: new TypeRef(['cpp'], 'RawPointer', [ueType]),
//           haxeGlueType: uePointer,
//           glueType: uePointer,
//
//           glueCppIncludes: cppIncludes.add('<OPointers.h>'),
//           glueHeaderIncludes:IncludeSet.fromUniqueArray(['<UEPointer.h>']),
//
//           haxeToGlueExpr: '@:privateAccess %.getWrapped().get_raw()',
//           glueToHaxeExpr: typeRef.getClassPath() + '.wrap( cast (%), ${typeRef.getUniqueID()}, $$parent )',
//           glueToUeExpr: '( (${ueType.getCppType()} *) (::unreal::helpers::UEPointer::getPointer(%)) )',
//           ownershipModifier: modf,
//           args: convArgs,
//
//           forwardDeclType: declType,
//           forwardDecls: forwardDecls,
//           baseType: baseType,
//         };
//         if (originalTypeRef != typeRef)
//           ret.glueToHaxeExpr = '( cast ' + ret.glueToHaxeExpr + ' : ${originalTypeRef} )';
//         if (modf == null) {
//           // By default, all non-UObject types are treated as PStruct
//           ret.ownershipModifier = modf = 'unreal.PStruct';
//         } else {
//           ret.haxeType = TypeRef.parseClassName(modf, [originalTypeRef]);
//         }
//
//         var external = false;
//         switch (modf) {
//           case 'unreal.PPtr':
//             ret.ueToGlueExpr = 'PPtr<${ueType.getCppType()}>::wrap( %, ${typeRef.getUniqueID()}, $$hasParent )';
//             external = true;
//           case 'unreal.PHaxeCreated':
//             ret.ueToGlueExpr = 'PHaxeCreated<${ueType.getCppType()}>::wrap( % )';
//             ret.glueToHaxeExpr = '@:privateAccess new unreal.PHaxeCreated(' + ret.glueToHaxeExpr + ')';
//           case 'unreal.PStruct':
//             ret.ueToGlueExpr = 'new PStruct<${ueType.getCppType()}>( % )';
//             // ret.glueToHaxeExpr = '@:privateAccess new unreal.PStruct(' + ret.glueToHaxeExpr + ')';
//             ret.glueToUeExpr = '(*(' + ret.glueToUeExpr + '))';
//             ret.ueType = ret.ueType.params[0];
//             if (ret.forwardDeclType == Always)
//               ret.forwardDeclType = ForwardDeclEnum.AsFunction;
//           case 'unreal.TSharedPtr':
//             ret.ueType = new TypeRef('TSharedPtr',[ueType]);
//             ret.ueToGlueExpr = 'PSharedPtr<${ueType.getCppType()}>::wrap( % )';
//             ret.glueToUeExpr = '( (PSharedPtr<${ueType.getCppType()}> *) %->toSharedPtr() )->value';
//             ret.glueToHaxeExpr = '( cast ' + ret.glueToHaxeExpr + ' : unreal.TSharedPtr<${typeRef}> )';
//           case 'unreal.TThreadSafeSharedPtr':
//             ret.ueType = new TypeRef('TSharedPtr',[ueType, new TypeRef(['ESPMode'], 'ThreadSafe')]);
//             ret.ueToGlueExpr = 'PSharedPtr<${ueType.getCppType()}, ESPMode::ThreadSafe>::wrap( % )';
//             ret.glueToUeExpr = '( (PSharedPtr<${ueType.getCppType()}, ESPMode::ThreadSafe> *) %->toSharedPtrTS() )->value';
//             ret.glueToHaxeExpr = '( cast ' + ret.glueToHaxeExpr + ' : unreal.TThreadSafeSharedPtr<${typeRef}> )';
//           case 'unreal.TSharedRef':
//             ret.ueType = new TypeRef('TSharedRef',[ueType]);
//             ret.ueToGlueExpr = 'new PSharedRef<${ueType.getCppType()}>( % )';
//             ret.glueToUeExpr = '( (PSharedRef<${ueType.getCppType()}> *) %->toSharedRef() )->value';
//             ret.glueToHaxeExpr = '( cast ' + ret.glueToHaxeExpr + ' : unreal.TSharedRef<${typeRef}> )';
//           case 'unreal.TThreadSafeSharedRef':
//             ret.ueType = new TypeRef('TSharedRef',[ueType, new TypeRef(['ESPMode'], 'ThreadSafe')]);
//             ret.ueToGlueExpr = 'new PSharedRef<${ueType.getCppType()}, ESPMode::ThreadSafe>( % )';
//             ret.glueToUeExpr = '( (PSharedRef<${ueType.getCppType()}, ESPMode::ThreadSafe> *) %->toSharedRefTS() )->value';
//             ret.glueToHaxeExpr = '( cast ' + ret.glueToHaxeExpr + ' : unreal.TThreadSafeSharedRef<${typeRef}> )';
//           case 'unreal.TWeakPtr':
//             ret.ueType = new TypeRef('TWeakPtr',[ueType]);
//             ret.ueToGlueExpr = 'PWeakPtr<${ueType.getCppType()}>::wrap( % )';
//             ret.glueToUeExpr = '( (PWeakPtr<${ueType.getCppType()}> *) %->toWeakPtr() )->value';
//             ret.glueToHaxeExpr = '( cast ' + ret.glueToHaxeExpr + ' : unreal.TWeakPtr<${typeRef}> )';
//           case 'unreal.TThreadSafeWeakPtr':
//             ret.ueType = new TypeRef('TWeakPtr',[ueType, new TypeRef(['ESPMode'], 'ThreadSafe')]);
//             ret.ueToGlueExpr = 'PWeakPtr<${ueType.getCppType()}, ESPMode::ThreadSafe>::wrap( % )';
//             ret.glueToUeExpr = '( (PWeakPtr<${ueType.getCppType()}, ESPMode::ThreadSafe> *) %->toWeakPtrTS() )->value';
//             ret.glueToHaxeExpr = '( cast ' + ret.glueToHaxeExpr + ' : unreal.TThreadSafeWeakPtr<${typeRef}> )';
//           case 'unreal.PRef':
//             @:privateAccess ret.ueType.name = 'Reference';
//             ret.ueToGlueExpr = 'PPtr<${ueType.getCppType()}>::wrap( &(%), ${typeRef.getUniqueID()}, $$hasParent )';
//             ret.glueToUeExpr = '*(' + ret.glueToUeExpr + ')';
//             external = true;
//           case _:
//             throw 'assert: $modf';
//         }
//
//         if (typeRef.params.length > 0) {
//           ret.glueCppIncludes.add('<' + typeRef.getGlueHelperType().getClassPath().replace('.','/') + '_UE.h>');
//           ret.glueCppIncludes.add('<ClassMap.h>');
//           var isTypeName = ctx.meta != null && ctx.meta.has(':typeName');
//           ret.ueToGlueExpr = 'new ' + typeRef.getGlueHelperType().getCppClass() + '_UE_obj<' +
//             [ for (param in args) {
//               var conv = TypeConv.get(param, pos);
//               if (isTypeName && conv.isUObject == true)
//                 conv.ueType.getCppClass();
//               else
//                 conv.ueType.getCppType().toString();
//             }].join(',') +
//           '>(' + ret.ueToGlueExpr + ')';
//
//           if (external) {
//             var expr = (modf == 'unreal.PRef') ? '&(%)' : '%';
//             ret.ueToGlueExpr = '(!$$hasParent && unreal::helpers::ClassMap_obj::findWrapper($expr, ${typeRef.getUniqueID()})) ? reinterpret_cast< ::unreal::helpers::UEPointer* >($expr) : (${ret.ueToGlueExpr})';
//           }
//         }
//         return ret;
//       }
//     }
//
//     // check if extends @:uextern
//     var uextension = false;
//     if (ctx.isUObject) {
//       while (superClass != null) {
//         var cur = superClass.t.get();
//         if (cur.meta.has(':uextern')) {
//           uextension = true;
//           break;
//         }
//         superClass = cur.superClass;
//       }
//     }
//
//     if (uextension) {
//       var glueCppIncludes = IncludeSet.fromUniqueArray(getMetaArray(meta, ':glueCppIncludes'));
//       glueCppIncludes.add('<HxcppRuntime.h>');
//       #if !bake_externs
//       var mod = getMetaArray(meta, ':utargetmodule');
//       var module = mod == null ? null : mod[0];
//       var dir = Globals.cur.haxeRuntimeDir;
//       if (module != null)
//         dir = dir + '/../$module';
//
//       glueCppIncludes.add('$dir/Generated/Public/${refName.withoutPrefix().name}.h');
//       #end
//       var ret:TypeConvInfo = {
//         haxeType: typeRef,
//         ueType: new TypeRef(['cpp'], 'RawPointer', [refName]),
//         haxeGlueType: voidStar,
//         glueType: voidStar,
//
//         isUObject: true,
//         isUExtension: true,
//
//         glueCppIncludes: glueCppIncludes.add('<UEPointer.h>'),
//
//         haxeToGlueExpr: 'unreal.helpers.HaxeHelpers.dynamicToPointer(%)',
//         glueToHaxeExpr: '( unreal.helpers.HaxeHelpers.pointerToDynamic(%) : ${typeRef.getClassPath()})',
//         ueToGlueExpr: '::unreal::helpers::UEPointer::getGcRef(%)',
//         glueToUeExpr: '((::${refName.getCppType()} *) ::unreal::helpers::HxcppRuntime::getWrapped( % ))',
//         ownershipModifier: modf,
//
//         forwardDeclType: ForwardDeclEnum.Always,
//         forwardDecls: [refName.getForwardDecl()],
//         baseType: baseType,
//       };
//
//       if (modf == 'unreal.PRef') {
//         ret.ueType = new TypeRef(['cpp'], 'Reference', [ret.ueType]);
//         ret.glueToUeExpr =
//           '(static_cast<${refName.getCppType()} *&> (*( (${refName.getCppType()} **) ::unreal::helpers::HxcppRuntime::getWrappedRef( % ) )))';
//       }
//
//       return ret;
//     }
//     if (isBasic)
//       return {
//         ueType: typeRef,
//         haxeType: typeRef,
//         glueHeaderIncludes:IncludeSet.fromUniqueArray(['<hxcpp.h>']),
//         isBasic: true,
//         args: convArgs,
//         baseType: baseType,
//       };
//
//     if (ctx.isTypeParam) {
//       var haxeType = new TypeRef(typeRef.name),
//           ueType = new TypeRef(['cpp'], 'RawPointer', [haxeType]);
//       var isRef = false;
//       if (modf != null) {
//         // HACK: work around Haxe issue #4591. Change back to use modf itself when fixed
//         switch(modf) {
//         case 'unreal.PStruct':
//           haxeType = new TypeRef(['ue4hx','internal'], 'PStructDef', [haxeType]);
//           ueType = haxeType;
//         case 'unreal.PHaxeCreated':
//           haxeType = new TypeRef(['ue4hx','internal'], 'PHaxeCreatedDef', [haxeType]);
//         case 'unreal.PPtr':
//           haxeType = new TypeRef(['ue4hx','internal'], 'PPtrDef', [haxeType]);
//         case 'unreal.PRef':
//           // we'll use haxeToUePtr
//           isRef = true;
//           ueType = haxeType;
//           haxeType = new TypeRef(['ue4hx','internal'], 'PRefDef', [haxeType]);
//         case _:
//           ueType = new TypeRef( modf.split('.').pop(), [haxeType] );
//           haxeType = TypeRef.parseClassName( modf, [haxeType] );
//         }
//       } else {
//         ueType = ueType.params[0];
//       }
//       var ret:TypeConvInfo = {
//         ueType: ueType,
//         haxeType: haxeType,
//         glueType: voidStar,
//         haxeGlueType: voidStar,
//
//         glueCppIncludes: IncludeSet.fromUniqueArray(['<TypeParamGlue.h>']),
//
//         ueToGlueExpr: 'TypeParamGlue<${ueType.getCppType()}>::ueToHaxe( % )',
//         glueToUeExpr: 'TypeParamGlue<${ueType.getCppType()}>::haxeToUe( % )',
//         haxeToGlueExpr: 'unreal.helpers.HaxeHelpers.dynamicToPointer( % )',
//         glueToHaxeExpr: '(unreal.helpers.HaxeHelpers.pointerToDynamic( % ) : ${haxeType.toString()})',
//         args: convArgs,
//         isTypeParam: true,
//         ownershipModifier: modf,
//         baseType: baseType,
//       };
//       if (isRef) {
//         ret.ueToGlueExpr = 'TypeParamGluePtr<${ueType.getCppType()}>::ueToHaxeRef( % )';
//         ret.glueToUeExpr = 'TypeParamGluePtr<${ueType.getCppType()}>::haxeToUePtr( % )';
//       }
//       return ret;
//     }
//
//     if (ctx.name == 'unreal.ByteArray') {
//       return {
//         ueType: byteArray,
//         haxeType: new TypeRef(['unreal'],'ByteArray'),
//         glueType: byteArray,
//         haxeGlueType: byteArray,
//
//         haxeToGlueExpr: '(%).ptr.get_raw()',
//         glueToHaxeExpr: 'new unreal.ByteArray(cpp.Pointer.fromRaw(%), -1)'
//       }
//     }
//     throw new Error('Unreal Glue: Type $name is not supported', pos);
//   }
//
//   static var basicTypes:Map<String, TypeConvInfo> = {
//     var basicConvert = [
//       "cpp.Float32" => "float",
//       "cpp.Float64" => "double",
//       "Float" => "double",
//       "cpp.Int16" => "int16",
//       "cpp.Int32" => "int32",
//       "Int" => "int32",
//       "cpp.Int8" => "int8",
//       "cpp.UInt16" => "uint16",
//       "cpp.UInt8" => "uint8"
//     ];
//
//     var infos:Array<TypeConvInfo> = [
//       {
//         ueType: new TypeRef('bool'),
//         haxeType: new TypeRef('Bool'),
//         isBasic: true,
//       },
//       {
//         ueType: new TypeRef('void'),
//         haxeType: new TypeRef('Void'),
//         isBasic: true,
//       },
//       {
//         ueType: new TypeRef('uint32'),
//         haxeType: new TypeRef(['unreal'],'FakeUInt32'),
//         haxeGlueType: new TypeRef(['cpp'],'Int32'),
//         glueType: new TypeRef(['cpp'], 'Int32'),
//
//         haxeToGlueExpr: '(cast (%) : cpp.Int32)',
//         glueToHaxeExpr: '(cast (%) : unreal.FakeUInt32)',
//         isBasic: true,
//       },
//       {
//         ueType: new TypeRef('uint64'),
//         haxeType: new TypeRef(['unreal'],'FakeUInt64'),
//         haxeGlueType: new TypeRef(['ue4hx','internal'], 'Int64Glue'),
//         glueType: new TypeRef(['cpp'], 'Int64'),
//
//         haxeToGlueExpr: '(cast (%) : ue4hx.internal.Int64Glue)',
//         glueToHaxeExpr: '(cast (%) : unreal.Int64)',
//         glueToUeExpr: '((uint64) (%))',
//         isBasic: true,
//       },
//       {
//         ueType: new TypeRef('int64'),
//         haxeType: new TypeRef(['unreal'],'Int64'),
//         haxeGlueType: new TypeRef(['ue4hx','internal'], 'Int64Glue'),
//         glueType: new TypeRef(['cpp'], 'Int64'),
//
//         haxeToGlueExpr: '(cast (%) : ue4hx.internal.Int64Glue)',
//         glueToHaxeExpr: '(cast (%) : unreal.Int64)',
//         glueToUeExpr: '((int64) (%))',
//         isBasic: true,
//       },
//       {
//         ueType: new TypeRef('void'),
//         haxeType: new TypeRef('Void'),
//         isBasic: true,
//       },
//       {
//         ueType: voidStar,
//         haxeType: voidStar,
//         isBasic: true,
//       },
//       {
//         ueType: voidStar,
//         haxeType: new TypeRef(['cpp'],'Pointer', [new TypeRef('Dynamic')]),
//         glueType: voidStar,
//
//         haxeToGlueExpr: '(%).rawCast()',
//         glueToHaxeExpr: 'cpp.Pointer.fromRaw(cast (%))',
//         isBasic: true,
//       },
//       {
//         ueType: voidStar,
//         haxeType: new TypeRef(['unreal'],'AnyPtr'),
//         glueType: voidStar,
//         haxeGlueType: voidStar,
//
//         haxeToGlueExpr: '(%).rawCast()',
//         glueToHaxeExpr: '( cpp.Pointer.fromRaw(cast (%)) : unreal.AnyPtr )',
//         // isBasic: true,
//       },
//       {
//         ueType: new TypeRef(['cpp'],'RawPointer', [new TypeRef('void const')]),
//         haxeType: new TypeRef(['unreal'],'ConstAnyPtr'),
//         glueType: voidStar,
//         haxeGlueType: voidStar,
//
//         haxeToGlueExpr: '(%).rawCast()',
//         glueToHaxeExpr: '( cpp.Pointer.fromRaw(cast (%)) : unreal.AnyPtr )',
//         ueToGlueExpr: '(const_cast<void *>(%))',
//         // isBasic: true,
//       },
//       // TCharStar
//       {
//         haxeType: new TypeRef(['unreal'],'TCharStar'),
//         ueType: new TypeRef(['cpp'], 'RawPointer', [new TypeRef('TCHAR')]),
//         haxeGlueType: voidStar,
//         glueType: voidStar,
//
//         glueCppIncludes:IncludeSet.fromUniqueArray(['Engine.h', '<HxcppRuntime.h>']),
//         glueHeaderIncludes:IncludeSet.fromUniqueArray(['<hxcpp.h>']),
//
//         ueToGlueExpr:'::unreal::helpers::HxcppRuntime::constCharToString(TCHAR_TO_UTF8( % ))',
//         glueToUeExpr:'UTF8_TO_TCHAR(::unreal::helpers::HxcppRuntime::stringToConstChar(%))',
//         haxeToGlueExpr:'unreal.helpers.HaxeHelpers.dynamicToPointer( % )',
//         glueToHaxeExpr:'(unreal.helpers.HaxeHelpers.pointerToDynamic( % ) : String)',
//         isBasic: false,
//       },
//     ];
//     infos = infos.concat([ for (key in basicConvert.keys()) {
//       ueType: TypeRef.parseClassName(basicConvert[key]),
//       glueType: TypeRef.parseClassName(key),
//       haxeType: TypeRef.parseClassName(key),
//       glueHeaderIncludes:IncludeSet.fromUniqueArray(['<hxcpp.h>']),
//       isBasic: true
//     }]);
//     var ret = new Map();
//     for (info in infos)
//     {
//       ret[info.haxeType.getClassPath()] = info;
//     }
//     ret;
//   };
//
//   static var scriptableUObject:TypeConvInfo = {
//     haxeType: new TypeRef(['unreal'], 'UObject'),
//     ueType: new TypeRef(['cpp'], 'RawPointer', [new TypeRef('UObject')]),
//     haxeGlueType: voidStar,
//     glueType: voidStar,
//
//     isUObject: true,
//
//     glueCppIncludes: IncludeSet.fromUniqueArray(['Engine.h']),
//
//     haxeToGlueExpr: 'unreal.helpers.HaxeHelpers.dynamicToPointer(%)',
//     glueToHaxeExpr: '( unreal.helpers.HaxeHelpers.pointerToDynamic(%) : unreal.UObject)',
//     ueToGlueExpr: '::unreal::helpers::UEPointer::getGcRef(%)',
//     glueToUeExpr: '((::UObject *) ::unreal::helpers::HxcppRuntime::getWrapped( % ))',
//
//     forwardDeclType: ForwardDeclEnum.Always,
//     forwardDecls: ['class UObject'],
//   }
// }
//
// typedef TypeConvInfo = {
//   /**
//     Represents the Haxe-side type
//    **/
//   public var haxeType:TypeRef;
//   /**
//     Represents the UE-side type (e.g. `FString` on case of FString)
//    **/
//   public var ueType:TypeRef;
//
//   /**
//     Represents the type in the glue helper as seen by Haxe. Again in the `FString` example,
//     its `haxeGlueType` will be `cpp.ConstCharStar`.
//
//     If null, this will be the same as `haxeType`
//    **/
//   @:optional public var haxeGlueType:Null<TypeRef>;
//   /**
//     Represents the actual glue type. Normally, it will be the same as the ueType;
//     However, in some special cases, it will be different.
//     One classic case where it is different is `FString`: While `ueType` is the
//     actual `FString` type, its `glueType` will be `const char *`
//
//     If null, this will be the same as `ueType`
//    **/
//   @:optional public var glueType:Null<TypeRef>;
//   // @:optional public var glueHelperType:TypeRef;
//
//   /**
//     Represents the public includes that can be included in the glue header
//     These can only be includes that are safe to be included in both UE4 and hxcpp sides
//    **/
//   @:optional public var glueHeaderIncludes:Null<IncludeSet>;
//   /**
//     Represents the private includes to the glue cpp files. These can be UE4 includes,
//     since the CPP file is only compiled by the UE4 side
//    **/
//   @:optional public var glueCppIncludes:Null<IncludeSet>;
//
//   /**
//     Gets the wrapping expression from UE type to the glue Type
//     e.g. on `FString` this would be what transforms `FString` into `const char *`
//    **/
//   @:optional public var ueToGlueExpr:Null<String>;
//   /**
//     Gets the wrapping expression from hxcpp `glueType` to UE4.
//     e.g. on `FString` this would be `FString( UTF8_TO_TCHAR(%) )`
//    **/
//   @:optional public var glueToUeExpr:Null<String>;
//   /**
//     Gets the wrapping expression from Haxe type to the glue type
//    **/
//   @:optional public var haxeToGlueExpr:Null<String>;
//   /**
//     Gets the wrapping expression from the Glue type to the Haxe type
//    **/
//   @:optional public var glueToHaxeExpr:Null<String>;
//
//   /**
//     Tells whether the type refers to a UObject type
//    **/
//   @:optional public var isUObject:Bool;
//
//   /**
//     Tells whether the type refers to a Haxe create UObject-derived type
//    **/
//   @:optional public var isUExtension:Bool;
//
//   /**
//     Tells whether the type is a basic type
//    **/
//   @:optional public var isBasic:Bool;
//   @:optional public var isEnum:Bool;
//
//   @:optional public var ownershipModifier:String;
//
//   @:optional public var args:Array<TypeConv>;
//   @:optional public var params:Array<String>;
//
//   @:optional public var isTypeParam:Bool;
//   @:optional public var isFunction:Bool;
//   @:optional public var isMethodPointer:Bool;
//   @:optional public var isInterface:Bool;
//   @:optional public var functionArgs:Array<TypeConvInfo>;
//   @:optional public var functionRet:TypeConvInfo;
//
//   // forward declaration
//   @:optional public var forwardDeclType:ForwardDecl;
//   @:optional public var forwardDecls:Array<String>;
//
//   @:optional public var baseType:BaseType;
// }
//
// typedef TypeConvCtx = {
//   name:String,
//   args:Array<Type>,
//   meta:MetaAccess,
//
//   ?isInterface:Bool,
//   ?superClass:Null<{ t : Ref<ClassType>, params : Array<Type> }>,
//   ?baseType:Null<BaseType>,
//   ?isBasic:Bool,
//   ?isUObject:Bool,
//   ?isEnum:Bool,
//   ?isFunction:Bool,
//   ?isAbstract:Bool,
//
//   ?originalType:TypeRef,
//   ?isTypeParam:Bool,
// }
//
// enum ForwardDeclEnum {
//   Never;
//   AsFunction;
//   Templated(mainIncludes:IncludeSet);
//   Always;
// }
//
// @:forward
// abstract ForwardDecl(ForwardDeclEnum) from ForwardDeclEnum to ForwardDeclEnum {
//   @:extern inline public function isNever() {
//     return this == null || this == Never;
//   }
// }

class TypeConv {
  public var data(default, null):TypeConvData;
  public var modifiers(default, null):Null<Array<Modifier>>;

  public var haxeType(default, null):TypeRef;
  public var ueType(default, null):TypeRef;
  public var glueType(default, null):TypeRef;
  public var haxeGlueType(default, null):TypeRef;

  private function new(data, ?modifiers, ?original) {
    this.data = data;
    this.haxeType = original;
    this.modifiers = modifiers;
    consolidate();
  }

  inline public function withModifiers(modifiers, ?original) {
    return new TypeConv(this.data, modifiers, original);
  }

  inline public function hasModifier(modf:Modifier) {
    return this.modifiers != null && this.modifiers.has(modf);
  }

  public function hasTypeParams():Bool {
    switch(this.data) {
      case CStruct(_,_,params):
        if (params != null) {
          for (param in params) {
            if (param.hasTypeParams()) {
              return true;
            }
          }
        }
      case CLambda(args,ret) | CMethodPointer(_,args,ret):
        if (ret.hasTypeParams()) return true;
        for (param in args) {
          if (param.hasTypeParams()) {
            return true;
          }
        }
      case CTypeParam(_):
        return true;

      case CBasic(_) | CSpecial(_) | CUObject(_) | CEnum(_):
    }
    return false;
  }

  private function consolidate() {
    var originalSet = this.haxeType != null;
    switch(this.data) {
      case CBasic(info) | CSpecial(info):
        if (this.haxeType == null) {
          this.haxeType = info.haxeType;
        }
        this.ueType = info.ueType;
        this.glueType = info.glueType != null ? info.glueType : info.ueType;
        this.haxeGlueType = info.haxeGlueType != null ? info.haxeGlueType : info.haxeType;
      case CUObject(type, flags, info):
        // OExternal, OInterface, OHaxe, OScriptHaxe
        if (flags.hasAny(OWeak)) {
          var name = flags.hasAll(OAutoWeak) ? 'TAutoWeakObjectPtr' : 'TWeakObjectPtr';
          this.ueType = new TypeRef(name, [this.ueType]);
          if (this.haxeType == null) {
            this.haxeType = new TypeRef(['unreal'],name,[info.haxeType]);
          }
        } else if (type == OSubclassOf) {
          var name = 'TSubclassOf';
          this.ueType = new TypeRef(name, [this.ueType]);
          if (this.haxeType == null) {
            this.haxeType = new TypeRef(['unreal'],name,[info.haxeType]);
          }
        }

        if (this.haxeType == null) {
          this.haxeType = info.haxeType;
        }
        this.ueType = new TypeRef(['cpp'], 'RawPointer', [info.ueType]);
        // we're using IntPtr for a simple reason: it's reflective - so compatible with cppia
        // and it's a type that both Unreal and Haxe can see (different from cpp.Pointer)
        this.glueType = uintPtr;
        this.haxeGlueType = uintPtr;
      case CEnum(type, info):
        // EExternal, EAbstract, EHaxe, EScriptHaxe
        if (this.haxeType == null) {
          this.haxeType = info.haxeType;
        }
        this.ueType = info.ueType;
        this.haxeGlueType = this.glueType = int32;
      case CStruct(type, info, params):
        // SExternal, SHaxe, SCriptHaxe
        if (this.haxeType == null) {
          if (params != null && params.length > 0) {
            this.haxeType = info.haxeType.withParams([ for (param in params) param.haxeType ]);
          } else {
            this.haxeType = info.haxeType;
          }
        }
        if (params != null && params.length > 0) {
          var ueParams = [ for (param in params) param.ueType ];
          var name = switch(info.ueType.name) {
            case 'TThreadSafeSharedPtr':
              ueParams.push(new TypeRef('ESPMode::ThreadSafe'));
              'TSharedPtr';
            case 'TThreadSafeSharedRef':
              ueParams.push(new TypeRef('ESPMode::ThreadSafe'));
              'TSharedRef';
            case 'TThreadSafeWeakPtr':
              ueParams.push(new TypeRef('ESPMode::ThreadSafe'));
              'TWeakPtr';
            case name:
              name;
          };
          this.ueType = info.ueType.with(name, ueParams);
        } else {
          this.ueType = info.ueType;
        }
        // we set structs to use VariantPtr because we can use both Haxe's GC'd instances
        // as non-Haxe GC
        this.haxeGlueType = this.glueType = variantPtr;

      case CLambda(fnArgs, fnRet):
        var binderTypeParams = fnArgs.copy();
        if (!fnRet.haxeType.isVoid()) {
          binderTypeParams.unshift(fnRet);
        }

        var binderClass = fnRet.haxeType.isVoid()
          ? (binderTypeParams.length > 0 ? 'LambdaBinderVoid' : 'LambdaBinderVoidVoid')
          : 'LambdaBinder';
        var binderTypeRef = new TypeRef(binderClass, binderTypeParams.map(function(tp) return tp.ueType));
        if (this.haxeType == null) {
          var args = [ for (arg in fnArgs) arg.haxeType ];
          args.push(fnRet.haxeType);
          this.haxeType = new TypeRef(['haxe'],'Function', 'Constraints', args);
        }
        this.ueType = binderTypeRef;
        this.haxeGlueType = this.glueType = uintPtr;
      case CMethodPointer(className, fnArgs, fnRet):
        this.ueType = uintPtr;
        this.haxeType = new TypeRef(['cpp'],'Pointer', [new TypeRef([],'Dynamic')]);
        this.haxeGlueType = this.glueType = uintPtr;
      case CTypeParam(name):
        this.haxeType = this.ueType = new TypeRef(name);
        this.glueType = this.haxeGlueType = uintPtr;
    }

    var modf = this.modifiers;
    if (modf != null) {
      if (modf.has(Ref) && this.data.match(CUObject(_,_,_))) {
        this.ueType = this.ueType.withoutPointer();
      }

      var i = modf.length;
      while (i --> 0) {
        switch(modf[i]) {
        case Const:
          if (!originalSet) {
            this.haxeType = new TypeRef(['unreal'], 'Const', [this.haxeType]);
          }
          this.ueType = this.ueType.withConst(true);
        case Ref:
          if (!originalSet) {
            this.haxeType = new TypeRef(['unreal'], 'PRef', [this.haxeType]);
          }
          this.ueType = new TypeRef(['cpp'], 'Reference', [this.ueType]);
        case Ptr:
          if (!originalSet) {
            this.haxeType = new TypeRef(['unreal'], 'PPtr', [this.haxeType]);
          }
          this.ueType = new TypeRef(['cpp'], 'RawPointer', [this.ueType]);
        }
      }
    }
  }

  public function collectGlueIncludes(set:IncludeSet) {
    switch(this.data) {
    case CBasic(info) | CSpecial(info):
      set.append(info.glueHeaderIncludes);
    case CUObject(type, flags, info):
      // we only use unreal::UIntPtr on the glue code
      set.add('IntPtr.h');
    case CEnum(type, info):
      set.add('hxcpp.h');
    case CStruct(type,info,params):
      set.add('IntPtr.h');

    case CLambda(_, _):
      set.add('IntPtr.h');
    case CMethodPointer(_,_,_):
      set.add('IntPtr.h');
    case CTypeParam(_):
      // no glue includes needed!
    }
  }

  public function collectUeIncludes(set:IncludeSet, ?forwardDecls:Map<String, String>, ?cppSet:IncludeSet) {
    recurseUeIncludes(set, forwardDecls, cppSet, this.hasModifier(Ptr) || this.hasModifier(Ref));
  }

  private function recurseUeIncludes(set:IncludeSet, forwardDecls:Map<String, String>, cppSet:IncludeSet, inPointer:Bool) {
    switch(this.data) {
    case CBasic(info) | CSpecial(info):
      set.append(info.glueCppIncludes);
    case CUObject(type, flags, info):
      if (flags.hasAny(OWeak)) {
        set.add("UObject/WeakObjectPtrTemplates.h");
      }
      if (type == OSubclassOf) {
        set.add("UObject/ObjectBase.h");
      }

      if (forwardDecls != null) {
        var decl = info.ueType.getForwardDecl();
        forwardDecls[decl] = decl;
        cppSet.append(info.glueCppIncludes);
      } else {
        set.append(info.glueCppIncludes);
        if (type == OHaxe || type == OScriptHaxe) {
          set.add('${ueType.withoutPrefix().name}.h');
        }
      }
    case CEnum(type, info):
      if (type == EHaxe || type == EScriptHaxe) {
        set.add('${ueType.withoutPrefix().name}.h');
      }
      set.append(info.glueCppIncludes);
    case CStruct(type,info,params):
      if (inPointer && forwardDecls != null) {
        var decl = info.ueType.getForwardDecl();
        forwardDecls[decl] = decl;
        cppSet.append(info.glueCppIncludes);
      } else {
        set.append(info.glueCppIncludes);
      }

      if (params != null) {
        var ptr = inPointer;
        if (!ptr && forwardDecls != null) {
          if (info.ueType.name == 'TArray') {
            ptr = true;
          }
        }

        for (param in params) {
          param.recurseUeIncludes(set, forwardDecls, cppSet, ptr);
        }
      }

    case CLambda(args, ret):
      if (forwardDecls == null) {
        set.add('LambdaBinding.h');
      }
      for (arg in args) {
        arg.recurseUeIncludes(set, forwardDecls, cppSet, true /* function arguments can be forward declared */);
      }
      ret.recurseUeIncludes(set, forwardDecls, cppSet, true);
    case CMethodPointer(className, args, ret):
      set.append(className.glueCppIncludes);
      for (arg in args) {
        arg.recurseUeIncludes(set, forwardDecls, cppSet, true /* function arguments can be forward declared */);
      }
      ret.recurseUeIncludes(set, forwardDecls, cppSet, true);
    case CTypeParam(name):
      if (forwardDecls == null) {
        set.add('TypeParamGlue.h');
      }
    }
  }

  inline public function haxeToGlue(expr:String, ctx:ConvCtx):String {
    return haxeToGlueRecurse(expr, ctx);
  }

  private function haxeToGlueRecurse(expr:String, ctx:ConvCtx):String {
    return switch(this.data) {
      case CBasic(info) | CSpecial(info):
        if (info.haxeToGlueExpr != null) {
          info.haxeToGlueExpr.replace('%', expr);
        } else {
          expr;
        }

      case CUObject(type, flags, info):
        // OExternal, OInterface, OHaxe, OScriptHaxe
        if (type == OInterface) {
          expr = '( cast ($expr) : unreal.UObject )';
        }
        '@:privateAccess $expr.wrapped';

      // EExternal, EAbstract, EHaxe, EScriptHaxe
      case CEnum(EAbstract, info):
        expr;
      case CEnum( type = (EScriptHaxe | EHaxe), info):
        var setType = type == EScriptHaxe ? ' : Dynamic' : '';
        var haxeType = this.haxeType;
        '{ var temp $setType = $expr; if (temp == null) { throw "null $haxeType passed to UE"; } Type.enumIndex(temp); }';
      case CEnum(type, info):
        var typeRef = info.haxeType,
            conv = typeRef.with(typeRef.name + '_EnumConv', typeRef.moduleName != null ? typeRef.moduleName : typeRef.name);
        '${conv.getClassPath()}.unwrap($expr)';

      case CStruct(type, info, params):
        // '($expr : unreal.VariantPtr)';
        expr;

      case CLambda(args,ret):
        'unreal.helpers.HaxeHelpers.dynamicToPointer( $expr )';
      case CMethodPointer(cname, args, ret):
        expr;
      case CTypeParam(name):
        'unreal.helpers.HaxeHelpers.dynamicToPointer( $expr )';
    }
  }

  public function glueToHaxe(expr:String, ctx:ConvCtx):String {
    return glueToHaxeRecurse(expr, ctx);
  }

  private function glueToHaxeRecurse(expr:String, ctx:ConvCtx):String {
    return switch(this.data) {
      case CBasic(info) | CSpecial(info):
        if (info.glueToHaxeExpr != null) {
          info.glueToHaxeExpr.replace('%', expr);
        } else {
          expr;
        }

      case CUObject(type, flags, info):
        // OExternal, OInterface, OHaxe, OScriptHaxe
        '( cast unreal.UObject.wrap($expr) : ${this.haxeType} )';

      // EExternal, EAbstract, EHaxe, EScriptHaxe
      case CEnum(EAbstract, info):
        '( ($expr) : ${haxeType} )';
      case CEnum( type = (EScriptHaxe | EHaxe), info):
        if (type == EScriptHaxe)
          'Type.createEnumIndex(Type.resolveEnum("${this.haxeType.getClassPath(false)}"), $expr)';
        else
          'ue4hx.internal.UEnumHelper.createEnumIndex(${this.haxeType.getClassPath(false)}, $expr)';
      case CEnum(type, info):
        var typeRef = info.haxeType,
            conv = typeRef.with(typeRef.name + '_EnumConv', typeRef.moduleName != null ? typeRef.moduleName : typeRef.name);
        '${conv.getClassPath()}.wrap($expr)';

      case CStruct(type, info, params):
        '( @:privateAccess ${info.haxeType.getClassPath()}.fromPointer( $expr ) : $haxeType )';

      case CLambda(args,ret):
        '( unreal.helpers.HaxeHelpers.pointerToDynamic( $expr ) : $haxeType )';
      case CMethodPointer(cname, args, ret):
        expr;
      case CTypeParam(name):
        '( unreal.helpers.HaxeHelpers.pointerToDynamic( $expr ) : $haxeType )';
    }
  }

  public function glueToUe(expr:String, ctx:ConvCtx):String {
    return glueToUeRecurse(expr, ctx);
  }

  private function glueToUeRecurse(expr:String, ctx:ConvCtx):String {
    return switch(this.data) {
      case CBasic(info) | CSpecial(info):
        if (info.glueToUeExpr != null) {
          info.glueToUeExpr.replace('%', expr);
        } else {
          expr;
        }

      case CUObject(type, flags, info):
        // OExternal, OInterface, OHaxe, OScriptHaxe
        var ret = '( (${info.ueType} *) $expr )';
        if (type == OInterface) {
          ret = 'Cast<${info.ueType.getCppType()}>( (UObject *) $expr )';
        } else if (type == OSubclassOf) {
          ret = '( ($ueType) $ret )';
        }
        if (flags.hasAny(OWeak | OAutoWeak)) {
          ret = '( ($ueType) $ret )';
        }
        ret;

      // EExternal, EAbstract, EHaxe, EScriptHaxe
      case CEnum(type, info):
        '( (${ueType.getCppType()}) $expr )';

      case CStruct(type, info, params):
        var ret = '::uhx::WrapHelper<${info.ueType.getCppType()}>::getPointer($expr)';
        if (this.modifiers == null || this.modifiers.has(Ref)) {
            ret = '*$ret';
        }
        ret;

      case CLambda(args,ret):
        ueType.getCppType() + '($expr)';
      case CMethodPointer(className, fnArgs, fnRet):
        var cppMethodType = new HelperBuf();
        cppMethodType << 'MemberFunctionTranslator<$className, ${fnRet.ueType.getCppType()}';
        if (fnArgs.length > 0) cppMethodType << ', ';
        cppMethodType.mapJoin(fnArgs, function(arg) return arg.ueType.getCppType().toString());
        cppMethodType << '>::Translator';
        '(($cppMethodType) $expr)()';
      case CTypeParam(name):
        '::uhx::TypeParamGlue<${ueType.getCppType()}>::haxeToUe( $expr )';
    }
  }

  public function ueToGlue(expr:String, ctx:ConvCtx):String {
    return ueToGlueRecurse(expr, ctx);
  }

  private function ueToGlueRecurse(expr:String, ctx:ConvCtx):String {
    if (this.hasModifier(Const)) {
      expr = 'const_cast<${ueType.getCppType(true)}>( $expr )';
    }

    return switch(this.data) {
      case CBasic(info) | CSpecial(info):
        if (info.ueToGlueExpr != null) {
          info.ueToGlueExpr.replace('%', expr);
        } else {
          expr;
        }

      case CUObject(type, flags, info):
        // OExternal, OInterface, OHaxe, OScriptHaxe
        var ret = expr;
        if (flags.hasAny(OWeak | OAutoWeak)) {
          '( $ret.Get() )';
        }

        if (type == OInterface) {
          ret = 'Cast<UObject>( $ret )';
        } else if (type == OSubclassOf) {
          ret = '( (UClass *) $ret )';
        }
        ret;

      // EExternal, EAbstract, EHaxe, EScriptHaxe
      case CEnum(type, info):
        '( (int) (${ueType.getCppType()}) $expr )';

      case CStruct(type, info, params):
        if (hasModifier(Ref)) {
          'unreal::VariantPtr( (void *) &($expr) )';
        } else if (hasModifier(Ptr)) {
          'unreal::VariantPtr( (void *) ($expr) )';
        } else {
          '::uhx::WrapHelper<${info.ueType.getCppType(true)}>::create($expr)';
        }

      case CLambda(args,ret):
        expr;
      case CMethodPointer(cname, args, ret):
        expr;
      case CTypeParam(name):
        '::uhx::TypeParamGlue<${ueType.getCppType(true)}>::ueToHaxe( $expr )';
    }
  }

  inline public static function get(type:Type, pos:Position):TypeConv {
    // var cache = Globals.cur.typeConvCache,
    //     str = Std.string(type);
    // var ret = cache[str];
    // if (ret != null) {
    //   return ret;
    // }
    // ret = getInfo(type, pos, { accFlags:ONone });
    // cache[str] = ret;
    // return ret;
    return getInfo(type, pos, { accFlags:ONone });
  }

  private static function getInfo(type:Type, pos:Position, ctx:InfoCtx):TypeConv {
    var cache = Globals.cur.typeConvCache;
    while(true) {
      switch(type) {
      case TInst(iref, tl):
        var name = tl.length == 0 ? iref.toString() : null;
        if (name != null) {
          var ret = cache[name];
          if (ret != null) {
            if (ctx.modf == null) {
              return ret;
            } else {
              return new TypeConv(ret.data, ctx.modf, ctx.original);
            }
          }
        }
        var it = iref.get();
        var ret = null;
        var info = getTypeInfo(it, pos);
        if (it.kind.match(KTypeParameter(_))) {
          name = null; // don't cache
          ctx.original = null;
          ret = CTypeParam(it.name);
        } else if (typeIsUObject(type)) {
          if (ctx.modf != null && ctx.modf.has(Ptr)) {
            Context.warning('Unreal Glue: PPtr of a UObject is not supported', pos);
          }
          if (ctx.isSubclassOf) {
            ret = CUObject(OSubclassOf, ctx.accFlags, info);
          } else if (!it.meta.has(':uextern')) {
            if (it.meta.has(':uscript') || Globals.cur.scriptModules.exists(it.module)) {
              ret = CUObject(OScriptHaxe, ctx.accFlags, info);
            } else {
              ret = CUObject(OHaxe, ctx.accFlags, info);
            }
          } else {
            ret = CUObject(OExternal, ctx.accFlags, info);
          }
        } else if (it.isInterface && it.meta.has(':uextern')) {
          if (ctx.modf != null && ctx.modf.has(Ptr)) {
            Context.warning('Unreal Glue: PPtr of a UObject is not supported', pos);
          }
          ret = CUObject(OInterface, ctx.accFlags, info);
        } else if (it.meta.has(':uextern')) {
          ret = CStruct(SExternal, info, tl.length > 0 ? [for (param in tl) get(param, pos)] : null);
        } else if (it.meta.has(':ustruct')) {
          if (it.meta.has(':uscript') || Globals.cur.scriptModules.exists(it.module)) {
            ret = CStruct(SScriptHaxe, info, tl.length > 0 ? [for (param in tl) get(param, pos)] : null);
          } else {
            ret = CStruct(SHaxe, info, tl.length > 0 ? [for (param in tl) get(param, pos)] : null);
          }
        } else {
          Context.warning('Unreal Glue: Type $iref is not supported', pos);
        }
        var ret = new TypeConv(ret, ctx.modf, ctx.original);
        if (name != null && ctx.modf == null) {
          cache[name] = ret;
        }
        return ret;

      case TEnum(eref, tl):
        if (ctx.modf != null) {
          Context.warning('Unreal Glue: Const, PPtr or PRef is not supported on enums', pos);
        }
        var name = eref.toString();
        var ret = cache[name];
        if (ret != null) {
          if (ctx.modf == null) {
            return ret;
          } else {
            return new TypeConv(ret.data, ctx.modf, ctx.original);
          }
        }

        var e = eref.get(),
            ret = null,
            info = getTypeInfo(e, pos);
        if (e.meta.has(':uextern')) {
          ret = CEnum(e.meta.has(':class') ? EExternalClass : EExternal, info);
        } else if (e.meta.has(':uenum')) {
          if (e.meta.has(':uscript') || Globals.cur.scriptModules.exists(e.module)) {
            ret = CEnum(EScriptHaxe, info);
          } else {
            ret = CEnum(EHaxe, info);
          }
        } else {
          Context.warning('Unreal Glue: Enum type $eref is not supported: It is not a uextern or a uenum', pos);
        }

        var ret = new TypeConv(ret, ctx.modf, ctx.original);
        if (name != null) {
          cache[name] = ret;
        }
        return ret;

      case TAbstract(aref, tl):
        var name = aref.toString();
        var ret = cache[name];
        if (ret != null) {
          return ret;
        }

        var a = aref.get(),
            ret = null,
            info = getTypeInfo(a, pos);
        if (a.meta.has(':uextern')) {
          ret = CStruct(SExternal, info, tl.length > 0 ? [for (param in tl) get(param, pos)] : null);
        } else if (a.meta.has(':ustruct')) {
          if (a.meta.has(':uscript') || Globals.cur.scriptModules.exists(a.module)) {
            ret = CStruct(SScriptHaxe, info, tl.length > 0 ? [for (param in tl) get(param, pos)] : null);
          } else {
            ret = CStruct(SHaxe, info, tl.length > 0 ? [for (param in tl) get(param, pos)] : null);
          }
        } else if (a.meta.has(':enum')) {
          if (ctx.modf != null) {
            Context.warning('Unreal Glue: Const, PPtr or PRef is not supported on enums', pos);
          }
          ret = CEnum(EAbstract, info);
        } else if (a.meta.has(':coreType')) {
          Context.warning('Unreal Glue: Basic type $name is not supported', pos);
        } else {
          switch(name) {
          case 'unreal.MethodPointer':
            if (ctx.modf != null) {
              Context.warning('Unreal Glue: Const, PPtr or PRef is not directly supported on MethodPointers', pos);
            }
            name = null;
            ret = parseMethodPointer(tl, pos);
          case _:
            if (ctx.original == null) {
              ctx.original = TypeRef.fromBaseType(a, tl, pos);
            }
            type = Context.followWithAbstracts(type, true);
          }
        }

        if (ret != null) {
          var ret = new TypeConv(ret, ctx.modf, ctx.original);
          if (name != null && ctx.modf == null) {
            cache[name] = ret;
          }
          return ret;
        }

      case TType(tref, tl):
        var name = tref.toString();
        var ret = cache[name];
        if (ret != null) {
          return ret;
        }

        var ret = null;
        var t = tref.get();
        if (t.meta.has(':unrealType')) {
          switch(name) {
          case 'unreal.Const':
            if (ctx.modf == null) ctx.modf = [];
            if (ctx.modf[ctx.modf.length-1] == Const) {
              Context.warning('Unreal Glue: Invalid Const<Const<>> type', pos);
            } else {
              ctx.modf.push(Const);
            }
          case 'unreal.PRef':
            if (ctx.modf == null) ctx.modf = [];
            if (ctx.modf.has(Ref) || ctx.modf.has(Ptr)) {
              throw new Error('Unreal Glue: A type cannot be defined with two PRefs or a PRef and a PPtr', pos);
            }
            // Const<PRef<>> should actually be PRef<Const<>>
            if (ctx.modf[ctx.modf.length-1] == Const) {
              ctx.modf.insert(ctx.modf.length-1, Ref);
            } else {
              ctx.modf.push(Ref);
            }
          case 'unreal.PPtr':
            if (ctx.modf == null) ctx.modf = [];
            if (ctx.modf.has(Ref) || ctx.modf.has(Ptr)) {
              throw new Error('Unreal Glue: A type cannot be defined with two PRefs or a PRef and a PPtr', pos);
            }
            ctx.modf.push(Ptr);
          case 'unreal.TWeakObjectPtr':
            if (ctx.accFlags.hasAny(OAutoWeak) || ctx.isSubclassOf) {
              Context.warning('Unreal Type: Illogical type (with multiple weak / subclassOf flags', pos);
            }
            ctx.accFlags |= OWeak;
          case 'unreal.TAutoWeakObjectPtr':
            if (ctx.accFlags.hasAny(OAutoWeak) || ctx.isSubclassOf) {
              Context.warning('Unreal Type: Illogical type (with multiple weak / subclassOf flags', pos);
            }
            ctx.accFlags |= OAutoWeak;
          case 'unreal.TSubclassOf':
            if (ctx.accFlags.hasAny(OWeak) || ctx.isSubclassOf) {
              Context.warning('Unreal Type: Illogical type (with multiple weak / subclassOf flags', pos);
            }
            ctx.isSubclassOf = true;
          case _:
            throw new Error('Unreal Type: Invalid typedef: $name', pos);
          }
        }

        if (ret != null) {
          var ret = new TypeConv(ret, ctx.modf, ctx.original);
          return ret;
        }
        type = Context.follow(type, true);

      case TLazy(f):
        type = f();

      case TFun(args, ret):
        var tcArgs = [ for(arg in args) get(arg.t, pos) ],
            tcRet = get(ret, pos);
        if (ctx.modf != null) {
          throw new Error('Unreal Glue: Const, PPtr or PRef is not directly supported on lambda functions', pos);
        }
        if (tcRet.hasModifier(Ref) && tcRet.data.match(CBasic(_)) && !tcRet.haxeType.isVoid()) {
          throw new Error('Unreal Glue: Function lambda types that return a reference to a basic type are not supported', pos);
        }
        return new TypeConv(CLambda(tcArgs, tcRet), ctx.modf, ctx.original);
      case t:
        throw new Error('Unreal Type: Invalid type $t', pos);
      }
    }
  }

  private static function parseMethodPointer(types:Array<Type>, pos:Position) {
    var objType = types[0],
        fn = types[1];
    var obj = switch(Context.followWithAbstracts(objType)) {
      case (t = TInst(c,tl)):
        getTypeInfo(c.get(), pos);
      case t:
        throw new Error('Unreal Glue: Type $t is invalid as an argument for MethodPointer', pos);
    };
    var args, ret;
    switch(Context.followWithAbstracts(fn)) {
      case TFun(a,r):
        args = [ for (arg in a) get(arg.t, pos) ];
        ret = get(r, pos);
      case t:
        throw new Error('Unreal Glue: Type $t is ainvalid as the function argument for MethodPointer', pos);
    }
    return CMethodPointer(obj, args, ret);
  }

  @:allow(ue4hx.internal.Globals) static function addSpecialTypes(to:Map<String, TypeConv>) {
    // Remember that any type added here must be added as an exception to the C++ templates
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
    var infos:Array<ExtTypeInfo> = [
      {
        ueType: new TypeRef('bool'),
        haxeType: new TypeRef('Bool'),
      },
      {
        ueType: new TypeRef('void'),
        haxeType: new TypeRef('Void'),
      },
      {
        ueType: new TypeRef('uint32'),
        haxeType: new TypeRef(['unreal'],'FakeUInt32'),
        haxeGlueType: new TypeRef(['cpp'],'UInt32'),
        glueType: new TypeRef(['cpp'], 'UInt32'),

        haxeToGlueExpr: '(cast (%) : cpp.UInt32)',
        glueToHaxeExpr: '(cast (%) : unreal.FakeUInt32)',
      },
      {
        ueType: new TypeRef('uint64'),
        haxeType: new TypeRef(['unreal'],'FakeUInt64'),
        haxeGlueType: new TypeRef(['ue4hx','internal'], 'Int64Glue'),
        glueType: new TypeRef(['cpp'], 'Int64'),

        haxeToGlueExpr: '(cast (%) : ue4hx.internal.Int64Glue)',
        glueToHaxeExpr: '(cast (%) : unreal.Int64)',
        glueToUeExpr: '((uint64) (%))',
      },
      {
        ueType: new TypeRef('int64'),
        haxeType: new TypeRef(['unreal'],'Int64'),
        haxeGlueType: new TypeRef(['ue4hx','internal'], 'Int64Glue'),
        glueType: new TypeRef(['cpp'], 'Int64'),

        haxeToGlueExpr: '(cast (%) : ue4hx.internal.Int64Glue)',
        glueToHaxeExpr: '(cast (%) : unreal.Int64)',
        glueToUeExpr: '((int64) (%))',
      },
      {
        ueType: new TypeRef(['cpp'],'RawPointer', [new TypeRef('void')]),
        glueType: new TypeRef(['unreal'],'VariantPtr'),
        haxeType: new TypeRef(['unreal'],'AnyPtr'),

        glueHeaderIncludes:IncludeSet.fromUniqueArray(['<VariantPtr.h>']),

        ueToGlueExpr: '( ::unreal::VariantPtr_obj::fromRawPtr(%) )',
        glueToUeExpr: '(%).toPointer()'
      },
      {
        ueType: new TypeRef(['cpp'],'RawPointer', [new TypeRef('void')], Const),
        glueType: new TypeRef(['unreal'],'VariantPtr'),
        haxeType: new TypeRef(['unreal'],'ConstAnyPtr'),

        glueHeaderIncludes:IncludeSet.fromUniqueArray(['<VariantPtr.h>']),

        ueToGlueExpr: '( ::unreal::VariantPtr_obj::fromRawPtr(const_cast<void *>(%)) )',
        glueToUeExpr: '(%).toPointer()',
      },
      {
        ueType: new TypeRef(['unreal'],'UIntPtr'),
        haxeType: new TypeRef(['unreal'],'UIntPtr'),
      },
      {
        ueType: new TypeRef(['unreal'],'IntPtr'),
        haxeType: new TypeRef(['unreal'],'IntPtr'),
      },
    ];
    infos = infos.concat([ for (key in basicConvert.keys()) {
      ueType: TypeRef.parseClassName(basicConvert[key]),
      glueType: TypeRef.parseClassName(key),
      haxeType: TypeRef.parseClassName(key),
      glueHeaderIncludes:IncludeSet.fromUniqueArray(['<hxcpp.h>']),
    }]);

    for (info in infos) {
      to[info.haxeType.toString()] = new TypeConv(CBasic(info));
    }

    infos = [
      // TCharStar
      {
        haxeType: new TypeRef(['unreal'],'TCharStar'),
        ueType: new TypeRef(['cpp'], 'RawPointer', [new TypeRef('TCHAR')]),
        haxeGlueType: voidStar,
        glueType: voidStar,

        glueCppIncludes:IncludeSet.fromUniqueArray(['Engine.h', '<HxcppRuntime.h>']),
        glueHeaderIncludes:IncludeSet.fromUniqueArray(['<hxcpp.h>']),

        ueToGlueExpr:'::unreal::helpers::HxcppRuntime::constCharToString(TCHAR_TO_UTF8( % ))',
        glueToUeExpr:'UTF8_TO_TCHAR(::unreal::helpers::HxcppRuntime::stringToConstChar(%))',
        haxeToGlueExpr:'unreal.helpers.HaxeHelpers.dynamicToPointer( % )',
        glueToHaxeExpr:'(unreal.helpers.HaxeHelpers.pointerToDynamic( % ) : String)',
      },
      { // TODO - use Pointer instead
        ueType: byteArray,
        haxeType: new TypeRef(['unreal'],'ByteArray'),
        glueType: byteArray,
        haxeGlueType: byteArray,

        haxeToGlueExpr: '(%).ptr.get_raw()',
        glueToHaxeExpr: 'new unreal.ByteArray(cpp.Pointer.fromRaw(%), -1)'
      },
    ];
    for (info in infos) {
      to[info.haxeType.toString()] = new TypeConv(CSpecial(info));
    }
  }

  private static function getTypeInfo(baseType:BaseType, ?args:Array<Type>, pos:Position):TypeInfo {
    var haxeType = TypeRef.fromBaseType(baseType, args, pos);
    var ueName = getMetaString(baseType.meta, ':uname');
    if (ueName == null) {
      ueName = baseType.name;
    }
    var ueType = TypeRef.parse(ueName);
    return {
      haxeType: haxeType,
      ueType: ueType,

      glueCppIncludes: IncludeSet.fromUniqueArray(getMetaArray(baseType.meta, ':glueCppIncludes')),
      glueHeaderIncludes: IncludeSet.fromUniqueArray(getMetaArray(baseType.meta, ':glueHeaderIncludes')),
    };
  }

  private static function typeIsUObject(t:Type) {
    var uobject = Globals.cur.uobject;
    if (uobject == null) {
      Globals.cur.uobject = uobject = Context.getType('unreal.UObject');
    }
    return Context.unify(t, uobject);
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
  static var byteArray(default,null) = new TypeRef(['cpp'],'RawPointer', [new TypeRef(['cpp'],'UInt8')]);
  static var variantPtr(default,null) = new TypeRef(['unreal'],'VariantPtr');
  static var uintPtr(default,null) = new TypeRef(['unreal'],'UIntPtr');
  static var int32(default,null) = new TypeRef('Int');
}

typedef TypeInfo = {
  /**
    Represents the Haxe-side type
   **/
  haxeType:TypeRef,

  /**
    Represents the UE-side type (e.g. `FString` on case of FString)
   **/
  ueType:TypeRef,

  /**
    Represents the private includes to the glue cpp files. These can be UE4 includes,
    since the CPP file is only compiled by the UE4 side
   **/
  ?glueCppIncludes:IncludeSet,
  /**
    Represents the public includes that can be included in the glue header
    These can only be includes that are safe to be included in both UE4 and hxcpp sides
   **/
  ?glueHeaderIncludes:IncludeSet,
};

typedef ExtTypeInfo = {
  > TypeInfo,

  /**
    Represents the actual glue type. Normally, it will be the same as the ueType;
    However, in some special cases, it will be different.

    If null, this will be the same as `ueType`
   **/
  ?glueType:TypeRef,

  /**
    Represents the type in the glue helper as seen by Haxe.

    If null, this will be the same as `haxeType`
   **/
  ?haxeGlueType:TypeRef,

  ?haxeToGlueExpr:String,
  ?glueToHaxeExpr:String,
  ?glueToUeExpr:String,
  ?ueToGlueExpr:String,
}

enum TypeConvData {
  CBasic(info:ExtTypeInfo);
  /**
    Special types like TCHAR *, which have a special treatment by unreal.hx
   **/
  CSpecial(info:ExtTypeInfo);
  CUObject(type:UObjectType, flags:UObjectFlags, info:TypeInfo);
  CEnum(type:EnumType, info:TypeInfo);
  CStruct(type:StructType, info:TypeInfo, ?params:Array<TypeConv>);

  // TODO - bytearray
  // CPointer(of:TypeConv, ?size:Int);

  CLambda(args:Array<TypeConv>, ret:TypeConv);
  CMethodPointer(className:TypeInfo, args:Array<TypeConv>, ret:TypeConv);
  CTypeParam(name:String);
}

@:enum abstract SharedTS(Int) from Int {
  var ThreadSafe = 1;
}

@:enum abstract SharedKind(Int) from Int {
  var Weak = 1;
  var Ref = 2;
}

@:enum abstract UObjectType(Int) from Int {
  var OExternal = 1;
  var OInterface = 2;
  var OHaxe = 3;
  var OScriptHaxe = 4;
  var OSubclassOf = 5;
}

@:enum abstract UObjectFlags(Int) from Int {
  var ONone = 0;
  var OWeak = 1;
  var OAutoWeak = 3;

  inline private function t() {
    return this;
  }

  @:op(A|B) inline public function add(f:UObjectFlags):UObjectFlags {
    return this | f.t();
  }

  inline public function hasAll(flag:UObjectFlags):Bool {
    return this & flag.t() == flag.t();
  }

  inline public function hasAny(flag:UObjectFlags):Bool {
    return this & flag.t() != 0;
  }
}

@:enum abstract EnumType(Int) from Int {
  var EExternal = 1;
  var EExternalClass = 2;
  var EAbstract = 3;
  var EHaxe = 4;
  var EScriptHaxe = 5;
}

@:enum abstract StructType(Int) from Int {
  var SExternal = 1;
  var SHaxe = 2;
  var SScriptHaxe = 3;
}

private typedef InfoCtx = {
  ?original:TypeRef,
  accFlags:UObjectFlags,
  ?isSubclassOf:Bool,
  ?modf:Array<Modifier>
}

@:enum abstract Modifier(Int) from Int {
  var Ptr = 1;
  var Ref = 2;
  var Const = 3;

  public function toString() {
    return switch(this) {
    case Ptr:
      'PPtr';
    case Ref:
      'PRef';
    case Const:
      'Const';
    case _:
      '?($this)';
    }
  }
}
