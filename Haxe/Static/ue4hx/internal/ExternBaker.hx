package ue4hx.internal;
import ue4hx.internal.buf.HelperBuf;
import haxe.macro.Compiler;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import sys.FileSystem;
import sys.io.File;

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
        for (file in FileSystem.readDirectory(dir)) {
          if (file.endsWith('.hx')) {
            if (file.endsWith('_Extra.hx')) {
              continue;
            }
            var module = pack.join('.') + (pack.length == 0 ? '' : '.') + file.substr(0,-3);
            if (processed[module])
              continue; // already existed on a classpath with higher precedence
            processed[module] = true;

            var mtime = FileSystem.stat('$dir/$file').mtime;
            var dest = '$target/${pack.join('/')}/$file';
            if (!force && FileSystem.exists(dest) && FileSystem.stat(dest).mtime.getTime() >= mtime.getTime())
              continue; // already in latest version
            toProcess.push(module);
          } else if (FileSystem.isDirectory('$dir/$file')) {
            pack.push(file);
            traverse();
            pack.pop();
          }
        }
      }
      traverse();
    }

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

  private var buf:HelperBuf;
  private var realBuf:HelperBuf;
  private var glue:StringBuf;
  private var glueType:TypeRef;
  private var thisConv:TypeConv;
  private var cls:ClassType;

  private var type:Type;
  private var typeRef:TypeRef;
  private var indentStr:String;

  private var pos:Position;
  private var params:Array<String>;
  private var dependentTypes:Array<String>;
  private var hasTParams:Bool;
  public var hadErrors(default, null):Bool;

  @:isVar private var voidType(get,null):Null<TypeConv>;

  public function new(buf:StringBuf) {
    this.realBuf = buf;
    this.buf = new StringBuf();
    this.indentStr = '';
    this.hadErrors = false;
    this.params = [];
  }

  public function processGenericFunctions(c:Ref<ClassType>):StringBuf {
    var cl = c.get();
    this.dependentTypes = [];
    this.cls = cl;
    this.params = [ for (p in cl.params) p.name ];
    this.glue = new StringBuf();
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
    this.buf.add('@:ueGluePath("${this.glueType.getClassPath()}")\n');
    this.buf.add('@:nativeGen\n');
    this.buf.add('class ');
    this.buf.add(caller.name);
    this.begin(' {');

    var methods = [];
    for (generic in generics) {
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

        var specializationTypes = [ for (param in tparams) TypeConv.get(param, this.pos) ];
        var specialization = { types:specializationTypes, generic:generic.field.name, mtypes: tparams };
        var nextIndex = methods.length;
        this.processField(impl, generic.isStatic, specialization, methods);
        var args = [];
        if (!generic.isStatic)
          args.push('this');
        for (arg in methods[nextIndex].args)
          args.push(arg.name);
        var call = caller.getCppClass() + '::' + impl.name + '(' + args.join(', ') + ');';
        if (!methods[nextIndex].ret.haxeType.isVoid())
          call = 'return ' + call;
        impl.meta.add(':functionCode', [macro $v{'\t\t' + call}], impl.pos);
      }
    }

    for (meth in methods)
      this.processMethodDef(meth, false);
    this.end('}');

    this.addDependentTypes();
    this.realBuf.add(this.buf);
    this.buf = new StringBuf();
    return this.glue;
  }

  private function addDependentTypes() {
    if (this.dependentTypes.length > 0) {
      var deps = [ for (d in this.dependentTypes) d => d ];
      this.realBuf.add('@:ueDependentTypes(');
      this.realBuf.mapJoin(deps, function(type) return '"$type"');
      this.realBuf.add(')\n');
    }
  }

  public function processType(type:Type):StringBuf {
    this.type = type;
    this.glue = new StringBuf();
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
    this.hasTParams = false;
    this.cls = c;
    this.dependentTypes = [];
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
    try {
      var extra = Context.getType(c.pack.join('.') + (c.pack.length > 0 ? '.' : '') + c.name + '_Extra');
      switch(extra) {
      case TInst(_.get() => ecl,_):
        meta = meta.concat(ecl.meta.get());
        if (ecl.meta.has(':hasCopy')) {
          meta = meta.filter(function(m) return m.name != ':noCopy');
        }
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
    }

    for (field in fields.concat(statics)) {
      if (field.params.length > 0) {
        this.buf.add('@:ueHasGenerics ');
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
      this.buf.add('@:ueGluePath("${this.glueType.getClassPath()}")\n');
    if (c.params.length > 0)
      this.buf.add('@:ueTemplate\n');
    if (c.isPrivate)
      this.buf.add('private ');
    if (c.isInterface) {
      this.buf.add('interface ');
    } else {
      this.buf.add('class ');
    }
    this.buf.add('${c.name}$params ');
    var hasSuperClass = true;
    if (c.superClass != null) {
      var supRef = TInst(c.superClass.t, c.superClass.params).toString();
      this.buf.add('extends $supRef ');
    } else if (c.isInterface) {
      this.buf.add('extends unreal.IInterface ');
    } else if (!this.thisConv.isUObject) {
      this.buf.add('extends unreal.Wrapper ');
    } else {
      hasSuperClass = false;
      this.buf.add('implements unreal.IInterface ');
    }

    for (iface in c.interfaces) {
      var t = TInst(iface.t, iface.params).toString();
      // var ifaceRef = TypeRef.fromBaseType(iface.t.get(), iface.params, c.pos);
      if (c.isInterface)
        this.buf.add('extends ');
      else
        this.buf.add('implements ');
      this.buf.add('$t ');
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
                ret: TypeConv.get(Context.getType("unreal.UClass"), pos),
                prop: PropType.NonProp,
                isHaxePublic: true, isFinal:true, isStatic: true, isPublic: true
              });
            }

            var glueClassGet = glueType.getClassPath() + '.StaticClass()';
            this.buf.add('static function __init__()');
            this.begin(' {');
              this.buf.add('unreal.helpers.ClassMap.addWrapper($glueClassGet, cpp.Function.fromStaticFunction(wrapPointer));');
              // this.buf.add('unreal.helpers.GlueClassMap.classMap.set("${uname}", cast ${c.name}.new);');//this.wrapped);');
            this.end('}');
            this.newline();

            // add wrap
            this.buf.add('@:unreflective static function wrapPointer(uobject:cpp.RawPointer<cpp.Void>):cpp.RawPointer<cpp.Void>');
            this.begin(' {');
              this.buf.add('var ptr:cpp.Pointer<Dynamic> = cpp.Pointer.fromRaw(cast uobject);');
              this.buf.add('return unreal.helpers.HaxeHelpers.dynamicToPointer(new ${this.typeRef.getClassPath()}(ptr));');
            this.end('}');
          }

          this.buf.add('@:unreflective public static function wrap(uobject:cpp.RawPointer<cpp.Void>):${this.typeRef.getClassPath()}');
          this.begin(' {');
            this.buf.add('return unreal.helpers.HaxeHelpers.pointerToDynamic( unreal.helpers.ClassMap.wrap(uobject) );');
          this.end('}');
        }
      } else if (!c.isInterface) {
        // add wrap for non-uobject types
        this.buf.add('@:unreflective public static function wrap$params(ptr:');
        this.buf.add(this.thisConv.haxeGlueType.toString());
        this.buf.add(', ?parent:Dynamic');
        this.buf.add('):' + this.thisConv.haxeType);
        this.begin(' {');
          if (!this.thisConv.haxeGlueType.isReflective()) {
            this.buf.add('var ptr = cpp.Pointer.fromRaw(cast ptr);');
            this.newline();
          }

          this.buf.add('if (ptr == null) return null;');
          this.newline();
          this.buf.add('return new ${this.typeRef.getClassPath()}(ptr, parent);');
        this.end('}');
      }

      if (!hasSuperClass) {
        this.newline();
        // add constructor
        this.buf.add('@:unreflective private var wrapped:${this.thisConv.haxeGlueType};');
        this.newline();
        if (this.thisConv.haxeGlueType.isReflective())
          this.buf.add('private function new(wrapped) this.wrapped = wrapped;\n\t');
        else
          this.buf.add('private function new(wrapped:${this.thisConv.haxeGlueType.toReflective()}) this.wrapped = wrapped.rawCast();\n\t');
        // This is used only on `unreal.UObject`,`cpp.Pointer<cpp.Void>` will fail if we used `this.thisConv.haxeGlueType.getReflective()`
        this.buf.add('@:extern inline private function getWrapped():cpp.Pointer<Dynamic>');
        this.begin(' {');
          this.buf.add('return this == null ? null : cpp.Pointer.fromRaw(cast this.wrapped);');
        this.end('}');

        // add the reflectGetWrapped()
        this.buf.add('@:ifFeature("${this.typeRef.getClassPath(true)}") private function reflectGetWrapped():cpp.Pointer<Dynamic>');
        this.begin(' {');
          this.buf.add('return cpp.Pointer.fromRaw(cast this.wrapped);');
        this.end('}');
        this.buf.add('@:ifFeature("${this.typeRef.getClassPath(true)}") private function reflectGetWrappedRef():cpp.Pointer<Dynamic>');
        this.begin(' {');
          this.buf.add('return cpp.Pointer.addressOf(this.wrapped).reinterpret();');
        this.end('}');
      } else if (!c.isInterface && !this.thisConv.isUObject) {
        // add rewrap
        this.buf.add('override public function rewrap(wrapped:cpp.Pointer<unreal.helpers.UEPointer>):${this.thisConv.haxeType}');
        this.begin(' {');
          this.buf.add('return new ${this.thisConv.haxeType}(wrapped);');
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
            prop:NonProp,
            isFinal: false, isHaxePublic:false, isStatic:false, isOverride: true, isPublic: true
          });
          methods.push({
            name: '_copyStruct',
            uname: '.copyStruct',
            doc: doc,
            meta:null,
            args:[],
            ret:TypeConv.get(type, c.pos, 'unreal.PStruct'),
            prop:NonProp,
            isFinal: false, isHaxePublic:false, isStatic:false, isOverride: true, isPublic: true
          });
        } else {
          this.buf.add('@:deprecated("This type does not support copy constructors") override private function _copy()');
          this.begin(' {');
            this.buf.add('return throw "The type ${this.thisConv.haxeType} does not support copy constructors";');
          this.end('}');
          this.buf.add('@:deprecated("This type does not support copy constructors") override private function _copyStruct()');
          this.begin(' {');
            this.buf.add('return throw "The type ${this.thisConv.haxeType} does not support copy constructors";');
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
            prop:NonProp,
            isFinal: false, isHaxePublic:false, isStatic:false, isOverride: true, isPublic: true
          });
        }
      }

    for (meth in methods)
      this.processMethodDef(meth, c.isInterface);
    this.end('}');

    // before defining the class, let's go through all types and see if we have any type parameters that are dependent on
    // our current type parameter specifications
    this.addDependentTypes();
    if (this.hasTParams)
      this.realBuf.add('@:hasTParams\n');
    this.realBuf.add(this.buf);
    this.buf = new StringBuf();
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

  private function processField(field:ClassField, isStatic:Bool, ?specialization:{ types:Array<TypeConv>, mtypes:Array<Type>, generic:String }, methods:Array<MethodDef>) {
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
        this.buf.add('public ');
      else
        this.buf.add('private ');

      if (isStatic)
        this.buf.add('static ');
      var tconv = TypeConv.get( field.type, field.pos );
      this.buf.add('var ');
      this.buf.add(field.name);
      this.buf.add('(');
      var prop = PropType.Prop;
      var realTConv = switch (tconv.ownershipModifier) {
        case 'unreal.PStruct':
          prop = PropType.StructProp;
          TypeConv.get( field.type, field.pos, 'unreal.PExternal' );
        case _:
          tconv;
      }
      switch(read) {
      case AccNormal | AccCall:
        methods.push({
          name: 'get_' + field.name,
          uname: uname,
          args: [],
          ret: realTConv,
          prop: prop, isFinal: true, isHaxePublic: false, isStatic: isStatic,
          isPublic: field.isPublic,
          meta: meta
        });
        this.buf.add('get,');
      case _:
        this.buf.add('never,');
      }
      switch(write) {
      case AccNormal | AccCall:
        methods.push({
          name: 'set_' + field.name,
          uname: uname,
          args: [{ name: 'value', t: tconv }],
          ret: tconv,
          prop: prop, isFinal: true, isHaxePublic: false, isStatic: isStatic,
          isPublic: field.isPublic,
          meta: meta
        });
        this.buf.add('set):');
      case _:
        this.buf.add('never):');
      }
      this.buf.add(realTConv.haxeType);
      this.buf.add(';');
      this.newline();
    case FMethod(k):
      switch(Context.follow(field.type)) {
      case TFun(args,ret):
        var cur = null;
        var args = args;
        if (specialization != null) {
          args = args.slice(specialization.types.length);
        }
        methods.push( cur = {
          name: field.name,
          uname: specialization == null || uname != field.name ? uname : specialization.generic,
          doc: field.doc,
          meta:field.meta.get(),
          params: [ for (p in field.params) p.name ],
          args: [ for (arg in args) { name: arg.name, t: TypeConv.get(arg.t, field.pos) } ],
          ret: TypeConv.get(ret, field.pos),
          prop: NonProp, isFinal: false, isHaxePublic: field.isPublic,
          isStatic: isStatic,
          isPublic: field.isPublic,
          specialization: specialization,
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
            prop: NonProp, isFinal: false, isHaxePublic: field.isPublic,
            isStatic: isStatic, isPublic: field.isPublic,
            specialization: specialization,
          });
        }
      case _: throw 'assert';
      }
    }
  }

  public function processMethodDef(meth:MethodDef, isInterface:Bool) {
    // var thisConv = this.thisConv;
    // if (meth.specialization != null && meth.specialization.mtypes.length > 0) {
    //   thisConv = TypeConv.get( this.type.applyTypeParameters( meth., meth.specialization.mtypes ), this.pos );
    // }
    var hasParams = meth.params != null && meth.params.length > 0;
    var ctx = meth.prop != NonProp && !meth.isStatic && !this.thisConv.isUObject ? [ "parent" => "this" ] : null;
    var isStatic = meth.isStatic;
    this.addDoc(meth.doc);
    this.addMeta(meth.meta);
    var helperArgs = meth.args.copy();
    if (!isStatic && this.params.length == 0) {
      var name = meth.specialization != null ? 'self' : 'this';
      helperArgs.unshift({ name: name, t: this.thisConv });
    }
    var isSetter = meth.prop != NonProp && meth.name.startsWith('set_');
    var glueRet = if (isSetter) {
      voidType;
    } else {
      meth.ret;
    }
    var isVoid = glueRet.haxeType.isVoid();
    if (!hasParams) {
      var st = '';
      if (this.params.length == 0 || meth.isStatic)
        st = 'static';
      this.glue.add('public $st function ${meth.name}(');
      this.glue.add([ for (arg in helperArgs) escapeName(arg.name) + ':' + arg.t.haxeGlueType.toString() ].join(', '));
      this.glue.add('):' + glueRet.haxeGlueType + ';\n');
    }

    // generate the header and cpp glue code
    //TODO: optimization: use StringBuf instead of all these string concats
    var cppArgDecl = [ for ( arg in helperArgs ) arg.t.glueType.getCppType() + ' ' + escapeName(arg.name) ].join(', ');
    var glueHeaderCode = new HelperBuf();

    if (hasParams) {
      glueHeaderCode << 'template<';
      glueHeaderCode.mapJoin(meth.params, function(p) return 'class $p');
      glueHeaderCode << '>\n\t';
    }
    if (this.params.length == 0 || meth.isStatic)
      glueHeaderCode << 'static ';
    glueHeaderCode << '${glueRet.glueType.getCppType()} ${meth.name}(' << cppArgDecl + ')';

    var baseGlueHeaderCode = null;
    if (this.params.length > 0 && !meth.isStatic) {
      baseGlueHeaderCode = 'virtual ' + glueHeaderCode.toString() + ' = 0;';
      // glueHeaderCode += ' override';
    }

    // var glueCppPrelude = '';
    var cppArgs = meth.args,
        retHaxeType = meth.ret.haxeType;
    var op = null;
    var glueCppBody = new HelperBuf();
    glueCppBody << if (isStatic) {
      switch (meth.uname) {
        case 'new':
          'new ' + meth.ret.ueType.getCppClass();
        case '.ctor':
          meth.ret.ueType.getCppClass();
        case _:
          if (meth.meta.hasMeta(':global')) {
            var namespace = MacroHelpers.extractStringsFromMetadata(meth.meta, ':global')[0];
            if (namespace != null)
              '::' + namespace.replace('.','::') + '::' + meth.uname;
            else
              '::' + meth.uname;
          } else {
            this.thisConv.ueType.getCppClass() + '::' + meth.uname;
          }
      }
    } else {
      var self = null;
      if (this.params.length > 0 && !meth.isStatic)
        self = { name: 'this', t: this.thisConv };
      else
        self = { name:escapeName(helperArgs[0].name), t: helperArgs[0].t };

      switch(meth.uname) {
        case 'get_Item' | 'set_Item':
          op = '[';
          '(*' + self.t.glueToUe(self.name, ctx) + ')';
        case '.equals':
          var thisType = TypeConv.get(this.type, this.pos, 'unreal.PStruct');
          cppArgs = [{ name:'this', t:thisType}, { name:'other', t:thisType }];
          'TypeTraits::Equals<${thisType.ueType.getCppType()}>::isEq';
        case 'op_Dereference':
          op = '*';
          '(**(' + self.t.glueToUe(self.name, ctx) + '))';
        case '.copy':
          retHaxeType = thisConv.haxeType;
          cppArgs = [{ name:'this', t:TypeConv.get(this.type, this.pos, 'unreal.PStruct') }];
          'new ' + this.thisConv.ueType.getCppClass();
        case '.copyStruct':
          retHaxeType = thisConv.haxeType;
          cppArgs = [{ name:'this', t:TypeConv.get(this.type, this.pos, 'unreal.PStruct') }];
          this.thisConv.ueType.getCppClass();
        case _ if(!meth.isPublic):
          // For protected external functions we need to use a
          // local derived class with a static function that lets the wrapper
          // call the protected function.
          // See PROTECTED METHOD CALL comments farther down the code.
          '(' + self.t.glueToUe('_s_' + self.name, ctx) + '->*(&_staticcall_${meth.name}::' + meth.uname + '))';
        case _:
          self.t.glueToUe(self.name, ctx) + '->' + meth.uname;
      }
    }
    inline function doEscapeName(str:String) {
      if (this.params.length > 0 && !meth.isStatic)
        return str;
      else
        return escapeName(str);
    }

    var params = new HelperBuf();
    var declParams = new HelperBuf();
    if (hasParams) {
      params << '<';
      params.mapJoin(meth.params, function(param) return param);
      params << '>';
      declParams = params;
    } else if (meth.specialization != null && this.params.length == 0) {
      params << '<';
      params.mapJoin(meth.specialization.types, function (tconv) return {
        if (tconv.isUObject && tconv.ownershipModifier == 'unreal.PStruct')
          tconv.ueType.getCppClassName();
        else
          tconv.ueType.getCppType().toString();
      });
      params << '>';
    }
    glueCppBody.add(params);

    // Given an array of function arguments and a prefix to use for the arguments,
    // fill in a HelperBuff with any special glue code needed to convert types, and
    // return an array of strings containing the C++ types
    // TODO clean up how we're dealing with PRef
    function genArgTypes(cppArgs:Array<{ name:String, t:TypeConv }>, argPrefix:String, cppBodyVars : HelperBuf) : Array<String> {
      var cppArgTypes = [];
      for (arg in cppArgs) {
        if (arg.t.isTypeParam == true && (arg.t.ownershipModifier == 'unreal.PRef' || arg.t.ownershipModifier == 'ue4hx.internal.PRefDef')) {
          var prefixedArgName = argPrefix + arg.name;
          cppBodyVars << 'PtrHelper<${arg.t.ueType.getCppType()}> ${prefixedArgName}_t = ${arg.t.glueToUe(${prefixedArgName}, ctx)};\n\t\t\t';
          cppArgTypes.push('*(${prefixedArgName}_t.ptr)');
        } else {
          cppArgTypes.push(arg.t.glueToUe(argPrefix+doEscapeName(arg.name), ctx));
        }
      }
      return cppArgTypes;
    }

    //
    function genMethodCallArgs(body:String, meth:MethodDef, op:String, glueRet:TypeConv, cppArgs:Array<{ name:String, t:TypeConv }>, cppArgTypes:Array<String>) : String {
      if (meth.prop == StructProp && !isSetter) {
        body = '&' + body;
      } else if (meth.prop == Prop && !isSetter && meth.ret.isUObject == true && meth.ret.haxeType.name != 'TSubclassOf') {
        body = 'const_cast< ${meth.ret.ueType.getCppType()} >( $body )';
      }

      if (meth.prop != NonProp) {
        if (isSetter) {
          body += ' = ' + cppArgTypes[cppArgTypes.length-1];
        }
      } else if (op == '[') {
        body += '[' + cppArgTypes[0] + ']';
        if (cppArgs.length == 2)
          body += ' = ' + cppArgTypes[1];
      } else if (op == '*') {
        if (cppArgs.length > 0) {
          throw new Error('Extern Baker: op_Dereference must take zero arguments', pos);
        }
      } else {
        body += '(' + [ for (arg in cppArgTypes) arg ].join(', ') + ')';
      }
      if (!glueRet.haxeType.isVoid())
        body = 'return ' + glueRet.ueToGlue( body, ctx );
      return body;
    }

    var glueCppBody = glueCppBody.toString();
    var glueCppBodyVars = new HelperBuf();
    var cppArgTypes = genArgTypes(cppArgs, '', glueCppBodyVars);

    // PROTECTED METHOD CALL
    // We use a local derived class and static function to allow the haxe
    // glue wrapper to call through to the protected functions. This is explained here:
    // http://stackoverflow.com/questions/11631777/accessing-a-protected-member-of-a-base-class-in-another-subclass/11634082#11634082
    //
    if (!meth.isPublic) {
      var staticCppBodyVars = new HelperBuf();
      var staticCppArgTypes = genArgTypes(cppArgs, '_s_', staticCppBodyVars);

      var staticBody = genMethodCallArgs(glueCppBody, meth, op, glueRet, cppArgs, staticCppArgTypes);
      var localDerivedClassBody = new HelperBuf();
      // On windows, we need to disable the warning 4610 that this class can never be instantiated.
      // We know that it can't, and that's just fine. But warnings are promoted to errors. so we have to disable
      // this warning during this code.
      localDerivedClassBody << "\n#if PLATFORM_WINDOWS\n#pragma warning( disable : 4510 4610 )\n#endif // PLATFORM_WINDOWS\n\t";
      localDerivedClassBody << 'class _staticcall_${meth.name} : public ${typeRef.name} {\n';
      var staticCppArgDecl = [ for ( arg in helperArgs ) arg.t.glueType.getCppType() + ' ' + '_s_' + escapeName(arg.name) ].join(', ');
      localDerivedClassBody << '\t\tpublic:\n\t\t\tstatic ${glueRet.glueType.getCppType()} static_${meth.name}(${staticCppArgDecl}) {\n\t\t\t\t'
        << staticCppBodyVars
        << staticBody
        << ';\n\t\t}\n'
        << '\t};\n'
        << "#if PLATFORM_WINDOWS\n#pragma warning( default : 4510 4610 )\n#endif // PLATFORM_WINDOWS\n\n\t";
        if (!glueRet.haxeType.isVoid()) localDerivedClassBody << 'return ';
      localDerivedClassBody << '_staticcall_${meth.name}::static_${meth.name}('
        + [ for (arg in helperArgs) doEscapeName(arg.name) ].join(', ') + ')';
      glueCppBodyVars << localDerivedClassBody;
    }
    else {
      glueCppBody = genMethodCallArgs(glueCppBody, meth, op, glueRet, cppArgs, cppArgTypes);
      glueCppBodyVars << glueCppBody;
    }

    var glueCppCode = new HelperBuf();
    if (hasParams) {
      glueCppCode << 'template<';
      glueCppCode.mapJoin(meth.params, function(p) return 'class $p');
      glueCppCode << '>\n\t';
    }

    if (this.params.length > 0 && !hasParams && !meth.isStatic) {
      glueHeaderCode << ' {\n\t\t\t$glueCppBodyVars;\n\t\t}';
    } else {
      glueHeaderCode << ';';
      glueCppCode <<
        glueRet.glueType.getCppType() <<
        ' ${this.glueType.getCppType()}_obj::${meth.name}$declParams(' << cppArgDecl << ') {' <<
          '\n\t' << glueCppBodyVars << ';\n}';
    }
    var allTypes = [ for (arg in helperArgs) arg.t ];
    allTypes.push(meth.ret);
    if (!hasParams && !meth.isStatic && this.params.length > 0) {
      for (type in allTypes) {
        if (type.hasTypeParams()) {
          var tref = type.haxeType;
          while (tref.name == 'PRef' || tref.name == 'PRefDef') {
            if (tref.pack.length == 1 && tref.name == 'PRef' && tref.pack[0] == 'unreal') {
              tref = tref.params[0];
            } else if (tref.pack.length == 2 && tref.name == 'PRefDef' && tref.pack[0] == 'ue4hx' && tref.pack[1] == 'internal') {
              tref = tref.params[0];
            } else {
              break;
            }
          }
          this.dependentTypes.push(tref.toString());
        }
      }
    }
    for (t in allTypes) {
      if (t.args != null && t.args.length > 0 && !t.hasTypeParams()) {
        // add metadata to warn NeedsGlueBuild that we need to make sure this type is built
        this.buf.add('@:hasTParams');
        this.newline();
        this.hasTParams = true;
        break;
      }
    }

    if (!hasParams) {
      if (baseGlueHeaderCode != null) {
        this.buf.add('@:glueHeaderCode(\'');
        escapeString(baseGlueHeaderCode, this.buf);
        this.buf.add('\')');
        this.newline();
        this.buf.add('@:ueHeaderCode(\'');
        escapeString(glueHeaderCode.toString(), this.buf);
        this.buf.add('\')');
        this.newline();
      } else {
        // add the glue header and cpp code to the non-extern class (instead of the glue helper)
        // in order to be able to benefit from DCE (extern types are never DCE'd)
        this.buf.add('@:glueHeaderCode(\'');
        escapeString(glueHeaderCode.toString(), this.buf);
        this.buf.add('\')');
        this.newline();
        this.buf.add('@:glueCppCode(\'');
        escapeString(glueCppCode.toString(), this.buf);
        this.buf.add('\')');
        this.newline();
      }
    }

    var headerIncludes = new Map(),
        cppIncludes = new Map();
    for (type in allTypes) {
      type.getAllCppIncludes(cppIncludes);
      type.getAllHeaderIncludes(headerIncludes);
    }
    if (meth.uname == ".equals") {
      cppIncludes['<TypeTraits.h>'] = '<TypeTraits.h>';
    }
    var hasHeaderInc = headerIncludes.iterator().hasNext(),
        hasCppInc = cppIncludes.iterator().hasNext();
    if (hasHeaderInc && !isInterface) {
      var first = true;
      this.buf.add('@:glueHeaderIncludes(');
      for (inc in headerIncludes) {
        if (first) first = false; else this.buf.add(', ');
        this.buf.add('\'');
        escapeString(inc, this.buf);
        this.buf.add('\'');
      }
      this.buf.add(')');
      this.newline();
    }
    if (hasCppInc && !isInterface) {
      var first = true;
      this.buf.add('@:glueCppIncludes(');
      for (inc in cppIncludes) {
        if (first) first = false; else this.buf.add(', ');
        this.buf.add('\'');
        escapeString(inc, this.buf);
        this.buf.add('\'');
      }
      this.buf.add(')');
      this.newline();
    }
    if (hasParams)
      this.buf.add('@:generic ');

    var args = meth.args;
    if (meth.specialization != null) {
      isStatic = true;
      args = helperArgs;
    }
    if (meth.isFinal)
      this.buf.add('@:final @:nonVirtual ');
    if (meth.isHaxePublic)
      this.buf.add('public ');
    else
      this.buf.add('private ');
    if (isStatic)
      this.buf.add('static ');
    if (meth.isOverride)
      this.buf.add('override ');

    this.buf.add('function ${meth.name}');
    if (hasParams) {
      this.buf.add('<');
      var first = true;
      for (param in meth.params) {
        if (first) first = false; else this.buf.add(', ');
        this.buf.add(param);
      }
      this.buf.add('>');
    }
    this.buf.add('(');
    if (hasParams) {
      var first = true;
      for (param in meth.params) {
        if (first) first = false; else this.buf.add(', ');
        this.buf.add('?${param}_TP:unreal.TypeParam<$param>');
      }
      if (meth.args.length != 0) this.buf.add(', ');
    }
    //TODO: Fix this to not just hardset it to wrapper
    if (meth.uname == '.equals') {
      this.buf.add('other:unreal.Wrapper');
    } else {
      this.buf.add([ for (arg in args) arg.name + ':' + arg.t.haxeType.toString() ].join(', '));
    }
    this.buf.add('):' + retHaxeType + ' ');
    if (isInterface) {
      this.buf.add(';');
      this.newline();
      return;
    }
    this.begin('{');
      if (hasParams) {
        if (!isVoid)
          this.buf.add('return cast null;');
        else
          this.buf.add('return;');
      } else {
        if (!isStatic && !this.thisConv.isUObject) {
          this.buf.add('#if UE4_CHECK_POINTER');
          this.newline();
          this.buf.add('this.checkPointer();');
          this.newline();
          this.buf.add('#end');
          this.newline();
        }
        var haxeBodyCall = '${this.glueType}.${meth.name}';
        if (this.params.length > 0 && !meth.isStatic) {
          haxeBodyCall = '( cast this.wrapped : cpp.Pointer<${this.glueType}> ).ptr.${meth.name}';
        }

        var haxeBody =
          '$haxeBodyCall(' +
            [ for (arg in helperArgs) arg.t.haxeToGlue(arg.name, ctx) ].join(', ') +
          ')';
        if (isSetter)
          haxeBody = haxeBody + ';\n${this.indentStr}return value';
        else if (!isVoid)
          haxeBody = 'return ' + meth.ret.glueToHaxe(haxeBody, ctx);
        this.buf.add(haxeBody);
        this.buf.add(';');
      }
    this.end('}\n');
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

  private static function escapeString(str:String, ?buf:StringBuf):StringBuf {
    if (buf == null) buf = new StringBuf();
    for (i in 0...str.length) {
      var code = str.fastCodeAt(i);
      switch (code) {
      case '\\'.code:
        buf.add('\\\\');
      case '\n'.code:
        buf.add('\\n');
      case '\t'.code:
        buf.add('\\t');
      case '\''.code:
        buf.add('\\\'');
      case '"'.code:
        buf.add('\\"');
      case chr:
        buf.addChar(chr);
      }
    }
    return buf;
  }

  private function processEnum(e:EnumType) {
    this.pos = e.pos;
    if (!e.isExtern || !e.meta.has(':uextern')) return;
    this.typeRef = TypeRef.fromBaseType(e, e.pos);
    this.glueType = this.typeRef.getGlueHelperType();

    this.addDoc(e.doc);
    this.addMeta(e.meta.get());
    if (e.isPrivate)
      this.buf.add('private ');
    this.buf.add('enum ${e.name} ');
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
        this.buf.add(name + ';');
        this.newline();
      }
    this.end('}');
    this.newline();

    this.buf.add('@:ueGluePath("${this.glueType.getClassPath()}")\n');
    this.addMeta(e.meta.get());
    this.buf.add('class ${e.name}_EnumConv ');
    this.begin('{');
      this.buf.add('public static var all = std.Type.allEnums(${this.typeRef});');
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
      this.buf.add('@:glueHeaderCode("static int ueToHaxe(int value);")');
      this.newline();
      this.buf.add('@:glueCppCode("int ${this.glueType.getCppType()}_obj::ueToHaxe(int value) {');
      escapeString('\n\t' +ueToHaxe.toString() + '\n}', this.buf);
      this.buf.add('")');
      this.newline();
      this.buf.add('public static function ueToHaxe(value:Int):Int');
      this.begin(' {');
        this.buf.add('return ${this.glueType}.ueToHaxe(value);');
      this.end('}');

      this.glue.add('public static function haxeToUe(value:Int):Int;\n');
      this.buf.add('@:glueHeaderCode("static int haxeToUe(int value);")');
      this.newline();
      this.buf.add('@:glueCppCode("int ${this.glueType.getCppType()}_obj::haxeToUe(int value) {');
      escapeString('\n\t' +haxeToUe.toString() + '\n}', this.buf);
      this.buf.add('")');
      this.newline();
      this.buf.add('public static function haxeToUe(value:Int):Int');
      this.begin(' {');
        this.buf.add('return ${this.glueType}.haxeToUe(value);');
      this.end('}');

      this.buf.add('public static inline function wrap(v:Int):${this.typeRef} return all[ueToHaxe(v) - 1];');
      this.newline();
      this.buf.add('public static inline function unwrap(v:${this.typeRef}):Int return haxeToUe(v.getIndex() + 1);');
    this.end('}');
    this.newline();

    this.realBuf.add(this.buf);
    this.buf = new StringBuf();
  }

  private function addMeta(metas:Metadata) {
    if (metas != null) {
      for (meta in metas) {
        this.buf.add('@' + meta.name);
        if (meta.params != null && meta.params.length > 0) {
          this.buf.add('(');
          var first = true;
          for (param in meta.params) {
            if (first) first = false; else this.buf.add(', ');
            this.buf.add(param.toString());
          }
          this.buf.add(')');
        }
        if (meta.name == ':final')
          this.buf.add(' @:nonVirtual ');
        this.newline();
      }
    }
  }

  private function addDoc(doc:Null<String>) {
    if (doc != null) {
      buf.add('/**');
      buf.add(doc);
      buf.add('**/\n');
      buf.add(indentStr);
    }
  }

  private function begin(?brkt:String) {
    if (brkt != null) {
      buf.add(brkt);
      buf.add('\n');
      buf.add(indentStr += '  ');
    } else {
      indentStr += '  ';
    }
  }

  private function end(?brkt:String) {
    indentStr = indentStr.substr(2);
    if (brkt != null) {
      this.newline();
      buf.add(brkt);
      this.newline();
    }
  }

  private function newline() {
    buf.add('\n');
    buf.add(indentStr);
  }

  private function get_voidType():TypeConv {
    if (this.voidType == null)
      this.voidType = TypeConv.get(Context.getType('Void'), this.pos);
    return this.voidType;
  }
}

@:enum abstract PropType(Int) {
  var NonProp = 0x0;
  var Prop = 0x1;
  var StructProp = 0x2;
}

typedef MethodDef = {
  name:String,
  uname:String,
  ?doc:Null<String>,
  ?meta:Metadata,
  ?params:Array<String>,
  args:Array<{ name:String, t:TypeConv }>,
  ret:TypeConv,
  prop:PropType,
  isFinal:Bool,
  isHaxePublic:Bool,
  isPublic:Bool,
  isStatic:Bool,
  ?isOverride:Bool,
  ?specialization:{ types:Array<TypeConv>, mtypes:Array<Type>, generic:String },
}
