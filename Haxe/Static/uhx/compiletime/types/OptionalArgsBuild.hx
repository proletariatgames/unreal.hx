package uhx.compiletime.types;
import haxe.macro.Context;
using Lambda;
using haxe.macro.Tools;

class OptionalArgsBuild {
  static var emptyMark = macro __empty__;
  static var nullExpr = macro null;
  public static function build() {
    var clt = Context.getLocalClass(),
        cls = clt == null ? null : clt.get();
    if (cls == null || !cls.isExtern) {
      return null;
    }

    var fields = Context.getBuildFields(),
        hasAnyOpt = false;
    for (field in fields) {
      var debgs = [];
      var opts = [],
          hasOpts = false;
      switch(field.kind) {
      case FFun(fn):
        for (arg in fn.args) {
          debgs.push(arg.type);
          if (arg.opt || arg.meta.length > 0 || arg.value != null) {
            var meta = null;
            if (arg.meta != null && arg.meta.length > 0) {
              meta = arg.meta.find(function(meta) return meta.name == ':opt');
            }
            if (meta != null && meta.params[0] != null) {
              hasOpts = true;
              opts.push(meta.params[0]);
            } else if (arg.value != null) {
              hasOpts = true;
              opts.push(arg.value);
            } else if (arg.opt) {
              hasOpts = true;
              opts.push(nullExpr);
            } else {
              opts.push(emptyMark);
            }
          } else {
            opts.push(emptyMark);
          }
        }
      case _:
      }
      if (hasOpts) {
        cls.meta.add(':opt_' + field.name, opts, field.pos);
        hasAnyOpt = true;
      }
    }

    return null;
  }
}
