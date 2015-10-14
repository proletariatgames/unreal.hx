package ue4hx.internal.buf;
import sys.FileSystem;
import sys.io.File;

using StringTools;

//abstract
class BaseWriter {
  public var path(default, null):String;
  public var buf:HelperBuf;

  private var includeMap:Map<String,Bool>;
  private var includes:Array<String>;

  private function new(path) {
    this.path = path;
    this.buf = new HelperBuf();
    this.includeMap = new Map();
    this.includes = [];
  }

  public function include(inc:String) {
    if (!includeMap.exists(inc)) {
      this.includes.push(inc);
      this.includeMap[inc] = true;
    }
  }

  private function getIncludes(buf:HelperBuf)
  {
    var incs = [ for (inc in this.includes) inc ];
    incs.sort(function(v1, v2) if (v1.endsWith('.generated.h')) return 1; else if (v2.endsWith('.generated.h')) return -1; else return Reflect.compare(v1,v2));
    for (inc in incs)
    {
      inc = inc.replace('\\','/');
      buf.add('#include ');
      if (inc.startsWith('\"') || inc.startsWith('<'))
        buf.add(inc);
      else
        buf.add('"$inc"');
      buf.add('\n');
    }
  }

  private function getContents(module:String):String {
    throw 'Not Implemented';
  }

  public function close(module:String) {
    if (module == null) module = Globals.cur.module;
    var contents = getContents(module);
    if (!FileSystem.exists(path) || File.getContent(path).trim() != contents) {
      File.saveContent(path, contents);
    }
  }
}
