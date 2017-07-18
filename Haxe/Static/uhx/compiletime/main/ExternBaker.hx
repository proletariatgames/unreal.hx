package uhx.compiletime.main;
import haxe.macro.Compiler;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import sys.FileSystem;
import sys.io.File;
import uhx.compiletime.tools.CodeFormatter;
import uhx.compiletime.tools.HelperBuf;
import uhx.compiletime.types.GlueMethod;
import uhx.compiletime.types.TypeRef;
import uhx.compiletime.types.TypeConv;

using haxe.macro.Tools;
using Lambda;
using StringTools;
using uhx.compiletime.tools.MacroHelpers;

/**
  This is the first pass in the Haxe compilation pipeline. It must run as a separate
  compilation step, as it will generate actual Haxe files which will be used as the source for the next
  passes.
 **/
class ExternBaker {
  /**
    Processes the 'Externs' directories and creates Haxe wrappers based on them.
    This command should be run through `--macro` command-line option, and `--no-output` (so
    hxcpp doesn't try to build those files).
    The target directory will be the selected by `-cpp <targetdir>` command-line option

    Classpaths included here will be added with ascending priority - the last being the higher
    prioirty, and the first being the lower.

    By default, `process` will only process Haxe files whose timestamps are higher than
    the target extern file. Set `force` to true to override this
   **/
  public static function process(classpaths:Array<String>, force:Bool) {
    // first, add the classpaths to the current compiler
    for (cp in classpaths) {
      Compiler.addClassPath(cp);
    }

    // we want to parse the documentation as well
    if (!Context.defined('use_rtti_doc'))
      Compiler.define('use_rtti_doc');

    // we need this timestamp to make sure we bake everything if uhx.compiletime package
    var latestInternal = (force ? 0.0 : getLatestInternalChange());
    // walk into the paths - from last to first - and if needed, create the wrapper code
    var target = FileSystem.fullPath( Compiler.getOutput() );
    if (!FileSystem.exists(target)) FileSystem.createDirectory(target);
    var processed = new Map(),
        filesToCompile = new Map(),
        duplicateFiles = new Map();
    var i = classpaths.length;
    var hadErrors = false,
        isLocalExtern = true;
    while( i --> 0 ) {
      isLocalExtern = i == classpaths.length - 1;
      var cp = FileSystem.fullPath(classpaths[i]);
      if (!FileSystem.exists(cp)) continue;
      var pack = [];
      function traverse() {
        var dir = cp + '/' + pack.join('/');
        var files = FileSystem.readDirectory(dir);
        for (file in files) {
          if (file.endsWith('.hx')) {
            var module = pack.join('.') + (pack.length == 0 ? '' : '.') + file.substr(0,-3);
            if (file.endsWith('_Extra.hx')) {
              joinMetas(module, file);
              continue;
            }
            var fileName = '$dir/$file';
            if (processed.exists(module) || duplicateFiles.exists(module)) {
              var old = processed[module];
              Context.warning('Unreal Extern Baker: File $module is defined on another classpath: $old. Ignoring definition', Context.makePosition({min:0, max:0, file:fileName}));
              if (old != null) {
                Context.warning('Unreal Extern Baker: Previous definition here', Context.makePosition({min:0, max:0, file:old}));
              }
              duplicateFiles[module] = true;
              processed.remove(module);
              continue; // already existed on a classpath with higher precedence
            }
            processed[module] = fileName;

            var mtime = FileSystem.stat('$dir/$file').mtime.getTime();
            var fname = file.substr(0,-3);
            for (cp in classpaths) {
              var curPath = '$cp/${pack.join("/")}';
              if (FileSystem.exists('$curPath/${fname}_Extra.hx')) {
                var extramtime = FileSystem.stat('$curPath/${fname}_Extra.hx').mtime.getTime();
                if (extramtime > mtime)
                  mtime = extramtime;
              }
            }

            var destTime = 0.0;
            var dest = '$target/${pack.join('/')}/$file';
            if (!force && FileSystem.exists(dest) && (destTime = FileSystem.stat(dest).mtime.getTime()) >= mtime && destTime >= latestInternal) {
              continue; // already in latest version
            }
            filesToCompile[fileName.toLowerCase()] = { module:module, file:fileName, localExtern:isLocalExtern };
          }
        }
        for (file in files) {
          if (file.indexOf('.') < 0 && FileSystem.isDirectory('$dir/$file')) {
            pack.push(file);
            traverse();
            pack.pop();
          }
        }
      }
      traverse();
    }

    // delete untouched modules
    var pack = [];
    function traverse() {
      var dir = '$target/${pack.join('/')}';
      if (FileSystem.exists(dir)) {
        for (file in FileSystem.readDirectory(dir)) {
          if (file.endsWith('.hx') && !file.endsWith('GlueGeneric.hx') && !file.endsWith('Glue.hx') && !file.endsWith('GlueGenericCaller.hx')) {
            var module = pack.join('.') + (pack.length == 0 ? '' : '.') + file.substr(0,-3);
            if (!processed.exists(module)) {
              trace('Deleting uneeded baked extern $module ($dir/$file)');
              FileSystem.deleteFile('$dir/$file');
            }
          } else if (FileSystem.isDirectory('$dir/$file')) {
            pack.push(file);
            traverse();
            pack.pop();
          }
        }
      }
    }
    traverse();

    if (duplicateFiles.iterator().hasNext()) {
      Context.error('Unreal Extern Baker: Has duplicate file paths. Exiting', Context.currentPos());
    }

    function generatedSourceIsValid(srcFile:String, generatedFile:String, info:GeneratedInfo):Bool {
      if (info == null) {
        return true;
      }

      // if the original source file still exists, wasn't changed, and
      if (info.srcFile != srcFile.toLowerCase() && FileSystem.exists(info.srcFile) && !filesToCompile.exists(info.srcFile)) {
        Context.warning('Unreal Extern Baker: A conflict was detected while generating ${generatedFile}: It was previously generated by ${info.srcFile}, ' +
            'which is unchanged, and is now generated by ${srcFile}. Please make sure that this reference is not duplicate. If you think this is an error, ' +
            'you may compile with the BAKE_EXTERNS=1 environment variable, or delete your `{ProjectRoot}/Haxe/Generated` folder to force all files to be ' +
            'regenerated and try again', // a bug report will also be appreciated
            Context.makePosition({ file:srcFile, max:0, min:0 }));
        return false;
      }
      return true;
    }

    var unames = new Map();
    for (ref in filesToCompile) {
      var generatedHeader = getGeneratedHeader({ srcFile: ref.file.toLowerCase(), ver:1 });
      var module = Context.getModule(ref.module);
      var pack = ref.module.split('.'),
          name = pack.pop();

      var buf = new StringBuf();
      buf.add(generatedHeader);
      if (pack.length != 0) {
        buf.add('package ${pack.join('.')};\n');
      }
      var processor = new ExternBaker(buf);
      for (type in module) {
        var pos = null;
        var uname = switch(type) {
          case TInst(c,_):
            var c = c.get();
            if (c.meta.has(':haxeGenerated')) {
              continue;
            }
            pos = c.pos;
            MacroHelpers.getUName(c);
          case TEnum(e,_):
            var e = e.get();
            if (e.meta.has(':haxeGenerated')) {
              continue;
            }
            pos = e.pos;
            MacroHelpers.getUName(e);
          case TAbstract(a,_):
            var a = a.get();
            if (a.meta.has(':haxeGenerated')) {
              continue;
            }
            pos = a.pos;
            MacroHelpers.getUName(a);
          case TType(t,_):
            // force the type to be built
            Context.follow(type);
            // reload it - to referesh its metadata
            var t = t.get();
            if (!t.meta.has(':uPrimeTypedef')) {
              continue;
            }
            pos = t.pos;
            MacroHelpers.getUName(t);
          case _:
            null;
        }
        var lastPos = uname == null ? null : unames[uname];
        if (lastPos != null) {
          Context.warning('A class or struct with the name $uname was already defined. Please delete the one of the definitions, or change their name', pos);
          Context.warning('$uname was defined here', lastPos);
          hadErrors = true;
          continue;
        }
        if (uname != null) {
          unames[uname] = pos;
        }

        var glueBuf = processor.processType(type, ref.localExtern ? null : 'Unreal'),
            glue = Std.string(glueBuf);
        hadErrors = hadErrors || processor.hadErrors;
        if (glueBuf != null && glue != '') {
          var glueType = processor.glueType;
          var dir = target + '/' + glueType.pack.join('/');

          if (!FileSystem.exists(dir)) FileSystem.createDirectory(dir);
          var targetFile = '$dir/${glueType.name}.hx';
          var info = getGeneratedInfo(targetFile);
          if (generatedSourceIsValid(ref.file, targetFile, info)) {
            var file = File.write(targetFile, false);
            file.writeString(generatedHeader);
            file.writeString(uhx.compiletime.tools.BaseWriter.prelude);
            file.writeString('package ${glueType.pack.join('.')};\n' +
              '@:unrealGlue extern class ${glueType.name} {\n');
            file.writeString(glue);
            file.writeString('}');
            file.close();
          } else {
            hadErrors = true;
          }
        }
      }
      var dir = target + '/' + pack.join('/');
      if (!FileSystem.exists(dir)) FileSystem.createDirectory(dir);

      var targetFile = '$dir/$name.hx';
      var info = getGeneratedInfo(targetFile);
      if (generatedSourceIsValid(ref.file, targetFile, info)) {
        File.saveContent(targetFile, buf.toString());
      } else {
        hadErrors = true;
      }
    }
    if (hadErrors) {
      throw new Error('Extern bake finished with errors',Context.currentPos());
    }
  }

  private static function getGeneratedInfo(generatedFile:String):Null<GeneratedInfo> {
    if (FileSystem.exists(generatedFile)) {
      var ln:String = null;
      try {
        var file = sys.io.File.read(generatedFile);
        ln = file.readLine();
        file.close();
      }
      catch(e:Dynamic) {
        throw new Error('Error while reading generated file $generatedFile: $e', Context.makePosition({ file:generatedFile, max:0, min:0 }));
        return null;
      }

      if (!ln.startsWith('// GenData:')) {
        // assume it's old data
        return null;
      }
      ln = ln.substr('// GenData:'.length);
      var ret:GeneratedInfo = haxe.Json.parse(ln);
      ret.srcFile = ret.srcFile.toLowerCase();
      return ret;
    }
    return null;
  }

  public static function getGeneratedHeader(info:GeneratedInfo):String {
    return '// GenData:${haxe.Json.stringify(info)}\n';
  }

  private static function getLatestInternalChange():Float {
    var latest = 0.0;
    for (cp in Context.getClassPath()) {
      if (FileSystem.exists('$cp/uhx/compiletime')) {
        function recurse(dir:String) {
          for (file in FileSystem.readDirectory(dir)) {
            if (FileSystem.isDirectory('$dir/$file')) {
              recurse('$dir/$file');
            } else if (file.endsWith('.hx')) {
              var time = FileSystem.stat('$dir/$file').mtime.getTime();
              if (time > latest) {
                latest = time;
              }
            }
          }
        }
        recurse('$cp/uhx/compiletime');
      }
    }

    var cwd = Sys.getCwd();
    var hxml = '$cwd/baker-arguments.hxml';
    if (FileSystem.exists(hxml)) {
      var time = FileSystem.stat(hxml).mtime.getTime();
      if (time > latest) {
        latest = time;
      }
    }

    return latest;
  }

  private static function joinMetas(extraModuleName:String, file:String) {
    var pos = Context.makePosition({ min:0, max:0, file:file });
    var extraModule = getModule(extraModuleName, pos);
    if (extraModule == null || extraModule.length == 0) {
      return;
    }
    if (extraModule.length > 1) {
      throw new Error('The `_Extra` file should not declare any other type', pos);
    }

    switch(Context.follow(extraModule[0])) {
    case TInst(_.get() => cextra,_):
      var moduleName = extraModuleName.substr(0,extraModuleName.length - '_Extra'.length);
      var modules = getModule(moduleName, pos);
      if (modules == null || modules.length == 0) {
        return;
      }
      var base:BaseType = null;
      for (mod in modules) {
        base = switch(mod) {
          case TInst(cl, _):
            if (cl.toString() == moduleName) {
              cl.get();
            } else {
              null;
            }
          case TEnum(e, _):
            if (e.toString() == moduleName) {
              e.get();
            } else {
              null;
            }
          case TAbstract(a, _):
            if (a.toString() == moduleName) {
              a.get();
            } else {
              null;
            }
          case TType(t, _):
            if (t.toString() == moduleName) {
              t.get();
            } else {
              null;
            }
          case type:
            throw new Error('Unsupported type ${type.toString()} for module ${extraModuleName.substr(0,extraModuleName.length - '_Extra'.length)}', pos);
        };
        if (base != null) {
          break;
        }
      }
      if (base == null) {
        throw new Error('Type ${moduleName} is referenced by an `_Extra` type but it does not define a valid type', pos);
      }
      if (cextra.meta.has(':glueCppIncludes')) {
        base.meta.remove(':glueCppIncludes');
      }
      if (cextra.meta.has(':hasCopy')) {
        base.meta.remove(':noCopy');
      }
      if (cextra.meta.has(':hasEquals')) {
        base.meta.remove(':noEquals');
      }
      for (meta in cextra.meta.get()) {
        base.meta.add(meta.name, meta.params, meta.pos);
      }
    case _:
      throw new Error('Module $extraModuleName should be an extern class', Context.makePosition({ min:0, max:0, file:file }));
    }
  }

  private var buf:CodeFormatter;
  private var realBuf:HelperBuf;
  private var glue:CodeFormatter;
  private var glueType:TypeRef;
  private var thisConv:TypeConv;
  private var cls:ClassType;

  private var type:Type;
  private var typeRef:TypeRef;

  private var pos:Position;
  private var params:Array<String>;
  public var hadErrors(default, null):Bool;

  @:isVar private var voidType(get,null):Null<TypeConv>;

  public function new(buf:StringBuf) {
    this.realBuf = buf;
    this.buf = new CodeFormatter();
    this.hadErrors = false;
    this.params = [];
  }

  public function processGenericFunctions(c:Ref<ClassType>):CodeFormatter {
    var cl = c.get(),
        base:BaseType = null;
    switch(cl.kind) {
    case KAbstractImpl(a):
      base = a.get();
      this.type = TAbstract(a, [ for (arg in base.params) arg.t ]);
    case _:
      base = cl;
      this.type = TInst(c, [ for (arg in cl.params) arg.t ]);
    }
    this.cls = cl;
    this.params = [ for (p in cl.params) p.name ];
    this.glue = new CodeFormatter();
    var typeRef = TypeRef.fromBaseType(base, base.pos),
        glue = typeRef.getGlueHelperType(),
        caller = new TypeRef(glue.pack, glue.name + "GenericCaller"),
        genericGlue = new TypeRef(glue.pack, glue.name + "Generic");
    var implType = cl.pack.join('.') + (cl.pack.length == 0 ? '' : '.') + cl.name;
    this.glueType = genericGlue;

    this.thisConv = TypeConv.get(this.type, cl.pos, true);
    var generics = [];
    var isStatic = true;
    for (fields in [cl.statics.get(), cl.fields.get()]) {
      for (field in fields) {
        if (field.meta.has(':generic')) {
          field.meta.add(':extern', [], field.pos);
          // look for implementations
          var impls = [];
          for (impl in fields) {
            if (impl.name.startsWith(field.name + '_') && impl.meta.has(':genericInstance')) {
              impls.push(impl);
            }
          }
          impls.sort(function(cf1, cf2) return Reflect.compare(cf1.name, cf2.name));
          generics.push({ isStatic:isStatic && !field.meta.has(':impl'), field: field, impls: impls });
        }
      }
      isStatic = false;
    }

    if (cl.isInterface) throw new Error('Unreal Glue Code: Templated functions aren\'t supported on interfaces', pos);
    if (generics.length == 0) return null;
    this.add('@:ueGluePath("${this.glueType.getClassPath()}")\n');
    this.add('@:nativeGen\n');
    this.add('class ');
    this.add(caller.name);
    this.begin(' {');

    var feat = typeRef.getClassPath(true);
    var methods = [];
    for (generic in generics) {
      if (generic.field.meta.has(':expr')) {
        continue;
      }
      // exclude the generic base field
      for (impl in generic.impls) {
        impl.meta.remove(':glueCppCode');
        impl.meta.remove(':glueHeaderCode');
        // poor man's version of mk_mono
        var tparams = [ for (param in generic.field.params) Context.typeof(macro null) ];
        var func = generic.field.type.applyTypeParameters(generic.field.params, tparams);
        if (!Context.unify(func, impl.type)) {
          Context.warning('Assert: ${impl.name} doesn\'t unify with ${generic.field.name}', generic.field.pos);
          continue;
        }

        var pos = Context.getPosInfos(generic.field.pos);
        pos.file = pos.file + " (" + impl.name + ")";
        this.pos = Context.makePosition(pos);
        impl.pos = this.pos;

        var specializationTypes = [ for (param in tparams) TypeConv.get(param, this.pos, true) ];
        var specialization = { types:specializationTypes, genericFunction:generic.field.name, mtypes: tparams };
        var nextIndex = methods.length;
        this.processField(impl, generic.isStatic, specialization, methods);
        var args = [];
        if (!generic.isStatic)
          args.push(impl.meta.has(':impl') ? 'this1' : 'this');
        for (arg in methods[nextIndex].args)
          args.push(arg.name);
        if (methods[nextIndex].meta == null) methods[nextIndex].meta = [];
        methods[nextIndex].meta.push({ name:':ifFeature', params:[macro $v{'${implType}.${impl.name}'}], pos:impl.pos });
        var call = caller.getCppClass() + '::' + impl.name + '(' + args.join(', ') + ');';
        if (!methods[nextIndex].ret.haxeType.isVoid())
          call = 'return ' + call;
        impl.meta.add(':functionCode', [macro $v{'\t\t' + call}], impl.pos);
      }
    }

    for (meth in methods)
      this.processMethodDef(meth, false);
    this.end('}');

    this.realBuf.add(this.buf);
    this.buf = new CodeFormatter();
    return this.glue;
  }

  public function processType(type:Type, ?defaultModule:String):CodeFormatter {
    this.type = type;
    this.glue = new CodeFormatter();
    switch(type) {
    case TInst(c,tl):
      var cls = c.get();
      if (cls.superClass != null) {
        if (cls.superClass.t.get().meta.has(':haxeGenerated')) {
          Context.warning('This class was not generated by Haxe, but descends from a Haxe generated class', cls.pos);
        }
      }
      if (defaultModule != null && !cls.meta.has(':umodule')) {
        cls.meta.add(':umodule', [macro $v{defaultModule}], cls.pos);
      }
      this.processClass(type, cls);
    case TEnum(e,tl):
      var e = e.get();
      if (defaultModule != null && !e.meta.has(':umodule')) {
        e.meta.add(':umodule', [macro $v{defaultModule}], e.pos);
      }
      this.processEnum(e);
    case TType(t,_):
      var t2 = Context.follow(type, true);
      switch(t2) {
      case TInst(c,tl):
        var cls = c.get();
        if (defaultModule != null && !cls.meta.has(':umodule')) {
          cls.meta.add(':umodule', [macro $v{defaultModule}], cls.pos);
        }
        this.processClass(type, cls);
      case _:
        Context.warning('Type $type is not supported',t.get().pos);
      }
    case _:
      var pos = switch(Context.follow(type)) {
      case TInst(c,tl): c.get().pos;
      case TEnum(e,tl): e.get().pos;
      case TAbstract(a,tl): a.get().pos;
      case TAnonymous(a): a.get().fields[0].pos;
      case _: return null;
      }
      this.pos = pos;
      Context.warning('Type $type is not supported',pos);
    }
    return glue;
  }

  private function processTemplatedClass(tconv:TypeConv, c:ClassType) {
    var decl = new CodeFormatter(),
        impl = new CodeFormatter();
    var cppType = tconv.ueType.getCppType().toString(),
        glueName = tconv.haxeType.getGlueHelperType().getCppType() + '_UE_obj';
    var className = tconv.ueType.withoutPointer(true).name;
    decl << 'namespace uhx {' << new Newline()
         << 'template<';
    decl.foldJoin(c.params, function(param,buf) return buf << 'class ' << param.name);
    decl << '>' << new Newline();
    decl << 'struct TTemplatedData<' << cppType << '>' << new Begin('{')
          << 'typedef TStructOpsTypeTraits<$cppType> TTraits;' << new Newline()
          << 'FORCEINLINE static const StructInfo *getInfo();' << new Newline()
          << 'private:' << new Newline()
          << 'static void destruct(unreal::UIntPtr ptr)' << new Begin('{')
            << 'uhx::TDestruct<' << cppType << '>::doDestruct(ptr);'
          << new End('}')
        << new End('};')
      << '}' << new Newline();
    impl << 'template<';
    impl.foldJoin(c.params, function(param,buf) return buf << 'class ' << param.name);
    impl << '> const uhx::StructInfo *::uhx::TTemplatedData<' << cppType << '>::getInfo()' << new Begin('{')
          << 'static $glueName<';
    impl.foldJoin(c.params, function(param,buf) return buf << param.name);
    impl << '> genericImplementation;' << new Newline();
    impl << 'static const StructInfo * genericParams[${c.params.length + 1}] = { ';
    impl.foldJoin(c.params, function(param,buf) return buf << 'uhx::TAnyData< ' << param.name << ' >::getInfo()');
    impl << ', nullptr };' << new Newline();
    impl << 'static uhx::StructInfo info = ' << new Begin('{')
            << '/* .name = */ "' << tconv.ueType.name << '",' << new Newline()
            << '/* .flags = */ UHX_Templated,' << new Newline()
            << '/* .size = */ (unreal::UIntPtr) sizeof(' << cppType << '),' << new Newline()
            << '/* .alignment = */ (unreal::UIntPtr) uhx::Alignment<' << cppType << '>::get(),' << new Newline()
            << '/* .destruct = */ (TTraits::WithNoDestructor || std::is_trivially_destructible<' << cppType << '>::value ? nullptr : &TTemplatedData<$cppType>::destruct),' << new Newline()
            << '/* .equals = */ nullptr,' << new Newline()
            << '/* .genericParams = */ genericParams,' << new Newline()
            << '/* .genericImplementation = */ &genericImplementation'
          << new End('};')
          << 'return &info;'
      << new End('}');
    c.meta.add(':ueHeaderStart', [macro $v{decl.toString()}], c.pos);
    c.meta.add(':ueHeaderEnd'  , [macro $v{impl.toString()}], c.pos);
  }

  private function processClass(type:Type, c:ClassType) {
    this.cls = c;
    this.params = [ for (p in c.params) p.name ];
    this.pos = c.pos;
    if (!c.isExtern) return;
    this.type = type;
    this.typeRef = TypeRef.fromBaseType(c, c.pos);
    this.glueType = this.typeRef.getGlueHelperType();
    this.thisConv = TypeConv.get(type,c.pos);

    switch(this.thisConv.data) {
    case CStruct(_,_,_,params):
      if (params != null && params.length > 0) {
        processTemplatedClass(this.thisConv, c);
      }
    case _:
    }
    if (!c.meta.has(':uextern')) {
      throw new Error('Extern Baker: Extern class $typeRef is on the extern class path, but is not a @:uextern type', c.pos);
    }

    this.addDoc(c.doc);
    var fields = c.fields.get(),
        statics = c.statics.get(),
        ctor = c.constructor == null ? null : c.constructor.get();
    var meta = c.meta.get();
    // process the _Extra type if found
    var extraName = c.pack.join('.') + (c.pack.length > 0 ? '.' : '') + c.name + '_Extra';
    var extra = getModule(extraName, c.pos);
    if (extra != null && extra.length > 0) {
      switch(extra[0]) {
      case TInst(_.get() => ecl,_):
        var efields = ecl.fields.get();
        var estatics = ecl.statics.get();
        var ector = ecl.constructor == null ? null : ecl.constructor.get();
        if (ector != null) {
          if (ctor != null) {
            Context.warning('Unreal Extern Baker: The constructor already exists on ${c.name}', ector.pos);
          }
          ctor = ector;
        }
        for (field in efields) {
          var oldField = fields.find(function(f) return f.name == field.name);
          if (oldField != null) {
            Context.warning('Unreal Extern Baker: The field ${field.name} already exists on ${c.name}', field.pos);
          } else {
            fields.push(field);
          }
        }

        for (field in estatics) {
          var oldField = statics.find(function(f) return f.name == field.name);
          if (oldField != null) {
            Context.warning('Unreal Extern Baker: The field ${field.name} already exists on ${c.name}', field.pos);
          } else {
            statics.push(field);
          }
        }
      case _:
        var pos = switch(extra[0]) {
        case TAbstract(a,_):
          a.get().pos;
        case TEnum(e,_):
          e.get().pos;
        case TType(t,_):
          t.get().pos;
        case _:
          c.pos;
        }
        Context.warning('Unreal Extern Baker: Type ${c.name}_Extra is not a class',pos);
      }
    }

    for (field in fields.concat(statics)) {
      if (field.params.length > 0) {
        this.add('@:ueHasGenerics ');
        break;
      }
    }

    var params = new HelperBuf();
    var isNoTemplate = c.meta.has(':noTemplate');
    if (c.params != null && c.params.length > 0 && !isNoTemplate) {
      params << '<';
      params.mapJoin(c.params, function(p) return p.name);
      params << '>';
    }
    var params = params.toString();

    this.addMeta(meta);
    if (MacroHelpers.extractStrings(c.meta, ':umodule')[0] == 'UnrealEd' || c.pack.join('.') == 'unreal.editor') {
      this.add('#if !WITH_EDITOR @:deprecated("The class ${c.name} is an editor-only class and should not be used on non-editor builds") #end');
      this.newline();
    }
    if (!c.isInterface) {
      this.add('@:ueGluePath("${this.glueType.getClassPath()}")\n');
    }
    if (c.params.length > 0 && !isNoTemplate) {
      this.add('@:ueTemplate\n');
    }
    if (c.isPrivate) {
      this.add('private ');
    }

    var isAbstract = false,
        isTemplateStruct = false,
        superStruct = null;
    if (this.thisConv.data.match(CUObject(_))) {
      if (c.isInterface) {
        this.add('interface ');
      } else {
        this.add('class ');
      }
      this.add('${c.name}$params ');
      if (c.superClass != null) {
        var supRef = TInst(c.superClass.t, c.superClass.params).toString();
        this.add('extends $supRef ');
      } else if (c.isInterface) {
        this.add('extends unreal.IInterface ');
      } else {
        this.add('implements unreal.IInterface ');
      }
    } else {
      isAbstract = true;
      if (!this.thisConv.data.match(CUObject(_))) {
        if (c.superClass == null) {
          this.add('@:forward(dispose,isDisposed) ');
        } else {
          this.add('@:forward ');
        }
      }
      this.add('abstract ${c.name}$params(');
      if (c.superClass == null) {
        switch(c.meta.extract(':udelegate')[0]) {
        case null:
          if (c.params.length > 0 && !isNoTemplate) {
            superStruct = new TypeRef(['unreal'], 'TemplateStruct');
          } else {
            superStruct = new TypeRef(['unreal'], 'Struct');
          }
        case { params: [macro var _:$t], pos:pos }:
          superStruct = TypeRef.fromType( t.toType(), pos );
        case e:
          throw new Error('Bad @:udelegate format: $e', e.pos);
        }

        this.add('$superStruct) to $superStruct ');
      } else {
        superStruct = TypeRef.fromType( TInst(c.superClass.t, c.superClass.params), c.pos );
        this.add('$superStruct) ');
      }
      var sup = c.superClass;
      while(sup != null) {
        var supRef = TInst(sup.t, sup.params).toString();
        this.add('to $supRef ');
        sup = sup.t.get().superClass;
      }
      this.add('to unreal.Struct to unreal.VariantPtr ');
    }

    for (iface in c.interfaces) {
      var t = TInst(iface.t, iface.params).toString();
      // var ifaceRef = TypeRef.fromBaseType(iface.t.get(), iface.params, c.pos);
      if (isAbstract) {
        this.add('to ');
      } else {
        if (c.isInterface)
          this.add('extends ');
        else
          this.add('implements ');
      }
      this.add('$t ');
    }
    var methods = [];
    this.begin('{');
      if (isAbstract && !isTemplateStruct && c.params.length > 0 && !isNoTemplate) {
        // if a templated struct extends a non-templated struct, we need to expose this
        this.add('@:extern inline private function getTemplateStruct():unreal.Wrapper.TemplateWrapper { return @:privateAccess unreal.TemplateStruct.getTemplateStruct(this); }');
        this.newline();
      }
      if (ctor != null) {
        processField(ctor,true, null, methods);
      }
      for (field in statics) {
        processField(field,true, null, methods);
      }
      for (field in fields) {
        processField(field,false, null, methods);
      }

      if (this.thisConv.data.match(CUObject(_))) {
        var uname = switch(MacroHelpers.extractStrings(c.meta, ':uname')[0]) {
        case null:
          c.name;
        case name:
          name;
        };
        uname = uname.substr(1);

        // Add the className to the classMap with the wrapped as the value so we can access it in wrap().
        if (!c.isInterface && !meta.hasMeta(':global')) {
          if (!meta.hasMeta(':noClass')) {
            if (!methods.exists(function(m) return m.uname == 'StaticClass')) {
              methods.push({
                name:'StaticClass',
                uname:'StaticClass',
                doc:'\n\t\tReturns the `UClass` object which describes this class\n\t',
                args: [],
                meta: [{ name:':ifFeature', params:[ macro $v{'${this.thisConv.haxeType.withoutModule().getClassPath()}.*'} ], pos:c.pos }],
                ret: TypeConv.get(Context.getType("unreal.UClass"), pos),
                flags: Final | Static,
                pos: c.pos,
              });
            }

            var glueClassGet = glueType.getClassPath() + '.StaticClass()';
            this.add('static function __init__():Void');
            this.begin(' {');
              this.add('#if !cppia');
              this.newline();
              this.add('var func = cpp.Function.fromStaticFunction(wrapPointer).toFunction();');
              this.newline();
              this.add('uhx.ue.ClassMap.addWrapper($glueClassGet, func);');
              this.newline();
              this.add('#else');
              this.newline();
              this.add('uhx.runtime.Helpers.addCppiaExternWrapper("${uname}", "${this.typeRef.getClassPath(true)}");');
              this.newline();
              this.add('#end');
            this.end('}');
            this.newline();

            // add wrap
            this.add('#if !cppia');
            this.newline();
            this.add('static function wrapPointer(uobject:unreal.UIntPtr):unreal.UIntPtr');
            this.begin(' {');
              this.add('return uhx.internal.HaxeHelpers.dynamicToPointer(new ${this.typeRef.getClassPath()}(uobject));');
            this.end('}');
            this.add('#end');
            this.newline();
          }

          this.add('inline public static function wrap(uobject:${this.thisConv.haxeGlueType}):${this.typeRef.getClassPath()}');
          this.begin(' {');
            this.add('return cast uhx.ClassWrap.wrap(uobject);');
          this.end('}');
        }
      } else if (!c.isInterface) {  // non-uobject
        // add wrap for non-uobject types
        this.add('inline public static function fromPointer$params(ptr:');
        this.add(this.thisConv.haxeGlueType.toString());
        this.add('):' + this.thisConv.haxeType);
        this.begin(' {');
          this.add('return cast ptr;');
        this.end('}');

        if (c.meta.has(':ustruct')) {
          var uname = switch(MacroHelpers.extractStrings(c.meta, ':uname')[0]) {
          case null:
            c.name;
          case name:
            name;
          };
          uname = uname.substr(1);
          this.add('#if cppia');
          this.newline();
          this.add('@:noCompletion private static var uhx_structData:unreal.UScriptStruct;');
          this.newline();
          this.add('@:noCompletion private inline function get_structData():unreal.UScriptStruct');
          this.begin(' {');
            this.add('return (uhx_structData != null ? uhx_structData : (uhx_structData = uhx.runtime.UReflectionGenerator.getUStruct("$uname")));');
          this.end('}');
          this.add('#end');
          this.newline();
        }
      }

      if (c.superClass == null && !isAbstract && !this.thisConv.data.match(CUObject(OInterface,_,_))) {
        this.newline();
        // add constructor
        this.add('private var wrapped:${this.thisConv.haxeGlueType};');
        this.newline();
        if (this.thisConv.haxeGlueType.isReflective()) {
          this.add('private function new(wrapped)');
          this.begin(' {');
            this.add('this.wrapped = wrapped;');
            this.newline();
            this.add('if (Reflect.hasField(Type.getClass(this), "_uhx_isHaxeType"))');
            this.begin(' {');
              this.add('uhx.ClassWrap.pushCtor(this);');
            this.end('}');
          this.end('}');
          // this.add('private function new(wrapped) this.wrapped = wrapped;\n\t');
        } else {
          this.add('private function new(wrapped:${this.thisConv.haxeGlueType.toReflective()}) this.wrapped = wrapped.rawCast();\n\t');
        }

        if (this.thisConv.data.match(CUObject(_))) {
          this.add('private var serialNumber:Int = -1;');
          this.newline();
          this.add('private var internalIndex:Int = -1;');
          this.newline();
          this.add('inline private function invalidate():Void');
          this.begin(' {');
            this.add('this.wrapped = 0;');
          this.end('}');

          this.add('inline public function isValid(threadSafe:Bool=false):Bool');
          this.begin(' {');
            // make an inline version that checks if `this` is null as well
            this.add('return this != null && this.pvtIsValid(threadSafe);');
          this.end('}');

          this.add('@:noCompletion #if (!cppia && !debug) inline #end private function pvtIsValid(threadSafe:Bool):Bool');
          this.begin(' {');
            this.add('return this.wrapped != 0 && '
                +' uhx.internal.ObjectArrayHelper_Glue.objectToIndex(this.wrapped) == internalIndex && '
                +' (!threadSafe || uhx.internal.ObjectArrayHelper_Glue.isValid(internalIndex, serialNumber, false));');
          this.end('}');
        }

      } else if (!c.isInterface && !meta.hasMeta(':global') && !this.thisConv.data.match(CUObject(_))) {
        if (!meta.hasMeta(':noCopy')) {
          var doc = "\n    Invokes the copy constructor of the referenced C++ class.\n    " +
            "This has some limitations - it won't copy the full inheritance chain of the class if it wasn't typed as the exact class\n    " +
            "it will also be a compilation error if the wrapped class forbids the C++ copy constructor;\n    " +
            "in this case, the extern class definition should contain the `@:noCopy` metadata\n  ";
          // copy constructor
          // TODO add params if type has type parameter
          methods.push({
            name: 'copyNew',
            uname: '.copy',
            doc: doc,
            meta:null,
            args:[],
            ret:this.thisConv.withModifiers([Ptr], new TypeRef(['unreal'], 'POwnedPtr', [this.thisConv.haxeType])),
            flags: MNone,
            pos: c.pos,
          });
          methods.push({
            name: 'copy',
            uname: '.copyStruct',
            doc: doc,
            meta:null,
            args:[],
            ret:this.thisConv,
            flags: MNone,
            pos: c.pos,
          });
        } else {
          this.add('@:deprecated("This type does not support copy constructors") private function copy():${this.thisConv.haxeType.toString()}');
          this.begin(' {');
            this.add('return throw "The type ${this.thisConv.haxeType} does not support copy constructors";');
          this.end('}');
          this.add('@:deprecated("This type does not support copy constructors") private function copyStruct():${this.thisConv.haxeType.toString()}');
          this.begin(' {');
            this.add('return throw "The type ${this.thisConv.haxeType} does not support copy constructors";');
          this.end('}');
        }
        if (!meta.hasMeta(':noEquals')) {
            methods.push({
            name: 'equals',
            uname: '.equals',
            doc: null,
            meta:null,
            args:[{name:"other", t:this.thisConv}],
            ret:TypeConv.get(Context.getType("Bool"), c.pos),
            flags: MNone,
            pos: c.pos,
          });
        }
        /*
        // add setFinalizer for debugging purposes
        this.newline();
        this.begin('override private function setFinalizer() {');
        this.add('ClassMap.registerWrapper(this.wrapped.ptr.getPointer(), uhx.internal.HaxeHelpers.dynamicToPointer(this));');
        this.add('cpp.vm.Gc.setFinalizer((this : unreal.Wrapper), cpp.Callable.fromStaticFunction(disposeUEPointer));');
        this.end( }');
        this.newline();

        this.add('@:void @:unreflective static function disposeUEPointer(wrapper:unreal.Wrapper):Void ');
        this.begin('{');
        this.add('if (!wrapper.disposed)');
        this.begin('{');
        this.add('ClassMap.unregisterWrapper(wrapper.wrapped.ptr.getPointer(), uhx.internal.HaxeHelpers.dynamicToPointer(wrapper));');
        this.add('wrapper.wrapped.destroy();');
        this.end('}');
        this.end('}');
        */
      }

    for (meth in methods) {
      this.processMethodDef(meth, c.isInterface);
    }
    this.end('}');

    // before defining the class, let's go through all types and see if we have any type parameters that are dependent on
    // our current type parameter specifications
    this.realBuf.add(this.buf);
    this.buf = new CodeFormatter();
  }

  private function processField(field:ClassField, isStatic:Bool, ?specialization:{ types:Array<TypeConv>, mtypes:Array<Type>, genericFunction:String }, methods:Array<MethodDef>) {
    var uname = switch(MacroHelpers.extractStrings(field.meta, ':uname')[0]) {
      case null:
        field.name;
      case name:
        name;
    };
    var isNoTemplate = field.meta.has(':noTemplate') || this.cls.meta.has(':noTemplate');

    switch(field.kind) {
    case FVar(read,write):
      this.addDoc(field.doc);
      var meta = field.meta.get();
      this.addMeta(meta);
      if (field.isPublic) {
        this.add('public ');
      } else {
        this.add('private ');
      }

      if (isStatic) {
        this.add('static ');
      }
      var tconv = TypeConv.get( field.type, field.pos, null, isNoTemplate );
      this.add('var ');
      this.add(field.name);
      this.add('(');
      var flags = Property;
      if (isNoTemplate) {
        flags |= NoTemplate;
      }
      var realTConv = if (tconv.data.match(CStruct(_)) && (tconv.modifiers == null || (!tconv.modifiers.has(Ref) && !tconv.modifiers.has(Ptr)))) {
        flags = StructProperty;
        tconv.withModifiers([Ptr]);
      } else {
        tconv;
      }
      if (!field.isPublic) {
        flags |= CppPrivate;
      }
      if (isStatic) {
        flags |= Static;
      }
      if (field.meta.has(":uproperty") && (cls.meta.has(':uclass') || cls.meta.has(':ustruct'))) {
        flags |= UnrealReflective;
      }
      switch(read) {
      case AccNormal | AccCall:
        methods.push({
          name: 'get_' + field.name,
          uname: uname,
          args: [],
          ret: realTConv,
          flags: Final | HaxePrivate | flags,
          meta: meta,
          pos: field.pos,
        });
        this.add('get,');
      case _:
        this.add('never,');
      }
      switch(write) {
      case AccNormal | AccCall:
        methods.push({
          name: 'set_' + field.name,
          uname: uname,
          args: [{ name: 'value', t: tconv }],
          ret: tconv,
          flags: Final | HaxePrivate | flags,
          meta: meta,
          pos: field.pos,
        });
        this.add('set):');
      case _:
        this.add('never):');
      }
      this.add(realTConv.haxeType);
      this.add(';');
      this.newline();
    case FMethod(k):
      switch(Context.follow(field.type)) {
      case TFun(args,ret) if (field.meta.has(':expr')):
        this.addDoc(field.doc);
        this.addMeta(field.meta.get().filter(function(meta) return meta.name != ':expr'));
        if (isStatic && field.name != 'new') {
          this.buf.add('static ');
        }
        this.buf.add( field.isPublic ? 'public function ' : 'private function ' );
        this.buf.add(field.name);
        if (field.params.length > 0) {
          this.buf.add('<');
          this.buf.mapJoin(field.params, function(p) return p.name);
          this.buf.add('>');
        }

        inline function typeToString(t:Type) {
          try {
            // this will correctly deal with type params and types that were defined in modules
            return TypeRef.fromType(t, field.pos).toString();
          } catch(e:Dynamic) {
            // unsupported type - like function types
            return t.toString();
          }
        }

        this.buf.add('(');
        this.buf.mapJoin(args, function(arg) return (arg.opt ? '?' : '') + arg.name + ' : ' + typeToString(arg.t));
        this.buf.add(') : ');
        this.buf.add(typeToString(ret));
        var expr = field.meta.extract(':expr')[0].params[0];
        this.buf.add({ expr:EBlock([expr]), pos:expr.pos }.toString());
        this.newline();
      case TFun(args,ret):
        var cur = null;
        var args = args;
        if (specialization != null) {
          if (field.meta.has(':impl')) {
            // args = args.copy();
            // args.splice(1,specialization.types.length);
            args = args.slice(specialization.types.length + 1);
          } else {
            args = args.slice(specialization.types.length);
          }
        }
        var flags = MNone;
        if (!field.isPublic) {
          flags |= HaxePrivate | CppPrivate;
        }
        if (isStatic) {
          flags |= Static;
        }
        if (field.meta.has(":ufunction") && cls.meta.has(':uclass')) {
          flags |= UnrealReflective;
        }
        if (isNoTemplate) {
          flags |= NoTemplate;
        }
        methods.push( cur = {
          name: field.name,
          uname: specialization == null || uname != field.name ? uname : specialization.genericFunction,
          doc: field.doc,
          meta:specialization != null ? field.meta.get().filter(function(field) return field.name != ':functionCode') : field.meta.get(),
          params: [ for (p in field.params) { name:p.name, t:TypeConv.get(p.t, field.pos, null, isNoTemplate) } ],
          args: [ for (arg in args) { name: arg.name, t: TypeConv.get(arg.t, field.pos, null, isNoTemplate) } ],
          ret: TypeConv.get(ret, field.pos, specialization != null, isNoTemplate),
          flags: flags,
          specialization: specialization,
          pos: field.pos,
        });
        if (uname == 'new' && field.name != 'new' && specialization == null) {
          // make sure that the return type is of type POwnedPtr
          var realT = getOwnedPtr(ret);
          if (realT == null) {
            Context.warning(
              'The function constructor `${field.name}` should return an `unreal.POwnedPtr` type. Otherwise, this reference will leak', field.pos);
            hadErrors = true;
            realT = ret;
          }
          inline function cancelParams(t:Type) {
            return ret.applyTypeParameters(field.params, [for (p in field.params) Context.typeof(macro null)]);
          }

          var retComplex = cancelParams(ret).toComplexType();
          var thisType = thisConv.haxeType.withParams([ for (p in thisConv.haxeType.params) new TypeRef('Dynamic') ]).toComplexType();
          // make sure that the type is exactly POwnedPtr<MyRetType>
          Context.typeof(macro @:pos(field.pos) {
            var complex:$retComplex = null;
            var x:unreal.POwnedPtr<$thisType> = complex;
          });
        }
      case _: throw 'assert';
      }
    }
  }

  public function processMethodDef(meth:MethodDef, isInterface:Bool) {
    var gm = new GlueMethod(meth, this.type, this.glueType, this.params != null && this.params.length > 0);
    if (isInterface) {
      gm.haxeCode = null;
      gm.headerCode = null;
      gm.ueHeaderCode = null;
      gm.cppCode = null;
    }
    gm.getFieldString( this.buf, this.glue );
  }

  private static function getOwnedPtr(type:Type):Null<Type> {
    while (type != null) {
      switch(type) {
      case TAbstract(aRef, tl):
        if (aRef.toString() == 'unreal.POwnedPtr') {
          return tl[0];
        }
        var a = aRef.get();
        if (a.meta.has(':coreType'))
            break;
#if (haxe_ver >= 3.3)
        // this is more robust than the 3.2 version, since it will also correctly
        // follow @:multiType abstracts
        type = type.followWithAbstracts(true);
#else
        type = a.type.applyTypeParameters(a.params, tl);
#end
      case TInst(_,_) | TEnum(_,_) | TAnonymous(_) | TFun(_,_) | TDynamic(_):
        break;
      case TMono(ref):
        type = ref.get();
      case TLazy(fn):
        type = fn();
      case TType(_,_):
        type = Context.follow(type, true);
      }
    }
    return null;
  }

  private static function escapeName(name:String) {
    return switch(name) {
      case 'this':
        'self';
      case _:
        name;
    };
  }

  private static function escapeString(str:String, buf:CodeFormatter):Void {
    buf << new Escaped(str);
  }

  private function processEnum(e:EnumType) {
    this.pos = e.pos;
    if (!e.isExtern) return;
    if (!e.meta.has(':uextern')) {
      e.meta.add(':uextern', [], e.pos);
    }
    this.typeRef = TypeRef.fromBaseType(e, e.pos);
    this.glueType = this.typeRef.getGlueHelperType();

    this.addDoc(e.doc);
    this.addMeta(e.meta.get());
    if (e.isPrivate)
      this.add('private ');
    this.add('enum ${e.name} ');
    this.begin('{');
      for (name in e.names) {
        var ctor = e.constructs[name];
        switch (Context.follow(ctor.type)) {
        case TEnum(_,_):
        case _:
          throw new Error('Unreal Type Bake: Enum constructor $name has parameters', ctor.pos);
        }
        this.addDoc(ctor.doc);
        this.addMeta(ctor.meta.get());
        this.add(name + ';');
        this.newline();
      }
    this.end('}');
    this.newline();

    var ueName = MacroHelpers.extractStrings(e.meta, ':uname')[0];
    var isClass = e.meta.has(':class');
    var uePack = null;
    if (ueName == null) {
      ueName = e.name;
      uePack = e.pack;
    } else {
      uePack = ueName.split('.');
      ueName = uePack.pop();
    }
    var ueEnumType = uePack.join('::') + (uePack.length == 0 ? '' : '::') + ueName;

    this.add('@:ueGluePath("${this.glueType.getClassPath()}")\n');
    this.addMeta(e.meta.get());
    this.add('@:glueCppIncludes("uhx/expose/HxcppRuntime.h", "uhx/EnumGlue.h")');
    this.newline();
    var fmt = new CodeFormatter();
    fmt << '@:ueCppDef("';
    var data = new HelperBuf();
    data << 'namespace uhx {\n\n';
    data << 'template<> struct EnumGlue<$ueEnumType> {\n'
      << '\tstatic $ueEnumType haxeToUe(unreal::UIntPtr haxe);\n'
      << '\tstatic unreal::UIntPtr ueToHaxe($ueEnumType ue);\n'
      << '};\n';
    data << '}\n\n';
    data << '$ueEnumType uhx::EnumGlue< $ueEnumType >::haxeToUe(unreal::UIntPtr haxe) {\n'
          << '\t\treturn ($ueEnumType) ${glueType.getCppClass()}::haxeToUe( uhx::expose::HxcppRuntime::enumIndex(haxe) + 1 );\n}\n'
        << 'unreal::UIntPtr uhx::EnumGlue< $ueEnumType >::ueToHaxe($ueEnumType ue) {\n'
          << '\t\tstatic unreal::UIntPtr array = uhx::expose::HxcppRuntime::getEnumArray("$ueEnumType");\n'
          << '\t\treturn uhx::expose::HxcppRuntime::arrayIndex(array, ${glueType.getCppClass()}::ueToHaxe((int) ue) - 1);\n}';
    fmt.addEscaped(data.toString());
    fmt << '")';
    this.add(fmt);
    this.newline();
    this.add('@:ifFeature("${typeRef.getClassPath(true)}.*") ');
    this.add('class ${e.name}_EnumConv ');
    this.begin('{');
      this.add('public static var all:Array<${e.name}>;');
      this.newline();
      this.add('static function __init__() { uhx.EnumMap.set("$ueEnumType", all = std.Type.allEnums(${this.typeRef})); }');
      this.newline();
      var ueCall = isClass ?
        uePack.join('::') + (uePack.length == 0 ? '' : '::') + ueName :
        uePack.join('::');
      if (ueCall != '')
        ueCall = ueCall + '::';

      var ueToHaxe = new HelperBuf() + 'switch(($ueEnumType) value) {\n\t',
          haxeToUe = new HelperBuf() + 'switch(value) {\n\t';
      var idx = 1;
      for (name in e.names) {
        var ctor = e.constructs[name];
        var ueName = MacroHelpers.extractStrings(ctor.meta, ':uname')[0];
        if (ueName == null) ueName = name;
        var uePack = null;
        ueToHaxe += 'case $ueCall$ueName:\n\t\treturn $idx;\n\t';
        haxeToUe += 'case $idx:\n\t\treturn (int) $ueCall$ueName;\n\t';
        idx++;
      }
      ueToHaxe += '}\n\treturn 0;';
      haxeToUe += '}\n\treturn 0;';

      this.glue.add('public static function ueToHaxe(value:Int):Int;\n');
      this.add('@:glueHeaderCode("static int ueToHaxe(int value);")');
      this.newline();
      this.add('@:glueCppCode("int ${this.glueType.getCppType()}_obj::ueToHaxe(int value) {');
      escapeString('\n\t' +ueToHaxe.toString() + '\n}', this.buf);
      this.add('")');
      this.newline();
      this.add('@:ifFeature("${typeRef.getClassPath(true)}.*") ');
      this.add('public static function ueToHaxe(value:Int):Int');
      this.begin(' {');
        this.add('return ${this.glueType}.ueToHaxe(value);');
      this.end('}');

      this.glue.add('public static function haxeToUe(value:Int):Int;\n');
      this.add('@:glueHeaderCode("static int haxeToUe(int value);")');
      this.newline();
      this.add('@:glueCppCode("int ${this.glueType.getCppType()}_obj::haxeToUe(int value) {');
      escapeString('\n\t' +haxeToUe.toString() + '\n}', this.buf);
      this.add('")');
      this.newline();
      this.add('@:ifFeature("${typeRef.getClassPath(true)}.*") ');
      this.add('public static function haxeToUe(value:Int):Int');
      this.begin(' {');
        this.add('return ${this.glueType}.haxeToUe(value);');
      this.end('}');

      this.add('public static inline function wrap(v:Int):${this.typeRef} return all[ueToHaxe(v) - 1];');
      this.newline();
      this.add('public static inline function unwrap(v:${this.typeRef}):Int return haxeToUe(v.getIndex() + 1);');
    this.end('}');
    this.newline();

    this.realBuf.add(this.buf);
    this.buf = new CodeFormatter();
  }

  private function addMeta(metas:Metadata) {
    if (metas != null) {
      for (meta in metas) {
        this.add('@' + meta.name);
        if (meta.params != null && meta.params.length > 0) {
          this.add('(');
          var first = true;
          for (param in meta.params) {
            if (first) first = false; else this.add(', ');
            this.add(param.toString());
          }
          this.add(')');
        }
        if (meta.name == ':final')
          this.add(' @:nonVirtual ');
        this.newline();
      }
    }
  }

  inline private function addDoc(doc:Null<String>) {
    if (doc != null) {
      buf << new Comment(doc);
    }
  }

  inline private function begin(?brkt:String) {
    buf << new Begin(brkt);
  }

  inline private function end(?brkt:String) {
    buf << new End(brkt);
  }

  inline private function newline() {
    buf << new Newline();
  }

  inline private function add(dyn:Dynamic) {
    buf << Std.string(dyn);
  }

  private function get_voidType():TypeConv {
    if (this.voidType == null)
      this.voidType = TypeConv.get(Context.getType('Void'), this.pos);
    return this.voidType;
  }

  private static function getModule(name:String, pos:Position) {
    try {
      return Context.getModule(name);
    } catch(e:Dynamic) {
      if (!Std.string(e).startsWith("Type not found : " + name)) {
        throw new Error(Std.string(e), pos);
      }
      return null;
    }
  }
}

typedef GeneratedInfo = {
  ver:Int,
  srcFile:String
}
