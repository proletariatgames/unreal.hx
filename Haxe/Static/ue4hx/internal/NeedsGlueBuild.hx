package ue4hx.internal;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

using Lambda;
using ue4hx.internal.MacroHelpers;
using haxe.macro.Tools;

class NeedsGlueBuild
{
  static var firstCompilation = true;
  static var hasRun = false;
  public static function build():Array<Field>
  {
    registerMacroCalls();

    var cls = Context.getLocalClass().get();
    if (!cls.meta.has(':uextern')) {
      // FIXME: allow any namespace by using @:native; add @:native handling
      if (cls.pack.length == 0)
        throw new Error('Unreal Glue Extension: Do not extend Unreal types on the global namespace. Use a package', cls.pos);
      var hadErrors = false;
      // if we don't have the @:uextern meta, it means
      // we're subclassing an extern class

      // if it's a UObject descendant:
      // FIXME: add support for interfaces as well
      var isUObject = false,
          superClass = cls.superClass;
      while (superClass != null) {
        if (superClass.t.toString() == 'unreal.UObject') {
          isUObject = true;
          break;
        }
        superClass = superClass.t.get().superClass;
      }
      // non-extern type that derives from UObject:
      // change uproperties to call getter/setters
      // warn if constructors are created
      var thisType = TypeRef.fromBaseType(cls, cls.pos),
          thisComplex = thisType.toComplexType();

      // we need to indirectly reference it since the @:genericBuild cannot have its
      // static fields accessed directly
      var glueRefExpr = macro ue4hx.internal.DelayedGlue.getGlueType();

      var superCalls = new Map(),
          uprops = [];
      var fields:Array<Field> = Context.getBuildFields(),
          toAdd = [];
      for (field in fields) {
        if (field.access != null && field.access.has(AOverride)) {
          // TODO: should we check for non-override fields as well? This would
          //       add some overhead for all override fields, which is something I'd like to avoid for now
          //       specially since super calling in other fields doesn't seem particularly useful
          switch (field.kind) {
          case FFun(fn) if (fn.expr != null):
            function map(e:Expr) {
              return switch (e.expr) {
              case ECall(macro super.$field, args):
                superCalls[field] = field;
                { expr:ECall(macro @:pos(e.pos) ue4hx.internal.DelayedGlue.getSuperExpr($v{field}), args), pos: e.pos };
              case _:
                e.map(map);
              }
            }
            fn.expr = map(fn.expr);
          case _:
          }
        }
        var isUProp = field.meta.hasMeta(':uproperty');
        if (isUProp) {
          switch (field.kind) {
            case FVar(t,e) | FProp('default','default',t,e) if (t != null):
              uprops.push(field.name);
              var getter = 'get_' + field.name,
                  setter = 'set_' + field.name;
              var dummy = if (field.access != null && field.access.has(AStatic)) {
                macro class {
                  private function $getter():$t return $glueRefExpr.$getter();
                  private function $setter(val:$t):$t {
                    $glueRefExpr.$setter(val);
                    return val;
                  }
                }
              } else {
                macro class {
                  private function $getter():$t return $glueRefExpr.$getter(this);
                  private function $setter(val:$t):$t {
                    $glueRefExpr.$setter(this, val);
                    return val;
                  }
                }
              };

              for (field in dummy.fields) toAdd.push(field);
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
        // TODO check if it's UFUNCTION / UDELEGATE
      }

      if (uprops.length > 0)
        cls.meta.add(':uproperties', [ for (prop in uprops) macro $v{prop} ], cls.pos);
      cls.meta.add(':usupercalls', [ for (prop in uprops) macro $v{prop} ], cls.pos);
      // add the haxe-side glue helper
      toAdd.push((macro class {
        @:extern private static function __internal_typing() {
          var x : ue4hx.internal.HaxeExposeGen<$thisComplex> = null;
        };
      }).fields[0]);

      // add the glueRef definition if needed
      for (field in toAdd) fields.push(field);

      if (hadErrors)
        Context.error('Unreal Glue Extension: Build failed', cls.pos);
      return fields;
    }

    return null;
  }

  /**
    Registers onGenerate handler once per compilation
   **/
  public static function registerMacroCalls() {
    if (hasRun) return;
    hasRun = true;
    if (firstCompilation) {
      firstCompilation = false;
      Context.onMacroContextReused(function() {
        trace('reusing macro context');
        hasRun = false;
        return true;
      });
    }
    var nativeGlue = new NativeGlueCode();
    Context.onGenerate( nativeGlue.onGenerate );
    // seems like Haxe macro interpreter has a problem with void member closures,
    // so we need this function definition
    Context.onAfterGenerate( function() nativeGlue.onAfterGenerate() );
    haxe.macro.Compiler.include('unreal.helpers');
  }
}
