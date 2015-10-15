package ue4hx.internal;
import ue4hx.internal.buf.HelperBuf;
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Compiler;
import haxe.macro.Type;
import sys.io.File;
import sys.FileSystem;

using StringTools;
using haxe.macro.Tools;

class GenericFuncBuild {

  public function new() {
  }

  public function buildFunctions(cl:ClassType) {
    var typeRef = TypeRef.fromBaseType(cl, cl.pos),
        glue = typeRef.getGlueHelperType(),
        caller = new TypeRef(glue.pack, glue.name + "GenericCaller"),
        genericGlue = new TypeRef(glue.pack, glue.name + "Generic");

    var target = Compiler.getDefine('bake_dir');
    if (target == null) {
      Context.warning('Haxe Glue Generic Wrapper: `bake_dir` directive is not set and this code uses generics. Make sure you have the latest build tool. Compilation may fail.', cl.pos);
      return;
    }
    var buf = new StringBuf();
    buf.add('package ${genericGlue.pack.join(".")};\n\n');
    var glueCode = new ExternBaker(buf).processGenericFunctions(cl);
    if (glueCode != null) {
      cl.meta.add(':cppFileCode', [macro $v{'#include <${caller.getClassPath().replace('.','/')}.h>\n'}], cl.pos);
      // write file if different

      var dir = target + '/' + caller.pack.join('/');
      if (!FileSystem.exists(dir)) FileSystem.createDirectory(dir);
      inline function writeIfNeeded(path:String, contents:String) {
        if (!FileSystem.exists(path) || File.getContent(path) != contents)
          File.saveContent(path, contents);
      }
      writeIfNeeded('$dir/${caller.name}.hx', buf.toString());
      var glue = 'package ${genericGlue.pack.join('.')};\n\n@:unrealGlue extern class ${genericGlue.name} {\n$glueCode\n}';
      writeIfNeeded('$dir/${genericGlue.name}.hx', glue);
      Context.getType(caller.getClassPath());

      Globals.cur.gluesToGenerate = Globals.cur.gluesToGenerate.add(caller.getClassPath());
    }
  }

  public function commentedCode(cl:ClassType) {
    var typeRef = TypeRef.fromBaseType(cl, cl.pos),
        glue = typeRef.getGlueHelperType(),
        caller = new TypeRef(glue.pack, glue.name + "GenericCaller"),
        genericGlue = new TypeRef(glue.pack, glue.name + "Generic");

    var thisConv = TypeConv.get( Context.getType(typeRef.getClassPath()), cl.pos );
    var glueBuild = [],
        callerBuild = [];
    var generics = [];
    var isStatic = true;
    for (fields in [cl.statics.get(), cl.fields.get()]) {
      for (field in fields) {
        if (field.meta.has(':generic')) {
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

    for (generic in generics) {
      trace('generic', generic.field.name);

      // exclude the generic base field
      generic.field.meta.add(':extern', [], generic.field.pos);
      for (impl in generic.impls) {
        trace('\timpl',impl.name);
        // poor man's version of mk_mono
        var tparams = [ for (param in generic.field.params) Context.typeof(macro null) ];
        var func = generic.field.type.applyTypeParameters(generic.field.params, tparams);
        if (!Context.unify(func, impl.type)) {
          Context.warning('Assert: ${impl.name} doesn\'t unify with ${generic.field.name}', generic.field.pos);
          continue;
        }

        var pos = Context.getPosInfos(generic.field.pos);
        pos.file = pos.file + " (" + impl.name + ")";
        var pos = Context.makePosition(pos);
        var ret = null, args = null;
        switch (Context.follow(impl.type)) {
          case TFun(a,r):
            args = [ for (arg in a) { name:arg.name, type: TypeConv.get(arg.t, pos) } ];
            ret = TypeConv.get(r, pos);
          case _: throw 'assert';
        }
        // create the caller
        var haxeBody = new HelperBuf();
        var glueArgs = if (generic.isStatic)
          args;
        else
          [{ name:'this', type: thisConv }].concat(args);

        // haxeBody += genericGlue.getClassPath() + '.' + impl.name + '(';
        // haxeBody.mapJoin(args, function(arg) return arg.type.haxeToGlue(arg.name));
        // haxeBody += ')';
        // if (!ret.haxeType.isVoid())
        //   haxeBody = new HelperBuf() + 'return ' + ret.glueToHaxe(haxeBody.toString()) + ';';
        // else
        //   haxeBody += ';';
        //
        // create the glue
        var header = new HelperBuf();
      }
    }
  }
}
