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
            if (cls.meta.has(':unrealGlue'))
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
  private var writer:GlueWriter;
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
    // get the haxeRuntimeDir include path
    var targetPath = '$haxeRuntimeDir/${name.replace('.','/')}';
    cls.meta.add(':include', [macro $v{'$targetPath.h'}], currentPos());

    var dir = haxe.io.Path.directory(targetPath);
    if (!exists(dir)) createDirectory(dir);

    var cppName = '::' + name.replace('.', '::') +'_obj';
    var writer = this.writer = new GlueWriter('$targetPath.h', '$targetPath.cpp', name);
    var inclGlue = exprConstString( cls.meta.extract(':unrealGlue')[0].params[1] );
    writer.wcpp('#include <HaxeRuntime.h>\n');
    writer.wcpp('#include "$targetPath.h"\n');
    writer.wcpp('#include <$inclGlue>\n');

    var wrappedClass = exprConstString( cls.meta.extract(':unrealGlue')[0].params[0] );
    writer.declare(wrappedClass);
    for (pack in cls.pack)
    {
      writer.wboth('namespace $pack {\n');
    }

    // TODO: extend wrapped type so we can access its protected fields
    writer.wh('class ${cls.name}_obj {\n\tpublic:\n');

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
      writer.wh('\t\tstatic $retStr ${field.name}(');
      writer.wcpp('$retStr $cppName::${field.name}(');

      var first = true;
      for (arg in args)
      {
        if (first) first = false; else writer.wboth(', ');

        var t = wrapperType(arg.t, field.pos);
        writer.wboth('$t ${arg.name}');
      }
      writer.wboth(') ');
      writer.wh(';\n');
      writer.wcpp('{\n\t');

      if (retStr != 'void')
        writer.wcpp('return ');
      if (field.meta.has(':member')) // non-static
      {
        var thisArg = args.shift();
        writer.wcpp(thisArg.name + '->' + field.name);
      } else {
        writer.wcpp(wrappedClass + '::' + field.name);
      }

      if (!field.meta.has(':prop'))
      {
        writer.wcpp('(');
        var first = true;
        for (arg in args)
        {
          if (first) first = false; else writer.wcpp(', ');
          writer.wcpp("IMPLEMENTME");
        }
        writer.wcpp(')');
      }

      writer.wcpp(';\n}\n\n');
    }

    writer.wh('};\n\n');
    for (pack in cls.pack)
    {
      writer.wboth('}\n');
    }

    writer.close();
  }

  private function wrapperType(t:Type, pos:Position):String
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

        if (isUObj)
          writer.declare(name);
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
