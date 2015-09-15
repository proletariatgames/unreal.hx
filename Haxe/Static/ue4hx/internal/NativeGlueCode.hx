package ue4hx.internal;
import haxe.io.Path;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import sys.FileSystem;
import sys.io.File;
import ue4hx.internal.MacroHelpers;

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

  private function write(type:Type, writer:GlueWriter, gluePath:String) {
    switch (type) {
      case TInst(c,tl):
        var gluePack = gluePath.split('.'),
            glueName = gluePack.pop();
        var cl = c.get();

        var headerPath = '$haxeRuntimeDir/${gluePack.join('/')}/${glueName}.h';
        var headerDefs = MacroHelpers.extractStrings(cl.meta, ':ueHeaderDef');

        writer.addCppInclude(headerPath);
        for (pack in gluePack) {
          writer.wboth('namespace $pack {\n');
        }
        if (headerDefs.length == 0) {
          writer.wh('class ${glueName}_obj {\n\tpublic:\n');
        } else {
          for (headerDef in headerDefs) {
            writer.wh(headerDef);
          }
        }
        for (inc in MacroHelpers.extractStrings(cl.meta, ':glueHeaderIncludes'))
          writer.addHeaderInclude(inc);

        for (inc in MacroHelpers.extractStrings(cl.meta, ':glueCppIncludes'))
          writer.addCppInclude(inc);

        var cppDefs = MacroHelpers.extractStrings(cl.meta, ':ueCppDef');
        if (cppDefs != null) {
          for (cppDef in cppDefs) {
            writer.wcpp(cppDef);
          }
        }

        for (field in cl.statics.get().concat(cl.fields.get())) {
          var glueHeaderCode = MacroHelpers.extractStrings(field.meta, ':glueHeaderCode')[0];
          if (glueHeaderCode != null)
            writer.wh('\t\t$glueHeaderCode\n');
          for (inc in MacroHelpers.extractStrings(field.meta, ':glueHeaderIncludes'))
            writer.addHeaderInclude(inc);

          var glueCppCode = MacroHelpers.extractStrings(field.meta, ':glueCppCode')[0];
          if (glueCppCode != null)
            writer.wcpp(glueCppCode);
          writer.wcpp('\n');
          for (inc in MacroHelpers.extractStrings(field.meta, ':glueCppIncludes'))
            writer.addCppInclude(inc);
        }
        writer.wh('};\n\n');

        for (pack in gluePack) {
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
          if (cl.meta.has(':ueGluePath')) {
            var gluePath = MacroHelpers.extractStrings(cl.meta, ':ueGluePath')[0];
            var cppPath = '$haxeRuntimeDir/${gluePath.replace('.','/')}.cpp';
            var writer = new GlueWriter(null, cppPath, gluePath);
            write(type,writer, gluePath);
          }
          if (cl.meta.has(':uexpose')) {
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
        var cl = c.get();
        if (cl.meta.has(':uexpose')) {
          cl.meta.add(':keep', [], cl.pos);
          cl.meta.add(':nativeGen', [], cl.pos);
          glueTypes.push(type);
        }
        if (cl.meta.has(':ueGluePath')) {
          var cl = c.get();
          var gluePath = MacroHelpers.extractStrings(cl.meta, ':ueGluePath')[0];

          var gluePack = gluePath.split('.'),
              glueName = gluePack.pop();
          var baseDir = '$haxeRuntimeDir/${gluePack.join('/')}';
          if (!FileSystem.exists(baseDir)) FileSystem.createDirectory(baseDir);
          var headerPath = '$baseDir/${glueName}.h';

          try {
            switch (Context.follow(Context.getType(gluePath))) {
            case TInst(glueClassRef,_):
              var glueClass = glueClassRef.get();
              glueClass.meta.add(':include', [macro $v{headerPath}], cl.pos);
            case _: throw 'assert: $typeName ($gluePath is not a class)';
            }
          }
          catch(e:Dynamic) {
            // the glue type doesn't exist: this happens when extending a UE4 class
          }

          glueTypes.push(type);
          var writer = new GlueWriter(headerPath, null, gluePath);
          write(type, writer, gluePath);
        }
      case _:
      }
    }
  }
}
