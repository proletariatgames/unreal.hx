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

  public function buildFunctions(c:Ref<ClassType>) {
    var cl = c.get(),
        base:BaseType = null;
    switch(cl.kind) {
    case KAbstractImpl(a):
      base = a.get();
    case _:
      base = cl;
    }
    var typeRef = TypeRef.fromBaseType(base, base.pos),
        glue = typeRef.getGlueHelperType(),
        caller = new TypeRef(glue.pack, glue.name + "GenericCaller"),
        genericGlue = new TypeRef(glue.pack, glue.name + "Generic");

    var target = Context.definedValue('bake_dir');
    if (target == null) {
      Context.warning('Haxe Glue Generic Wrapper: `bake_dir` directive is not set and this code uses generics. Make sure you have the latest build tool. Compilation may fail.', cl.pos);
      return;
    }
    var buf = new StringBuf();
    buf.add('package ${genericGlue.pack.join(".")};\n\n');
    var glueCode = new ExternBaker(buf).processGenericFunctions(c);
    if (glueCode != null) {
      var path = caller.getClassPath().replace('.','/') + '.h';
      base.meta.add(':cppFileCode', [macro $v{'#include <${path}>\n'}], cl.pos);
      if (Context.definedValue('dce') == 'full') {
        var output = Compiler.getOutput() + '/include/$path';
        var path = haxe.io.Path.directory(output);
        if (!FileSystem.exists(path)) {
          FileSystem.createDirectory(path);
        }
        sys.io.File.saveContent(output, '#pragma once');
      }

      var dir = target + '/' + caller.pack.join('/');
      if (!FileSystem.exists(dir)) FileSystem.createDirectory(dir);
      inline function writeIfNeeded(path:String, contents:String) {
        if (!FileSystem.exists(path) || File.getContent(path) != contents)
          File.saveContent(path, contents);
      }
      writeIfNeeded('$dir/${caller.name}.hx', buf.toString());
      var glue = 'package ${genericGlue.pack.join('.')};\n\n@:unrealGlue extern class ${genericGlue.name} {\n$glueCode\n}';
      writeIfNeeded('$dir/${genericGlue.name}.hx', glue);
      Globals.cur.cachedBuiltTypes.push(caller.getClassPath());
      Globals.cur.hasUnprocessedTypes = true;
      Context.getType(caller.getClassPath());

      Globals.cur.gluesToGenerate = Globals.cur.gluesToGenerate.add(caller.getClassPath());
    }

  }
}
