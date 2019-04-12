package uhx.compiletime.types;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import uhx.compiletime.tools.HelperBuf;
import uhx.compiletime.tools.IncludeSet;
import uhx.meta.MetaDef;

using haxe.macro.TypeTools;
using Lambda;
using StringTools;

/**
  Represents a Haxe type whose glue code will be generated. Contains all the information
  on how to generate the glue code for the type

  @see TypeConvInfo
 **/
class TypeConv {
#if bake_externs
  private static var typeHasLoaded:Map<String, Bool> = new Map();
  public static var onTypeLoad:String->Void = null;
#end
  public var data(default, null):TypeConvData;
  public var modifiers(default, null):Null<Array<Modifier>>;

  public var haxeType(default, null):TypeRef;
  public var ueType(default, null):TypeRef;
  public var glueType(default, null):TypeRef;
  public var haxeGlueType(default, null):TypeRef;
  public var tparamName(default, null):Null<String>;
  private var originalSet(default, null):Bool;

  private function new(data, ?modifiers, ?original) {
    this.data = data;
    this.haxeType = original;
    this.modifiers = modifiers;
    consolidate();
  }

  public static function changeCppName(name:String)
  {
    switch(name)
    {
      case 'asm' | 'else' | 'new' | 'this' |
      'auto' | 'enum' | 'operator' | 'throw' |
      'bool' | 'explicit' | 'private' | 'true' |
      'break' | 'export' | 'protected' | 'try' |
      'case' | 'extern' | 'public' | 'typedef' |
      'catch' | 'false' | 'register' | 'typeid' |
      'char' | 'float' | 'reinterpret_cast' | 'typename' |
      'class' | 'for' | 'return' | 'union' |
      'const' | 'friend' | 'short' | 'unsigned' |
      'const_cast' | 'goto' | 'signed' | 'using' |
      'continue' | 'if' | 'sizeof' | 'virtual' |
      'default' | 'inline' | 'static' | 'void' |
      'delete' | 'int' | 'static_cast' | 'volatile' |
      'do' | 'long' | 'struct' | 'wchar_t' |
      'double' | 'mutable' | 'switch' | 'while' |
      'dynamic_cast' | 'namespace' | 'template':
        return 'uhx_' + name;
      case _:
        return name;
    }
  }

  public function equivalentTo(other:TypeConv) {
    if (this == other) {
      return true;
    }

    if ((this.modifiers == null) != (other.modifiers == null)) {
      return false;
    }
    if (this.modifiers != null) {
      for (modf in this.modifiers) {
        switch(modf) {
          case Ptr:
            if (!other.modifiers.has(Ptr)) {
              return false;
            }
          case Ref:
            if (!other.modifiers.has(Ref)) {
              return false;
            }
          case Const:
            if (!other.modifiers.has(Const)) {
              return false;
            }
          case _:
        }
      }
    }

    switch [this.data, other.data] {
    case [CBasic(infoT), CBasic(infoO)]:
      return infoT.ueType.name == infoO.ueType.name;
    case [CSpecial(infoT), CSpecial(infoO)]:
      return infoT.haxeType.toString() == infoO.haxeType.toString();
    case [CUObject(_, f1, i1), CUObject(_, f2, i2)]:
      if (f1 != f2) {
        return false;
      }
      return i1.haxeType.toString() == i2.haxeType.toString();
    case [CEnum(_, _, i1), CEnum(_, _, i2)]:
      return i1.haxeType.toString() == i2.haxeType.toString();
    case [CStruct(_, f1, i1, p1), CStruct(_, f2, i2, p2)]:
      if (f1 != f2) {
        return false;
      }
      if (p1 != null) {
        if (p2 == null) {
          return false;
        }
        if (p1.length != p2.length) {
          return false;
        }
        for (i in 0...p1.length) {
          if (!p1[i].equivalentTo(p2[i])) {
            return false;
          }
        }
      }
      return i1.ueType.withoutPointer(true).toString() == i2.ueType.withoutPointer(true).toString();
    case [CPtr(t1, r1), CPtr(t2,r2)]:
      if (r1 != r2) {
        return false;
      }
      return t1.equivalentTo(t2);
    case [CLambda(a1, r1), CLambda(a2,r2)]:
      if (a1.length != a2.length) {
        return false;
      }
      for (i in 0...a1.length) {
        if (!a1[i].equivalentTo(a2[i])) {
          return false;
        }
      }
      return r1.equivalentTo(r2);
    case [CMethodPointer(c1, a1, r1), CMethodPointer(c2, a2, r2)]:
      if (c1 != c2) {
        return false;
      }
      if (a1.length != a2.length) {
        return false;
      }
      for (i in 0...a1.length) {
        if (!a1[i].equivalentTo(a2[i])) {
          return false;
        }
      }
      return r1.equivalentTo(r2);
    case [CTypeParam(_,k1), CTypeParam(_,k2)]:
      return k1 == k2;
    case _:
      return false;
    }
  }

  inline private static function checkTypeLoaded(name:String) {
#if bake_externs
    if (onTypeLoad != null && !typeHasLoaded.exists(name)) {
      typeHasLoaded[name] = true;
      onTypeLoad(name);
    }
#end
  }

#if bake_externs
  inline public static function setTypeLoaded(name:String) {
    typeHasLoaded[name] = true;
  }
#end

  private static function dataToShortString(data:TypeConvData):String
  {
    switch(data)
    {
    case CBasic(info):
      var ret = switch(info.ueType.name) {
        case 'bool':
          'B';
        case 'int8':
          'I8';
        case 'uint8':
          'U8';
        case 'int16':
          'I16';
        case 'uint16':
          'U16';
        case 'int32':
          'I32';
        case 'uint32':
          'U32';
        case 'int64':
          'I64';
        case 'uint64':
          'U64';
        case 'float':
          'F';
        case 'double':
          'FD';
        case 'void':
          'V';
        case _:
          'B' + info.ueType.name;
      }
      if (ret == null)
      {
        ret = 'B' + info.ueType.name;
      }
      return ret;
    case CSpecial(info):
      return 'S' + info.haxeType.name;
    case CUObject(_, flags, info):
      var ret = 'U';
      if (flags.hasAny(OWeak))
      {
        ret += 'w';
      }
      if (flags.hasAny(OAutoWeak))
      {
        ret += 'a';
      }
      if (flags.hasAny(OSubclassOf))
      {
        ret += 's';
      }
      if (flags.hasAny(OScriptInterface))
      {
        ret += 'i';
      }
      return ret + info.ueType.name;
    case CEnum(_, flags, info):
      if (flags.hasAny(EEnumAsByte))
      {
        return 'BE' + info.ueType.name;
      }
      return 'E' + info.ueType.name;
    case CStruct(_, _, info, params):
      var p = params == null ? '' : ('_' + params.map(function(p) return p.toShortString()).join('a'));
      return 'S' + info.ueType.name + p;
    case CPtr(of, isRef):
      return (isRef ? 'R' : 'P') + of.toShortString();
    case CLambda(args, ret):
      return 'L' + [for (arg in args) arg.toShortString()].join('_') + 'r' + ret.toShortString();
    case CMethodPointer(cls, args, ret):
      return 'M' + cls + [for (arg in args) arg.toShortString()].join('_') + 'r' + ret.toShortString();
    case CTypeParam(name,kind):
      var ret = 'T';
      switch(kind)
      {
        case PSubclassOf:
          ret += 's';
        case PWeak:
          ret += 'w';
        case PAutoWeak:
          ret += 'a';
        case PNone:
      }
      return ret + name;
    }
  }

  public function toShortString():String
  {
    var ret = dataToShortString(this.data).replace('__', '_');
    if (this.modifiers != null)
    {
      for (modf in this.modifiers)
      {
        switch(modf)
        {
          case Ptr:
            ret = 'p' + ret;
          case Ref:
            ret = 'r' + ret;
          case Const:
            ret = 'c' + ret;
          case Marker:
            ret = 'm' + ret;
        }
      }
    }
    return ret;
  }

  public function toUPropertyDef():Null<UPropertyDef> {
    var name:Null<String> = null,
        typeFlags:TypeFlags = 0,
        defParams:Array<UPropertyDef> = null;

    var type:Null<MetaType> = switch(this.data) {
      case CBasic(info):
        switch(info.ueType.name) {
          case 'bool':
            TBool;
          case 'int8':
            TI8;
          case 'uint8':
            TU8;
          case 'int16':
            TI16;
          case 'uint16':
            TU16;
          case 'int32':
            TI32;
          case 'uint32':
            TU32;
          case 'int64':
            TI64;
          case 'uint64':
            TU64;

          case 'float':
            F32;
          case 'double':
            F64;
          case _:
            null;
        }
      case CSpecial(_):
        null;
      case CUObject(type, flags, info):
        name = info.ueType.name;
        if (type != OInterface) {
          if (flags.hasAny(OWeak)) {
            typeFlags |= FWeak;
          }
          if (flags.hasAny(OAutoWeak)) {
            typeFlags |= FAutoWeak;
          }
          if (flags.hasAny(OSubclassOf)) {
            typeFlags |= FSubclassOf;
          }
        }
        switch(type) {
        case OInterface:
          TInterface;
        case OHaxe:
          typeFlags |= FHaxeCreated;
          TUObject;
        case OScriptHaxe:
          typeFlags |= FScriptCreated;
          TUObject;
        case _:
          TUObject;
        }
      case CEnum(type, flags, info) if (flags.hasAll(EUEnum)):
        if ((type == EExternal || type == EAbstract) && info.ueType.pack.length > 0) {
          name = info.ueType.pack[info.ueType.pack.length-1];
        } else {
          name = info.ueType.name;
        }
        TEnum;
      case CEnum(_):
        null;
      case CPtr(conv, isRef):
        var ret = conv.toUPropertyDef();
        if (ret != null) {
          if (isRef) {
            ret.flags |= FRef;
          } else {
            return null; // Ptr is not supported by uproperties
          }
        }
        return ret;
      case CStruct(type, flags, info, params):
        switch(type) {
        case SHaxe:
          typeFlags |= FHaxeCreated;
        case SScriptHaxe:
          typeFlags |= FScriptCreated;
        case _:
        }

        switch(info.ueType.name) {
          case 'TArray' | 'TSet':
            var param = params[0].toUPropertyDef();
            if (param == null) {
              null;
            } else {
              defParams = [param];
              info.ueType.name == 'TArray' ? TArray : TSet;
            }
          case 'TMap':
            var kparam = params[0].toUPropertyDef(),
                vparam = params[1].toUPropertyDef();

            if (kparam == null || vparam == null) {
              null;
            } else {
              defParams = [kparam,vparam];
              TMap;
            }
          case _:
            if (flags.hasAny(SUStruct)) {
              switch(info.ueType.name) {
                case 'FString':
                  TString;
                case 'FText':
                  TText;
                case 'FName':
                  TName;
                case uname:
                  name = uname;
                  TStruct;
              }
            } else if (flags.hasAny(SDynamicDelegate)) {
              name = info.ueType.name;
              TDynamicDelegate;
            } else if (flags.hasAny(SDynamicMulticastDelegate)) {
              name = info.ueType.name;
              TDynamicMulticastDelegate;
            } else {
              null;
            }
        }
      case CLambda(_) | CMethodPointer(_) | CTypeParam(_):
        null;
    };
    if (type == null) {
      return null;
    }
    if (this.modifiers != null) {
      for (modf in this.modifiers) {
        switch(modf) {
        case Ptr:
          return null; // PPtr is not supported on UProperties
        case Ref:
          typeFlags |= FRef;
        case Const:
          typeFlags |= FConst;
        case _:
        }
      }
    }

    typeFlags.type = type;

    var ret:UPropertyDef = {
      hxName: null,
      uname: null,
      flags: typeFlags,
      typeUName: name
    };
    if (defParams != null) {
      ret.params = defParams;
    }

    return ret;
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
      case CPtr(t,_):
        return t.hasTypeParams();
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
        } else if (flags.hasAny(OScriptInterface)) {
          var name = 'TScriptInterface';
          this.ueType = new TypeRef(name, [info.ueType]);
          if (this.haxeType == null) {
            this.haxeType = new TypeRef(['unreal'], name, [info.haxeType]);
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
      case CEnum(type, flags, info):
        // EExternal, EAbstract, EHaxe, EScriptHaxe
        if (this.haxeType == null) {
          this.haxeType = info.haxeType;
        }
        this.ueType = info.ueType;
        this.haxeGlueType = int32Haxe;
        this.glueType = int32Glue;
        if (flags.hasAll(EEnumAsByte)) {
          this.haxeType = new TypeRef(['unreal'], 'TEnumAsByte', [this.haxeType]);
          this.ueType = new TypeRef('TEnumAsByte', [this.ueType]);
        }
      case CPtr(type, isRef):
        this.haxeType = type.haxeType;
        this.ueType = type.ueType;
        this.haxeGlueType = uintPtr;
        this.glueType = uintPtr;
        if (isRef) {
          this.haxeType = new TypeRef(['unreal'], 'Ref', [this.haxeType]);
          this.ueType = new TypeRef(['cpp'], 'Reference', [this.ueType]);
        } else {
          this.haxeType = new TypeRef(['unreal'], 'Ptr', [this.haxeType]);
          this.ueType = new TypeRef(['cpp'], 'RawPointer', [this.ueType]);
        }
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
          this.haxeType = new TypeRef(['unreal'], 'Const', [this.haxeType]);
          if (this.data.match(CUObject(_)) && !hadMarker) {
            this.ueType = this.ueType.leafWithConst(true);
          } else {
            this.ueType = this.ueType.withConst(true);
          }
        case Ref:
          this.haxeType = new TypeRef(['unreal'], 'PRef', [this.haxeType]);
          this.ueType = new TypeRef(['cpp'], 'Reference', [this.ueType]);
        case Ptr:
          this.haxeType = new TypeRef(['unreal'], 'PPtr', [this.haxeType]);
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
    case CEnum(type, _, info):
      set.add('<hxcpp.h>');
    case CStruct(type,_,info,params):
      set.add('VariantPtr.h');

    case CPtr(of,_):
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
      var canForwardDecl = true;
      if (flags.hasAny(OWeak)) {
        set.add('UObject/WeakObjectPtr.h');
        set.add("UObject/WeakObjectPtrTemplates.h");
      }
      if (flags.hasAny(OSubclassOf)) {
        set.add("CoreUObject.h");
      }
      if (flags.hasAny(OScriptInterface)) {
        set.add("UObject/ScriptInterface.h");
        set.add("uhx/UEHelpers.h");
      }

      if (forwardDecls != null && canForwardDecl) {
        var decl = info.ueType.getForwardDecl();
        forwardDecls[decl] = decl;
        cppSet.append(info.glueCppIncludes);
      } else {
        set.append(info.glueCppIncludes);
        if (type == OHaxe || type == OScriptHaxe) {
          set.add('${info.ueType.withoutPrefix().name}.h');
        }
      }
    case CEnum(type, _, info):
      if (type == EHaxe || type == EScriptHaxe) {
        set.add('${ueType.withoutPrefix().name}.h');
      }
      set.append(info.glueCppIncludes);
    case CStruct(type,flags,info,params):
      set.add('uhx/Wrapper.h');
      set.append(info.glueCppIncludes);

      if (params != null) {
        var ptr = inPointer;
        for (param in params) {
          param.recurseUeIncludes(set, forwardDecls, cppSet, ptr);
        }

        var glue = info.haxeType.getGlueHelperType();
        set.add(glue.pack.join('/') + (glue.pack.length == 0 ? '' : '/') + glue.name + '_UE.h');
      }

    case CPtr(of,_):
      of.recurseUeIncludes(set, forwardDecls, cppSet, true);

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
          set.add('UObject/WeakObjectPtr.h');
          set.add("UObject/WeakObjectPtrTemplates.h");
        case PSubclassOf:
          set.add("CoreUObject.h");
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
        'uhx.internal.HaxeHelpers.getUObjectWrapped($expr)';

      // EExternal, EAbstract, EHaxe, EScriptHaxe
      case CEnum(EAbstract, _, info):
        expr;
      case CEnum( type = (EScriptHaxe | EHaxe), _, info):
        var setType = type == EScriptHaxe ? ' : Dynamic' : '';
        var haxeType = this.haxeType;
        '{ var temp $setType = $expr; if (temp == null) { throw "null $haxeType passed to UE"; } Type.enumIndex(temp); }';
      case CEnum(type, _, info):
        var typeRef = info.haxeType,
            conv = typeRef.with(typeRef.name + '_EnumConv', typeRef.moduleName != null ? typeRef.moduleName : typeRef.name);
        '${conv.getClassPath()}.unwrap($expr)';

      case CStruct(type, flags, info, params):
        // '($expr : unreal.VariantPtr)';
        if (flags.hasAny(SOwnedPtr)) {
          '($expr).getRaw()';
        } else {
          expr;
        }

      case CPtr(of, isRef):
        return '($expr).asUIntPtr()';

      case CLambda(args,ret):
        'uhx.internal.HaxeHelpers.dynamicToPointer( $expr )';
      case CMethodPointer(cname, args, ret):
        expr;
      case CTypeParam(name, _):
        '( cast $expr : unreal.VariantPtr ).getUIntPtrRepresentation()';
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
        if (this.tparamName == null) {
          '( cast unreal.UObject.wrap($expr) : ${this.haxeType} )';
        } else {
          '( cast unreal.UObject.wrap($expr) : ${this.tparamName} )';
        }

      // EExternal, EAbstract, EHaxe, EScriptHaxe
      case CEnum(EAbstract, _, info):
        '( ($expr) : ${haxeType} )';
      case CEnum( type = (EScriptHaxe | EHaxe), _, info):
        if (type == EScriptHaxe)
          'Type.createEnumIndex(Type.resolveEnum("${this.haxeType.getClassPath(true)}"), $expr)';
        else
          'uhx.internal.UEnumHelper.createEnumIndex(${this.haxeType.getClassPath(false)}, $expr)';
      case CEnum(type, _, info):
        var typeRef = info.haxeType,
            conv = typeRef.with(typeRef.name + '_EnumConv', typeRef.moduleName != null ? typeRef.moduleName : typeRef.name);
        '${conv.getClassPath()}.wrap($expr)';

      case CStruct(type, flags, info, params):
        '( @:privateAccess ${info.haxeType.getClassPath()}.fromPointer( $expr ) : $haxeType )';

      case CPtr(of, isRef):
        '(cast ($expr) : ${this.haxeType})';

      case CLambda(args,ret):
        '( uhx.internal.HaxeHelpers.pointerToDynamic( $expr ) : $haxeType )';
      case CMethodPointer(cname, args, ret):
        expr;
      case CTypeParam(name, _):
        '( uhx.internal.HaxeHelpers.pointerToDynamic( $expr ) : $haxeType )';
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
          if (flags.hasAny(OScriptInterface)) {
            ret = 'uhx::UEHelpers::createScriptInterface<${info.ueType.getCppType()}>(Cast<${info.ueType.getCppType()}>( (UObject *) $expr ))';
          } else {
            ret = 'Cast<${info.ueType.getCppType()}>( (UObject *) $expr )';
          }
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
      case CEnum(type, flags, info):
        if (flags.hasAll(EEnumAsByte))
        {
          '( (${ueType.getCppType()}) (${ueType.params[0].getCppType()}) $expr )';
        } else {
          '( (${ueType.getCppType()}) $expr )';
        }

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

      case CPtr(of, isRef):
        if (isRef) {
          '*(reinterpret_cast<${of.ueType.getCppType(false)}*>($expr))';
        } else {
          'reinterpret_cast<${this.ueType.getCppType(false)}>($expr)';
        }

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

  public function ueToGlueCtor(ctorArgs:String, argsTypes:Array<TypeConv>, ctx:ConvCtx, justWrapper=false) {
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
        var name = justWrapper ? 'emptyWrapper' : 'create$templ';
        return '$helper::$name($ctorArgs)';
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
        if (hasModifier(Ref)) {
          ret = '&($ret)';
        } else if (flags.hasAny(OWeak | OAutoWeak)) {
          ret = '( $ret.Get() )';
        }

        var const = this.hasModifier(Const) ? 'const' : '';
        if (type == OInterface) {
          if (flags.hasAny(OScriptInterface)) {
            ret = '($ret).GetObject()';
          } else {
            ret = 'const_cast<UObject *>(Cast<$const UObject>( $ret ))';
          }
        } else if (flags.hasAny(OSubclassOf)) {
          ret = 'const_cast<UClass *>( ($const UClass *) $ret )';
        } else {
          if (const != '') {
            ret = 'const_cast<UObject *>( (const UObject *) $ret )';
          }
        }

        '( (unreal::UIntPtr) ($ret) )';

      // EExternal, EAbstract, EHaxe, EScriptHaxe
      case CEnum(type, flags, info):
        var type = ueType;
        if (flags.hasAny(EEnumAsByte))
        {
          type = type.params[0];
        }
        '( (int) (${type.getCppType()}) $expr )';

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
            'unreal::VariantPtr::fromExternalPointer( (void *) &($expr) )';
          } else if (hasModifier(Ptr)) {
            'unreal::VariantPtr::fromExternalPointer( (void *) ($expr) )';
          } else {
            '::uhx::StructHelper<${this.ueType.withoutPointer(true).withConst(false).getCppType()}>::fromStruct($expr)';
          }
        }

      case CPtr(of, isRef):
        if (isRef) {
          '(unreal::UIntPtr) &($expr)';
        } else {
          '(unreal::UIntPtr) ($expr)';
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

  private static function normalizeType(t:Type):Type {
    while(true) {
      switch(t) {
      case TLazy(fn):
        t = fn();
      case TMono(mono):
        t = mono.get();
      case TAbstract(a,tl):
        if (tl.length > 0) {
          for (i in 0...tl.length) {
            var t = normalizeType(tl[i]);
            if (t == null) {
              return null;
            }
            tl[i] = t;
          }
        }
        return t;
      case TInst(i,tl):
        if (i.get().kind.match(KTypeParameter(_))) {
          return null;
        }
        if (tl.length > 0) {
          for (i in 0...tl.length) {
            var t = normalizeType(tl[i]);
            if (t == null) {
              return null;
            }
            tl[i] = t;
          }
        }
        return t;
      case TType(ti,tl):
        if (tl.length > 0) {
          for (i in 0...tl.length) {
            var t = normalizeType(tl[i]);
            if (t == null) {
              return null;
            }
            tl[i] = t;
          }
        }
        return t;
      case TFun(args,ret):
        for (arg in args) {
          var t = normalizeType(arg.t);
          if (t == null) {
            return null;
          }
          arg.t = t;
        }
        var ret = normalizeType(ret);
        if (ret == null) {
          return null;
        }
        return TFun(args, ret);
      case _:
        return null;
      }
    }
  }

  public static function get(type:Type, pos:Position, ?inTypeParam:Bool=false, ?isNoTemplate:Bool=false):TypeConv {
    var useCache = !isNoTemplate;
    while (true) {
      switch(type) {
      case TLazy(fn):
        type = fn();
      case TMono(mono):
        type = mono.get();
      case TAbstract(_,tl) | TInst(_,tl) | TType(_,tl):
        if (tl.length > 0) {
          var norm = normalizeType(type);
          if (norm == null) {
            useCache = false;
          } else {
            type = norm;
          }
        }
        break;
      case TFun(_):
        var norm = normalizeType(type);
        if (norm == null) {
          useCache = false;
        } else {
          type = norm;
        }
        break;
      case _:
        useCache = false;
        break;
      }
    }

#if (haxe_ver < 4)
    if (useCache) {
      var t = Std.string(type);
      var cache = Globals.cur.typeConvCache;

      var ret = cache[t];
      if (ret == null) {
        var ctx:InfoCtx = { accFlags:ONone, accEnumFlags: ENone };
        ret = getInfo(type, pos, ctx, inTypeParam, isNoTemplate);
        if (!ctx.disableCache) {
          cache[t] = ret;
        }
      }

      return ret;
    }
    else
#end
    {
      return getInfo(type, pos, { accFlags:ONone, accEnumFlags: ENone }, inTypeParam, isNoTemplate);
    }
  }

  private static function getInfo(type:Type, pos:Position, ctx:InfoCtx, inTypeParam:Bool, isNoTemplate:Bool):TypeConv {
    var cache = Globals.cur.typeConvCache;
    var o = type;
    while(type != null) {
      switch(type) {
      case TInst(iref, tl):
        if (tl.length > 0) {
          ctx.disableCache = true;
        }
        var name = iref.toString();
        checkTypeLoaded(name);
        var ret = cache[name];
        if (ret != null) {
          if (ctx.modf == null && ctx.original == null) {
            return ret;
          } else {
            return new TypeConv(ret.data, ctx.modf, ctx.original);
          }
        }

        var it = iref.get();
        var ret = null;
        var info = getTypeInfo(it, pos);
        var structFlags = ctx.accStructFlags == null ? SNone : ctx.accStructFlags;
        if (it.meta.has(':typeName')) {
          structFlags |= STypeName;
        }
        if (it.meta.has(':ustruct')) {
          structFlags |= SUStruct;
        }
        if (it.meta.has(':udynamicDelegate')) {
          structFlags |= SDynamicDelegate;
        }
        if (it.meta.has(':udynamicMulticastDelegate')) {
          structFlags |= SDynamicMulticastDelegate;
        }
        if (it.kind.match(KTypeParameter(_))) {
          if (isNoTemplate) {
            switch(it.kind) {
            case KTypeParameter([t]):
              ctx.accFlags |= OWasTParam;
              var ret = getInfo(t, pos, ctx, inTypeParam, isNoTemplate);
              ret.tparamName = it.name;
              switch(ret.data) {
              case CUObject(_,_,_):
                return ret;
              case _:
                throw new Error('Unreal Glue: The type parameter ${it.name} is a ${ret.data}, but only UObject-derived types are allowed on @:noTemplate types', it.pos);
              }
            case _:
              throw new Error('Unreal Glue: The @:noTemplate type parameter ${it.name} does not contain a single equivalent UObject type', it.pos);
            }
          } else {
            var kind = if(ctx.accFlags.hasAny(OSubclassOf)) {
              PSubclassOf;
            } else if(ctx.accFlags.hasAll(OAutoWeak)) {
              PAutoWeak;
            } else if (ctx.accFlags.hasAny(OWeak)) {
              PWeak;
            } else {
              PNone;
            }
            ctx.original = null;
            ctx.disableCache = true;
            ret = CTypeParam(it.name, kind);
          }
        } else if (typeIsUObject(type)) {
          if (ctx.modf != null && ctx.modf.has(Ptr) && !inTypeParam) {
            Context.warning('Unreal Glue: PPtr of a UObject is not supported', pos);
          }
          if (!it.meta.has(':uextern')) {
            if (it.meta.has(':uscript') || (Context.defined('cppia') && !Globals.cur.staticModules.exists(it.module))) {
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
          ret = CStruct(SExternal, structFlags, info, tl.length > 0 ? [for (param in tl) get(param, pos, inTypeParam, isNoTemplate)] : null);
        } else if (it.meta.has(':haxeCreated')) {
          if (it.meta.has(':uscript') || (Context.defined('cppia') && !Globals.cur.staticModules.exists(it.module))) {
            ret = CStruct(SScriptHaxe, structFlags, info, tl.length > 0 ? [for (param in tl) get(param, pos, inTypeParam, isNoTemplate)] : null);
          } else {
            ret = CStruct(SHaxe, structFlags, info, tl.length > 0 ? [for (param in tl) get(param, pos, inTypeParam, isNoTemplate)] : null);
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
                Context.warning('Unreal Glue: PPtr of UObjects is not supported', pos);
              }
            case _:
            }
          }
          return new TypeConv(ret, ctx.modf, ctx.original);
        }

      case TEnum(eref, tl):
        if (ctx.modf != null && !(ctx.modf.length == 1 && ctx.modf[0] == Const)) {
          // Const enums work the same as non-const, so we do support them
          Context.warning('Unreal Glue: PPtr or PRef is not supported on enums', pos);
        }
#if bake_externs
        checkTypeLoaded(eref.toString());
#end
        var e = eref.get(),
            ret = null,
            info = getTypeInfo(e, pos);
        var flag = ctx.accEnumFlags;
        if (flag == null) flag = ENone;
        if (e.meta.has(':uenum')) flag = flag | EUEnum;
        if (e.meta.has(':uextern') && !e.meta.has(':haxeGenerated')) {
          ret = CEnum(e.meta.has(':class') ? EExternalClass : EExternal, flag, info);
        } else if (e.meta.has(':uenum')) {
          if (e.meta.has(':uscript') || (Context.defined('cppia') && !Globals.cur.staticModules.exists(e.module))) {
            ret = CEnum(EScriptHaxe, flag | EUEnum, info);
          } else {
            ret = CEnum(EHaxe, flag | EUEnum, info);
          }
        } else {
          Context.warning('Unreal Glue: Enum type $eref is not supported: It is not a uextern or a uenum', pos);
        }

        return new TypeConv(ret, ctx.modf, ctx.original);

      case TAbstract(aref, tl):
        if (tl.length > 0) {
          ctx.disableCache = true;
        }
        var name = aref.toString();
        checkTypeLoaded(name);
        if (tl.length == 0) {
          var ret = cache[name];
          if (ret != null) {
            if (ctx.modf == null && ctx.original == null) {
              return ret;
            } else {
              return new TypeConv(ret.data, ctx.modf, ctx.original);
            }
          }
        } else if (name == 'Null') {
          type = tl[0];
          continue;
        }
        switch(name) {
        case "unreal.Ptr" | "unreal.Ref" | "unreal.FixedArray":
          var isRef = name == "unreal.Ref";
          if (ctx.modf != null) {
            for (modf in ctx.modf) {
              if (modf == Ref) {
                throw new Error('Unreal Glue: Invalid modifier PRef for type $name', pos);
              } else if (modf == Ptr) {
                throw new Error('Unreal Glue: Invalid modifier PPtr for type $name', pos);
              }
            }
          }

          var ret = TypeConv.get(tl[0], pos);
          switch(ret.data) {
          case CStruct(_):
            if (ret.hasModifier(Ref)) {
              throw new Error('Unreal Glue: $name of a reference is not allowed', pos);
            }
            if (!ret.hasModifier(Ptr)) {
              var suggestion = isRef ? 'PRef<>' : 'PPtr<>';
              throw new Error('Unreal Glue: $name of a struct is only allowed on `PPtr<>` types (e.g. $name<PPtr<${tl[0]}>>). Use $suggestion instead', pos);
            }
          case CBasic(_) | CSpecial(_) | CUObject(_) | CEnum(_) | CPtr(_) | CTypeParam(_):
            // ok
          case _:
            throw new Error('Unreal Glue: $name is not supported for the type kind ${std.Type.enumConstructor(ret.data)} (${tl[0]})', pos);
          }
          return new TypeConv(CPtr(ret, isRef), ctx.modf, ctx.original);
        }

        var a = aref.get(),
            ret = null,
            info = getTypeInfo(a, pos);
        var structFlags = ctx.accStructFlags == null ? SNone : ctx.accStructFlags;
        if (a.meta.has(':typeName')) {
          structFlags |= STypeName;
        }
        if (a.meta.has(':ustruct')) {
          structFlags |= SUStruct;
        }
        if (a.meta.has(':udynamicDelegate')) {
          structFlags |= SDynamicDelegate;
        }
        if (a.meta.has(':udynamicMulticastDelegate')) {
          structFlags |= SDynamicMulticastDelegate;
        }
        var hasUextern = a.meta.has(':uextern');
        if (hasUextern && a.meta.has(':enum')) {
          if (ctx.modf != null) {
            Context.warning('Unreal Glue: Const, PPtr or PRef is not supported on enums', pos);
          }
          var underlying = get(a.type, pos, inTypeParam, isNoTemplate);
          var ret = new TypeConv(CEnum(EAbstract, ctx.accEnumFlags | EUEnum, info), ctx.modf, ctx.original);
          ret.glueType = underlying.glueType;
          ret.haxeGlueType = underlying.haxeGlueType;
          return ret;
        } else if (hasUextern) {
          ret = CStruct(SExternal, structFlags, info, tl.length > 0 ? [for (param in tl) get(param, pos, inTypeParam, isNoTemplate)] : null);
        } else if (a.meta.has(':haxeCreated')) {
          if (a.meta.has(':uscript') || (Context.defined('cppia') && !Globals.cur.staticModules.exists(a.module))) {
            ret = CStruct(SScriptHaxe, structFlags, info, tl.length > 0 ? [for (param in tl) get(param, pos, inTypeParam, isNoTemplate)] : null);
          } else {
            ret = CStruct(SHaxe, structFlags, info, tl.length > 0 ? [for (param in tl) get(param, pos, inTypeParam, isNoTemplate)] : null);
          }
        } else if (a.meta.has(':coreType')) {
          throw new Error('Unreal Glue: Basic type $name is not supported', pos);
        } else {
          switch(name) {
          case 'unreal.MethodPointer':
            if (ctx.modf != null) {
              Context.warning('Unreal Glue: Const, PPtr or PRef is not directly supported on MethodPointers', pos);
            }
            name = null;
            ret = parseMethodPointer(tl, pos);
          case _:
            if (name == 'unreal.POwnedPtr') {
              if (ctx.accStructFlags == null) {
                ctx.accStructFlags = SNone;
              }
              ctx.accStructFlags |= SOwnedPtr;
            }
            switch(name)
            {
            case 'unreal.TEnumAsByte':
              ctx.accEnumFlags |= EEnumAsByte;
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
              type = tl[0];
              continue;
            case _:
              if (ctx.original == null) {
                ctx.original = TypeRef.fromBaseType(a, tl, pos);
              }
            }
            type = a.type.applyTypeParameters(a.params, tl);
          }
        }

        if (ret != null) {
          return new TypeConv(ret, ctx.modf, ctx.original);
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
          case 'unreal.TScriptInterface':
            if (ctx.accFlags.hasAny(OWeak | OSubclassOf | OAutoWeak)) {
              Context.warning('Unreal Type: Illogical type (TScriptInterface with weak / subclassOf flags', pos);
            }
            ctx.accFlags |= OScriptInterface;
            type = tl[0];
            if (ctx.modf == null) ctx.modf = [];
            ctx.modf.push(Marker);
            continue;
          case _:
            throw new Error('Unreal Type: Invalid typedef: $name', pos);
          }
        }

        if (ret != null) {
          return new TypeConv(ret, ctx.modf, ctx.original);
        }
        var oldType = haxe.macro.TypeTools.toString(type);
        type = t.type.applyTypeParameters(t.params, tl);
        if (oldType == haxe.macro.TypeTools.toString(type)) {
          throw new Error('Unreal Glue: Type loop detected on type $oldType. This might happen due to compilation errors on UnrealStruct/Delegates creation', t.pos);
        }

      case TLazy(f):
        ctx.disableCache = true;
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
        ctx.disableCache = true;
        type = mono.get();

      case t:
        trace('Invalid type $t');
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

  @:allow(uhx.compiletime.Globals) static function addSpecialTypes(to:Map<String, TypeConv>) {
    // Remember that any type added here must be added as an exception to the C++ templates
    var basicConvert = [
      "cpp.Float32" => "float",
      "cpp.Float64" => "double",
      "Float" => "double",
      "cpp.Int16" => "int16",
      "cpp.Int32" => "int32",
      "cpp.Int64" => "int64",
      "cpp.Int8" => "int8",
      "cpp.UInt16" => "uint16",
      "cpp.UInt8" => "uint8",
      "cpp.UInt32" => "uint32",
      "cpp.UInt64" => "uint64",
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
        ueType: new TypeRef('int32'),
        haxeType: new TypeRef('Int'),
        glueType: new TypeRef('int'),

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
        ueType: new TypeRef(['cpp'],'RawPointer', [new TypeRef('void', Const)]),
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
      {
        ueType: new TypeRef([],'SIZE_T'),
        glueType: new TypeRef(['unreal'],'SizeT'),
        haxeType: new TypeRef(['unreal'],'SizeT'),

        glueHeaderIncludes:IncludeSet.fromUniqueArray(['<IntPtr.h>']),
        glueCppIncludes:IncludeSet.fromUniqueArray(['HAL/Platform.h']),
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
    var charStar = new TypeRef(['cpp'], 'RawPointer', [new TypeRef('char', Const)]);

    infos = [
      // TCharStar
      {
        haxeType: new TypeRef(['unreal'],'TCharStar'),
        ueType: new TypeRef(['cpp'], 'RawPointer', [new TypeRef('TCHAR')]),
        haxeGlueType: uintPtr,
        glueType: uintPtr,

        glueCppIncludes:IncludeSet.fromUniqueArray(['CoreMinimal.h', '<uhx/expose/HxcppRuntime.h>']),
        glueHeaderIncludes:IncludeSet.fromUniqueArray(['<hxcpp.h>']),

        ueToGlueExpr:'::uhx::expose::HxcppRuntime::constCharToString(TCHAR_TO_UTF8( (const char *) (%) ))',
        glueToUeExpr:'UTF8_TO_TCHAR(::uhx::expose::HxcppRuntime::stringToConstChar((unreal::UIntPtr) (%)))',
        haxeToGlueExpr:'uhx.internal.HaxeHelpers.dynamicToPointer( % )',
        glueToHaxeExpr:'(uhx.internal.HaxeHelpers.pointerToDynamic( % ) : String)',
      },
      // cpp.ConstCharStar
      {
        haxeType: new TypeRef(['cpp'],'ConstCharStar'),
        ueType: charStar,
        glueType: charStar,
      },
      // VariantPtr
      {
        haxeType: variantPtr,
        ueType: variantPtr,
        glueHeaderIncludes:IncludeSet.fromUniqueArray(['VariantPtr.h']),
      },
      // UIntPtr
      {
        haxeType: uintPtr,
        ueType: uintPtr,
        glueHeaderIncludes:IncludeSet.fromUniqueArray(['IntPtr.h']),
      },
      {
        haxeType: new TypeRef(['unreal'], 'IntPtr'),
        ueType: new TypeRef(['unreal'], 'IntPtr'),
        glueHeaderIncludes:IncludeSet.fromUniqueArray(['IntPtr.h']),
      },
      // AnsiCharStar
      {
        haxeType: new TypeRef(['unreal'],'AnsiCharStar'),
        ueType: new TypeRef(['cpp'], 'RawPointer', [new TypeRef('ANSICHAR')]),
        haxeGlueType: uintPtr,
        glueType: uintPtr,

        glueCppIncludes:IncludeSet.fromUniqueArray(['CoreMinimal.h', '<uhx/expose/HxcppRuntime.h>']),
        glueHeaderIncludes:IncludeSet.fromUniqueArray(['<hxcpp.h>']),

        ueToGlueExpr:'::uhx::expose::HxcppRuntime::constCharToString(TCHAR_TO_UTF8(ANSI_TO_TCHAR( (const char *) (%) )))',
        glueToUeExpr:'TCHAR_TO_ANSI(UTF8_TO_TCHAR(::uhx::expose::HxcppRuntime::stringToConstChar((unreal::UIntPtr) (%))))',
        haxeToGlueExpr:'uhx.internal.HaxeHelpers.dynamicToPointer( % )',
        glueToHaxeExpr:'(uhx.internal.HaxeHelpers.pointerToDynamic( % ) : String)',
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
  static var int32Haxe(default,null) = new TypeRef('Int');
  static var int32Glue(default,null) = new TypeRef('int');
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
  CEnum(type:EEnumType, flags:EnumFlags, info:TypeInfo);
  CStruct(type:StructType, flags:StructFlags, info:TypeInfo, ?params:Array<TypeConv>);

  CPtr(of:TypeConv, isRef:Bool);

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
  var OWasTParam = 8;
  var OScriptInterface = 16;

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

@:enum abstract EEnumType(Int) from Int {
  var EExternal = 1;
  var EExternalClass = 2;
  var EAbstract = 3;
  var EHaxe = 4;
  var EScriptHaxe = 5;
}

@:enum abstract EnumFlags(Int) from Int {
  var ENone = 0;
  var EUEnum = 0x1; // is UEnum
  var EEnumAsByte = 0x2; // TEnumAsByte<>

  inline private function t() {
    return this;
  }

  @:op(A|B) inline public function add(f:EnumFlags):EnumFlags {
    return this | f.t();
  }

  inline public function hasAll(flag:EnumFlags):Bool {
    return this & flag.t() == flag.t();
  }

  inline public function hasAny(flag:EnumFlags):Bool {
    return this & flag.t() != 0;
  }
}

@:enum abstract StructType(Int) from Int {
  var SExternal = 1;
  var SHaxe = 2;
  var SScriptHaxe = 3;
}

@:enum abstract StructFlags(Int) from Int {
  var SNone = 0;
  // @:typeName generic types
  var STypeName = 0x1;
  var SUStruct = 0x2;
  var SDynamicDelegate = 0x4;
  var SDynamicMulticastDelegate = 0x8;
  var SOwnedPtr = 0x10;

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
  ?accStructFlags:StructFlags,
  ?modf:Array<Modifier>,
  ?disableCache:Bool,
  accEnumFlags:EnumFlags
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
