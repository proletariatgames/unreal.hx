package unreal;
#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import uhx.compiletime.Globals;
import uhx.compiletime.UhxMeta;

using haxe.macro.Tools;
using uhx.compiletime.tools.MacroHelpers;
#end

class I18n {
  /**
    Creates a FText that can be translated using `key` and `text` - same as the Unreal macro LOCTEXT.
    In order to find the LOCTEXT_NAMESPACE, the metadata @:loctext_namespace is searched in the current function or in the
    current class definiton
  **/
  macro public static function loctext(key:String, text:String):ExprOf<unreal.FText> {
    return loctextPvt(key, text);
  }

  /**
    Creates a FText that can be translated using `namespace`, `key` and `text`
  **/
  macro public static function nsloctext(namespace:String, key:String, text:String):ExprOf<unreal.FText> {
    return addLoctext(Context.getLocalClass().get(), text, namespace, key, Context.currentPos());
  }

  #if macro
  public static function loctextPvt(key:String, text:String):Expr {
    var pos = Context.currentPos();
    var cls = Context.getLocalClass();
    var ns = getLoctextNamespace(cls, Context.getLocalMethod(), pos);
    if (ns == null) {
      throw new Error('LOCTEXT: Could not find @:loctext_namespace either in this class, as well as in the current method', pos);
    }

    return addLoctext(cls.get(), text, ns, key, pos);
  }

  public static function addLoctext(cls:ClassType, origText:String, origNs:String, origKey:String, pos:Position):Expr {
    var text = macro @:pos(pos) $v{origText},
        ns = macro @:pos(pos) $v{origNs},
        key = macro @:pos(pos) $v{origKey};
    cls.meta.add(':used_loctext', [text, ns, key], pos);
    if (!Context.defined('UHX_SKIP_LOCTEXT')) {
      var loctext = 'LOCTEXT(`$origText`,`$origNs`,`$origKey`)';
      var icls = switch(Context.follow(Context.getType('unreal.I18n'))) {
        case TInst(cl,_):
          cl;
        case _: throw 'assert';
      };
      if (Context.defined('cppia')) {
        if (!Globals.cur.compiledScriptGluesExists(icls.toString() + ':$loctext') && !Context.defined('display')) {
          Context.warning('UHXERR: The LOCTEXT with key `$origKey`, text `$origText`, and namespace `$origNs` was not compiled in static', pos);
        }
      } else {
        var meta = icls.get().meta;
        if (!meta.has(':ucompiled_$loctext'))
        {
          meta.add(UhxMeta.UCompiled, [macro $v{loctext}], cls.pos);
          meta.add(':ucompiled_$loctext', [], cls.pos);
        }
      }
    }
    return macro @:pos(pos) unreal.internationalization.FInternationalization.ForUseOnlyByLocMacroAndGraphNodeTextLiterals_CreateText($text, $ns, $key);
  }

  public static function getLoctextNamespace(clsRef:Null<Ref<ClassType>>, method:Null<String>, pos:Position):Null<String> {
    if (clsRef == null) {
      return null;
    }
    var cls = clsRef.get();
    if (method != null) {
      #if false // TODO enable this once field cache is set
      var cf = Globals.findField(cls, method, true);
      if (cf == null) {
        cf = Globals.findField(cls, method, false);
      }
      #else
      var cf = cls.findField(method, true);
      if (cf == null) {
        cf = cls.findField(method, false);
      }
      #end
      if (cf == null) {
        Context.warning('Method $method was not found in $clsRef when grabbing LOCTEXT_NAMESPACE', pos);
      } else {
        var meta = cf.meta.extractStrings(':loctext_namespace')[0];
        if (meta != null) {
          return meta;
        }
      }
    }
    return cls.meta.extractStrings(':loctext_namespace')[0];
  }
  #end
}