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

  private var glueTypes:Map<String, Ref<ClassType>>;
  private var touchedModules:Map<String,Map<String, TouchKind>>;
  private var modules:Map<String,Bool>;
  private var infos:Map<String,GlueInfo>;

  private var stampOutput:String;

  public function new() {
    this.touchedModules = new Map();
    this.modules = new Map();
    this.glueTypes = new Map();
    this.infos = new Map();
    this.stampOutput = haxe.macro.Compiler.getOutput() + '/Stamps';
    if (!FileSystem.exists(this.stampOutput)) {
      FileSystem.createDirectory(this.stampOutput);
    }
  }

  private function getInfo(base:BaseType) {
    var name = base.pack.join('.') + '.' + base.name;
    var ret = this.infos[name];
    if (ret == null) {
      this.infos[name] = ret = GlueInfo.fromBaseType(base);
    }
    return ret;
  }

  public function touch(kind:TouchKind, file:String, ?module:String) {
    if (module == null) module = Globals.cur.module;
    var mod = this.touchedModules[module];
    if (mod == null) this.touchedModules[module] = mod = new Map();
    var ret = mod[file];
    if (ret == null) {
      ret = kind;
    } else {
      ret = ret | kind;
    }
    mod[file] = ret;
  }

  private function writeUEHeader(cl:ClassType, writer:HeaderWriter, gluePath:String, info:GlueInfo) {
    var gluePack = gluePath.split('.'),
        oldGlueName = gluePack.pop();
    var glueName = oldGlueName + "_UE";
    gluePath += "_UE";

    touch(THeader, gluePath, info.targetModule);
    writer.buf.add('#ifndef HXCPP_CLASS_ATTRIBUTES\n#define SCOPED_HXCPP\n#define HXCPP_CLASS_ATTRIBUTES MAY_EXPORT_SYMBOL\n#endif\n');
    writer.include('uhx/StructInfo_UE.h');
    writer.include('uhx/TypeTraits.h');

    var data = MacroHelpers.extractStrings(cl.meta, ':ueHeaderStart')[0];
    if (data != null) {
      writer.buf.add(data);
    }

    for (pack in gluePack) {
      writer.buf.add('namespace $pack {\n');
    }

    var base:BaseType = switch(cl.kind) {
      case KAbstractImpl(a):
        a.get();
      case _:
        cl;
    };
    if (base.params.length > 0) {
      writer.buf << 'template <';
      writer.buf.mapJoin(base.params, function(p) return 'class ' + p.name);
      writer.buf << '>';
    }
    writer.buf.add('class HXCPP_CLASS_ATTRIBUTES ${glueName}_obj : public ${oldGlueName}_obj {\n\tpublic:\n');
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

    data = MacroHelpers.extractStrings(cl.meta, ':ueHeaderEnd')[0];
    if (data != null) {
      writer.buf.add(data);
    }
    writer.buf.add('#ifdef SCOPED_HXCPP\n#undef SCOPED_HXCPP\n#undef HXCPP_CLASS_ATTRIBUTES\n#endif\n');
    writer.close(info.targetModule);
  }

  private function writeHeader(cl:ClassType, writer:HeaderWriter, gluePath:String, info:GlueInfo) {
    var gluePack = gluePath.split('.'),
        glueName = gluePack.pop();

    touch(THeader, gluePath, info.targetModule);
    var headerDefs = MacroHelpers.extractStrings(cl.meta, ':ueHeaderDef');

    writer.buf.add('#ifndef HXCPP_CLASS_ATTRIBUTES\n#define SCOPED_HXCPP\n#define HXCPP_CLASS_ATTRIBUTES MAY_EXPORT_SYMBOL\n#endif\n');

    if (cl.meta.has(':ueTemplate')) {
      // writer.include('<UEPointer.h>');
    }

    for (pack in gluePack) {
      writer.buf.add('namespace $pack {\n');
    }
    if (headerDefs.length == 0) {
      var ext = '';
      writer.buf.add('class HXCPP_CLASS_ATTRIBUTES ${glueName}_obj $ext{\n\tpublic:\n');
    } else {
      for (headerDef in headerDefs) {
        writer.buf.add(headerDef);
      }
    }
    for (inc in MacroHelpers.extractStrings(cl.meta, ':glueHeaderIncludes'))
      writer.include(inc);

    for (extraField in MacroHelpers.extractStrings(cl.meta, ':glueHeaderClass')) {
      writer.buf.add(extraField);
    }

    for (field in cl.statics.get().concat(cl.fields.get())) {
      if (field.meta.has(':extern')) continue;
      var glueHeaderCode = MacroHelpers.extractStrings(field.meta, ':glueHeaderCode')[0];
      if (glueHeaderCode != null)
        writer.buf.add('\t\t$glueHeaderCode\n');
      for (inc in MacroHelpers.extractStrings(field.meta, ':glueHeaderIncludes'))
        writer.include(inc);
      for (fwd in MacroHelpers.extractStrings(field.meta, ':headerForwards'))
        writer.forwardDeclare(fwd);
    }
    writer.buf.add('};\n\n');

    if (headerDefs.length == 0)
      writer.buf.add('typedef ${glueName}_obj $glueName;\n\n');
    for (pack in gluePack) {
      writer.buf.add('}\n');
    }
    writer.buf.add('#ifdef SCOPED_HXCPP\n#undef SCOPED_HXCPP\n#undef HXCPP_CLASS_ATTRIBUTES\n#endif\n');
    writer.close(info.targetModule);
  }

  private function writeCpp(cl:ClassType, writer:CppWriter, gluePath:String, info:GlueInfo) {
    var headerPath = info.getHeaderPath(gluePath);

    writer.include(headerPath);
    for (inc in MacroHelpers.extractStrings(cl.meta, ':glueCppIncludes')) {
      writer.include(inc);
    }

    var cppDefs = MacroHelpers.extractStrings(cl.meta, ':ueCppDef');
    if (cppDefs != null) {
      for (cppDef in cppDefs) {
        var def = cppDef.trim();
        if (def.length > 0) {
          writer.buf.add(cppDef);
          writer.buf.add('\n');
        }
      }
      // trace(cl.name);
      // trace('==========================================');
      //   for (field in cl.statics.get().concat(cl.fields.get())) {
      //     trace(field.name, field.meta.has(':extern'));
      //     var glueCppCode = MacroHelpers.extractStrings(field.meta, ':glueCppCode')[0];
      //     trace(glueCppCode);
      //   }
    }

    for (field in cl.statics.get().concat(cl.fields.get())) {
      if (field.meta.has(':extern')) continue;
      var glueCppCode = MacroHelpers.extractStrings(field.meta, ':glueCppCode')[0];
      if (glueCppCode != null) {
        writer.buf.add(glueCppCode);
        writer.buf.add('\n');
      }
      for (inc in MacroHelpers.extractStrings(field.meta, ':glueCppIncludes'))
        writer.include(inc);
    }
    writer.close(info.targetModule);
  }

  public function writeGlueCpp(cl:ClassType) {
    for (module in MacroHelpers.extractStrings(cl.meta, ':umodule')) {
      modules[module] = true;
    }

    var info = this.getInfo(cl);
    var gluePath = MacroHelpers.extractStrings(cl.meta, ':ueGluePath')[0];
    this.touch(TCpp, gluePath, info.targetModule);
    var stampPath = '$stampOutput/$gluePath.stamp';
    var cppPath = info.getCppPath(gluePath, true);

    if (!checkShouldGenerate(stampPath, cppPath, cl))
      return;

    var writer = new CppWriter(cppPath);
    writeCpp(cl, writer, gluePath, info);
    File.saveContent(stampPath,'');
  }

  private function checkShouldGenerate(stampPath:String, targetPath:String, clt:ClassType):Bool {
    if (Globals.cur.hasOlderCache) {
      if (!FileSystem.exists(targetPath)) return true;
      if (clt.meta.has(':wasCompiled')) {
        return false;
      }
      if (clt.meta.has(':uextern')) {
        // we only need to update if the source file was changed more recently
        var sourceFile = MacroHelpers.getPath( Context.getPosInfos(clt.pos).file );
        if (sourceFile != null && FileSystem.exists(stampPath) && FileSystem.stat(stampPath).mtime.getTime() > FileSystem.stat(sourceFile).mtime.getTime()) {
          return false;
        }
      }
    }
    return true;
  }

  public function writeGlueHeader(cl:ClassType) {
    var gluePath = MacroHelpers.extractStrings(cl.meta, ':ueGluePath')[0];
    var info = this.getInfo(cl);
    this.touch(THeader, gluePath, info.targetModule);

    var headerPath = info.getHeaderPath(gluePath,true);
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

    var stampPath = '$stampOutput/$gluePath.stamp',
        shouldGenerate = checkShouldGenerate(stampPath, headerPath, cl);
    if (cl.meta.has(':ueTemplate')) {
      touch(THeader, gluePath + '_UE', info.targetModule);
    }

    if (shouldGenerate) {
      var writer = new HeaderWriter(headerPath);
      writer.dontInclude(headerPath);
      writeHeader(cl, writer, gluePath, info);
      if (cl.meta.has(':ueTemplate')) {
        var templWriter = new HeaderWriter(headerPath.substr(0,-2) + '_UE.h');
        writeUEHeader(cl, templWriter, gluePath, info);
      }
      File.saveContent(stampPath,'');
    }
  }

  public function onAfterGenerate() {
    if (Globals.cur.haxeRuntimeDir == null) return;
    var cppTarget:String = haxe.macro.Compiler.getOutput();
    for (t in glueTypes) {
      var cl = t.get();
      var type = TypeRef.fromBaseType(cl, cl.pos);
      var cpath = type.getClassPath();
      // var cl = switch(Context.getType( cpath )) {
      //   case TInst(c,_): c.get();
      //   case _: throw 'assert';
      // };
      if (cl.meta.has(':ueGluePath')) {
        writeGlueCpp(cl);
      }
      if (!cl.isExtern && cl.meta.has(':uexpose')) {
        var info = this.getInfo(cl);
        var runtimeDir = info.basePath;
        // copy the header to the generated folder
        this.touch(THeader, cpath, info.targetModule);
        var path = cpath.replace('.','/');

        var headerPath = '$cppTarget/include/${path}.h';
        if (!FileSystem.exists(headerPath)) continue;
        var targetPath = '$runtimeDir/Generated/Public/$path.h';
        var dir = Path.directory(targetPath);
        var stampPath = '$stampOutput/$cpath.stamp';
        var shouldCopy = checkShouldGenerate(stampPath, targetPath, cl);

        if (shouldCopy) {
          if (!FileSystem.exists(dir)) FileSystem.createDirectory(dir);

          var contents = File.getContent(headerPath);
          // take off the self-include
          contents = contents.replace('#include <$path.h>', '');
          if (!FileSystem.exists(targetPath) || File.getContent(targetPath) != contents)
            File.saveContent(targetPath, contents);
          File.saveContent(stampPath, '');
        }
      }

      var dependencies = MacroHelpers.extractStrings(cl.meta, ':ufiledependency');
      var module = MacroHelpers.extractStrings(cl.meta, ':utargetmodule')[0];
      for (dep in dependencies) {
        var idx = dep.indexOf('@');
        if (idx >= 0) {
          var s = dep.split('@');
          touch(TAll, s[0], s[1]);
        } else {
          touch(TAll, dep, module);
        }
      }
    }

    // add all extra modules which we depend on
    if (!FileSystem.exists('$cppTarget/Data'))
      FileSystem.createDirectory('$cppTarget/Data');
    var mfile = sys.io.File.write('$cppTarget/Data/modules.txt');
    for (module in modules.keys()) {
      mfile.writeString(module + '\n');
    }
    mfile.close();

    // clean generated folder
    var touched:Map<String,TouchKind> = null;
    function recurse(path:String, packPath:String, ext:String, kind:TouchKind):Bool {
      var foundFile = false;
      for (file in FileSystem.readDirectory(path)) {
        if (FileSystem.isDirectory('$path/$file')) {
          if ( !(packPath == '' && file == 'Data') ) {
            var found = recurse('$path/$file', '$packPath$file.', ext, kind);
            foundFile = foundFile || found;
          }
        } else {
          var ret = touched[packPath + Path.withoutExtension(file)];
          if ( ret == null || !ret.hasAny(kind) || (ext != null && Path.extension(file) != ext) ) {
            trace('Deleting uneeded file $path/$file');
            FileSystem.deleteFile('$path/$file');
          } else {
            foundFile = true;
          }
        }
      }
      if (!foundFile) {
        try {
          FileSystem.deleteDirectory(path);
        }
        catch (e:Dynamic) {}
      }
      return foundFile;
    }
    for (key in this.touchedModules.keys()) {
      touched = this.touchedModules[key];
      recurse(Globals.cur.haxeRuntimeDir + '/../$key/Generated/Public', '', 'h', THeader);
      recurse(Globals.cur.haxeRuntimeDir + '/../$key/Generated/Private', '', 'cpp', TCpp);
    }
  }

  public function onGenerate(types:Array<Type>) {
    if (Globals.cur.haxeRuntimeDir == null) return;

    for (type in types) {
      switch(type) {
      case TInst(c,tl):
        var typeName = c.toString();
        var cl = c.get();
        switch(cl.kind) {
        case KAbstractImpl(a):
          var a = a.get();
          for (meta in a.meta.get()) {
            cl.meta.add(meta.name, meta.params, meta.pos);
          }
        case _:
        }
        if (cl.meta.has(':alreadyCompiled')) {
          if (!cl.meta.has(':wasCompiled')) {
            cl.meta.add(':wasCompiled',[],cl.pos);
          }
        } else {
          cl.meta.add(':alreadyCompiled',[],cl.pos);
        }
        if (cl.meta.has(':uexpose')) {
          if (!cl.meta.has(':ifFeature'))
            cl.meta.add(':keep', [], cl.pos);
          cl.meta.add(':nativeGen', [], cl.pos);
          glueTypes[ TypeRef.fromBaseType(cl, cl.pos).getClassPath() ] = c;
        }
        if (cl.meta.has(':ueGluePath') && !glueTypes.exists(TypeRef.fromBaseType(cl, cl.pos).getClassPath()) ) {
          glueTypes[ TypeRef.fromBaseType(cl, cl.pos).getClassPath() ] = c;
          writeGlueHeader(cl);
        }
        // add only once - we'll select a type that is always compiled
        if (typeName == 'unreal.helpers.HxcppRuntime' && !cl.meta.has(':buildXml')) {
          var dir = Globals.cur.haxeRuntimeDir;
          if (Globals.cur.glueTargetModule != null) {
            dir += '/../${Globals.cur.glueTargetModule}';
          }
          cl.meta.add(':buildXml', [macro $v{
          '<files id="haxe">
            <compilerflag value="-I$dir/Generated/Shared" />
          </files>'
          }], cl.pos);
        }
        if (cl.meta.has(':uintrinsic')) {
          var incPath = MacroHelpers.extractStrings(cl.meta, ':uintrinsic')[0];
          // var targetModule = Globals.cur.haxeTargetModule;
          var targetDir = Globals.cur.haxeRuntimeDir;
          if (Globals.cur.glueTargetModule != null) {
            targetDir += '/../${Globals.cur.glueTargetModule}';
          }
          cl.meta.add(':include', [macro $v{'$targetDir/$incPath'}], cl.pos);
        }
      case TEnum(e, _):
        var et = e.get();
        if (et.meta.has(':uenum')) {
          var info = this.getInfo(et);
          touch(THeader, info.uname.getClassPath(), info.targetModule);
        }
      case _:
      }
    }
  }
}

@:enum abstract TouchKind(Int) from Int {
  var TCpp = 1;
  var THeader = 2;
  var TAll = 3;

  inline private function t() {
    return this;
  }

  @:op(A|B) inline public function add(f:TouchKind):TouchKind {
    return this | f.t();
  }

  inline public function hasAll(flag:TouchKind):Bool {
    return this & flag.t() == flag.t();
  }

  inline public function hasAny(flag:TouchKind):Bool {
    return this & flag.t() != 0;
  }

  inline public function without(flags:TouchKind):TouchKind {
    return this & ~(flags.t());
  }
}
