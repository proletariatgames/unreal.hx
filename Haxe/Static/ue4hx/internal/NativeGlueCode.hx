package ue4hx.internal;
import ue4hx.internal.buf.*;
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

  private var glueTypes:Map<String, ClassType>;
  private var touchedModules:Map<String,Map<String, Bool>>;
  private var modules:Map<String,Bool>;

  public function new() {
    this.touchedModules = new Map();
    this.modules = new Map();
    this.glueTypes = new Map();
  }

  private function touch(file:String, ?module:String) {
    if (module == null) module = Globals.cur.module;
    var mod = this.touchedModules[module];
    if (mod == null) this.touchedModules[module] = mod = new Map();
    mod[file] = true;
  }

  private function writeUEHeader(cl:ClassType, writer:HeaderWriter, gluePath:String, module:String) {
    var gluePack = gluePath.split('.'),
        oldGlueName = gluePack.pop();
    var glueName = oldGlueName + "_UE";
    gluePath += "_UE";

    touch(gluePath, module);
    var dir = module == null ? Globals.cur.haxeRuntimeDir : Globals.cur.haxeRuntimeDir + '/../$module';

    for (pack in gluePack) {
      writer.buf.add('namespace $pack {\n');
    }

    if (cl.params.length > 0) {
      writer.buf += 'template <';
      writer.buf.mapJoin(cl.params, function(p) return 'typename ' + p.name);
      writer.buf += '>';
    }
    writer.buf.add('class ${glueName}_obj : public ${oldGlueName}_obj {\n\tpublic:\n');
    writer.buf.add('\t\t${glueName}_obj(::unreal::helpers::UEPointer *ptr) : ${oldGlueName}_obj(ptr) {}\n');
    for (inc in MacroHelpers.extractStrings(cl.meta, ':glueCppIncludes'))
      writer.include(inc);

    for (field in cl.statics.get().concat(cl.fields.get())) {
      if (field.meta.has(':extern')) continue;
      var glueHeaderCode = MacroHelpers.extractStrings(field.meta, ':ueHeaderCode')[0];
      if (glueHeaderCode != null)
        writer.buf.add('\t\t$glueHeaderCode\n');
      writer.include('<' + gluePack.join('/') + '/' + oldGlueName + '.h>');
      for (inc in MacroHelpers.extractStrings(field.meta, ':glueHeaderIncludes'))
        writer.include(inc);
      for (inc in MacroHelpers.extractStrings(field.meta, ':glueCppIncludes'))
        writer.include(inc);
    }
    writer.buf.add('};\n\n');

    for (pack in gluePack) {
      writer.buf.add('}\n');
    }
    writer.close(module == null ? Globals.cur.module : module);

  }

  private function writeHeader(cl:ClassType, writer:HeaderWriter, gluePath:String, module:String) {
    var gluePack = gluePath.split('.'),
        glueName = gluePack.pop();

    touch(gluePath, module);
    var dir = module == null ? Globals.cur.haxeRuntimeDir : Globals.cur.haxeRuntimeDir + '/../$module';
    var headerDefs = MacroHelpers.extractStrings(cl.meta, ':ueHeaderDef');
    var ctor = null;
    if (cl.meta.has(':ueTemplate'))
      writer.include('<unreal/helpers/UEPointer.h>');

    for (pack in gluePack) {
      writer.buf.add('namespace $pack {\n');
    }
    if (headerDefs.length == 0) {
      var ext = '';
      if (cl.meta.has(':ueTemplate')) {
        ext = ' : public ::unreal::helpers::UEProxyPointer ';
        ctor = '${glueName}_obj(::unreal::helpers::UEPointer *ptr) : ::unreal::helpers::UEProxyPointer(ptr) {}';
      }
      writer.buf.add('class ${glueName}_obj $ext{\n\tpublic:\n');
      if (ctor != null)
        writer.buf.add(ctor);
    } else {
      for (headerDef in headerDefs) {
        writer.buf.add(headerDef);
      }
    }
    for (inc in MacroHelpers.extractStrings(cl.meta, ':glueHeaderIncludes'))
      writer.include(inc);

    for (field in cl.statics.get().concat(cl.fields.get())) {
      if (field.meta.has(':extern')) continue;
      var glueHeaderCode = MacroHelpers.extractStrings(field.meta, ':glueHeaderCode')[0];
      if (glueHeaderCode != null)
        writer.buf.add('\t\t$glueHeaderCode\n');
      for (inc in MacroHelpers.extractStrings(field.meta, ':glueHeaderIncludes'))
        writer.include(inc);
    }
    writer.buf.add('};\n\n');

    if (headerDefs.length == 0)
      writer.buf.add('typedef ${glueName}_obj $glueName;\n\n');
    for (pack in gluePack) {
      writer.buf.add('}\n');
    }
    writer.close(module == null ? Globals.cur.module : module);
  }

  private function writeCpp(cl:ClassType, writer:CppWriter, gluePath:String, module:String) {
    var gluePack = gluePath.split('.'),
        glueName = gluePack.pop();

    touch(gluePath, module);
    var dir = module == null ? Globals.cur.haxeRuntimeDir : Globals.cur.haxeRuntimeDir + '/../$module';
    var headerPath = '$dir/Generated/Public/${gluePack.join('/')}/${glueName}.h';

    writer.include(headerPath);
    for (inc in MacroHelpers.extractStrings(cl.meta, ':glueCppIncludes'))
      writer.include(inc);

    var cppDefs = MacroHelpers.extractStrings(cl.meta, ':ueCppDef');
    if (cppDefs != null) {
      for (cppDef in cppDefs) {
        writer.buf.add(cppDef);
        writer.buf.add('\n');
      }
    }

    for (field in cl.statics.get().concat(cl.fields.get())) {
      if (field.meta.has(':extern')) continue;
      var glueCppCode = MacroHelpers.extractStrings(field.meta, ':glueCppCode')[0];
      if (glueCppCode != null)
        writer.buf.add(glueCppCode);
      writer.buf.add('\n');
      for (inc in MacroHelpers.extractStrings(field.meta, ':glueCppIncludes'))
        writer.include(inc);
    }
    writer.close(module);
  }

  public function writeGlueCpp(cl:ClassType) {
    for (module in MacroHelpers.extractStrings(cl.meta, ':umodule')) {
      modules[module] = true;
    }

    var module = MacroHelpers.extractStrings(cl.meta, ':utargetmodule')[0];
    var gluePath = MacroHelpers.extractStrings(cl.meta, ':ueGluePath')[0];
    var targetDir = module == null ? Globals.cur.haxeRuntimeDir : Globals.cur.haxeRuntimeDir + '/../$module';
    var gluePack = gluePath.split('.'),
    glueName = gluePack.pop();
    var baseDir = '$targetDir/Generated/Private/${gluePack.join('/')}';
    if (!FileSystem.exists(baseDir)) FileSystem.createDirectory(baseDir);
    this.touch(gluePath, module);

    var cppPath = '$baseDir/$glueName.cpp';
    var writer = new CppWriter(cppPath);
    writeCpp(cl, writer, gluePath, module);
  }

  public function writeGlueHeader(cl:ClassType) {
    var gluePath = MacroHelpers.extractStrings(cl.meta, ':ueGluePath')[0];
    var module = MacroHelpers.extractStrings(cl.meta, ':utargetmodule')[0];
    this.touch(gluePath, module);

    var targetDir = module == null ? Globals.cur.haxeRuntimeDir : Globals.cur.haxeRuntimeDir + '/../$module';
    var gluePack = gluePath.split('.'),
        glueName = gluePack.pop();
    var baseDir = '$targetDir/Generated/Public/${gluePack.join('/')}';
    if (!FileSystem.exists(baseDir)) FileSystem.createDirectory(baseDir);
    var headerPath = '$targetDir/Generated/Public/${gluePath.replace('.','/')}.h';
    // C++ doesn't like Windows forward slashes
    headerPath = headerPath.replace('\\','/');

    try {
      switch (Context.follow(Context.getType(gluePath))) {
      case TInst(glueClassRef,_):
        var glueClass = glueClassRef.get();
        glueClass.meta.add(':include', [macro $v{headerPath}], cl.pos);
      case _: throw 'assert: $gluePath is not a class';
      }
    }
    catch(e:Dynamic) {
      // the glue type doesn't exist: this happens when extending a UE4 class
    }

    glueTypes[ TypeRef.fromBaseType(cl, cl.pos).getClassPath() ] = cl;
    var writer = new HeaderWriter(headerPath);
    writer.dontInclude(headerPath);
    writeHeader(cl, writer, gluePath, module);
    if (cl.meta.has(':ueTemplate')) {
      var templWriter = new HeaderWriter('$baseDir/${glueName}_UE.h');
      writeUEHeader(cl, templWriter, gluePath, module);
    }
  }

  public function onAfterGenerate() {
    if (Globals.cur.haxeRuntimeDir == null) return;
    var cppTarget:String = haxe.macro.Compiler.getOutput();
    for (cl in glueTypes) {
      if (cl.meta.has(':ueGluePath')) {
        writeGlueCpp(cl);
      }
      if (cl.meta.has(':uexpose')) {
        // copy the header to the generated folder
        var path = TypeRef.fromBaseType(cl, cl.pos).getClassPath();
        this.touch(path);
        var ref = TypeRef.parseClassName(path);
        var path = path.replace('.','/');

        var headerPath = '$cppTarget/include/${path}.h';
        var targetPath = '${Globals.cur.haxeRuntimeDir}/Generated/Public/$path.h';
        var dir = Path.directory(targetPath);
        if (!FileSystem.exists(dir)) FileSystem.createDirectory(dir);

        var contents = File.getContent(headerPath);
        if (!FileSystem.exists(targetPath) || File.getContent(targetPath) != contents)
          File.saveContent(targetPath, contents);
      }
    }

    // add all extra modules which we depend on
    if (!FileSystem.exists('${Globals.cur.haxeRuntimeDir}/Generated/Data'))
      FileSystem.createDirectory('${Globals.cur.haxeRuntimeDir}/Generated/Data');
    var mfile = sys.io.File.write('${Globals.cur.haxeRuntimeDir}/Generated/Data/modules.txt');
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
      recurse(Globals.cur.haxeRuntimeDir + '/../$key/Generated/Public', '', 'h');
      recurse(Globals.cur.haxeRuntimeDir + '/../$key/Generated/Private', '', 'cpp');
    }
  }

  public function onGenerate(types:Array<Type>) {
    if (Globals.cur.haxeRuntimeDir == null) return;

    for (type in types) {
      switch(type) {
      case TInst(c,tl):
        var typeName = c.toString();
        var cl = c.get();
        if (cl.meta.has(':uexpose')) {
          cl.meta.add(':keep', [], cl.pos);
          cl.meta.add(':nativeGen', [], cl.pos);
          glueTypes[ TypeRef.fromBaseType(cl, cl.pos).getClassPath() ] = cl;
        }
        if (cl.meta.has(':ueGluePath') && !glueTypes.exists(TypeRef.fromBaseType(cl, cl.pos).getClassPath()) ) {
          writeGlueHeader(cl);
        }
      case _:
      }
    }
  }
}
