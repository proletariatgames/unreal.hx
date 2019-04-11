package uhx.compiletime.main;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import sys.FileSystem;
import sys.io.File;
import uhx.compiletime.tools.*;
import uhx.compiletime.types.*;

using StringTools;
using uhx.compiletime.tools.MacroHelpers;

/**
  Takes care of generating the native glue code - both header and source files
  This is called by `GlueGenerator`
 **/
class NativeGlueCode
{
  public var glues(default, null):GlueManager;
  private var glueTypes:Map<String, Ref<ClassType>>;
  private var modules:Map<String,Bool>;
  private var producedFiles:Array<String>;

  private var stampOutput:String;
  // This version gets bumped each time a fundamental glue generation has changed
  // so that all previous genereated files should be considered outdated
  private static var glueGenerationVersion = 1;

  public function new() {
    this.glues = new GlueManager(this);
    this.producedFiles = [];
    this.modules = new Map();
    this.glueTypes = new Map();
    this.stampOutput = haxe.macro.Compiler.getOutput() + '/Stamps/$glueGenerationVersion';
    if (!FileSystem.exists(this.stampOutput)) {
      FileSystem.createDirectory(this.stampOutput);
    }
    Globals.cur.glueManager = this.glues;
  }

  public function addProducedFile(file:String) {
    this.producedFiles.push(file);
  }

  private function getNewerUhxStamp() {
    var best = .0;
    function recurse(dir:String) {
      for (file in FileSystem.readDirectory(dir)) {
        if (file.endsWith('.hx')) {
          var time = FileSystem.stat('$dir/$file').mtime.getTime();
          if (time > best) {
            best = time;
          }
        } else if (FileSystem.isDirectory('$dir/$file')) {
          recurse('$dir/$file');
        }
      }
    }
    for (cp in Context.getClassPath()) {
      if (FileSystem.exists('$cp/uhx/compiletime') && FileSystem.isDirectory('$cp/uhx/compiletime')) {
        recurse('$cp/uhx/compiletime');
      }
    }
    return best;
  }

  private function writeUEHeader(cl:ClassType, writer:HeaderWriter, gluePath:String) {
    var gluePack = gluePath.split('.'),
        oldGlueName = gluePack.pop();
    var glueName = oldGlueName + "_UE";
    gluePath += "_UE";

    writer.buf.add('#ifndef HXCPP_CLASS_ATTRIBUTES\n#define SCOPED_HXCPP\n#define HXCPP_CLASS_ATTRIBUTES MAY_EXPORT_SYMBOL\n#endif\n');
    writer.include('uhx/StructInfo_UE.h');
    writer.include('uhx/TypeTraits.h');

    var data = cl.meta.extractStrings(':ueHeaderStart')[0];
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
    for (inc in cl.meta.extractStrings(':glueCppIncludes')) {
      writer.include(inc);
    }

    for (field in cl.statics.get().concat(cl.fields.get())) {
      if (field.meta.has(':extern')) continue;
      var glueHeaderCode = field.meta.extractStrings(':ueHeaderCode')[0];
      if (glueHeaderCode != null)
        writer.buf.add('\t\t$glueHeaderCode\n');
      writer.include('<' + gluePack.join('/') + '/' + oldGlueName + '.h>');
      for (inc in field.meta.extractStrings(':glueHeaderIncludes'))
        writer.include(inc);
      for (inc in field.meta.extractStrings(':glueCppIncludes'))
        writer.include(inc);
    }
    writer.buf.add('};\n\n');

    for (pack in gluePack) {
      writer.buf.add('}\n');
    }

    data = cl.meta.extractStrings(':ueHeaderEnd')[0];
    if (data != null) {
      writer.buf.add(data);
    }
    writer.buf.add('#ifdef SCOPED_HXCPP\n#undef SCOPED_HXCPP\n#undef HXCPP_CLASS_ATTRIBUTES\n#endif\n');
    writer.close(null);
  }

  private function writeHeader(cl:ClassType, writer:HeaderWriter, gluePath:String) {
    var gluePack = gluePath.split('.'),
        glueName = gluePack.pop();

    var headerDefs = cl.meta.extractStrings(':ueHeaderDef');

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
    for (inc in cl.meta.extractStrings(':glueHeaderIncludes')) {
      writer.include(inc);
    }

    for (extraField in cl.meta.extractStrings(':glueHeaderClass')) {
      writer.buf.add(extraField);
    }

    for (field in cl.statics.get().concat(cl.fields.get())) {
      if (field.meta.has(':extern')) continue;
      var glueHeaderCode = field.meta.extractStrings(':glueHeaderCode')[0];
      if (glueHeaderCode != null) {
        writer.buf.add('\t\t$glueHeaderCode\n');
      }
      for (inc in field.meta.extractStrings(':glueHeaderIncludes'))
        writer.include(inc);
      for (fwd in field.meta.extractStrings(':headerForwards'))
        writer.forwardDeclare(fwd);
    }
    writer.buf.add('};\n\n');

    var headerTail = cl.meta.extractStrings(':ueHeaderTail');
    if (headerTail != null) {
      for (tail in headerTail) {
        writer.buf.add(tail);
      }
    }

    if (headerDefs.length == 0) {
      writer.buf.add('typedef ${glueName}_obj $glueName;\n\n');
    }
    for (pack in gluePack) {
      writer.buf.add('}\n');
    }
    writer.buf.add('#ifdef SCOPED_HXCPP\n#undef SCOPED_HXCPP\n#undef HXCPP_CLASS_ATTRIBUTES\n#endif\n');
    writer.close(null);
  }

  private function writeCpp(cl:ClassType, writer:CppWriter, gluePath:TypeRef) {
    var headerPath = null;
    if (cl.meta.has(':uexportheader')) {
      headerPath = GlueInfo.getExportHeaderPath(gluePath.getClassPath(true));
    } else {
      headerPath = GlueInfo.getHeaderPath(gluePath);
    }

    writer.include(headerPath);
    for (inc in cl.meta.extractStrings(':glueCppIncludes')) {
      writer.include(inc);
    }

    var cppDefs = cl.meta.extractStrings(':ueCppDef');
    if (cppDefs != null) {
      for (cppDef in cppDefs) {
        var def = cppDef.trim();
        if (def.length > 0) {
          writer.buf.add(cppDef);
          writer.buf.add('\n');
        }
      }
    }

    for (field in cl.statics.get().concat(cl.fields.get())) {
      if (field.meta.has(':extern')) continue;
      var glueCppCode = field.meta.extractStrings(':glueCppCode')[0];
      if (glueCppCode != null) {
        writer.buf.add(glueCppCode);
        writer.buf.add('\n');
      }
      for (inc in field.meta.extractStrings(':glueCppIncludes'))
        writer.include(inc);
    }
    return writer.close(null);
  }

  public function writeGlueCpp(cl:ClassType) {
    var firstModule = null;
    for (module in cl.meta.extractStrings(':umodule')) {
      if (module != 'Unreal') {
        modules[module] = true;
      }
      if (firstModule == null) {
        firstModule = module;
      }
    }
    if (firstModule == null) {
      firstModule = Globals.cur.module;
    }

    var gluePath = cl.meta.extractStrings(':ueGluePath')[0];
    if (gluePath == null) {
      return;
    }

    glues.touch(TPrivateCpp, gluePath);
    var stampPath = '$stampOutput/$gluePath.cpp.stamp';
    var gluePathRef = TypeRef.parseClassName(gluePath);
    var cppPath = GlueInfo.getCppPath(gluePathRef, true);
    var shouldGenerate = checkShouldGenerate(stampPath, cppPath, cl);

    if (!shouldGenerate) {
      this.producedFiles.push(cppPath);
      glues.addCpp(cppPath, firstModule, shouldGenerate);
      return;
    }

    var writer = new CppWriter(cppPath);
    var generated = writeCpp(cl, writer, gluePathRef);
    if (!writer.isDeleted) {
      this.producedFiles.push(cppPath);
      glues.addCpp(cppPath, firstModule, generated);
    } else {
      glues.setDeleted(cppPath, firstModule);
    }
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
        if (sourceFile != null && FileSystem.exists(stampPath)) {
          var stampPath = FileSystem.stat(stampPath).mtime.getTime(),
              sourceStat = FileSystem.stat(sourceFile).mtime.getTime();
          if (stampPath > sourceStat) {
            return false;
          }
        }
      }
    }
    return true;
  }

  public function writeGlueHeader(cl:ClassType) {
    var kind:TouchKind = TPrivateHeader;
    if (cl.meta.has(':uexportheader')) {
      kind = TExportHeader;
    }
    var gluePath = cl.meta.extractStrings(':ueGluePath')[0];
    if (gluePath == null) {
      return;
    }
    glues.touch(kind, gluePath);

    var gluePathRef = TypeRef.parseClassName(gluePath);
    var headerPath = kind == TPrivateHeader ?
      GlueInfo.getHeaderPath(gluePathRef, true) :
      GlueInfo.getExportHeaderPath(gluePathRef.getClassPath(true), true);
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

    this.producedFiles.push(headerPath);
    var stampPath = '$stampOutput/$gluePath.h.stamp',
        shouldGenerate = checkShouldGenerate(stampPath, headerPath, cl);
    if (cl.meta.has(':ueTemplate')) {
      glues.touch(kind, gluePath + '_UE');
    }

    if (shouldGenerate) {
      var writer = new HeaderWriter(headerPath);
      writer.dontInclude(headerPath);
      writeHeader(cl, writer, gluePath);
      if (cl.meta.has(':ueTemplate')) {
        var path = headerPath.substr(0,-2) + '_UE.h';
        this.producedFiles.push(path);
        var templWriter = new HeaderWriter(path);
        writeUEHeader(cl, templWriter, gluePath);
      }
      File.saveContent(stampPath,'');
    }
  }

  public function prepareUExposeClass(cl:ClassType)
  {
    var wrapperPath = TypeRef.fromBaseType(cl, cl.pos);
    var originalPath = wrapperPath.with(wrapperPath.name + '_Haxe');
    if (!cl.meta.has(':native'))
    {
      cl.meta.add(':native', [macro $v{originalPath.getClassPath()}], cl.pos);
    }
    if (!cl.meta.has(':ifFeature') && !cl.meta.has(':keep')) {
      cl.meta.add(':keep', [], cl.pos);
    }
    if (!cl.meta.has(':nativeGen'))
    {
      cl.meta.add(':nativeGen', [], cl.pos);
    }

    var kind:TouchKind = TSharedHeader;
    var targetPath = GlueInfo.getSharedHeaderPath(TypeRef.parseClassName( wrapperPath.getClassPath() ), true);

    var stampPath = '$stampOutput/$wrapperPath-expose.h.stamp',
        shouldGenerate = checkShouldGenerate(stampPath, targetPath, cl);
    glues.touch(kind, wrapperPath.getClassPath());

    if (!shouldGenerate)
    {
      return;
    }

    var header = new uhx.compiletime.tools.HeaderWriter(targetPath);
    var incs = new uhx.compiletime.tools.IncludeSet();
    header.include(originalPath.getClassPath().replace('.','/') + '.h');
    header.include('uhx/AutoHaxeInit.h');
    var buf = header.buf;

    for (pack in cl.pack)
    {
      buf << 'namespace $pack {\n';
    }

    buf << 'class ${cl.name} {\npublic:';

    var extraCode = cl.meta.extractStrings(':wrapperClassCode')[0];
    if (extraCode != null)
    {
      buf << extraCode;
    }
    var originalClass = originalPath.getCppClass();
    for (field in cl.statics.get())
    {
      if (field.meta.has(':extern'))
      {
        continue;
      }
      switch(Context.follow(field.type))
      {
      case TFun(args,ret):
        var name = field.name;
        var args = [ for (arg in args) { name:TypeConv.changeCppName(arg.name), t:TypeConv.get(arg.t, field.pos) }];
        var ret = TypeConv.get(ret, field.pos);
        buf.add('\tinline static ${ret.glueType.getCppType()} $name(');
        var first = true;
        for (arg in args)
        {
          if (first)
          {
            first = false;
          } else {
            buf.add(', ');
          }
          arg.t.collectUeIncludes(incs);
          buf.add(arg.t.glueType.getCppType() + ' ' + arg.name);
        }
        buf.add(') {\n\t\tAutoHaxeInit uhx_auto_init;\n\t\t');
        if (!ret.ueType.isVoid())
        {
          buf.add('return ');
        }
        buf.add('$originalClass::$name(');
        buf.mapJoin(args, function(arg) return arg.name);
        buf.add(');\n\t}\n');
      case _:
      }
    }
    for (inc in incs)
    {
      header.include(inc);
    }
    buf << '};\n';
    for (pack in cl.pack)
    {
      buf << '}\n';
    }
    header.close(null);
  }

  public function onAfterGenerate() {
    if (Globals.cur.unrealSourceDir == null) return;
    var staticBaseDir:String = Globals.cur.staticBaseDir,
        cppTarget = haxe.macro.Compiler.getOutput();
    var isDce = Context.definedValue('dce') == 'full';
    for (t in glueTypes) {
      var cl = t.get();
      var type = TypeRef.fromBaseType(cl, cl.pos);
      var cpath = type.getClassPath();
      if (isDce && (cl.isExtern || (!cl.meta.has(':used') && !cl.meta.has(':directlyUsed')))) {
        continue;
      }
      if (cl.meta.has(':ueGluePath')) {
        writeGlueCpp(cl);
      }
      if (!cl.isExtern && cl.meta.has(':uexpose')) {
        cpath = cl.meta.extractStrings(':native')[0];
        // copy the header to the generated folder
        glues.touch(TSharedHeader, cpath);
        var path = cpath.replace('.','/');

        var headerPath = '$cppTarget/include/${path}.h';
        if (!FileSystem.exists(headerPath)) {
          trace('The uexpose header at path $headerPath does not exist. Skipping');
          continue;
        }
        var targetPath = GlueInfo.getSharedHeaderPath(TypeRef.parseClassName( cpath ), true);
        var stampPath = '$stampOutput/$cpath.h.stamp';
        this.producedFiles.push(targetPath);
        var shouldCopy = checkShouldGenerate(stampPath, targetPath, cl);

        if (shouldCopy) {
          var contents = File.getContent(headerPath);
          // take off the self-include
          contents = contents.replace('#include <$path.h>', '');
          if (!FileSystem.exists(targetPath) || File.getContent(targetPath) != contents) {
            File.saveContent(targetPath, contents);
          }
          File.saveContent(stampPath, '');
        }
      }

      var dependencies = cl.meta.extractStrings(':ufiledependency');
      if (dependencies != null && dependencies.length > 0) {
        if (dependencies.length == 1) {
          throw new Error('The file dependency is not in the newer format', cl.pos);
        }
        var kind = TouchKind.parse(dependencies.shift(), cl.pos);
        for (dep in dependencies) {
          glues.touch(kind, dep);
        }
      }
    }

    // add all extra modules which we depend on
    if (!FileSystem.exists('$staticBaseDir/Data')) {
      FileSystem.createDirectory('$staticBaseDir/Data');
    }
    var modules = [ for (module in modules.keys()) module ];
    modules.sort(Reflect.compare);
    var contents = modules.join('\n').trim();
    var targetModules = '$staticBaseDir/Data/modules.txt';
    if (!FileSystem.exists(targetModules) || File.getContent(targetModules).trim() != contents) {
      File.saveContent(targetModules, contents);
    }

    if (Context.defined("WITH_CPPIA")) {
      var glueModules = [ for (key in glueTypes.keys()) key ];
      glueModules.sort(Reflect.compare);
      var contents = glueModules.join('\n');
      var file = '$staticBaseDir/Data/compiled.txt';
      if (!FileSystem.exists(file) || sys.io.File.getContent(file) != contents) {
        sys.io.File.saveContent(file, contents);
      }
    }

    // clean generated folder
    glues.cleanDirs();
    glues.makeUnityBuild();

    var file = '$staticBaseDir/Data/staticProducedFiles.txt';
    sys.io.File.saveContent(file, this.producedFiles.join('\n'));
  }

  public function onGenerate(types:Array<Type>) {
    if (Globals.cur.unrealSourceDir == null) return;
    var targetTemplate = glues.updateGameModule();

    var hadErrors = false;
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
        if (Context.defined('WITH_CPPIA')) {
          if (!cl.isExtern && !cl.meta.has(':uscript')) {
            var sup = cl.superClass;
            if (sup != null) {
              var superClass = sup.t.get();
              if (superClass.meta.has(':uscript')) {
                Context.warning('Unreal.hx Error: The class $typeName is a subclass of script-defined class ${sup.t}, which is not supported.', superClass.pos);
                Context.warning('Defined here', cl.pos);
                hadErrors = true;
              }
            }
          }
        }
        if (cl.meta.has(':alreadyCompiled')) {
          if (!cl.meta.has(':wasCompiled')) {
            cl.meta.add(':wasCompiled',[],cl.pos);
          }
        } else {
          cl.meta.add(':alreadyCompiled',[],cl.pos);
        }
        var hadGlue = glueTypes.exists(TypeRef.fromBaseType(cl, cl.pos).getClassPath());
        if (cl.meta.has(':uexpose')) {
          glueTypes[ TypeRef.fromBaseType(cl, cl.pos).getClassPath() ] = c;
          prepareUExposeClass(cl);
        }
        if (cl.meta.has(':ueGluePath') && !hadGlue ) {
          glueTypes[ TypeRef.fromBaseType(cl, cl.pos).getClassPath() ] = c;
          writeGlueHeader(cl);
        }
        // add only once - we'll select a type that is always compiled
        if (typeName == 'uhx.expose.HxcppRuntime' && !cl.meta.has(':buildXml')) {
          var dir = Globals.cur.unrealSourceDir;
          var sharedDir = GlueInfo.getSharedHeaderDir(null);
          cl.meta.add(':buildXml', [macro $v{
          '
          <files id="haxe">
            <compilerflag value="-I$targetTemplate/Shared" />
            <compilerflag value="-I$sharedDir" />
          </files>
          <files id="cppia">
            <compilerflag value="-I$targetTemplate/Shared" />
          </files>
          '
          }], cl.pos);
        }
      case TEnum(e, _):
        var et = e.get();
        if (et.meta.has(':uenum')) {
          glues.touch(TExportHeader, MacroHelpers.getUName(et));
        }
      case _:
      }
    }

    if (hadErrors) {
      throw new Error('Build finished with errors', Context.currentPos());
    }
  }
}

