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
  var stringArray:Array<String>;
  var stringToIndex:Map<String, Int>;
  var reverseDeps:Map<Int, Map<Int, Bool>>;
  var extraFiles:Map<Int, Int>;
  var deletedFiles:Map<String, Bool>;

  public function new() {
    this.stringArray = [];
    this.stringToIndex = new Map();
    this.reverseDeps = new Map();
    this.extraFiles = new Map();
    this.deletedFiles = new Map();
  }

  private function getIndex(name:String):Int {
    if (name == '') {
      throw 'Empty file';
    }

    var idx = stringToIndex[name];
    if (idx == null) {
      idx = stringArray.push(name) - 1;
      stringToIndex[name] = idx;
    }
    return idx;
  }

  public function setExtraFile(module:String) {
    if (module == '') {
      throw 'Empty file';
    }
    var mainFile = getIndex(module),
        extra = getIndex(module + '_Extra');
    extraFiles[mainFile] = extra;
    addDependencyIndex(mainFile, extra);
    addDependencyIndex(extra, mainFile);
  }

  private function addDependencyIndex(module:Int, dependsOn:Int) {
    if (dependsOn == null) {
      return;
    }
    var dep = reverseDeps[dependsOn];
    if (dep == null) {
      reverseDeps[dependsOn] = dep = new Map();
    }
    dep[module] = true;
    var extra = extraFiles[module];
    if (extra != null) {
      dep[extra] = true;
    }
  }

  public function addDependency(module:String, dependsOn:String) {
    if (module == '' || dependsOn == '') {
      return; // just don't add the dependency
    }
    this.addDependencyIndex(getIndex(module), getIndex(dependsOn));
  }

  public function save(fileName:String) {
    var buf = new haxe.io.BytesBuffer(),
        rev = this.reverseDeps,
        del = this.deletedFiles;
    buf.addByte(1);
    // var file = null,
    //     conversion = null;
    // if (FileSystem.exists(fileName)) {
    //   file = File.read(fileName);
    //   if (file.readByte() != 0x1) {
    //     file.close();
    //     FileSystem.deleteFile(fileName);
    //     throw 'Invalid dependency list file version: $fileName';
    //   }
    //   conversion = new Map();
    //   var curIndex = -1;
    //   while(true) {
    //     var source = file.readUntil(0);
    //     if (source == '') {
    //       if (file.readByte() != 2) {
    //         throw 'Invalid file';
    //       }
    //       break;
    //     }
    //     ++curIndex;
    //     var realIndex = getIndex(source);
    //     conversion[curIndex] = realIndex;
    //   }
    // }

    for (arr in stringArray) {
      buf.addString(arr);
      buf.addByte(0);
    }
    buf.addByte(0);

    // if (file != null) {
    //   // read and write
    //   try {
    //     var source = conversion[file.readInt32()];
    //     buf.addInt32(source);
    //     var deps = rev[source];
    //     if (deps != null) {
    //       rev.remove(source);
    //       while(true) {
    //         var dep = file.readInt32();
    //         if (dep == -1) {
    //           break;
    //         }
    //         dep = conversion[dep];
    //         buf.addInt32(dep);
    //         deps.remove(dep);
    //       }
    //       for (dep in deps.keys()) {
    //         buf.addInt32(dep);
    //       }
    //       buf.addInt32(-1);
    //     } else {
    //       while(true) {
    //         var cur = file.readInt32();
    //         if (cur == -1) {
    //           break;
    //         }
    //         buf.addInt32(conversion[cur]);
    //       }
    //       buf.addInt32(-1);
    //     }
    //   }
    //   catch(e:Eof) {
    //   }
    //   file.close();
    // }

    for (key in rev.keys()) {
      buf.addInt32(key);
      for (dep in rev[key].keys()) {
        buf.addInt32(dep);
      }
      buf.addInt32(-1);
    }

    File.saveBytes(fileName, buf.getBytes());
  }

  public function updateDeps(module:String, t:Type) {
    var dependsOn = switch(Context.follow(t)) {
      case TInst(c,_):
        c.get().module;
      case TEnum(e,_):
        e.get().module;
      case TAbstract(a,_):
        a.get().module;
      case _:
        null;
    }
    if (dependsOn != null) {
      this.addDependency(module, dependsOn);
    }
  }
}