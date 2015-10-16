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

  private var buf:StringBuf;
  private var glue:StringBuf;
  private var glueType:TypeRef;
  private var thisConv:TypeConv;

  private var type:Type;
  private var typeRef:TypeRef;
  private var indentStr:String;

  private var pos:Position;
  public var hadErrors(default, null):Bool;

  @:isVar private var voidType(get,null):Null<TypeConv>;

  public function new(buf:StringBuf) {
    this.buf = buf;
    this.indentStr = '';
    this.hadErrors = false;
  }

  public function processGenericFunctions(cl:ClassType):StringBuf {
    this.glue = new StringBuf();
    var typeRef = TypeRef.fromBaseType(cl, cl.pos),
        glue = typeRef.getGlueHelperType(),
        caller = new TypeRef(glue.pack, glue.name + "GenericCaller"),
        genericGlue = new TypeRef(glue.pack, glue.name + "Generic");
    this.glueType = genericGlue;

    this.type = Context.getType(typeRef.getClassPath());
    this.thisConv = TypeConv.get(this.type, cl.pos);
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

    if (generics.length == 0) return null;
    this.buf.add('@:ueGluePath("${this.glueType.getClassPath()}")\n');
    this.buf.add('@:nativeGen\n');
    this.buf.add('class ${caller.name}');
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
        var specialization = { types:specializationTypes, generic:generic.field.name };
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
      this.processMethodDef(meth);
    this.end('}');
    return this.glue;
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
    this.pos = c.pos;
    if (!c.isExtern || !c.meta.has(':uextern')) return;
    this.type = type;
    this.typeRef = TypeRef.fromBaseType(c, c.pos);
    this.glueType = this.typeRef.getGlueHelperType();
    this.thisConv = TypeConv.get(type,c.pos);

    this.addDoc(c.doc);
    var fields = c.fields.get(),
        statics = c.statics.get();
    for (field in fields.concat(statics)) {
      if (field.params.length > 0) {
        this.buf.add('@:ueHasGenerics ');
        break;
      }
    }

    this.addMeta(c.meta.get());
    this.buf.add('@:ueGluePath("${this.glueType.getClassPath()}")\n');
    if (c.isPrivate)
      this.buf.add('private ');
    this.buf.add('class ${c.name} ');
    var hasSuperClass = true;
    if (c.superClass != null) {
      var supRef = TypeRef.fromBaseType(c.superClass.t.get(), c.superClass.params, c.pos);
      this.buf.add('extends $supRef ');
    } else if (!this.thisConv.isUObject) {
      this.buf.add('extends unreal.Wrapper ');
    } else {
      hasSuperClass = false;
      this.buf.add('implements ue4hx.internal.NeedsGlue ');
    }

    for (iface in c.interfaces) {
      var ifaceRef = TypeRef.fromBaseType(iface.t.get(), iface.params, c.pos);
      this.buf.add('implements $ifaceRef ');
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
        this.buf.add('static function __init__()');
        this.begin(' {');
        this.buf.add('unreal.helpers.GlueClassMap.classMap.set("${uname}", cast ${c.name}.new);');//this.wrapped);');
        this.end('}');
        this.newline();
      }

      // add the wrap field
      // FIXME: test if class is the same so we can get inheritance correctly (on UObjects only)
      this.buf.add('@:unreflective public static function wrap(ptr:');
      this.buf.add(this.thisConv.haxeGlueType.toString());
        if (!this.thisConv.isUObject) {
          this.buf.add(', ?parent:Dynamic');
        }
      this.buf.add('):' + this.thisConv.haxeType);
      this.begin(' {');
        if (!this.thisConv.haxeGlueType.isReflective()) {
          this.buf.add('var ptr = cpp.Pointer.fromRaw(cast ptr);');
          this.newline();
        }

        this.buf.add('if (ptr == null) return null;');
        this.newline();
        if(this.thisConv.isUObject) {
          this.buf.add('var currentClass = new unreal.UObject(ptr).GetClass();');
          this.newline();
          this.buf.add('while (unreal.helpers.GlueClassMap.classMap.get(currentClass.GetDesc()) == null)');
          this.begin(' {');
            this.buf.add('currentClass = currentClass.GetSuperClass();');
          this.end('}');
          this.buf.add('return unreal.helpers.GlueClassMap.classMap.get(currentClass.GetDesc())(ptr);');
        }
        else {
          this.buf.add('return new ${this.typeRef.getClassPath()}(ptr, parent);');
        }
      this.end('}');

      if (!hasSuperClass) {
        this.newline();
        // add constructor
        this.buf.add('@:unreflective private var wrapped:${this.thisConv.haxeGlueType};');
        this.newline();
        if (this.thisConv.haxeGlueType.isReflective())
          this.buf.add('private function new(wrapped) this.wrapped = wrapped;\n\t');
        else
          this.buf.add('private function new(wrapped:${this.thisConv.haxeGlueType.toReflective()}) this.wrapped = wrapped.rawCast();\n\t');
        this.buf.add('@:extern inline private function getWrapped():${this.thisConv.haxeGlueType}');
        this.begin(' {');
          this.buf.add('return this == null ? untyped __cpp__("(void *) 0") : this.wrapped;');
        this.end('}');

        // add the reflectGetWrapped()
        this.buf.add('@:ifFeature("${this.typeRef.getClassPath(true)}") private function reflectGetWrapped():cpp.Pointer<Dynamic>');
        this.begin(' {');
          this.buf.add('return cpp.Pointer.fromRaw(cast this.wrapped);');
        this.end('}');
      } else if (!this.thisConv.isUObject) {
        // add rewrap
        this.buf.add('override public function rewrap(wrapped:cpp.Pointer<unreal.helpers.UEPointer>):${this.thisConv.haxeType}');
        this.begin(' {');
          this.buf.add('return new ${this.thisConv.haxeType}(wrapped);');
        this.end('}');
        if (!c.meta.has(':noCopy')) {
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
            isFinal: false, isPublic:false, isStatic:false, isOverride: true
          });
          methods.push({
            name: '_copyStruct',
            uname: '.copyStruct',
            doc: doc,
            meta:null,
            args:[],
            ret:TypeConv.get(type, c.pos, 'unreal.PStruct'),
            prop:NonProp,
            isFinal: false, isPublic:false, isStatic:false, isOverride: true
          });
        } else {
          this.buf.add('@:deprecated("This type does not support copy constructors") override public function copy()');
          this.begin(' {');
            this.buf.add('throw "The type ${this.thisConv.haxeType} does not support copy constructors";');
          this.end('}');
          this.buf.add('@:deprecated("This type does not support copy constructors") override public function copyStruct()');
          this.begin(' {');
            this.buf.add('throw "The type ${this.thisConv.haxeType} does not support copy constructors";');
          this.end('}');
        }
      }

    for (meth in methods)
      this.processMethodDef(meth);
    this.end('}');
  }

  private function processField(field:ClassField, isStatic:Bool, ?specialization:{ types:Array<TypeConv>, generic:String }, methods:Array<MethodDef>) {
    var uname = switch(MacroHelpers.extractStrings(field.meta, ':uname')[0]) {
      case null:
        field.name;
      case name:
        name;
    };

    switch(field.kind) {
    case FVar(read,write):
      this.addDoc(field.doc);
      this.addMeta(field.meta.get());
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
      var realTConv = switch [tconv.haxeType.pack, tconv.haxeType.name] {
        case [ ['unreal'], 'PStruct' ]:
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
          prop: prop, isFinal: true, isPublic: false, isStatic: isStatic
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
          prop: prop, isFinal: true, isPublic: false, isStatic: isStatic
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
          uname: specialization != null ? specialization.generic : uname,
          doc: field.doc,
          meta:field.meta.get(),
          params: [ for (p in field.params) p.name ],
          args: [ for (arg in args) { name: arg.name, t: TypeConv.get(arg.t, field.pos) } ],
          ret: TypeConv.get(ret, field.pos),
          prop: NonProp, isFinal: false, isPublic: field.isPublic, isStatic: isStatic,
          specialization: specialization,
        });
        if (uname == 'new') {
          // make sure that the return type is of type PHaxeCreated
          if (!isHaxeCreated(ret)) {
            Context.warning(
              'The function constructor `${field.name}` should return an `unreal.PHaxeCreated` type. Otherwise, this reference will leak', field.pos);
            hadErrors = true;
          }
          var retComplex = ret.toComplexType();
          var thisType = thisConv.haxeType.toComplexType();
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
            prop: NonProp, isFinal: false, isPublic: field.isPublic, isStatic: isStatic,
            specialization: specialization,
          });
        }
      case _: throw 'assert';
      }
    }
  }

  public function processMethodDef(meth:MethodDef) {
    var hasParams = meth.params != null && meth.params.length > 0;
    var ctx = meth.prop != NonProp && !meth.isStatic && !this.thisConv.isUObject ? [ "parent" => "this" ] : null;
    var isStatic = meth.isStatic;
    this.addDoc(meth.doc);
    this.addMeta(meth.meta);
    var helperArgs = meth.args.copy();
    if (!isStatic) {
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
      this.glue.add('public static function ${meth.name}(');
      this.glue.add([ for (arg in helperArgs) escapeName(arg.name) + ':' + arg.t.haxeGlueType.toString() ].join(', '));
      this.glue.add('):' + glueRet.haxeGlueType + ';\n');
    }

    // generate the header and cpp glue code
    //TODO: optimization: use StringBuf instead of all these string concats
    var cppArgDecl = [ for ( arg in helperArgs ) arg.t.glueType.getCppType() + ' ' + escapeName(arg.name) ].join(', ');
    var glueHeaderCode = new HelperBuf();

    if (hasParams) {
      glueHeaderCode += 'template<';
      glueHeaderCode.mapJoin(meth.params, function(p) return 'class $p');
      glueHeaderCode += '>\n\t';
    }
    glueHeaderCode += 'static ${glueRet.glueType.getCppType()} ${meth.name}(' + cppArgDecl + ');';

    // var glueCppPrelude = '';
    var cppArgs = meth.args,
        retHaxeType = meth.ret.haxeType;
    var glueCppBody = new HelperBuf();
    glueCppBody += if (isStatic) {
      switch (meth.uname) {
      case 'new':
        'new ' + this.thisConv.ueType.getCppClass();
      case '.ctor':
        this.thisConv.ueType.getCppClass();
      case _:
        if (meth.meta.hasMeta(':global'))
          meth.uname;
        else
          this.thisConv.ueType.getCppClass() + '::' + meth.uname;
      }
    } else {
      switch(meth.uname) {
      case '.copy':
        retHaxeType = thisConv.haxeType;
        cppArgs = [{ name:'this', t:TypeConv.get(this.type, this.pos, 'unreal.PStruct') }];
        'new ' + this.thisConv.ueType.getCppClass();
      case '.copyStruct':
        retHaxeType = thisConv.haxeType;
        cppArgs = [{ name:'this', t:TypeConv.get(this.type, this.pos, 'unreal.PStruct') }];
        this.thisConv.ueType.getCppClass();
      case _:
        var self = helperArgs[0];
        self.t.glueToUe(escapeName(self.name), ctx) + '->' + meth.uname;
      }
    }
    var params = new HelperBuf();
    var declParams = new HelperBuf();
    if (hasParams) {
      params += '<';
      params.mapJoin(meth.params, function(param) return param);
      params += '>';
      declParams = params;
    } else if (meth.specialization != null) {
      params += '<';
      params.mapJoin(meth.specialization.types, function (tconv) return {
        if (tconv.isUObject && tconv.ownershipModifier == 'unreal.PStruct')
          tconv.ueType.getCppClassName();
        else
          tconv.ueType.getCppType().toString();
      });
      params += '>';
    }
    glueCppBody.add(params);

    var glueCppBody = glueCppBody.toString();
    if (meth.prop == StructProp && meth.name.startsWith('get_'))
      glueCppBody = '&' + glueCppBody;

    if (meth.prop != NonProp) {
      if (isSetter) {
        glueCppBody += ' = ' + meth.args[0].t.glueToUe('value', ctx);
      }
    } else {
      glueCppBody += '(' + [ for (arg in cppArgs) arg.t.glueToUe(escapeName(arg.name), ctx) ].join(', ') + ')';
    }
    if (!isVoid)
      glueCppBody = 'return ' + glueRet.ueToGlue( glueCppBody, ctx );

    var glueCppCode = new HelperBuf();
    if (hasParams) {
      glueCppCode += 'template<';
      glueCppCode.mapJoin(meth.params, function(p) return 'class $p');
      glueCppCode += '>\n\t';
    }
    var glueCppCode =
      glueCppCode +
      glueRet.glueType.getCppType() +
      ' ${this.glueType.getCppType()}_obj::${meth.name}$declParams(' + cppArgDecl + ') {' +
        '\n\t' + glueCppBody + ';\n}';
    var allTypes = [ for (arg in helperArgs) arg.t ];
    allTypes.push(meth.ret);
    if (meth.specialization != null) {
      for (s in meth.specialization.types)
        allTypes.push(s);
    }

    if (!hasParams) {
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

    var headerIncludes = new Map(),
        cppIncludes = new Map();
    var hasHeaderInc = false,
        hasCppInc = false;
    for (type in allTypes) {
      if (type.glueCppIncludes != null) {
        for (inc in type.glueCppIncludes)
          cppIncludes[inc] = inc;
          hasCppInc = true;
      }
      if (type.glueHeaderIncludes != null) {
        for (inc in type.glueHeaderIncludes)
          headerIncludes[inc] = inc;
          hasHeaderInc = true;
      }
    }
    if (hasHeaderInc) {
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
    if (hasCppInc) {
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
    if (meth.isPublic)
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
    this.buf.add([ for (arg in args) arg.name + ':' + arg.t.haxeType.toString() ].join(', '));
    this.buf.add('):' + retHaxeType + ' ');
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
        var haxeBody =
          '${this.glueType}.${meth.name}(' +
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
  isPublic:Bool,
  isStatic:Bool,
  ?isOverride:Bool,
  ?specialization:{ types:Array<TypeConv>, generic:String }
}
