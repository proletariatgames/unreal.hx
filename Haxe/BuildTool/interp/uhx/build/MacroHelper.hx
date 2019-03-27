package uhx.build;

class MacroHelper {
  macro public static function getDefines() {
    var defines = haxe.macro.Context.getDefines();
    var exprs = [];
    for (key in defines.keys()) {

      switch(key) {
        case 'interp' |
        'neko' | 'eval' | 'macro' |
        'haxe_ver' | 'source-header' |
        'haxe3' | 'haxe4' | 'true':
        // ignore
        case _:
          exprs.push(macro $v{key} => $v{defines[key]});
      }
    }
    return { expr:EArrayDecl(exprs), pos:haxe.macro.Context.currentPos() };
  }

  macro public static function getIgnoreArgs() {
    var configs = ['UhxBuildData', 'UhxBuildConfig'];
    var args = [
      'builderPath', 'ProjectDir', 'UE_CPPIA_RECOMPILE', 'TargetPlatform', 'sys',
      'ProjectFile', 'TargetConfiguration', 'PluginDir', 'EngineDir', 'TargetName', 'RootDir'
    ];
    for (config in configs) {
      switch (haxe.macro.Context.follow(haxe.macro.Context.getType(config))) {
      case TInst(c,_):
        for (field in c.get().fields.get()) {
          args.push(field.name);
        }
      case TAnonymous(a):
        for (field in a.get().fields) {
          args.push(field.name);
        }
      case t:
        throw 'Invalid type $t for $config';
      }
    }

    return macro $v{args};
  }
}