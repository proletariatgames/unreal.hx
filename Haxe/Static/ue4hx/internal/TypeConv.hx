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
class TypeConv {
  public var data(default, null):TypeConvData;
  public var modifiers(default, null):Null<Array<Modifier>>;

  public var haxeType(default, null):TypeRef;
  public var ueType(default, null):TypeRef;
  public var glueType(default, null):TypeRef;
  public var haxeGlueType(default, null):TypeRef;
  private var originalSet(default, null):Bool;

  private function new(data, ?modifiers, ?original) {
    this.data = data;
    this.haxeType = original;
    this.modifiers = modifiers;
    consolidate();
  }

  inline public function withModifiers(modifiers, ?original) {
    return new TypeConv(this.data, modifiers, original == null ? (originalSet ? wrapType(haxeType, modifiers) : null) : original);
  }

  inline public function withData(data:TypeConvData, ?original) {
    return new TypeConv(data, this.modifiers, original == null ? (originalSet ? wrapType(haxeType, modifiers) : null) : original);
  }

  private static function wrapType(type:TypeRef, modifiers:Array<Modifier>) {
    // first take off all current modifiers
    while (true) {
      switch(type.name) {
      case 'PRef' | 'PPtr' | 'Const':
        type = type.params[0];
      case _:
        break;
      }
    }

    if (modifiers != null) {
      var i = modifiers.length;
      while (i --> 0) {
        switch(modifiers[i]) {
        case Const:
          type = new TypeRef(['unreal'], 'Const', [type]);
        case Ref:
          type = new TypeRef(['unreal'], 'PRef', [type]);
        case Ptr:
          type = new TypeRef(['unreal'], 'PPtr', [type]);
        case Marker:
        }
      }
    }
    return type;
  }

  inline public function hasModifier(modf:Modifier) {
    return this.modifiers != null && this.modifiers.has(modf);
  }

  public function isStructByVal() {
    switch(data) {
      case CStruct(_):
        if (modifiers == null)
          return true;
        for (modf in modifiers) {
          switch(modf) {
            case Ptr | Ref:
              return false;
            case Const:
            case Marker:
          }
        }
        return true;
      case _:
        return false;
    }
  }

  public function hasTypeParams():Bool {
    switch(this.data) {
      case CStruct(_,_,_,params):
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
    this.originalSet = this.haxeType != null;
    switch(this.data) {
      case CBasic(info) | CSpecial(info):
        if (this.haxeType == null) {
          this.haxeType = info.haxeType;
        }
        this.ueType = info.ueType;
        this.glueType = info.glueType != null ? info.glueType : info.ueType;
        this.haxeGlueType = info.haxeGlueType != null ? info.haxeGlueType : info.haxeType;
        if (hasModifier(Const) && info.ueType.withoutPointer().name == 'TCHAR') {
          this.ueType = new TypeRef(['cpp'],'RawPointer', [new TypeRef('TCHAR', Const)]);
        }
      case CUObject(type, flags, info):
        // OExternal, OInterface, OHaxe, OScriptHaxe
        if (flags.hasAny(OWeak)) {
          var name = flags.hasAll(OAutoWeak) ? 'TAutoWeakObjectPtr' : 'TWeakObjectPtr';
          this.ueType = new TypeRef(name, [info.ueType]);
          if (this.haxeType == null) {
            this.haxeType = new TypeRef(['unreal'],name,[info.haxeType]);
          }
        } else if (flags.hasAny(OSubclassOf)) {
          var name = 'TSubclassOf';
          var ueType = if (type == OInterface) {
            info.ueType.with('U' + info.ueType.name.substr(1));
          } else {
            info.ueType;
          }
          this.ueType = new TypeRef(name, [ueType]);
          if (this.haxeType == null) {
            this.haxeType = new TypeRef(['unreal'],name,[info.haxeType]);
          }
        }

        if (this.haxeType == null) {
          this.haxeType = info.haxeType;
        }
        if (this.ueType == null) {
          this.ueType = new TypeRef(['cpp'], 'RawPointer', [info.ueType]);
        }
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
      case CStruct(type, flags, info, params):
        // SExternal, SHaxe, SCriptHaxe
        if (this.haxeType == null) {
          if (params != null && params.length > 0) {
            this.haxeType = info.haxeType.withParams([ for (param in params) param.haxeType ]);
          } else {
            this.haxeType = info.haxeType;
          }
        }
        if (params != null && params.length > 0) {
          var ueParams = null; // [ for (param in params) param.ueType ];
          if (flags.hasAny(STypeName)) {
            ueParams = [];
            for (param in params) {
              switch(param.data) {
                case CUObject(_,flags,info) if (!flags.hasAny(OWeak | OSubclassOf)):
                  ueParams.push(info.ueType);
                case _:
                  ueParams.push(param.ueType);
              }
            }
          } else {
            ueParams = [ for (param in params) param.ueType ];
          }
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
            case 'TSharedPtr' | 'TSharedRef' | 'TWeakPtr':
              ueParams.push(new TypeRef('ESPMode::Fast'));
              info.ueType.name;
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
        var binderTypeRef = new TypeRef(['uhx'], binderClass, binderTypeParams.map(function(tp) return tp.ueType));
        if (this.haxeType == null) {
          var args = [ for (arg in fnArgs) arg.haxeType ];
          args.push(fnRet.haxeType);
          this.haxeType = new TypeRef(['haxe'],'Function', 'Constraints', args);
        }
        this.ueType = binderTypeRef;
        this.haxeGlueType = this.glueType = uintPtr;
      case CMethodPointer(className, fnArgs, fnRet):
        this.ueType = uintPtr;
        this.haxeType = uintPtr;
        this.haxeGlueType = this.glueType = uintPtr;
      case CTypeParam(name, kind):
        this.haxeType = this.ueType = new TypeRef(name);
        this.glueType = this.haxeGlueType = uintPtr;
        var extra = switch(kind) {
          case PWeak:
            'TWeakObjectPtr';
          case PAutoWeak:
            'TAutoWeakObjectPtr';
          case PSubclassOf:
            'TSubclassOf';
          case PNone:
            null;
        };
        if (extra != null) {
          this.haxeType = new TypeRef(['unreal'], extra, [this.haxeType]);
          this.ueType = new TypeRef(extra, [this.ueType]);
        }
    }

    var modf = this.modifiers;
    if (modf != null) {
      if (modf.has(Ref) && this.data.match(CUObject(_,_,_))) {
        this.ueType = this.ueType.withoutPointer();
      }

      var hadMarker = false;
      var i = modf.length;
      while (i --> 0) {
        switch(modf[i]) {
        case Const:
          if (!originalSet) {
            this.haxeType = new TypeRef(['unreal'], 'Const', [this.haxeType]);
          }
          if (this.data.match(CUObject(_)) && !hadMarker) {
            this.ueType = this.ueType.leafWithConst(true);
          } else {
            this.ueType = this.ueType.withConst(true);
          }
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
        case Marker:
          hadMarker = true;
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
      set.add('<hxcpp.h>');
    case CStruct(type,_,info,params):
      set.add('VariantPtr.h');

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
      if (flags.hasAny(OSubclassOf)) {
        set.add("UObject/ObjectBase.h");
      }

      if (forwardDecls != null) {
        var decl = info.ueType.getForwardDecl();
        forwardDecls[decl] = decl;
        cppSet.append(info.glueCppIncludes);
      } else {
        set.append(info.glueCppIncludes);
        if (type == OHaxe || type == OScriptHaxe) {
          set.add('${info.ueType.withoutPrefix().name}.h');
        }
      }
    case CEnum(type, info):
      if (type == EHaxe || type == EScriptHaxe) {
        set.add('${ueType.withoutPrefix().name}.h');
      }
      set.append(info.glueCppIncludes);
    case CStruct(type,flags,info,params):
      set.add('uhx/Wrapper.h');
      set.append(info.glueCppIncludes);

      // // we need to know if it was declared as a class or a struct for this to work
      // if (inPointer && forwardDecls != null) {
      //   var decl = info.ueType.getForwardDecl();
      //   forwardDecls[decl] = decl;
      //   cppSet.append(info.glueCppIncludes);
      // } else {
      //   set.append(info.glueCppIncludes);
      // }

      if (params != null) {
        var ptr = inPointer;
        for (param in params) {
          param.recurseUeIncludes(set, forwardDecls, cppSet, ptr);
        }

        var glue = info.haxeType.getGlueHelperType();
        set.add(glue.pack.join('/') + (glue.pack.length == 0 ? '' : '/') + glue.name + '_UE.h');
      }

    case CLambda(args, ret):
      set.add('uhx/LambdaBinding.h');
      for (arg in args) {
        arg.recurseUeIncludes(set, forwardDecls, cppSet, true /* function arguments can be forward declared */);
      }
      ret.recurseUeIncludes(set, forwardDecls, cppSet, true);
    case CMethodPointer(className, args, ret):
      set.add('uhx/LambdaBinding.h');
      set.append(className.glueCppIncludes);
      for (arg in args) {
        arg.recurseUeIncludes(set, forwardDecls, cppSet, true /* function arguments can be forward declared */);
      }
      ret.recurseUeIncludes(set, forwardDecls, cppSet, true);
    case CTypeParam(name, kind):
      switch(kind) {
        case PWeak | PAutoWeak:
          set.add("UObject/WeakObjectPtrTemplates.h");
        case PSubclassOf:
          set.add("UObject/ObjectBase.h");
        case PNone:
      }
      if (forwardDecls == null) {
        set.add('uhx/TypeParamGlue.h');
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
          expr = 'cast $expr';
        }
        'unreal.helpers.HaxeHelpers.getUObjectWrapped($expr)';

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

      case CStruct(type, flags, info, params):
        // '($expr : unreal.VariantPtr)';
        expr;

      case CLambda(args,ret):
        'unreal.helpers.HaxeHelpers.dynamicToPointer( $expr )';
      case CMethodPointer(cname, args, ret):
        expr;
      case CTypeParam(name, _):
        'unreal.helpers.HaxeHelpers.variantToPointer( $expr )';
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
          'Type.createEnumIndex(Type.resolveEnum("${this.haxeType.getClassPath(true)}"), $expr)';
        else
          'ue4hx.internal.UEnumHelper.createEnumIndex(${this.haxeType.getClassPath(false)}, $expr)';
      case CEnum(type, info):
        var typeRef = info.haxeType,
            conv = typeRef.with(typeRef.name + '_EnumConv', typeRef.moduleName != null ? typeRef.moduleName : typeRef.name);
        '${conv.getClassPath()}.wrap($expr)';

      case CStruct(type, flags, info, params):
        '( @:privateAccess ${info.haxeType.getClassPath()}.fromPointer( $expr ) : $haxeType )';

      case CLambda(args,ret):
        '( unreal.helpers.HaxeHelpers.pointerToDynamic( $expr ) : $haxeType )';
      case CMethodPointer(cname, args, ret):
        expr;
      case CTypeParam(name, _):
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
        var ret = '( (${info.ueType.getCppType()} *) $expr )';
        if (type == OInterface && !flags.hasAny(OSubclassOf)) {
          ret = 'Cast<${info.ueType.getCppType()}>( (UObject *) $expr )';
        } else if (flags.hasAny(OSubclassOf)) {
          ret = '( (${ueType.withoutPointer(true).getCppType()}) (UClass *) $expr )';
        }
        if (flags.hasAny(OWeak | OAutoWeak)) {
          ret = '( (${ueType.withoutPointer(true).getCppType()}) $ret )';
        } else if (hasModifier(Ref)) {
          ret = '*$ret';
        }
        ret;

      // EExternal, EAbstract, EHaxe, EScriptHaxe
      case CEnum(type, info):
        '( (${ueType.getCppType()}) $expr )';

      case CStruct(type, flags, info, params):
        var ret = null;
        if (params != null && params.length > 0) {
          ret = '::uhx::TemplateHelper< ${this.ueType.withoutPointer(true).getCppType(true)} >::getPointer($expr)';
        } else {
          ret = '::uhx::StructHelper< ${this.ueType.withoutPointer(true).getCppType(true)} >::getPointer($expr)';
        }
        if (this.modifiers == null || !this.modifiers.has(Ptr)) {
          ret = '*$ret';
        }
        ret;

      case CLambda(args,ret):
        ueType.getCppType() + '($expr)';
      case CMethodPointer(className, fnArgs, fnRet):
        var cppMethodType = new HelperBuf();
        cppMethodType << '::uhx::MemberFunctionTranslator<${className.ueType.getCppType()}, ${fnRet.ueType.getCppType()}';
        if (fnArgs.length > 0) cppMethodType << ', ';
        cppMethodType.mapJoin(fnArgs, function(arg) return arg.ueType.getCppType().toString());
        cppMethodType << '>::Translator';
        '(($cppMethodType) $expr)()';
      case CTypeParam(name, kind):
        var cppType = (hasModifier(Ref) ? ueType.withoutPointer(true).withConst(false).getCppType() : ueType.getCppType()) + '';
        if (this.hasModifier(Ref)) {
          '::uhx::TypeParamGluePtr<${cppType}>::haxeToUePtr( $expr )';
        } else {
          '::uhx::TypeParamGlue<${cppType}>::haxeToUe( $expr )';
        }
    }
  }

  public function ueToGlueCtor(ctorArgs:String, argsTypes:Array<TypeConv>, ctx:ConvCtx) {
    if (hasModifier(Ref) || hasModifier(Ptr) || hasAnyConst()) {
      throw new Error('Invalid constructor return type: $haxeType', ctx.pos);
    }
    return switch(this.data) {
      case CStruct(type, flags, info, params):
        var helper = if (params != null && params.length > 0) {
          '::uhx::TemplateHelper<${this.ueType.withoutPointer(true).withConst(false).getCppType()}>';
        } else {
          '::uhx::StructHelper<${this.ueType.withoutPointer(true).withConst(false).getCppType()}>';
        };
        var templ = '<' + [ for (arg in argsTypes) arg.ueType.getCppType() ].join(',') + '>';
        return '$helper::create$templ($ctorArgs)';
      case _:
        throw new Error('Invalid constructor return type: $haxeType. Expected struct', ctx.pos);
    }
  }

  public function ueToGlue(expr:String, ctx:ConvCtx):String {
    return ueToGlueRecurse(expr, ctx);
  }

  private function ueToGlueRecurse(expr:String, ctx:ConvCtx):String {
    var originalExpr = expr;
    if ((hasModifier(Ref) || hasModifier(Ptr)) && hasAnyConst()) {
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
        var ret = originalExpr;
        if (flags.hasAny(OWeak | OAutoWeak)) {
          ret = '( $ret.Get() )';
        }

        var const = this.hasModifier(Const) ? 'const' : '';
        if (type == OInterface) {
          ret = 'const_cast<UObject *>(Cast<$const UObject>( $ret ))';
        } else if (flags.hasAny(OSubclassOf)) {
          ret = 'const_cast<UClass *>( ($const UClass *) $ret )';
        } else {
          if (const != '') {
            ret = 'const_cast<UObject *>( (const UObject *) $ret )';
          }
        }

        '( (unreal::UIntPtr) ($ret) )';

      // EExternal, EAbstract, EHaxe, EScriptHaxe
      case CEnum(type, info):
        '( (int) (${ueType.getCppType()}) $expr )';

      case CStruct(type, flags, info, params):
        if (params != null && params.length > 0) {
          var helper = '::uhx::TemplateHelper<${this.ueType.withoutPointer(true).withConst(false).getCppType()}>';
          if (hasModifier(Ref)) {
            '$helper::fromPointer( &($expr) )';
          } else if (hasModifier(Ptr)) {
            '$helper::fromPointer( ($expr) )';
          } else {
            '$helper::fromStruct( ($expr) )';
          }
        } else {
          if (hasModifier(Ref)) {
            'unreal::VariantPtr( (void *) &($expr) )';
          } else if (hasModifier(Ptr)) {
            'unreal::VariantPtr( (void *) ($expr) )';
          } else {
            '::uhx::StructHelper<${this.ueType.withoutPointer(true).withConst(false).getCppType()}>::fromStruct($expr)';
          }
        }

      case CLambda(args,ret):
        expr;
      case CMethodPointer(cname, args, ret):
        expr;
      case CTypeParam(name,kind):
        var cppType = (hasModifier(Ref) ? ueType.withoutPointer(true).getCppType() : ueType.getCppType(true)) + '';
        if (this.hasModifier(Ref)) {
          '::uhx::TypeParamGluePtr<${cppType}>::ueToHaxeRef( $expr )';
        } else {
          '::uhx::TypeParamGlue<${cppType}>::ueToHaxe( $expr )';
        }
    }
  }

  public function hasAnyConst():Bool {
    if (hasModifier(Const)) {
      return true;
    }
    switch(data) {
    case CStruct(_,_,_,params):
      if (params != null) {
        for (p in params) {
          if (p.hasAnyConst()) {
            return true;
          }
        }
      }
    case CLambda(args, ret) | CMethodPointer(_, args, ret):
      for (arg in args) if (arg.hasAnyConst()) return true;
      if (ret.hasAnyConst()) return true;
    case _:
    }
    return false;
  }

  inline public static function get(type:Type, pos:Position, ?inTypeParam:Bool=false):TypeConv {
    return getInfo(type, pos, { accFlags:ONone }, inTypeParam);
  }

  private static function getInfo(type:Type, pos:Position, ctx:InfoCtx, inTypeParam:Bool):TypeConv {
    var cache = Globals.cur.typeConvCache;
    var o = type;
    while(type != null) {
      switch(type) {
      case TInst(iref, tl):
        var name = tl.length == 0 ? iref.toString() : null;
        if (name != null) {
          var ret = cache[name];
          if (ret != null && ctx.accFlags == 0) {
            if (ctx.modf == null && ctx.original == null) {
              return ret;
            } else {
              return new TypeConv(ret.data, ctx.modf, ctx.original);
            }
          }
        }
        var it = iref.get();
        var ret = null;
        var info = getTypeInfo(it, pos);
        var structFlags = (it.meta.has(':typeName') ? STypeName : SNone);
        if (it.kind.match(KTypeParameter(_))) {
          var kind = if(ctx.accFlags.hasAny(OSubclassOf)) {
            PSubclassOf;
          } else if(ctx.accFlags.hasAll(OAutoWeak)) {
            PAutoWeak;
          } else if (ctx.accFlags.hasAny(OWeak)) {
            PWeak;
          } else {
            PNone;
          }
          name = null; // don't cache
          ctx.original = null;
          ret = CTypeParam(it.name, kind);
        } else if (typeIsUObject(type)) {
          if (ctx.modf != null && ctx.modf.has(Ptr)) {
            Context.warning('Unreal Glue: PPtr of a UObject is not supported', pos);
          }
          if (!it.meta.has(':uextern')) {
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
          ret = CStruct(SExternal, structFlags, info, tl.length > 0 ? [for (param in tl) get(param, pos, inTypeParam)] : null);
        } else if (it.meta.has(':ustruct')) {
          if (it.meta.has(':uscript') || Globals.cur.scriptModules.exists(it.module)) {
            ret = CStruct(SScriptHaxe, structFlags, info, tl.length > 0 ? [for (param in tl) get(param, pos, inTypeParam)] : null);
          } else {
            ret = CStruct(SHaxe, structFlags, info, tl.length > 0 ? [for (param in tl) get(param, pos, inTypeParam)] : null);
          }
        } else if (it.kind.match(KAbstractImpl(_))) {
          var impl = switch(it.kind) {
            case KAbstractImpl(a):
              a;
            case _:
              throw 'assert';
          };
          var args = [ for (p in impl.get().params) p.t ];
          type = TAbstract(impl,args);
        } else {
          trace(haxe.CallStack.toString(haxe.CallStack.callStack()));
          throw new Error('Unreal Glue: Type $o is not supported', pos);
        }

        if (ret != null) {
          if (ctx.modf != null) {
            switch(ret) {
            case CUObject(type, flags, info):
              var markerIdx = ctx.modf.indexOf(Marker);
              if (markerIdx >= 0 && ctx.modf.indexOf(Ref) > markerIdx) {
                Context.warning('Unreal Glue: PRef<> ignored because it is inside a TSubclassOf / TWeakObjectPtr', pos);
              } else if (markerIdx < 0 && ctx.modf.has(Ptr) && !inTypeParam) {
                // TODO add Ptr suggestion once it's ready
                throw new Error('Unreal Glue: PPtr of UObjects is not supported', pos);
              }
            case _:
            }
          }
          var ret = new TypeConv(ret, ctx.modf, ctx.original);
          if (tl.length == 0 && name != null && ctx.modf == null && ctx.original == null && ctx.accFlags == 0) {
            cache[name] = ret;
          }
          return ret;
        }

      case TEnum(eref, tl):
        if (ctx.modf != null) {
          Context.warning('Unreal Glue: Const, PPtr or PRef is not supported on enums', pos);
        }
        var name = eref.toString();
        var ret = cache[name];
        if (ret != null) {
          if (ctx.modf == null && ctx.original == null) {
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
        if (name != null && ctx.modf == null && ctx.original == null && ctx.accFlags == 0) {
          cache[name] = ret;
        }
        return ret;

      case TAbstract(aref, tl):
        var name = aref.toString();
        if (tl.length == 0) {
          var ret = cache[name];
          if (ret != null) {
            if (ctx.modf == null && ctx.original == null) {
              return ret;
            } else {
              return new TypeConv(ret.data, ctx.modf, ctx.original);
            }
          }
        }

        var a = aref.get(),
            ret = null,
            info = getTypeInfo(a, pos);
        var structFlags = (a.meta.has(':typeName') ? STypeName : SNone);
        var hasUextern = a.meta.has(':uextern');
        if (hasUextern && a.meta.has(':enum')) {
          if (ctx.modf != null) {
            Context.warning('Unreal Glue: Const, PPtr or PRef is not supported on enums', pos);
          }
          ret = CEnum(EAbstract, info);
        } else if (hasUextern) {
          ret = CStruct(SExternal, structFlags, info, tl.length > 0 ? [for (param in tl) get(param, pos, inTypeParam)] : null);
        } else if (a.meta.has(':ustruct')) {
          if (a.meta.has(':uscript') || Globals.cur.scriptModules.exists(a.module)) {
            ret = CStruct(SScriptHaxe, structFlags, info, tl.length > 0 ? [for (param in tl) get(param, pos, inTypeParam)] : null);
          } else {
            ret = CStruct(SHaxe, structFlags, info, tl.length > 0 ? [for (param in tl) get(param, pos, inTypeParam)] : null);
          }
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
            type = a.type.applyTypeParameters(a.params, tl);
          }
        }

        if (ret != null) {
          var ret = new TypeConv(ret, ctx.modf, ctx.original);
          if (tl.length != 0 && name != null && ctx.modf == null && ctx.original == null && ctx.accFlags == 0) {
            cache[name] = ret;
          }
          return ret;
        }

      case TType(tref, tl):
        var name = tref.toString();
        var ret = cache[name];
        if (ret != null) {
          if (ctx.modf == null && ctx.original == null) {
            return ret;
          } else {
            return new TypeConv(ret.data, ctx.modf, ctx.original);
          }
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
              if (!inTypeParam) {
                throw new Error('Unreal Glue: A type cannot be defined with two PRefs or a PRef and a PPtr', pos);
              }
            } else {
              // Const<PRef<>> should actually be PRef<Const<>>
              if (ctx.modf[ctx.modf.length-1] == Const) {
                ctx.modf.insert(ctx.modf.length-1, Ref);
              } else {
                ctx.modf.push(Ref);
              }
            }
          case 'unreal.PPtr':
            if (ctx.modf == null) ctx.modf = [];
            if (ctx.modf.has(Ref) || ctx.modf.has(Ptr)) {
              if (!inTypeParam) {
                throw new Error('Unreal Glue: A type cannot be defined with two PRefs or a PRef and a PPtr', pos);
              }
            } else {
              ctx.modf.push(Ptr);
            }
          case 'unreal.TWeakObjectPtr':
            if (ctx.accFlags.hasAny(OAutoWeak | OSubclassOf)) {
              Context.warning('Unreal Type: Illogical type (with multiple weak / subclassOf flags', pos);
            }
            ctx.accFlags |= OWeak;
            if (ctx.modf == null) ctx.modf = [];
            ctx.modf.push(Marker);
          case 'unreal.TAutoWeakObjectPtr':
            if (ctx.accFlags.hasAny(OAutoWeak | OSubclassOf)) {
              Context.warning('Unreal Type: Illogical type (with multiple weak / subclassOf flags', pos);
            }
            ctx.accFlags |= OAutoWeak;
            if (ctx.modf == null) ctx.modf = [];
            ctx.modf.push(Marker);
          case 'unreal.TSubclassOf':
            if (ctx.accFlags.hasAny(OWeak | OSubclassOf)) {
              Context.warning('Unreal Type: Illogical type (with multiple weak / subclassOf flags', pos);
            }
            ctx.accFlags |= OSubclassOf;
            type = tl[0];
            if (ctx.modf == null) ctx.modf = [];
            ctx.modf.push(Marker);
            continue;
          case _:
            throw new Error('Unreal Type: Invalid typedef: $name', pos);
          }
        }

        if (ret != null) {
          var ret = new TypeConv(ret, ctx.modf, ctx.original);
          return ret;
        }
        type = t.type.applyTypeParameters(t.params, tl);

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
      case TMono(mono):
        type = mono.get();

      case t:
        trace(haxe.CallStack.toString(haxe.CallStack.callStack()));
        throw new Error('Unreal Type: Invalid type $t', pos);
      }
    }
    throw new Error('Unreal Type: Invalid type $type', pos);
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

        glueHeaderIncludes:IncludeSet.fromUniqueArray(['<hxcpp.h>']),
      },
      {
        ueType: new TypeRef('uint64'),
        haxeType: new TypeRef(['unreal'],'FakeUInt64'),
        glueType: new TypeRef(['cpp'], 'Int64'),

        haxeToGlueExpr: '(cast (%) : cpp.Int64)',
        glueToHaxeExpr: '(cast (%) : unreal.Int64)',
        glueToUeExpr: '((uint64) (%))',

        glueHeaderIncludes:IncludeSet.fromUniqueArray(['<hxcpp.h>']),
      },
      {
        ueType: new TypeRef('int64'),
        haxeType: new TypeRef(['unreal'],'Int64'),
        glueType: new TypeRef(['cpp'], 'Int64'),

        haxeToGlueExpr: '(cast (%) : cpp.Int64)',
        glueToHaxeExpr: '(cast (%) : unreal.Int64)',
        glueToUeExpr: '((int64) (%))',

        glueHeaderIncludes:IncludeSet.fromUniqueArray(['<hxcpp.h>']),
      },
      {
        ueType: new TypeRef(['cpp'],'RawPointer', [new TypeRef('void')]),
        glueType: new TypeRef(['unreal'],'UIntPtr'),
        haxeType: new TypeRef(['unreal'],'AnyPtr'),

        ueToGlueExpr: '( (unreal::UIntPtr) (%) )',
        glueToUeExpr: '( (void *) (%) )',

        glueHeaderIncludes:IncludeSet.fromUniqueArray(['<IntPtr.h>']),
      },
      {
        ueType: new TypeRef(['cpp'],'RawPointer', [new TypeRef('void')], Const),
        glueType: new TypeRef(['unreal'],'UIntPtr'),
        haxeType: new TypeRef(['unreal'],'ConstAnyPtr'),

        ueToGlueExpr: '( (unreal::UIntPtr) (%) )',
        glueToUeExpr: '( (void *) (%) )',

        glueHeaderIncludes:IncludeSet.fromUniqueArray(['<IntPtr.h>']),
      },
      {
        ueType: new TypeRef(['unreal'],'UIntPtr'),
        haxeType: new TypeRef(['unreal'],'UIntPtr'),

        glueHeaderIncludes:IncludeSet.fromUniqueArray(['<IntPtr.h>']),
      },
      {
        ueType: new TypeRef(['unreal'],'IntPtr'),
        haxeType: new TypeRef(['unreal'],'IntPtr'),

        glueHeaderIncludes:IncludeSet.fromUniqueArray(['<IntPtr.h>']),
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
        haxeGlueType: uintPtr,
        glueType: uintPtr,

        glueCppIncludes:IncludeSet.fromUniqueArray(['Engine.h', '<unreal/helpers/HxcppRuntime.h>']),
        glueHeaderIncludes:IncludeSet.fromUniqueArray(['<hxcpp.h>']),

        ueToGlueExpr:'::unreal::helpers::HxcppRuntime::constCharToString(TCHAR_TO_UTF8( (const char *) (%) ))',
        glueToUeExpr:'UTF8_TO_TCHAR(::unreal::helpers::HxcppRuntime::stringToConstChar((unreal::UIntPtr) (%)))',
        haxeToGlueExpr:'unreal.helpers.HaxeHelpers.dynamicToPointer( % )',
        glueToHaxeExpr:'(unreal.helpers.HaxeHelpers.pointerToDynamic( % ) : String)',
      },
      { // TODO - use Pointer instead
        ueType: byteArray,
        haxeType: new TypeRef(['unreal'],'ByteArray'),
        glueType: byteArray,
        haxeGlueType: byteArray,

        haxeToGlueExpr: '(%).ptr.get_raw()',
        glueToHaxeExpr: 'new unreal.ByteArray(cpp.Pointer.fromRaw(%), -1)',

        glueHeaderIncludes:IncludeSet.fromUniqueArray(['<hxcpp.h>']),
      },
    ];
    for (info in infos) {
      to[info.haxeType.toString()] = new TypeConv(CSpecial(info));
    }
  }

  private static function getTypeInfo(baseType:BaseType, ?args:Array<Type>, pos:Position):TypeInfo {
    var haxeType = TypeRef.fromBaseType(baseType, args, pos);
#if bake_externs
    if (baseType.meta.has(':bake_externs_name_hack')) {
      haxeType = TypeRef.parse( getMetaString(baseType.meta, ':bake_externs_name_hack') );
    }
#end
    var ueName = getMetaString(baseType.meta, ':uname');
    if (ueName == null) {
      ueName = baseType.name;
    }
    var ueType = TypeRef.parseClassName(ueName);
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
  CStruct(type:StructType, flags:StructFlags, info:TypeInfo, ?params:Array<TypeConv>);

  // TODO - bytearray
  // CPointer(of:TypeConv, ?size:Int);

  CLambda(args:Array<TypeConv>, ret:TypeConv);
  CMethodPointer(className:TypeInfo, args:Array<TypeConv>, ret:TypeConv);
  CTypeParam(name:String, kind:TypeParamKind);
}

@:enum abstract UObjectType(Int) from Int {
  var OExternal = 1;
  var OInterface = 2;
  var OHaxe = 3;
  var OScriptHaxe = 4;
}

@:enum abstract UObjectFlags(Int) from Int {
  var ONone = 0;
  var OWeak = 1;
  var OAutoWeak = 3;
  var OSubclassOf = 4;

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

@:enum abstract TypeParamKind(Int) from Int {
  var PNone = 0;
  var PSubclassOf = 1;
  var PWeak = 2;
  var PAutoWeak = 3;
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

@:enum abstract StructFlags(Int) from Int {
  var SNone = 0;
  // @:typeName generic types
  var STypeName = 1;

  inline private function t() {
    return this;
  }

  @:op(A|B) inline public function add(f:StructFlags):StructFlags {
    return this | f.t();
  }

  inline public function hasAll(flag:StructFlags):Bool {
    return this & flag.t() == flag.t();
  }

  inline public function hasAny(flag:StructFlags):Bool {
    return this & flag.t() != 0;
  }
}

private typedef InfoCtx = {
  ?original:TypeRef,
  accFlags:UObjectFlags,
  ?modf:Array<Modifier>
}

@:enum abstract Modifier(Int) from Int {
  var Ptr = 1;
  var Ref = 2;
  var Const = 3;

  /**
    Just a placeholder to separate some cases like
    Const<TWeakObjectPtr<>> and TWeakObjectPtr<Const<>>
   **/
  var Marker = 4;

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
