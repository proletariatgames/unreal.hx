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
  private var touchedModules:Map<String,Map<String, Bool>>;

  @:isVar public static var haxeRuntimeDir(get,null):String;
  public static var module(get,null):String;

  private static function get_haxeRuntimeDir() {
    if (haxeRuntimeDir != null)
      return haxeRuntimeDir;

    setHaxeRuntimeDir();
    return haxeRuntimeDir;
  }

  private static function get_module() {
    var ret = haxeRuntimeDir.replace('\\','/');
    while (ret.endsWith('/'))
      ret = ret.substr(0,-1);
    return ret.substr(ret.lastIndexOf('/')+1);
  }

  private static function setHaxeRuntimeDir() {
    var dir = haxeRuntimeDir = Context.definedValue('haxe_runtime_dir');

#if !bake_externs
    if (dir == null) {
      Context.warning('Unreal Glue: The haxe_runtime_dir directive is not set. This compilation may fail', Context.currentPos());
    }
    else
#end
    {
      haxeRuntimeDir = FileSystem.fullPath(dir);
    }
  }

  public function new() {
    setHaxeRuntimeDir();
    this.touchedModules = new Map();
  }

  private function touch(file:String, ?module:String) {
    if (module == null) module = NativeGlueCode.module;
    var mod = this.touchedModules[module];
    if (mod == null) this.touchedModules[module] = mod = new Map();
    mod[file] = true;
  }

  private function write(type:Type, writer:GlueWriter, gluePath:String, module:String) {
    if (haxeRuntimeDir == null) return;
    switch (type) {
      case TInst(c,tl):
        var gluePack = gluePath.split('.'),
            glueName = gluePack.pop();
        var cl = c.get();

        touch(gluePath, module);
        var dir = module == null ? haxeRuntimeDir : haxeRuntimeDir + '/../$module';
        var headerPath = '$dir/Generated/Public/${gluePack.join('/')}/${glueName}.h';
        var headerDefs = MacroHelpers.extractStrings(cl.meta, ':ueHeaderDef');

        writer.addCppInclude(headerPath);
        for (pack in gluePack) {
          writer.wh('namespace $pack {\n');
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
            writer.wcpp('\n');
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
          writer.wh('}\n');
        }
        writer.close(module);
      case _:
    }
  }

  public function onAfterGenerate() {
    if (haxeRuntimeDir == null) return;
    var modules = new Map();
    var cppTarget:String = haxe.macro.Compiler.getOutput();
    for (type in glueTypes) {
      switch(type) {
        case TInst(c,tl):
          var cl = c.get();
          if (cl.meta.has(':ueGluePath')) {
            for (module in MacroHelpers.extractStrings(cl.meta, ':umodule')) {
              modules[module] = true;
            }

            var module = MacroHelpers.extractStrings(cl.meta, ':utargetmodule')[0];
            var gluePath = MacroHelpers.extractStrings(cl.meta, ':ueGluePath')[0];
            var targetDir = module == null ? haxeRuntimeDir : haxeRuntimeDir + '/../$module';
            var gluePack = gluePath.split('.'),
                glueName = gluePack.pop();
            var baseDir = '$targetDir/Generated/Private/${gluePack.join('/')}';
            if (!FileSystem.exists(baseDir)) FileSystem.createDirectory(baseDir);
            this.touch(gluePath, module);

            var cppPath = '$baseDir/$glueName.cpp';
            var writer = new GlueWriter(null, cppPath, gluePath);
            write(type,writer, gluePath, module);
          }
          if (cl.meta.has(':uexpose')) {
            // copy the header to the generated folder
            this.touch(c.toString());
            var ref = TypeRef.parseClassName( c.toString() );
            var path = c.toString().replace('.','/');

            var headerPath = '$cppTarget/include/${path}.h';
            var targetPath = '$haxeRuntimeDir/Generated/Public/$path.h';
            var dir = Path.directory(targetPath);
            if (!FileSystem.exists(dir)) FileSystem.createDirectory(dir);

            var contents = File.getContent(headerPath);
            if (!FileSystem.exists(targetPath) || File.getContent(targetPath) != contents)
              File.saveContent(targetPath, contents);
          }
        case _:
      }
    }

    // add all extra modules which we depend on
    if (!FileSystem.exists('$haxeRuntimeDir/Generated/Data'))
      FileSystem.createDirectory('$haxeRuntimeDir/Generated/Data');
    var mfile = sys.io.File.write('$haxeRuntimeDir/Generated/Data/modules.txt');
    for (module in modules.keys()) {
      mfile.writeString(module + '\n');
    }
    mfile.close();

    // clean generated folder
    var touched:Map<String,Bool> = null;
    function recurse(path:String, packPath:String, ?ext:String) {
      for (file in FileSystem.readDirectory(path)) {
        if (FileSystem.isDirectory('$path/$file')) {
          if ( !(packPath == '' && file == 'Data') )
            recurse('$path/$file', '$packPath$file.');
        } else if ( (ext != null && Path.extension(file) != ext) || !touched.exists(packPath + Path.withoutExtension(file))) {
          trace('Deleting uneeded file $path/$file');
          FileSystem.deleteFile('$path/$file');
        }
      }
    }
    for (key in this.touchedModules.keys()) {
      touched = this.touchedModules[key];
      recurse(haxeRuntimeDir + '/../$key/Generated/Public', '', 'h');
      recurse(haxeRuntimeDir + '/../$key/Generated/Private', '', 'cpp');
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
          var module = MacroHelpers.extractStrings(cl.meta, ':utargetmodule')[0];
          this.touch(gluePath, module);

          var targetDir = module == null ? haxeRuntimeDir : haxeRuntimeDir + '/../$module';
          var gluePack = gluePath.split('.'),
              glueName = gluePack.pop();
          var baseDir = '$targetDir/Generated/Public/${gluePack.join('/')}';
          if (!FileSystem.exists(baseDir)) FileSystem.createDirectory(baseDir);
          var headerPath = '$baseDir/${glueName}.h';
          // C++ doesn't like Windows forward slashes
          headerPath = headerPath.replace('\\','/');

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
          write(type, writer, gluePath, module);
        }
      case _:
      }
    }
  }
}
