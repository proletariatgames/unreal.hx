package uhx.compiletime.tools;
import haxe.io.Eof;
import haxe.macro.Context;
import haxe.macro.Type;
import sys.FileSystem;
import sys.io.File;

/**
  A simple one dimensional dependency tree.
  We don't need to do more than one dependency hop as this is used
  by the Extern Baker - and if something changes on one file, it will only ever
  affect the way the glue is generated on the files that immediately include it
**/
class DepList {
  var reverseDeps:Map<String, Map<String, Bool>>;
  var extraFiles:Map<String, String>;
  var deletedFiles:Map<String, Bool>;

  public function new() {
    this.reverseDeps = new Map();
    this.extraFiles = new Map();
    this.deletedFiles = new Map();
  }

  public function setExtraFile(mainFile:String, extra:String) {
    extraFiles[mainFile] = extra;
    addDependency(mainFile, extra);
    addDependency(extra, mainFile);
  }

  public function addDependency(file:String, dependsOn:String) {
    if (dependsOn == null) {
      return;
    }
    var dep = reverseDeps[dependsOn];
    if (dep == null) {
      reverseDeps[dependsOn] = dep = new Map();
    }
    dep[file] = true;
    var extra = extraFiles[file];
    if (extra != null) {
      dep[extra] = true;
    }
  }

  public function save(fileName:String) {
    var buf = new haxe.io.BytesBuffer(),
        rev = this.reverseDeps,
        del = this.deletedFiles;
    buf.addByte(1);
    if (FileSystem.exists(fileName)) {
      var file = File.read(fileName);
      if (file.readByte() != 0x1) {
        file.close();
        FileSystem.deleteFile(fileName);
        throw 'Invalid dependency list file version: $fileName';
      }
      // read and write
      try {
        var source = file.readUntil(0);
        buf.addString(source);
        buf.addByte(0);
        var deps = rev[source];
        if (deps != null) {
          rev.remove(source);
          while(true) {
            var dep = file.readUntil(0);
            if (dep == '') {
              if (file.readByte() != 0x1) {
                throw 'Invalid break character for $fileName (entry $source)';
              }
              break;
            }
            buf.addString(dep);
            buf.addByte(0);
            deps.remove(dep);
          }
          for (dep in deps.keys()) {
            if (dep != '') {
              buf.addString(dep);
              buf.addByte(0);
            }
          }
          buf.addByte(0);
          buf.addByte(1);
        } else {
          buf.addString(file.readUntil(1));
        }
      }
      catch(e:Eof) {
      }
      file.close();
    }

    for (key in rev.keys()) {
      buf.addString(key);
      buf.addByte(0);
      for (dep in rev[key].keys()) {
        buf.addString(dep);
        buf.addByte(0);
      }
      buf.addByte(0);
      buf.addByte(1);
    }

    File.saveBytes(fileName, buf.getBytes());
  }

  public function updateDeps(file:String, t:Type) {
    var dependsOn = switch(Context.follow(t)) {
      case TInst(c,_):
        Context.getPosInfos(c.get().pos).file;
      case TEnum(e,_):
        Context.getPosInfos(e.get().pos).file;
      case TAbstract(a,_):
        Context.getPosInfos(a.get().pos).file;
      case _:
        null;
    }
    this.addDependency(file, dependsOn);
  }
}