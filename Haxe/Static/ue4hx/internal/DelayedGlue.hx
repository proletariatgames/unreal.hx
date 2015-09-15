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
    return getGlueType_impl(cls, pos);
  }


  macro public static function getSuperExpr(field:String):haxe.macro.Expr {
    var cls = Context.getLocalClass().get(),
        pos = Context.currentPos();
    // make sure that the super field was not already defined in haxe code
    var sup = cls.superClass;
    while (sup != null) {
      var scls = sup.t.get();
      if (scls.meta.has(':uextern')) break;
      for (sfield in scls.fields.get()) {
        if (sfield.name == field) {
          // this field was already defined in a Haxe class; just use normal super
          return macro @:pos(pos) super.$field;
        }
      }
      sup = scls.superClass;
    }

    var glueExpr = getGlueType_impl(cls, pos),
        fieldName = 'ue4hx_super__' + field;
    return macro null;
    // return macro @:pos(pos) $glueExpr.$fieldName;
  }

#if macro
  private static function getGlueType_impl(cls:ClassType, pos:Position) {
    var type = TypeRef.fromBaseType(cls, pos);
    var glue = type.getGlueHelperType();
    try {
      // ensure the glue is built
      Context.getType( glue.getClassPath() );
    }
    catch(e:Dynamic) {
      var msg = Std.string(e);
      if (msg.startsWith('Type not found')) {
        // type is not built. build it!
        new DelayedGlue(cls,pos).build();
      } else {
        neko.Lib.rethrow(e);
      }
    }

    return Context.parse( glue.getClassPath(), pos );
  }
#end

// #if macro
  var cls:haxe.macro.Type.ClassType;
  var pos:haxe.macro.Expr.Position;

  public function new(cls, pos) {
    this.cls = cls;
    this.pos = pos;
  }

  public function build() {
    var cls = this.cls,
        typeRef = TypeRef.fromBaseType( cls, this.pos ),
        buildFields = [];

    // TODO: clean up those references with a better interface
    // var ueName = BuildExpose.getNativeUeName(cls);
    for (prop in MacroHelpers.extractStrings( cls.meta, ':uproperties' )) {
    }
  }

// #end
}
