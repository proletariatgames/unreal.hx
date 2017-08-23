package uhx.build;
import uhx.build.Log.*;
import sys.FileSystem;
import sys.io.File;

class DepList {
  public var filename(default, null):String;
  private var stringArray:Array<String>;
  private var deps:Map<Int, Array<Int>>;
  private var stringToId:Map<String, Int>;
  private var file:sys.io.FileInput;

  public function new(filename:String) {
    this.filename = filename;
    this.stringArray = [];
    this.stringToId = new Map();
    this.deps = new Map();
  }

  public function readHeader():Bool {
    if (!FileSystem.exists(filename)) {
      return false;
    }
    file = File.read(filename);
    if (file.readByte() != 0x1) {
      warnFile('The file "$filename" is not a valid dependency file.', {file:filename});
      file.close();
      file = null;
      return false;
    } else {
      while(true) {
        var str = file.readUntil(0);
        if (str == '') {
          break;
        }
        this.stringToId[str] = stringArray.push(str) - 1;
      }
      return true;
    }
  }

  /**
    Reads the dependencies to `modulesToCompile`
  **/
  public function readDependencies(modulesToCompile:Map<String, Bool>, processed:Map<String, Bool>, traceFiles:Bool) {
    var toAdd = [];
    var stringArray = this.stringArray,
        deps = this.deps,
        file = this.file;
    if (file == null) {
      warnFile('Dependency file was not open', {file:filename});
      return;
    }
    try {
      while(true) {
        var mainId = file.readInt32();
        if (mainId == -1) {
          break;
        }
        var main = stringArray[mainId];
        if (main == null) {
          throw 'Invalid id $mainId';
        }
        var shouldAdd = false,
            reason = null,
            shouldDelete = false;
        if (modulesToCompile == null) {
          shouldAdd = false;
        } else if (modulesToCompile.exists(main)) {
          shouldAdd = true;
          reason = traceFiles ? 'it depends on $main' : null;
        } else if (!processed.exists(main)) {
          shouldAdd = true;
          shouldDelete = true;
          reason = traceFiles ? 'it depends on $main' : null;
          if (traceFiles) {
            log(' Baking $main\'s dependencies because it was deleted');
          }
        }
        var arr = null;
        if (!shouldDelete) {
          deps[mainId] = arr = [];
        }
        while (true) {
          var i32 = file.readInt32();
          if (i32 < 0) {
            break;
          }
          if (arr != null) {
            arr.push(i32);
          }
          if (shouldAdd) {
            var targetModule = stringArray[i32];
            // delay adding so we don't add more dependencies than we need (the extern baker only cares for immediate dependency changes)
            toAdd.push(targetModule);
            if (reason != null) {
              log(' Baking $targetModule because $reason');
            }
          }
        }
      }
    } catch(e:haxe.io.Eof) {
    }

    for (add in toAdd) {
      modulesToCompile[add] = true;
    }

    file.close();
    this.file = null;
  }

  public function markDeleted(module:String) {
    var id = stringToId[module];
    if (id != null) {
      this.deps.remove(id);
    }
  }

  public function merge(newer:DepList) {
    if (newer.file != null) {
      throw 'Cannot merge lists: Newer list was not processed';
    } else if (this.file != null) {
      throw 'Cannot merge lists: Old list was not processed';
    }
    if (newer.stringArray.length == 0) {
      return; // empty
    } else if (this.stringArray.length == 0) {
      this.stringArray = newer.stringArray;
      this.stringToId = newer.stringToId;
      this.deps = newer.deps;
      return;
    }
    var stringArray = this.stringArray,
        otherStringArray = newer.stringArray,
        deps = this.deps,
        otherDeps = newer.deps;

    var otherIdToId = new Map();
    for (i in 0...otherStringArray.length) {
      var cur = otherStringArray[i];
      if (cur == '') {
        continue;
      }
      var ret = stringToId[cur];
      if (ret == null) {
        ret = stringArray.push(cur) - 1;
      }
      otherIdToId[i] = ret;
    }

    for (key in otherDeps.keys()) {
      deps[otherIdToId[key]] = [for (val in otherDeps[key]) otherIdToId[val]];
    }
  }

  public function save(filename:String) {
    var deps = this.deps;
    var target = File.write(filename);
    target.writeByte(0x1);
    for (arr in stringArray) {
      target.writeString(arr);
      target.writeByte(0);
    }
    target.writeByte(0);
    for (dep in deps.keys()) {
      target.writeInt32(dep);
      for (dep in deps[dep]) {
        target.writeInt32(dep);
      }
      target.writeInt32(-1);
    }
    target.close();
  }
}