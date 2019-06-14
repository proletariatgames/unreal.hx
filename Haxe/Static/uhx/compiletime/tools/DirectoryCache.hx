package uhx.compiletime.tools;
import haxe.io.Path;
import sys.FileStat;

typedef FileData = {
  ?stat:FileStat,
  ?isDir:Bool
}

typedef DirCacheData = Map<String, Map<String, FileData>>;

abstract DirectoryCache(DirCacheData) {
  inline public function new() {
    this = new Map();
  }

  private static var nullMap = new Map();

  public function exists(path:String) {
    path = Path.normalize(path);
    if (this.exists(path)) {
      return true;
    }
    var path = new Path(path);
    var data = getDirData(path.dir);
    if (data == nullMap) {
      return false;
    } else {
      return data.exists(getFileName(path));
    }
  }

  public function deleteFile(file:String) {
    var path = getNormalizedPath(file);
    var data = this[path.dir];
    if (data != null) {
      data.remove(getFileName(path));
    }
    sys.FileSystem.deleteFile(file);
  }

  public function deleteDirectory(origPath:String) {
    sys.FileSystem.deleteDirectory(origPath);
    var path = Path.normalize(origPath);
    this.remove(path);
    var path = new Path(path);
    var data = this[path.dir];
    if (data != null) {
      data.remove(getFileName(path));
    }
  }

  public function createDirectory(origPath:String) {
    sys.FileSystem.createDirectory(origPath);
    var path = getNormalizedPath(origPath);
    var data = this[path.dir];
    if (data != null) {
      var name = getFileName(path);
      data[name] = { isDir: true };
    }
  }

  public function saveContent(path:String, contents:String) {
    sys.io.File.saveContent(path, contents);
    var path = getNormalizedPath(path);
    var data = this[path.dir];
    if (data != null) {
      var name = getFileName(path);
      data[name] = { isDir: false }; // reset stat data
    }
  }

  public function stat(origPath:String) {
    var path = getNormalizedPath(origPath);
    var data = getDirData(path.dir);
    if (data == nullMap) {
      throw 'parent directory ${path.dir} for $path does not exist';
    } else {
      var ret = data[getFileName(path)];
      if (ret == null) {
        throw 'file does not exist $path';
      }
      if (ret.stat == null) {
        ret.stat = sys.FileSystem.stat(origPath);
      }
      return ret.stat;
    }
  }

  public function isDirectory(origPath:String) {
    var path = Path.normalize(origPath);
    if (this.exists(path)) {
      return true;
    }
    var path = new Path(path);
    var data = getDirData(path.dir);
    if (data == nullMap) {
      throw 'Path $origPath does not exist';
    }

    var ret = data[getFileName(path)];
    if (ret == null) {
      throw 'Path $origPath does not exist';
    }
    if (ret.isDir == null) {
      ret.isDir = sys.FileSystem.isDirectory(origPath);
    }
    return ret.isDir;
  }

  public function readDirectory(path:String) {
    var data = getDirData(Path.normalize(path));
    if (data == nullMap) {
      throw 'directory $path does not exist';
    }

    return [for (key in data.keys()) key];
  }

  inline function getNormalizedPath(path:String):Path {
    return new Path(Path.normalize(path));
  }

  inline static function getFileName(path:Path):String {
    var name = path.file;
    if (path.ext != null) {
      name += '.' + path.ext;
    }
    return name;
  }

  inline function getDirData(normalized:String) {
    var ret = this[normalized];
    if (ret == null) {
      this[normalized] = ret = createDirData(normalized);
    }
    return ret;
  }

  function createDirData(normalized:String):Map<String, FileData> {
    var contents = null;
    try {
      contents = sys.FileSystem.readDirectory(normalized);
    }
    catch(e:Dynamic) {
      // does not exist
      return nullMap;
    }
    return [for (file in contents) file => {}];
  }
}