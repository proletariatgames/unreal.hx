package uhx.build;
#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
using haxe.macro.Tools;
#end

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
          if (key.indexOf('target.') != 0)
          {
            exprs.push(macro $v{key} => $v{defines[key]});
          }
      }
    }
    return { expr:EArrayDecl(exprs), pos:haxe.macro.Context.currentPos() };
  }

  macro public static function getArgs(type:haxe.macro.Expr, args:ExprOf<haxe.DynamicAccess<String>>)
  {
    var t = type.toString();
    var block = [];
    block.push(Context.parse('var ret:$t = cast {}', Context.currentPos()));
    switch (Context.followWithAbstracts(Context.getType(t)))
    {
      case TAnonymous(fields):
        for (field in fields.get().fields)
        {
          var expr = null;
          var name = switch(Context.followWithAbstracts(field.type))
          {
            case TAbstract(a, _):
              a.toString();
            case TInst(c,_):
              c.toString();
            case _:
              'unsupported';
          }
          var arg = macro $args[$v{field.name}];
          switch(name)
          {
            case 'Bool':
              expr = macro $arg == 'true' || $arg == '1';
            case 'Int':
              expr = macro Std.parseInt($arg);
            case 'Float':
              expr = macro Std.parseFloat($arg);
            case 'String':
              expr = macro $arg;
            case _:
              expr = macro try haxe.Json.parse($arg) catch(e:Dynamic) { trace('Error while parsing "' + $v{field.name} + '" ' + $arg + ' : ' + e ); null; };
          }
          var fieldName = field.name;
          block.push(macro if ($args.exists($v{fieldName})) { ret.$fieldName = $expr; });
        }
      case type:
        throw new Error('Invalid type $type for $t', Context.currentPos());
    }
    block.push(macro ret);
    return macro $b{block};
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