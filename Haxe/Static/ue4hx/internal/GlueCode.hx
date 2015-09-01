package ue4hx.internal;
import haxe.macro.Context;
import haxe.macro.Context.*;
import haxe.macro.Expr;
import haxe.macro.Type;
import sys.FileSystem.*;

using StringTools;

class GlueCode
{
  public static function create(haxeRuntimeDir:String)
  {
    // FIXME: run this at onAfterGenerate once HaxeFoundation/haxe#4515 is fixed
    Context.onGenerate(function(allTypes:Array<Type>) {
      var foundGlues = false;
      var gcode = new GlueCode(haxeRuntimeDir);
      for (type in allTypes)
      {
        switch(type)
        {
          case TInst(i,_):
            var cls = i.get();
            if (cls.meta.has(':uobjectGlue'))
            {
              // if (!foundGlues)
              // {
              //   foundGlues = true;
              //   cls.meta.add(':buildXml', [macro $v{'<files id="haxe"> <compilerflag value="-I$haxeRuntimeDir/" /></files>'}], currentPos());
              // }

              var name = i.toString();
              gcode.createGlue(cls, name);
            }
          case _:
        }
      }
    });
  }

  private var haxeRuntimeDir:String;
  public function new(haxeRuntimeDir)
  {
    this.haxeRuntimeDir = haxeRuntimeDir;
  }

  private static function exprConstString(e:Expr)
  {
    if (e == null) return null;
    switch(e.expr)
    {
      case EConst(CString(s)):
        return s;
      case _:
        return null;
    }
  }

  private function createGlue(cls:ClassType, name:String)
  {
    var path = name.replace('.','/');
    // add the haxeRuntimeDir include path
    var wholePath = '$haxeRuntimeDir/$path';
    cls.meta.add(':include', [macro $v{'$wholePath.h'}], currentPos());

    var dir = haxe.io.Path.directory(wholePath);
    if (!exists(dir)) createDirectory(dir);
    var header = sys.io.File.write('$wholePath.h');
    var cpp = sys.io.File.write('$wholePath.cpp');

    var cppName = '::' + name.replace('.', '::');
    var defName = name.replace('.','_').toUpperCase();
    header.writeString('#ifndef _${defName}_INCLUDED_\n#define _${defName}_INCLUDED_\n');
    var inclGlue = exprConstString( cls.meta.extract(':uobjectGlue')[0].params[1] );
    cpp.writeString('#include <HaxeRuntime.h>\n');
    cpp.writeString('#include "$wholePath.h"\n');
    cpp.writeString('#include <$inclGlue>\n');

    inline function writeBoth(str:String)
    {
      header.writeString(str);
      cpp.writeString(str);
    }
    inline function wcpp(str:String) cpp.writeString(str);
    inline function wh(str:String) header.writeString(str);

    var wrappedClass = exprConstString( cls.meta.extract(':uobjectGlue')[0].params[0] );
    wh('class $wrappedClass;\n');
    for (pack in cls.pack)
    {
      writeBoth('namespace $pack {\n');
    }

    // TODO: extend wrapped type so we can access its protected fields
    wh('class ${cls.name}_obj {\n\tpublic:\n');

    for (field in cls.statics.get())
    {
      switch (field.kind)
      {
        case FMethod(m):
        case _:
          continue;
      }
      var args = null, ret = null;
      switch(follow(field.type))
      {
        case TFun(a,r): args = a; ret = r;
        case _: continue;
      }

      var retStr = wrapperType(ret, field.pos);
      wh('\t\tstatic $retStr ${field.name}(');
      wcpp('$retStr $cppName::${field.name}(');

      var first = true;
      for (arg in args)
      {
        if (first) first = false; else writeBoth(', ');

        var t = wrapperType(arg.t, field.pos);
        wh('$t ${arg.name}');
      }
      writeBoth(') ');
      wh(';\n');
      wcpp('{\n');

      if (field.meta.has(':member')) // non-static
      {
      }
    }

    wh('};\n\n');
    for (pack in cls.pack)
    {
      writeBoth('}\n');
    }

    wh('#endif\n');
    header.close();
    cpp.close();
  }

  private static function wrapperType(t:Type, pos:Position):String
  {
    var args = null, name = null, isUObj = false;
    switch(followWithAbstracts(t))
    {
      case TAbstract(a,tl):
        name = a.toString();
        args = tl;
      case TInst(i, tl):
        name = i.toString();
        args = tl;
        var cl = i.get();
        isUObj = cl.meta.has(':uobjectType');
        var native = cl.meta.extract(':native');
        if (native.length > 0)
        {
          name = exprConstString(native[0].params[0]);
        }
      case TEnum(e, tl):
        name = e.toString();
        args = tl;
      case _:
        throw new Error('Cannot wrap type $t', pos);
    }

    switch(name)
    {
      case 'Bool':
        return 'bool';
      case 'cpp.RawPointer':
        var pointedTo = wrapperType(args[0], pos);
        return '$pointedTo *';
      case _ if (isUObj):
        return name.replace('.','::');
      case _:
        throw new Error('Unsupported type $t', pos);
    }
  }
}
