package ue4hx.internal;
import haxe.macro.Context;
import haxe.macro.Context.*;
import haxe.macro.Type;

class Build
{
  public static function build(targetFile:String)
  {
    Context.onGenerate(function(allTypes:Array<Type>) {
      var ret = sys.io.File.write(targetFile);
      for (type in allTypes)
      {
        switch(type)
        {
          case TInst(i,_):
            var cls = i.get();
            if (cls.meta.has(':uobject'))
              if (cls.pack.length == 0)
                ret.writeString(cls.name + '\n');
              else
                ret.writeString(cls.pack.join('/') + '/' + cls.name + '\n');
          case _:
        }
      }
      ret.close();
    });
  }
}
