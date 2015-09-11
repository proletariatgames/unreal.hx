package ue4hx.internal;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

using Lambda;
using ue4hx.internal.MacroHelpers;

class NeedsGlueBuild
{
  static var firstCompilation = true;
  static var hasRun = false;
  public static function build():Array<Field>
  {
    registerMacroCalls();

    var hadErrors = false;
    var cls = Context.getLocalClass().get();
    if (!cls.meta.has(':uextern')) {
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
      var glueRefExpr = Context.parse(thisType.withoutModule().getRefName() + '_GlueRef__', cls.pos);

      var fields:Array<Field> = Context.getBuildFields(),
          toAdd = [];
      for (field in fields) {
        var isUProp = field.meta.hasMeta(':UPROPERTY');
        if (isUProp) {
          switch (field.kind) {
            case FVar(t,e) | FProp('default','default',t,e) if (t != null):
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
                'Unreal Glue Extension: UPROPERTY properties with getters and setters are not supported by Unreal',
                field.pos);
              hadErrors = true;
            case FFun(_):
              Context.warning('Unreal Glue Extension: UPROPERTY is not compatible with functions', field.pos);
              hadErrors = true;
            case _:
              Context.warning(
                'Unreal Glue Extension: UPROPERTY properties must have a type',
                field.pos);
              hadErrors = true;
          }
        }
        // TODO check if it's UFUNCTION / UDELEGATE
      }

      // add the haxe-side glue helper
      Context.defineType({
        pack: cls.pack,
        name: cls.name + '_HaxeGlue__',
        pos: cls.pos,
        kind: TDAlias(macro : ue4hx.internal.HaxeGlueGen<$thisComplex> ),
        fields: []
      });

      // add the glueRef definition if needed
      trace(toAdd);
      if (toAdd.length > 0) {
        for (field in toAdd) fields.push(field);
        Context.defineType({
          pack: cls.pack,
          name: cls.name + '_GlueRef__',
          pos: cls.pos,
          kind: TDAlias( macro : ue4hx.internal.DelayedGlueType<$thisComplex> ),
          fields: []
        });

        if (hadErrors)
          Context.error('Unreal Glue Extension: Build failed', cls.pos);
        return fields;
      }
    }

    if (hadErrors)
      Context.error('Unreal Glue Extension: Build failed', cls.pos);

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
