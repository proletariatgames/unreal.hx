package uhx.compiletime.main;
import haxe.io.Path;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import sys.FileSystem;
import sys.io.File;
import uhx.compiletime.types.TypeRef;
using haxe.macro.Tools;

using StringTools;
using Lambda;

class LiveReload
{
  public static function run(file:String)
  {
    Globals.cur.checkBuildVersionLevel();
    var target = Globals.cur.staticBaseDir;
    registerMacroCalls(target);
    Globals.cur.getCompiled(target);
    Globals.cur.readScriptGlues('$target/Data/scriptGlues.txt');
    Globals.cur.inScriptPass = true;

    var pos = Context.currentPos();
    if (!FileSystem.exists(file))
    {
      throw new Error('Nothing to do: Input file "$file" does not exist', pos);
    }

    var compiledHashes = new Map();
    LiveReloadBuild.loadLiveHashes('static-live-hashes.txt', compiledHashes);
    LiveReloadBuild.loadLiveHashes('cppia-live-hashes.txt', compiledHashes);

    var classpaths = [ for (cp in Context.getClassPath()) Path.normalize(cp) ];
    var moduleNames:Map<String, Bool> = Globals.cur.liveReloadModules;
    var modulesToReload:Array<Array<Type>> = [];
    var bound = false;
    Context.onAfterTyping(function(types) {
      if (types.exists(function(t) return Std.string(t) == 'TClassDecl(uhx.compiletime.main.LiveReload)')) {
        return; // macro context
      }
      if (!bound)
      {
        bound = true;
      } else {
        return;
      }

      var block = [];
      for (module in modulesToReload)
      {
        var mainMeta = null;
        for (type in module)
        {
          var cl = switch (type) {
            case TInst(c,_):
              var c = c.get();
              mainMeta = c.meta;
              c;
            case TAbstract(a,_):
              var a = a.get();
              mainMeta = a.meta;
              a.impl.get();
            case _:
              null;
          };
          if (cl != null)
          {
            if (cl.meta.has(':hasLiveReload'))
            {
              var hash = LiveReloadBuild.getLiveHashFor(cl);
              var className = TypeRef.fastClassPath(cl);
              if (compiledHashes[className] != hash)
              {
                var isScript = mainMeta.has(':uscript');
                Context.warning('The current built version of this class (${compiledHashes[className]}) has a different' +
                ' layout than the version that is being built now ($hash). Please perform a full ${isScript ? 'cppia' : 'static'} build', cl.pos);
                Context.warning('UHXERR: A full ${isScript ? 'cppia': 'static'} build is required', cl.pos);
              }
              for (field in cl.fields.get())
              {
                LiveReloadBuild.createFunctionBinding(block, field, false, cl, className, hash);
              }
              for (field in cl.statics.get())
              {
                LiveReloadBuild.createFunctionBinding(block, field, true, cl, className, hash);
              }
            }
          }
        }
      }
      if (block.length == 0)
      {
        Context.warning('No live reloaded function was found', Context.currentPos());
      } else {
        var cls = macro class {
          public static function bindFunctions()
          {
            $b{block};
          }
        };
        cls.name = 'LiveReloadLive';
        cls.pack = ['uhx'];
        Context.defineType(cls);
      }
    });
    Context.onGenerate(function(types) {
      for (t in types)
      {
        switch(t)
        {
          case TInst(c, _):
            switch(c.toString())
            {
              case 'uhx.LiveReloadLive' | 'UnrealCppia':
              case _:
                c.get().exclude();
            }
          case TAbstract(a,_):
            var a = a.get();
            if (a.impl != null)
            {
              a.impl.get().exclude();
            }
          case TEnum(e,_):
            e.get().exclude();
          case _:
        }
      }
    });

    var files = File.getContent(file).trim().split('\n');
    // haxe.macro.CompilationServer.invalidateFiles(files);
    for (file in files)
    {
      var file = Path.normalize(file);
      var fileLower = file.toLowerCase();
      var module = null;
      for (cp in classpaths)
      {
        if (cp != '' && fileLower.startsWith(cp.toLowerCase()))
        {
          var parts = file.substring(cp.length, file.length - 3).split('/');
          if (parts[0] == '')
          {
            parts.shift();
          }
          // haxe.macro.CompilationServer.invalidateFiles([cp + '/' + parts.join('/') + '.hx']);
          module = parts.join('.');
          break;
        }
      }
      if (module == null)
      {
        Context.warning('File $file is not in any classpath', pos);
        continue;
      } else if (!module.startsWith('uhx.compiletime')) {
        moduleNames[module] = true;
        modulesToReload.push(Context.getModule(module));
      }
    }
  }

  static var hasRun = false;
  static var firstCompilation = true;
  private static function registerMacroCalls(target:String) {
    if (hasRun) return;
    hasRun = true;
    #if !haxe4
    if (firstCompilation) {
      firstCompilation = false;
      Context.onMacroContextReused(function() {
        hasRun = false;

        trace('macro context reused');
        Globals.reset();
        return true;
      });
    }
    #end
    Globals.cur.setHaxeRuntimeDir();
  }
}