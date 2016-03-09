package ue4hx.internal;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

using Lambda;
using ue4hx.internal.MacroHelpers;
using haxe.macro.Tools;

class NeedsGlueBuild
{
  static var checkedVersion = false;
  public static function build():Array<Field>
  {
    #if bake_externs
    return null;
    #end
    // check version level
    if (!checkedVersion) {
      Globals.cur.checkBuildVersionLevel();
      checkedVersion = true;
    }
    var localClass = Context.getLocalClass(),
        cls = localClass.get(),
        thisType = TypeRef.fromBaseType(cls, cls.pos);

    if (Globals.cur.gluesTouched.exists(localClass.toString()))
      return null;

    addOperators(localClass.toString(), cls, thisType);
    Globals.cur.gluesTouched[localClass.toString()] = true;

    if (cls.meta.has(':ueGluePath')) {
      Globals.cur.gluesToGenerate = Globals.cur.gluesToGenerate.add(thisType.getClassPath());
    }
    if (cls.meta.has(':needsTypeParamGlue')) {
      Globals.cur.typesThatNeedTParams = Globals.cur.typesThatNeedTParams.add(thisType.getClassPath());
    }
    if (cls.meta.has(':ueNoGlue')) {
      return null;
    }

    var fields:Array<Field> = Context.getBuildFields(),
        toAdd = [];

    var delayedglue = macro ue4hx.internal.DelayedGlue;
    if (Context.defined('display') || (Context.defined('cppia') && !Globals.cur.scriptModules.exists(cls.module))) {
      // don't spend precious macro processing time if this is not a script module
      delayedglue = macro cast null;
    }
    if (!cls.meta.has(':uextern')) {
      // If this is a USTRUCT definiton, mark it with :ustruct so that DelayedGlue will generated the C++ header for it,
      // and add wrap/create calls
      var superCls = cls.superClass;
      while (superCls != null) {
        var scls = superCls.t.get();
        if (scls.meta.has(':ustruct')) {
          if (!cls.meta.has(':ustruct')) {
            cls.meta.add(':ustruct', [], cls.pos);
          }
          cls.meta.add(':unativecalls', [ macro "create" ], cls.pos);

          if (!cls.meta.has(':uextern')) {
            var uname = MacroHelpers.extractStrings(cls.meta, ':uname')[0];
            if (uname == null) uname = cls.name;
            var structHeaderPath = '$uname.h';
            cls.meta.add(':glueCppIncludes', [macro $v{structHeaderPath}], cls.pos);

            var typeThis:TypePath = {pack:[], name:cls.name};
            var complexThis = TPath(typeThis);
            var added = macro class {
              @:unreflective public static function wrap(wrapped:cpp.RawPointer<unreal.helpers.UEPointer>, ?parent:Dynamic):$complexThis {
                var wrapped = cpp.Pointer.fromRaw(wrapped);
                return wrapped != null ? new $typeThis(wrapped, parent) : null;
              }
              @:uname("new") public static function create():unreal.PHaxeCreated<$complexThis> {
                return $delayedglue.getNativeCall("create", true);
              }
            };
            for (field in added.fields) {
              toAdd.push(field);
            }
          }
          break;
        }
        superCls = superCls.t.get().superClass;
      }
    }
    var superClass = cls.superClass == null ? null : cls.superClass.t.get();

    if (!cls.meta.has(':uextern') && localClass.toString() != 'unreal.Wrapper') {
      cls.meta.add(':uextension', [], cls.pos);
      if (Globals.cur.inScriptPass) {
        cls.meta.add(':uscript', [], cls.pos);
      }
      // FIXME: allow any namespace by using @:native; add @:native handling
      if (cls.pack.length == 0)
        throw new Error('Unreal Glue Extension: Do not extend Unreal types on the global namespace. Use a package', cls.pos);
      var hadErrors = false;
      // if we don't have the @:uextern meta, it means
      // we're subclassing an extern class

      // non-extern type that derives from UObject:
      // change uproperties to call getter/setters
      // warn if constructors are created

      var changed = false;
      var superCalls = new Map(),
          uprops = [];
      var nativeCalls = new Map();
      var methodPtrs = new Map();
      for (field in fields) {
        if (cls.meta.has(':ustruct') && Globals.cur.inScriptPass && field.kind.match(FFun(_))) {
          field.meta.push({ name:':live', pos:field.pos });
        }
        if (field.access != null && field.access.has(AOverride)) {
          field.meta.push({ name:':keep', pos:field.pos });
          // TODO: should we check for non-override fields as well? This would
          //       add some overhead for all override fields, which is something I'd like to avoid for now
          //       specially since super calling in other fields doesn't seem particularly useful
          switch (field.kind) {
          case FFun(fn) if (fn.expr != null):
            function map(e:Expr) {
              return switch (e.expr) {
              case ECall(macro super.$sfield, args):
                superCalls[sfield] = sfield;
                var args = [ for (arg in args) map(arg) ];
                changed = true;
                var ret = null;
                if (field.meta.hasMeta(':live')) {
                  // regardless if the super points to a haxe superclass or not,
                  // we will need to be able to call it through a static function
                  var fn = superClass.findField(sfield, false);
                  // get function arguments
                  if (fn == null) {
                    Context.warning('Field calls super but no super field with name $sfield', e.pos);
                    hadErrors = true;
                  } else {
                    switch(Context.follow(fn.type)) {
                    case TFun(fnargs,fnret):
                      var name = field.name + '__supercall_' + cls.name;
                      var isVoid = fnret.match(TAbstract(_.get() => { name:'Void', pack:[] }, _));
                      var expr = { expr:ECall(macro @:pos(e.pos) $delayedglue.getSuperExpr, [macro $v{sfield}, macro $v{name}].concat([for (arg in fnargs) macro $i{arg.name}])), pos:e.pos };
                      toAdd.push({
                        name: name,
                        kind: FFun({
                          args: [ for (arg in fnargs) { name: arg.name, opt: arg.opt, type: arg.t.toComplexType() } ],
                          ret: fnret.toComplexType(),
                          expr: isVoid ? expr : macro return $expr,
                        }),
                        pos: e.pos
                      });
                      ret = { expr:ECall(macro @:pos(e.pos) this.$name, args), pos:e.pos };
                    case _:
                      Context.warning('Super cannot be called on non-method members', e.pos);
                      hadErrors = true;
                    }
                  }
                }
                if (ret == null) {
                  ret = { expr:ECall(macro @:pos(e.pos) $delayedglue.getSuperExpr, [macro $v{sfield}, macro $v{sfield}].concat(args)), pos:e.pos };
                }
                ret;
              case _:
                e.map(map);
              }
            }
            if (!Context.defined('cppia') || Globals.cur.scriptModules.exists(cls.module)) {
              fn.expr = map(fn.expr);
            }
          case _:
          }
        }
        var isUProp = field.meta.hasMeta(':uproperty');
        if (!isUProp && field.meta.hasMeta(':uexpose')) {
          switch(field.kind) {
          case FVar(_) | FProp(_):
            isUProp = true;
          case _:
          }
        }

        var isStatic = field.access != null && field.access.has(AStatic);
        if (isUProp) {
          field.meta.push({ name:':keep', pos:field.pos });
          changed = true;
          switch (field.kind) {
            case FVar(t,e) | FProp('default','default',t,e) if (t != null):
              uprops.push(field.name);
              var getter = 'get_' + field.name,
                  setter = 'set_' + field.name;
              var dummy = macro class {
                private function $getter():$t {
                  return $delayedglue.getGetterSetterExpr($v{field.name}, $v{isStatic}, false);
                }
                private function $setter(value:$t):$t {
                  $delayedglue.getGetterSetterExpr($v{field.name}, $v{isStatic}, true);
                  return value;
                }
              };
              if (isStatic) {
                for (field in dummy.fields) field.access.push(AStatic);
              }

              for (field in dummy.fields) toAdd.push(field);
              field.kind = FProp("get", "set", t, e);
            case FProp(_,_,_,_):
              Context.warning(
                'Unreal Glue Extension: uproperty properties with getters and setters are not supported by Unreal',
                field.pos);
              hadErrors = true;
            case FFun(_):
              Context.warning('Unreal Glue Extension: uproperty is not compatible with functions', field.pos);
              hadErrors = true;
            case _:
              Context.warning(
                'Unreal Glue Extension: uproperty properties must have a type',
                field.pos);
              hadErrors = true;
          }
        }

        // add the methodPtr accessor for any functions that are exposed/implemented in C++
        if (!isStatic && (field.meta.hasMeta(':ufunction') || field.meta.hasMeta(':uexpose'))) {
          field.meta.push({ name:':keep', pos:field.pos });
          switch (field.kind) {
          case FFun(_):
            var uname = field.name;
            var unameMeta = MacroHelpers.extractMeta(field.meta, ':uname');
            if (unameMeta != null) {
              uname = switch(unameMeta.params[0].expr) {
                case EConst(CIdent(s)): s;
                case EConst(CString(s)): s;
                default: field.name;
              };
            }

            var glueFnName = '_get_${field.name}_methodPtr';

            var dummy = macro class {
              private static function $glueFnName() : cpp.Pointer<Dynamic> {
                return $delayedglue.getNativeCall($v{glueFnName}, true);
              }
            }
            methodPtrs[field.name] = field.name;
            toAdd.push(dummy.fields[0]);
          case _:
          }
        }

        for (meta in field.meta) {
          if (meta.name == ':ufunction' && meta.params != null) {
            var fn = switch (field.kind) {
            case FFun(f):
              f;
            case _:
              throw new Error('Unreal Glue Extension: @:ufunction meta on a non-function', field.pos);
            };
            for (param in meta.params) {
              if (UExtensionBuild.ufuncMetaNoImpl(param)) {
                var name = switch (param.expr) {
                case EConst(CIdent(i)):
                  i;
                case _: throw 'assert';
                }

                if (fn.expr != null) {
                  Context.warning('Unreal Glue Extension: $name ufunctions should not contain any implementation', field.pos);
                  hadErrors = true;
                }
                nativeCalls[field.name] = field.name;
                var call = {
                  expr:ECall(
                    macro @:pos(field.pos) $delayedglue.getNativeCall,
                    [macro $v{field.name}, macro $v{isStatic}].concat([ for (arg in fn.args) macro $i{arg.name} ])),
                  pos: field.pos
                };
                switch (fn.ret) {
                case null | TPath({ pack:[], name:"Void" }):
                  fn.expr = macro { $call; };
                case _:
                  fn.expr = macro { return cast $call; };
                }
                changed = true;
                field.meta.push({ name:':final', params:[], pos:field.pos });
              }

              if (UExtensionBuild.ufuncMetaNeedsImpl(param)) {
                var name = switch (param.expr) {
                case EConst(CIdent(i)):
                  i;
                case _: throw 'assert';
                }

                var found = false;
                for (impl in fields) {
                  if (impl.name == field.name + '_Implementation') {
                    found = true;
                    impl.meta.push({ name:':uexpose', params:[], pos:impl.pos });
                    break;
                  }
                }
                if (!found) {
                  Context.warning('Unreal Glue Extension: $name ufunctions need a `_Implementation` function which is missing for function ${field.name}', field.pos);
                  hadErrors = true;
                }
              }
            }
          }
        }
        // TODO check if it's UDELEGATE
      }

      if (!cls.meta.has(':ustruct')) {
        var staticClassDef = macro class {
          public static function StaticClass() : unreal.UClass {
            return $delayedglue.getNativeCall('StaticClass', true);
          }
        };

        toAdd.push(staticClassDef.fields[0]);
        nativeCalls.set('StaticClass', 'StaticClass');
      }

      if (uprops.length > 0)
        cls.meta.add(':uproperties', [ for (prop in uprops) macro $v{prop} ], cls.pos);
      cls.meta.add(':usupercalls', [ for (call in superCalls) macro $v{call} ], cls.pos);
      cls.meta.add(':unativecalls', [ for (call in nativeCalls) macro $v{call} ], cls.pos);
      cls.meta.add(':umethodptrs', [ for(call in methodPtrs) macro $v{call} ], cls.pos);

      // mark to add the haxe-side glue helper
      if (!cls.meta.has(':ustruct')) {
        Globals.cur.uextensions = Globals.cur.uextensions.add(thisType.getClassPath());
      } else {
        // Haxe-defined USTRUCTs are handled specially in DelayedGlue
      }

      // add the glueRef definition if needed
      for (field in toAdd) {
        if (cls.isInterface) {
          switch(field.kind) {
          case FFun(fn):
            fn.expr = null;
          case _:
          }
        }
        fields.push(field);
      }

      var created = false;
      if (Context.defined('cppia') || Context.defined('WITH_CPPIA')) {
        for (field in fields) {
          if (field.meta.hasMeta(':live')) {
            switch(field.kind) {
            case FFun(fn) if (fn.params == null || fn.params.length == 0):
              if (!created) {
                created = true;
                Globals.liveReloadFuncs[thisType.getClassPath()] = new Map();
              }
              var name = thisType.getClassPath() + '::' + field.name;
              var isStatic = field.access != null ? field.access.has(AStatic) : false;
              var retfn:Function = {
                args: isStatic ? fn.args : [{ name:'_self', type: TPath({ pack:[], name:cls.name }) }].concat(fn.args),
                ret: fn.ret,
                expr: fn.expr
              };
              var expr = { expr:EFunction(null, retfn), pos:field.pos};
              fn.expr = macro ue4hx.internal.LiveReloadBuild.build(${expr}, $v{thisType.getClassPath()}, $v{field.name}, $v{isStatic});
              changed = true;
            case _:
            }
          }
        }
      }

      if (hadErrors)
        Context.error('Unreal Glue Extension: Build failed', cls.pos);
      if (toAdd.length > 0 || changed)
        return fields;
    }

    return null;
  }

  static function addOperators(name:String, cls:ClassType, thisType:TypeRef) {
    var startNamespaces = new StringBuf();
    var endNamespaces = new StringBuf();
    var getPointer = null;
    var scls = cls.superClass;
    while (scls != null) {
      if (scls.t.toString() == 'unreal.Wrapper') {
        getPointer = '->ptr->getPointer()';
        break;
      } else if (scls.t.toString() == 'unreal.UObject') {
        getPointer = '';
        break;
      } else {
        scls = scls.t.get().superClass;
      }
    }
    for (ns in cls.pack) {
      startNamespaces.add('namespace $ns {');
      endNamespaces.add('} // namespace $ns\n');
    }
    var prelude = '';
    if (name == 'unreal.UObject') {
      getPointer = '';
      prelude = '
       int __Compare(const hx::Object *inRHS) const
       {
          const UObject_obj *other = dynamic_cast<const UObject_obj *>(inRHS);
          if (!other)
             return -1;
          return (wrapped == other->wrapped) ? 0 : -1;
       }
      ';
    } else if (name == 'unreal.Wrapper') {
      getPointer = '->ptr->getPointer()';
      prelude = '
       int __Compare(const hx::Object *inRHS) const
       {
          const Wrapper_obj *other = dynamic_cast<const Wrapper_obj *>(inRHS);
          if (!other)
             return -1;
          return (const_cast<Wrapper_obj *>(this)->wrapped->ptr->getPointer() == const_cast<Wrapper_obj *>(other)->wrapped->ptr->getPointer()) ? 0 : -1;
       }
      ';
    }
    var noParams = thisType.withParams([]);
    if (getPointer != null) {
      cls.meta.add(':headerClassCode', [macro $v{'
$prelude
      }; // class definition
      $endNamespaces
        template<>
        template<typename T>
        bool hx::ObjectPtr<${noParams.getCppClass()}_obj>::operator==(const T &inTRHS) const {
          ObjectPtr inRHS(inTRHS.mPtr,false);
          if (mPtr==inRHS.mPtr) return true;
          if (!mPtr || !inRHS.mPtr) return false;
          if (!mPtr->__compare(inRHS.mPtr))
            return true;

          ${noParams.getCppClass()} obj = inRHS;
          if (!obj.mPtr) return false;
          return mPtr->wrapped$getPointer == obj.mPtr->wrapped$getPointer;
        }

        template<>
        template<typename T>
        bool hx::ObjectPtr<${noParams.getCppClass()}_obj>::operator!=(const T &inTRHS) const {
          ObjectPtr inRHS(inTRHS.mPtr,false);
          if (mPtr==inRHS.mPtr) return false;
          if (!mPtr || !inRHS.mPtr) return true;
          if (!mPtr->__compare(inRHS.mPtr))
            return false;

          ${noParams.getCppClass()} obj = inRHS;
          if (!obj.mPtr) return true;
          return mPtr->wrapped$getPointer != obj.mPtr->wrapped$getPointer;
        }
        $startNamespaces
        namespace dummy {
      '}], cls.pos);
    } else if (cls.isInterface) {
      cls.meta.add(':headerClassCode', [macro $v{'
      }; // class definition
      $endNamespaces
        template<>
        template<typename T>
        bool hx::ObjectPtr<${noParams.getCppClass()}_obj>::operator==(const T &inTRHS) const {
          ObjectPtr inRHS(inTRHS.mPtr,false);
          if (mPtr==inRHS.mPtr) return true;
          if (!mPtr || !inRHS.mPtr) return false;
          if (!mPtr->__compare(inRHS.mPtr))
            return true;

          return !mPtr->__GetRealObject()->__Compare(inRHS.mPtr->__GetRealObject());
        }

        template<>
        template<typename T>
        bool hx::ObjectPtr<${noParams.getCppClass()}_obj>::operator!=(const T &inTRHS) const {
          ObjectPtr inRHS(inTRHS.mPtr,false);
          if (mPtr==inRHS.mPtr) return false;
          if (!mPtr || !inRHS.mPtr) return true;
          if (!mPtr->__compare(inRHS.mPtr))
            return false;

          return mPtr->__GetRealObject()->__Compare(inRHS.mPtr->__GetRealObject());
        }
        $startNamespaces
        namespace dummy {
      '}], cls.pos);
    }
  }

}
