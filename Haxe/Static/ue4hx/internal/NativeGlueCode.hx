package ue4hx.internal;
import haxe.io.Path;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import sys.FileSystem;
import sys.io.File;

using StringTools;

/**
  Takes care of generating the native glue code - both header and source files
  This is called by `GlueGenerator`
 **/
class NativeGlueCode
{

  private var glueTypes:Array<Type>;
  private var haxeRuntimeDir:String;

  public function new() {
    haxeRuntimeDir = Context.definedValue('haxe_runtime_dir');
    if (haxeRuntimeDir == null) {
      Context.warning('Unreal Glue: The haxe_runtime_dir directive is not set. This compilation may fail', Context.currentPos());
    } else {
      haxeRuntimeDir = FileSystem.fullPath(haxeRuntimeDir) + '/Generated';
    }
  }

  private function write(type:Type, writer:GlueWriter) {
    switch (type) {
      case TInst(c,tl):
        var cl = c.get();

        var headerPath = '$haxeRuntimeDir/${cl.pack.join('/')}/${cl.name}.h';

        writer.addCppInclude(headerPath);
        for (pack in cl.pack) {
          writer.wboth('namespace $pack {\n');
        }
        writer.wh('class ${cl.name}_obj {\n\tpublic:\n');
        for (inc in extract(cl.meta, 'glueHeaderIncludes'))
          writer.addHeaderInclude(inc);

        for (inc in extract(cl.meta, 'glueCppIncludes'))
          writer.addCppInclude(inc);

        for (field in cl.statics.get()) {
          var glueHeaderCode = extract(field.meta, 'glueHeaderCode')[0];
          if (glueHeaderCode != null)
            writer.wh('\t\t$glueHeaderCode\n');
          for (inc in extract(field.meta, 'glueHeaderIncludes'))
            writer.addHeaderInclude(inc);

          // TODO: use onAfterGenerate to genenrate the cpp glue code
          var glueCppCode = extract(field.meta, 'glueCppCode')[0];
          if (glueCppCode != null)
            writer.wcpp(glueCppCode);
          writer.wcpp('\n');
          for (inc in extract(field.meta, 'glueCppIncludes'))
            writer.addCppInclude(inc);
        }
        writer.wh('};\n\n');

        for (pack in cl.pack) {
          writer.wboth('}\n');
        }
        writer.close();
      case _:
    }
  }

  public function onAfterGenerate() {
    var cppTarget:String = haxe.macro.Compiler.getOutput();
    for (type in glueTypes) {
      switch(type) {
        case TInst(c,tl):
          var cl = c.get();
          if (cl.meta.has(':unrealGlue')) {
            var cppPath = '$haxeRuntimeDir/${c.toString().replace('.','/')}.cpp';
            var writer = new GlueWriter(null, cppPath, c.toString());
            write(type,writer);
          } else if (cl.meta.has(':ue4expose')) {
            // copy the header to the generated folder
            var path = c.toString().replace('.','/');
            var headerPath = '$cppTarget/include/${path}.h';
            var targetPath = '$haxeRuntimeDir/$path.h';
            var dir = Path.directory(targetPath);
            if (!FileSystem.exists(dir)) FileSystem.createDirectory(dir);

            var contents = File.getContent(headerPath);
            if (!FileSystem.exists(targetPath) || File.getContent(targetPath) != contents)
              File.saveContent(targetPath, contents);
          }
        case _:
      }
    }
  }

  public function onGenerate(types:Array<Type>) {
    glueTypes = [];
    if (haxeRuntimeDir == null) return;

    for (type in types) {
      switch(type) {
      case TInst(c,tl):
        var typeName = c.toString();
        if (typeName.startsWith('unreal.glue')) {
          var cl = c.get();
          if (!cl.meta.has(':unrealGlue'))
            continue;
          var baseDir = '$haxeRuntimeDir/${cl.pack.join('/')}';
          if (!FileSystem.exists(baseDir)) FileSystem.createDirectory(baseDir);
          var headerPath = '$baseDir/${cl.name}.h';
          cl.meta.add(':include', [macro $v{headerPath}], cl.pos);

          glueTypes.push(type);
          var writer = new GlueWriter(headerPath, null, c.toString());
          write(type, writer);
        } else if (typeName.startsWith('unreal.helpers')) {
          var cl = c.get();
          if (!cl.meta.has(':ue4expose'))
            continue;
          glueTypes.push(type);
        }
      case _:
      }
    }
  }

  private static function extract(meta:MetaAccess, name:String):Array<String> {
    var meta = meta.extract(name);
    if (meta == null || meta.length == 0 || meta[0].params == null || meta[0].params.length == 0)
      return [];
    var ret = [];
    for (param in meta[0].params) {
      switch(param.expr) {
        case EConst(CString(s)):
          ret.push(s);
        case _:
          throw 'assert';
      }
    }
    return ret;
  }
}
