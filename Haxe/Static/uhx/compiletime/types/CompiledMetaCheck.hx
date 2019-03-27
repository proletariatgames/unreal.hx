package uhx.compiletime.types;
import haxe.macro.Context;
using StringTools;

class CompiledMetaCheck {
  public static function build(name:String) {
    if (!Globals.cur.allCompiledModules.exists(name)) {
      return null;
    }
    var fields = Context.getBuildFields();
    var found = false;
    for (field in fields) {
      if (field.meta != null) {
        field.meta = field.meta.filter(function(meta) {
          if (meta.name == ':deprecated' && meta.params != null && meta.params.length == 1) {
            switch(meta.params[0].expr) {
              case EConst(CString(name)) if (name.startsWith('UHXERR:')):
                found = true;
                return false;
              case _:
            }
          }
          return true;
        });
      }
    }
    if (found) {
      return fields;
    } else {
      return null;
    }
  }
}