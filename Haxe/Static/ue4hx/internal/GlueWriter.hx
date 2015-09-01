package ue4hx.internal;
import sys.io.File;
import sys.FileSystem.*;

using StringTools;

class GlueWriter
{
  public var headerPath(default, null):String;
  public var cppPath(default, null):String;
  public var typeName(default, null):String;

  private var forwardDecls:Map<String, Bool>;
  private var header:StringBuf;
  private var cpp:StringBuf;

  public function new(headerPath, cppPath, typeName)
  {
    this.headerPath = headerPath;
    this.cppPath = cppPath;
    this.typeName = typeName;

    this.forwardDecls = new Map();
    this.header = new StringBuf();
    this.cpp = new StringBuf();
  }

  // write on header
  inline public function wh(obj)
    header.add(obj);

  // write on cpp
  inline public function wcpp(obj)
    cpp.add(obj);

  // write on both
  inline public function wboth(obj)
  {
    header.add(obj);
    cpp.add(obj);
  }

  // forward declare a cpp class (use CPP naming here)
  public function declare(name:String)
  {
    if (name.startsWith('::'))
      name = name.substr(2);
    forwardDecls[name] = true;
  }

  private function getForwardDecls()
  {
    var buf = new StringBuf();
    for (decl in forwardDecls.keys())
    {
      var pack = decl.split('::');
      for (i in 0...pack.length - 1)
        buf.add('namespace ${pack[i]} {\n');
      buf.add('class ${pack[pack.length-1]};\n');
      for (_ in 0...pack.length - 1)
        buf.add('}');
    }
    return buf.toString();
  }

  public function close()
  {
    var defName = typeName.replace('.','_').toUpperCase();
    var header = '#ifndef _${defName}_INCLUDED_\n#define _${defName}_INCLUDED_\n' +
      getForwardDecls() + '\n' +
      this.header.toString() +
      '\n#endif';
    var cpp = this.cpp.toString();

    if (!exists(headerPath) || File.getContent(headerPath) != header)
    {
      File.saveContent(headerPath, header);
    }
    if (!exists(cppPath) || File.getContent(cppPath) != cpp)
    {
      File.saveContent(cppPath, cpp);
    }
  }
}
