package ue4hx.internal;
import ue4hx.internal.buf.HelperBuf;
import ue4hx.internal.buf.CodeFormatter;
import haxe.macro.Compiler;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import sys.FileSystem;
import sys.io.File;
import ue4hx.internal.GlueMethod;

using haxe.macro.Tools;
using ue4hx.internal.MacroHelpers;

using StringTools;
using Lambda;

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

    // we need this timestamp to make sure we bake everything if ue4hx.internal package
    var latestInternal = (force ? 0.0 : getLatestInternalChange());
    // walk into the paths - from last to first - and if needed, create the wrapper code
    var target = Compiler.getOutput();
    if (!FileSystem.exists(target)) FileSystem.createDirectory(target);
    var processed = new Map(),
        toProcess = [];
    var i = classpaths.length;
    var hadErrors = false;
    while( i --> 0 ) {
      var cp = classpaths[i];
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
            if (processed.exists(module)) {
              continue; // already existed on a classpath with higher precedence
            }
            processed[module] = true;

            var mtime = FileSystem.stat('$dir/$file').mtime.getTime();
            var fname = file.substr(0,-3);
            if (FileSystem.exists('$dir/${fname}_Extra.hx')) {
              var extramtime = FileSystem.stat('$dir/${fname}_Extra.hx').mtime.getTime();
              if (extramtime > mtime)
                mtime = extramtime;
            }
            var destTime = 0.0;
            var dest = '$target/${pack.join('/')}/$file';
            if (!force && FileSystem.exists(dest) && (destTime = FileSystem.stat(dest).mtime.getTime()) >= mtime && destTime >= latestInternal)
              continue; // already in latest version
            toProcess.push(module);
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

    for (type in toProcess) {
      var module = Context.getModule(type);
      var pack = type.split('.'),
          name = pack.pop();

      var buf = new StringBuf();
      if (pack.length != 0)
        buf.add('package ${pack.join('.')};\n');
      var processor = new ExternBaker(buf);
      for (type in module) {
        var glueBuf = processor.processType(type),
            glue = Std.string(glueBuf);
        hadErrors = hadErrors || processor.hadErrors;
        if (glueBuf != null && glue != '') {
          var glueType = processor.glueType;
          var dir = target + '/' + glueType.pack.join('/');
          if (!FileSystem.exists(dir)) FileSystem.createDirectory(dir);
          var file = File.write('$dir/${glueType.name}.hx', false);
          file.writeString(NativeGlueCode.prelude);
          file.writeString('package ${glueType.pack.join('.')};\n' +
            '@:unrealGlue extern class ${glueType.name} {\n');
          file.writeString(glue);
          file.writeString('}');
          file.close();
        }
      }
      var dir = target + '/' + pack.join('/');
      if (!FileSystem.exists(dir)) FileSystem.createDirectory(dir);
      File.saveContent('$dir/$name.hx', buf.toString());
    }
    if (hadErrors)
      throw new Error('Extern bake finished with errors',Context.currentPos());
  }

  private static function getLatestInternalChange():Float {
    var latest = 0.0;
    for (cp in Context.getClassPath()) {
      if (FileSystem.exists('$cp/ue4hx/internal')) {
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
        recurse('$cp/ue4hx/internal');
      }
    }

    return latest;
  }

  private static function joinMetas(extraModule:String, file:String) {
    switch(Context.follow(Context.getType(extraModule))) {
    case TInst(_.get() => cextra,_):
      var base:BaseType = switch(Context.getType(extraModule.substr(0,extraModule.length - '_Extra'.length))) {
        case TInst(_.get() => cl, _):
          cl;
        case TEnum(_.get() => e, _):
          e;
        case TAbstract(_.get() => a, _):
          a;
        case TType(_.get() => t, _):
          t;
        case type:
          throw new Error('Unsupported type ${type.toString()} for module ${extraModule.substr(0,extraModule.length - '_Extra'.length)}', Context.makePosition({ min:0, max:0, file:file }));
      };
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
      throw new Error('Module $extraModule should be an extern class', Context.makePosition({ min:0, max:0, file:file }));
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
  private var dependentTypes:Map<String, String>;
  private var needsTypeParamGlue:Bool;
  public var hadErrors(default, null):Bool;

  @:isVar private var voidType(get,null):Null<TypeConv>;

  public function new(buf:StringBuf) {
    this.realBuf = buf;
    this.buf = new CodeFormatter();
    this.hadErrors = false;
    this.params = [];
  }

  public function processGenericFunctions(c:Ref<ClassType>):CodeFormatter {
    var cl = c.get();
    this.dependentTypes = new Map();
    this.cls = cl;
    this.params = [ for (p in cl.params) p.name ];
    this.glue = new CodeFormatter();
    var typeRef = TypeRef.fromBaseType(cl, cl.pos),
        glue = typeRef.getGlueHelperType(),
        caller = new TypeRef(glue.pack, glue.name + "GenericCaller"),
        genericGlue = new TypeRef(glue.pack, glue.name + "Generic");
    this.glueType = genericGlue;

    // this.type = Context.getType(typeRef.getClassPath());
    this.type = TInst(c, [ for (arg in cl.params) arg.t ]);
    this.thisConv = TypeConv.get(this.type, cl.pos, 'unreal.PExternal');
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
          generics.push({ isStatic:isStatic, field: field, impls: impls });
        }
      }
      isStatic = false;
    }

    if (cl.isInterface) throw new Error('Unreal Glue Code: Templated functions aren\'t supported on interfaces', pos);
    if (generics.length == 0) return null;
    this.add('@:ueGluePath("${this.glueType.getClassPath()}")\n');
    if (Globals.cur.haxeTargetModule != null) {
      this.add('@:utargetmodule("${Globals.cur.haxeTargetModule}") ');
    }
    this.add('@:nativeGen\n');
    this.add('class ');
    this.add(caller.name);
    this.begin(' {');

    var old = Globals.cur.currentFeature;
    var feat = typeRef.getClassPath(true);
    var methods = [];
    for (generic in generics) {
      if (generic.field.meta.has(':expr')) {
        continue;
      }
      // exclude the generic base field
      for (impl in generic.impls) {
        Globals.cur.currentFeature = '$feat.${impl.name}';
        // Globals.cur.currentFeature = 'keep';
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

        var specializationTypes = [ for (param in tparams) TypeConv.get(param, this.pos) ];
        var specialization = { types:specializationTypes, genericFunction:generic.field.name, mtypes: tparams };
        var nextIndex = methods.length;
        this.processField(impl, generic.isStatic, specialization, methods);
        var args = [];
        if (!generic.isStatic)
          args.push('this');
        for (arg in methods[nextIndex].args)
          args.push(arg.name);
        if (methods[nextIndex].meta == null) methods[nextIndex].meta = [];
        methods[nextIndex].meta.push({ name:':ifFeature', params:[macro $v{'${typeRef.withoutModule().getClassPath()}.${impl.name}'}], pos:impl.pos });
        var call = caller.getCppClass() + '::' + impl.name + '(' + args.join(', ') + ');';
        if (!methods[nextIndex].ret.haxeType.isVoid())
          call = 'return ' + call;
        impl.meta.add(':functionCode', [macro $v{'\t\t' + call}], impl.pos);
      }
    }
    Globals.cur.currentFeature = old;

    for (meth in methods)
      this.processMethodDef(meth, false);
    this.end('}');

    this.addDependentTypes();
    this.realBuf.add(this.buf);
    this.buf = new CodeFormatter();
    return this.glue;
  }

  private function addDependentTypes() {
    if (this.dependentTypes.iterator().hasNext()) {
      this.realBuf.add('@:ueDependentTypes(');
      this.realBuf.mapJoin(this.dependentTypes, function(type) return '"$type"');
      this.realBuf.add(')\n');
    }
  }

  public function processType(type:Type):CodeFormatter {
    this.type = type;
    this.glue = new CodeFormatter();
    switch(type) {
    case TInst(c,tl):
      this.processClass(type, c.get());
    case TEnum(e,tl):
      this.processEnum(e.get());
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

  private function processClass(type:Type, c:ClassType) {
    this.needsTypeParamGlue = false;
    this.cls = c;
    this.dependentTypes = new Map();
    this.params = [ for (p in c.params) p.name ];
    this.pos = c.pos;
    if (!c.isExtern || !c.meta.has(':uextern')) return;
    this.type = type;
    this.typeRef = TypeRef.fromBaseType(c, c.pos);
    this.glueType = this.typeRef.getGlueHelperType();
    this.thisConv = TypeConv.get(type,c.pos,'unreal.PExternal');

    this.addDoc(c.doc);
    var fields = c.fields.get(),
        statics = c.statics.get();
    var meta = c.meta.get();
    // process the _Extra type if found
    var extraName = c.pack.join('.') + (c.pack.length > 0 ? '.' : '') + c.name + '_Extra';
    try {
      var extra = Context.getType(extraName);
      switch(extra) {
      case TInst(_.get() => ecl,_):
        var efields = ecl.fields.get();
        var estatics = ecl.statics.get();
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
        var pos = switch(extra) {
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
    catch(e:Dynamic) {
      if (!Std.string(e).startsWith("Type not found '" + extraName)) {
        throw new Error(Std.string(e), c.pos);
      }
    }

    for (field in fields.concat(statics)) {
      if (field.params.length > 0) {
        this.add('@:ueHasGenerics ');
        break;
      }
    }

    var params = new HelperBuf();
    if (c.params != null && c.params.length > 0) {
      params << '<';
      params.mapJoin(c.params, function(p) return p.name);
      params << '>';
    }
    var params = params.toString();

    this.addMeta(meta);
    if (!c.isInterface)
      this.add('@:ueGluePath("${this.glueType.getClassPath()}")\n');
    if (c.params.length > 0)
      this.add('@:ueTemplate\n');
    if (c.isPrivate)
      this.add('private ');
    if (c.isInterface) {
      this.add('interface ');
    } else {
      this.add('class ');
    }
    this.add('${c.name}$params ');
    var hasSuperClass = true;
    if (c.superClass != null) {
      var supRef = TInst(c.superClass.t, c.superClass.params).toString();
      this.add('extends $supRef ');
    } else if (c.isInterface) {
      this.add('extends unreal.IInterface ');
    } else if (!this.thisConv.isUObject) {
      this.add('extends unreal.Wrapper ');
    } else {
      hasSuperClass = false;
      this.add('implements unreal.IInterface ');
    }

    for (iface in c.interfaces) {
      var t = TInst(iface.t, iface.params).toString();
      // var ifaceRef = TypeRef.fromBaseType(iface.t.get(), iface.params, c.pos);
      if (c.isInterface)
        this.add('extends ');
      else
        this.add('implements ');
      this.add('$t ');
    }
    var methods = [];
    this.begin('{');
      for (field in statics) {
        processField(field,true, null, methods);
      }
      for (field in fields) {
        processField(field,false, null, methods);
      }

      if (this.thisConv.isUObject) {
        var uname = switch(MacroHelpers.extractStrings(c.meta, ':uname')[0]) {
        case null:
          c.name;
        case name:
          name;
        };
        uname = uname.substr(1);

        // Add the className to the classMap with the wrapped as the value so we can access it in wrap().
        if (!c.isInterface) {
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
            this.add('static function __init__()');
            this.begin(' {');
              this.add('unreal.helpers.ClassMap.addWrapper($glueClassGet, cpp.Function.fromStaticFunction(wrapPointer));');
              // this.add('unreal.helpers.GlueClassMap.classMap.set("${uname}", cast ${c.name}.new);');//this.wrapped);');
            this.end('}');
            this.newline();

            // add wrap
            this.add('@:unreflective static function wrapPointer(uobject:cpp.RawPointer<cpp.Void>):cpp.RawPointer<cpp.Void>');
            this.begin(' {');
              this.add('var ptr:cpp.Pointer<Dynamic> = cpp.Pointer.fromRaw(cast uobject);');
              this.add('return unreal.helpers.HaxeHelpers.dynamicToPointer(new ${this.typeRef.getClassPath()}(ptr));');
            this.end('}');
          }

          this.add('@:unreflective public static function wrap(uobject:cpp.RawPointer<cpp.Void>):${this.typeRef.getClassPath()}');
          this.begin(' {');
            this.add('return unreal.helpers.HaxeHelpers.pointerToDynamic( unreal.helpers.ClassMap.wrap(uobject) );');
          this.end('}');
        }
      } else if (!c.isInterface) {
        // add wrap for non-uobject types
        this.add('@:unreflective public static function wrap$params(ptr:');
        this.add(this.thisConv.haxeGlueType.toString());
        this.add(', ?parent:Dynamic');
        this.add('):' + this.thisConv.haxeType);
        this.begin(' {');
          if (!this.thisConv.haxeGlueType.isReflective()) {
            this.add('var ptr = cpp.Pointer.fromRaw(cast ptr);');
            this.newline();
          }

          this.add('if (ptr == null) return null;');
          this.newline();
          this.add('return new ${this.typeRef.getClassPath()}(ptr, parent);');
        this.end('}');
      }

      if (!hasSuperClass) {
        this.newline();
        // add constructor
        this.add('@:unreflective private var wrapped:${this.thisConv.haxeGlueType};');
        this.newline();
        if (this.thisConv.haxeGlueType.isReflective())
          this.add('private function new(wrapped) this.wrapped = wrapped;\n\t');
        else
          this.add('private function new(wrapped:${this.thisConv.haxeGlueType.toReflective()}) this.wrapped = wrapped.rawCast();\n\t');
        // This is used only on `unreal.UObject`,`cpp.Pointer<cpp.Void>` will fail if we used `this.thisConv.haxeGlueType.getReflective()`
        this.add('@:extern inline private function getWrapped():cpp.Pointer<Dynamic>');
        this.begin(' {');
          this.add('return this == null ? null : cpp.Pointer.fromRaw(cast this.wrapped);');
        this.end('}');
        this.add('@:extern inline private function getWrappedAddr():cpp.Pointer<Dynamic>');
        this.begin(' {');
          this.add('return this == null ? null : cpp.Pointer.addressOf( this.wrapped ).reinterpret();');
        this.end('}');

      } else if (!c.isInterface && !this.thisConv.isUObject) {
        // add rewrap
        this.add('override public function rewrap(wrapped:cpp.Pointer<unreal.helpers.UEPointer>):${this.thisConv.haxeType}');
        this.begin(' {');
          this.add('return new ${this.thisConv.haxeType}(wrapped);');
        this.end('}');
        if (!meta.hasMeta(':noCopy')) {
          var doc = "\n    Invokes the copy constructor of the referenced C++ class.\n    " +
            "This has some limitations - it won't copy the full inheritance chain of the class if it wasn't typed as the exact class\n    " +
            "it will also be a compilation error if the wrapped class forbids the C++ copy constructor;\n    " +
            "in this case, the extern class definition should contain the `@:noCopy` metadata\n  ";
          // copy constructor
          // TODO add params if type has type parameter
          methods.push({
            name: '_copy',
            uname: '.copy',
            doc: doc,
            meta:null,
            args:[],
            ret:TypeConv.get(type, c.pos, 'unreal.PHaxeCreated'),
            flags: HaxeOverride | HaxePrivate,
            pos: c.pos,
          });
          methods.push({
            name: '_copyStruct',
            uname: '.copyStruct',
            doc: doc,
            meta:null,
            args:[],
            ret:TypeConv.get(type, c.pos, 'unreal.PStruct'),
            flags: HaxeOverride | HaxePrivate,
            pos: c.pos,
          });
        } else {
          this.add('@:deprecated("This type does not support copy constructors") override private function _copy():${this.thisConv.haxeType.toString()}');
          this.begin(' {');
            this.add('return throw "The type ${this.thisConv.haxeType} does not support copy constructors";');
          this.end('}');
          this.add('@:deprecated("This type does not support copy constructors") override private function _copyStruct():${this.thisConv.haxeType.toString()}');
          this.begin(' {');
            this.add('return throw "The type ${this.thisConv.haxeType} does not support copy constructors";');
          this.end('}');
        }
        if (!meta.hasMeta(':noEquals')) {
            methods.push({
            name: '_equals',
            uname: '.equals',
            doc: null,
            meta:null,
            args:[{name:"other", t:this.thisConv}],
            ret:TypeConv.get(Context.getType("Bool"), c.pos),
            flags: HaxePrivate | HaxeOverride,
            pos: c.pos,
          });
        }
        // add setFinalizer for debugging purposes
        this.newline();
        this.add('override private function setFinalizer() { cpp.vm.Gc.setFinalizer((this : unreal.Wrapper), cpp.Callable.fromStaticFunction(disposeUEPointer)); }');
        this.newline();

        this.add('@:void @:unreflective static function disposeUEPointer(wrapper:unreal.Wrapper):Void ');
        this.begin('{');
        this.add('if (!wrapper.disposed)');
        this.begin('{');
        this.add('wrapper.wrapped.destroy();');
        this.end('}');
        this.end('}');
      }

    for (meth in methods)
      this.processMethodDef(meth, c.isInterface);
    this.end('}');

    // before defining the class, let's go through all types and see if we have any type parameters that are dependent on
    // our current type parameter specifications
    this.addDependentTypes();
    if (this.needsTypeParamGlue)
      this.realBuf.add('@:needsTypeParamGlue\n');
    this.realBuf.add(this.buf);
    this.buf = new CodeFormatter();
  }

  // private static function getEnableIf(meth:MethodDef, body:String, decl:String, args:String):String {
  //   var buf = new HelperBuf();
  //   buf << 'template <bool CHECKOP=std::is_assignable<CHECKOP,CHECKOP>::value>\n\t\tclass ${meth.name}__if_op {\n\t\t\tpublic:\n\t\t\t';
  //     buf << decl << ';\n\t\t};\n\n\t\t';
  //   buf << 'template <> class ${meth.name}__if_op<true> {\n\t\t\tpublic:\n\t\t\t';
  //     buf << decl << ' {\n\t\t\t\t$body\n\t\t\t}\n\t\t};\n\n\t\t';
  //   buf << 'template <> class ${meth.name}__if_op<false> {\n\t\t\tpublic:\n\t\t\t';
  //     buf << decl << ' {\n\t\t\t\t::unreal::helpers::HxcppRuntime::throwString("Calling operator $op in type that can\'t be assigned");\n\t\t\t\tthrow "assert";\n\t\t\t}\n\t\t};\n\n\t\t';
  //   if (!meth.ret.haxeType.isVoid())
  //     buf << 'return ';
  //   buf << '${meth.name}__if_op<${meth.params[0]}>::${meth.name}($args)';
  //   return buf.toString();
  // }

  private function processField(field:ClassField, isStatic:Bool, ?specialization:{ types:Array<TypeConv>, mtypes:Array<Type>, genericFunction:String }, methods:Array<MethodDef>) {
    var uname = switch(MacroHelpers.extractStrings(field.meta, ':uname')[0]) {
      case null:
        field.name;
      case name:
        name;
    };

    switch(field.kind) {
    case FVar(read,write):
      this.addDoc(field.doc);
      var meta = field.meta.get();
      this.addMeta(meta);
      if (field.isPublic)
        this.add('public ');
      else
        this.add('private ');

      if (isStatic)
        this.add('static ');
      var tconv = TypeConv.get( field.type, field.pos );
      this.add('var ');
      this.add(field.name);
      this.add('(');
      var flags = Property;
      var realTConv = switch (tconv.ownershipModifier) {
        case 'unreal.PStruct':
          flags = StructProperty;
          TypeConv.get( field.type, field.pos, 'unreal.PExternal' );
        case _:
          tconv;
      }
      if (!field.isPublic)
        flags |= CppPrivate;
      if (isStatic)
        flags |= Static;
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
          args = args.slice(specialization.types.length);
        }
        var flags = None;
        if (!field.isPublic)
          flags |= HaxePrivate | CppPrivate;
        if (isStatic)
          flags |= Static;
        methods.push( cur = {
          name: field.name,
          uname: specialization == null || uname != field.name ? uname : specialization.genericFunction,
          doc: field.doc,
          meta:field.meta.get(),
          params: [ for (p in field.params) p.name ],
          args: [ for (arg in args) { name: arg.name, t: TypeConv.get(arg.t, field.pos) } ],
          ret: TypeConv.get(ret, field.pos),
          flags: flags,
          specialization: specialization,
          pos: field.pos,
        });
        if (uname == 'new' && specialization == null) {
          // make sure that the return type is of type PHaxeCreated
          if (!isHaxeCreated(ret)) {
            Context.warning(
              'The function constructor `${field.name}` should return an `unreal.PHaxeCreated` type. Otherwise, this reference will leak', field.pos);
            hadErrors = true;
          }
          inline function cancelParams(t:Type) {
            return ret.applyTypeParameters(field.params, [for (p in field.params) Context.typeof(macro null)]);
          }

          var retComplex = cancelParams(ret).toComplexType();
          var thisType = thisConv.haxeType.withParams([ for (p in thisConv.haxeType.params) new TypeRef('Dynamic') ]).toComplexType();
          // make sure that the type is exactly PHaxeCreated<MyRetType>
          Context.typeof(macro @:pos(field.pos) {
            var complex:$retComplex = null;
            var x:unreal.PHaxeCreated<$thisType> = complex;
          });

          methods.push({
            name: field.name + 'Struct',
            uname: '.ctor',
            params: [ for (p in field.params) p.name ],
            args: cur.args,
            ret: TypeConv.get(ret, field.pos, 'unreal.PStruct'),
            flags: flags,
            specialization: specialization,
            pos: field.pos,
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
    if (gm.needsTypeParamGlue) {
      this.needsTypeParamGlue = true;
    }
    for (dep in gm.dependentTypes) {
      this.dependentTypes[dep] = dep;
    }
    gm.getFieldString( this.buf, this.glue );
  }

  private static function isHaxeCreated(type:Type):Bool {
    while (type != null) {
      switch(type) {
      case TAbstract(aRef, tl):
        if (aRef.toString() == 'unreal.PHaxeCreated')
          return true;
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
    return false;
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
    if (!e.isExtern || !e.meta.has(':uextern')) return;
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

    this.add('@:ueGluePath("${this.glueType.getClassPath()}")\n');
    this.addMeta(e.meta.get());
    this.add('class ${e.name}_EnumConv ');
    this.begin('{');
      this.add('public static var all = std.Type.allEnums(${this.typeRef});');
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
      var ueCall = isClass ?
        uePack.join('::') + (uePack.length == 0 ? '' : '::') + ueName :
        uePack.join('::');
      if (ueCall != '')
        ueCall = ueCall + '::';
      var ueEnumType = uePack.join('::') + (uePack.length == 0 ? '' : '::') + ueName;

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
}
