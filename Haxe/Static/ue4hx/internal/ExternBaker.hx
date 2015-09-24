package ue4hx.internal;
import haxe.macro.Compiler;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import sys.FileSystem;
import sys.io.File;

using haxe.macro.Tools;

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

        var dir = target + '/' + pack.join('/');
        if (!FileSystem.exists(dir)) FileSystem.createDirectory(dir);
        File.saveContent('$dir/$name.hx', buf.toString());
      }
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
  private var hadErrors:Bool;

  @:isVar private var voidType(get,null):Null<TypeConv>;

  private function new(buf:StringBuf) {
    this.buf = buf;
    this.indentStr = '';
    this.hadErrors = false;
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
    this.typeRef = TypeRef.fromBaseType(c, c.pos);
    this.glueType = this.typeRef.getGlueHelperType();
    this.thisConv = TypeConv.get(type,c.pos);

    this.addDoc(c.doc);
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
    this.begin('{');
      for (field in c.statics.get()) {
        processField(field,true);
      }
      for (field in c.fields.get()) {
        processField(field,false);
      }

      // add the wrap field
      // FIXME: test if class is the same so we can get inheritance correctly (on UObjects only)
      this.buf.add('@:unreflective public static function wrap(ptr:');
      this.buf.add(this.thisConv.haxeGlueType.toString());
      this.buf.add('):' + this.thisConv.haxeType);
      this.begin(' {');
        if (!this.thisConv.haxeGlueType.isReflective()) {
          this.buf.add('var ptr = cpp.Pointer.fromRaw(cast ptr);');
          this.newline();
        }

        this.buf.add('if (ptr == null) return null;');
        this.newline();
        this.buf.add('return new ${this.typeRef.getClassPath()}(ptr);');
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

        // add the reflectGetWrapped()
        this.buf.add('@:ifFeature("${this.typeRef.getClassPath(true)}") private function reflectGetWrapped():cpp.Pointer<Dynamic>');
        this.begin(' {');
          this.buf.add('return cpp.Pointer.fromRaw(cast this.wrapped);');
        this.end('}');
      }

    this.end('}');
  }

  private function processField(field:ClassField, isStatic:Bool) {
    this.addDoc(field.doc);
    this.addMeta(field.meta.get());

    var uname = switch(MacroHelpers.extractStrings(field.meta, ':uname')[0]) {
      case null:
        field.name;
      case name:
        name;
    };

    var methods = [];
    switch(field.kind) {
    case FVar(read,write):
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
      switch(read) {
      case AccNormal | AccCall:
        methods.push({
          name: 'get_' + field.name,
          uname: uname,
          args: [],
          ret: tconv,
          isProp: true, isFinal: true, isPublic: false
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
          isProp: true, isFinal: true, isPublic: false
        });
        this.buf.add('set):');
      case _:
        this.buf.add('never):');
      }
      this.buf.add(tconv.haxeType);
      this.buf.add(';');
      this.newline();
    case FMethod(k):
      switch(Context.follow(field.type)) {
      case TFun(args,ret):
        if (uname == 'new') {
          // make sure that the return type is of type PHaxeCreated
          if (!isHaxeCreated(ret)) {
            Context.warning(
              'The function constructor `${field.name}` should return an `unreal.PHaxeCreated` type. Otherwise, this reference will leak', field.pos);
            hadErrors = true;
          }
        }
        methods.push({
          name: field.name,
          uname: uname,
          args: [ for (arg in args) { name: arg.name, t: TypeConv.get(arg.t, field.pos) } ],
          ret: TypeConv.get(ret, field.pos),
          isProp: false, isFinal: false, isPublic: field.isPublic
        });
      case _: throw 'assert';
      }
    }

    for (meth in methods) {
      var helperArgs = meth.args.copy();
      if (!isStatic)
        helperArgs.unshift({ name: 'this', t: this.thisConv });
      var isSetter = meth.isProp && meth.name.startsWith('set_');
      var glueRet = if (isSetter) {
        voidType;
      } else {
        meth.ret;
      }
      var isVoid = glueRet.haxeType.isVoid();
      this.glue.add('public static function ${meth.name}(');
      this.glue.add([ for (arg in helperArgs) escapeName(arg.name) + ':' + arg.t.haxeGlueType.toString() ].join(', '));
      this.glue.add('):' + glueRet.haxeGlueType + ';\n');

      // generate the header and cpp glue code
      //TODO: optimization: use StringBuf instead of all these string concats
      var cppArgDecl = [ for ( arg in helperArgs ) arg.t.glueType.getCppType() + ' ' + escapeName(arg.name) ].join(', ');
      var glueHeaderCode = 'static ${glueRet.glueType.getCppType()} ${meth.name}(' + cppArgDecl + ');';

      var glueCppBody = if (isStatic) {
        if (meth.uname == 'new') {
          'new ' + this.thisConv.ueType.getCppClass();
        } else {
          this.thisConv.ueType.getCppClass() + '::' + meth.uname;
        }
      } else {
        var self = helperArgs[0];
        self.t.glueToUe(escapeName(self.name)) + '->' + meth.uname;
      }

      if (meth.isProp) {
        if (isSetter) {
          glueCppBody += ' = ' + meth.args[0].t.glueToUe('value');
        }
      } else {
        glueCppBody += '(' + [ for (arg in meth.args) arg.t.glueToUe(escapeName(arg.name)) ].join(', ') + ')';
      }
      if (!isVoid)
        glueCppBody = 'return ' + glueRet.ueToGlue( glueCppBody );

      var glueCppCode =
        glueRet.glueType.getCppType() +
        ' ${this.glueType.getCppType()}_obj::${meth.name}(' + cppArgDecl + ') {' +
          '\n\t' + glueCppBody + ';\n}';
      var allTypes = [ for (arg in helperArgs) arg.t ];
      allTypes.push(meth.ret);

      // add the glue header and cpp code to the non-extern class (instead of the glue helper)
      // in order to be able to benefit from DCE (extern types are never DCE'd)
      this.buf.add('@:glueHeaderCode(\'');
      escapeString(glueHeaderCode, this.buf);
      this.buf.add('\')');
      this.newline();
      this.buf.add('@:glueCppCode(\'');
      escapeString(glueCppCode, this.buf);
      this.buf.add('\')');
      this.newline();

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

      if (meth.isFinal)
        this.buf.add('@:final @:nonVirtual ');
      if (meth.isPublic)
        this.buf.add('public ');
      else
        this.buf.add('private ');
      if (isStatic)
        this.buf.add('static ');

      this.buf.add('function ${meth.name}(');
      this.buf.add([ for (arg in meth.args) arg.name + ':' + arg.t.haxeType.toString() ].join(', '));
      this.buf.add('):' + meth.ret.haxeType + ' ');
      this.begin('{');
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
            [ for (arg in helperArgs) arg.t.haxeToGlue(arg.name) ].join(', ') +
          ')';
        if (isSetter)
          haxeBody = haxeBody + ';\n${this.indentStr}return value';
        else if (!isVoid)
          haxeBody = 'return ' + meth.ret.glueToHaxe(haxeBody);
        this.buf.add(haxeBody);
        this.buf.add(';');
      this.end('}\n');
    }
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
    // TODO
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
