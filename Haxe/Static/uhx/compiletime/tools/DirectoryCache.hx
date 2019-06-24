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

  #if !USE_DIR_CACHE
  inline
  #end
  public function exists(path:String) {
    #if USE_DIR_CACHE
    path = Path.normalize(path);
    var dir = this[path];
    if (dir != null) {
      return true;
    }
    var path = new Path(path);
    var data = getDirData(path.dir);
    if (data == null) {
      return false;
    } else {
      return data.exists(getFileName(path));
    }
    #else
    return sys.FileSystem.exists(path);
    #end
  }

  #if !USE_DIR_CACHE
  inline
  #end
  public function deleteFile(file:String) {
    #if USE_DIR_CACHE
    var path = getNormalizedPath(file);
    var data = this[path.dir];
    if (data != null) {
      data.remove(getFileName(path));
    }
    #end
    sys.FileSystem.deleteFile(file);
  }

  #if !USE_DIR_CACHE
  inline
  #end
  public function deleteDirectory(origPath:String) {
    sys.FileSystem.deleteDirectory(origPath);
    #if USE_DIR_CACHE
    var path = Path.normalize(origPath);
    this.remove(path);
    var path = new Path(path);
    var data = this[path.dir];
    if (data != null) {
      data.remove(getFileName(path));
    }
    #end
  }

  #if !USE_DIR_CACHE
  inline
  #end
  public function createDirectory(origPath:String) {
    sys.FileSystem.createDirectory(origPath);
    #if USE_DIR_CACHE
    var path = Path.normalize(origPath);
    this.remove(path);
    var path = new Path(path);
    var data = this[path.dir];
    if (data != null) {
      var name = getFileName(path);
      data[name] = { isDir: true };
    }
    #end
  }

  #if !USE_DIR_CACHE
  inline
  #end
  public function saveContent(path:String, contents:String) {
    sys.io.File.saveContent(path, contents);
    #if USE_DIR_CACHE
    var path = getNormalizedPath(path);
    var data = this[path.dir];
    if (data != null) {
      var name = getFileName(path);
      data[name] = { isDir: false }; // reset stat data
    }
    #end
  }

  #if !USE_DIR_CACHE
  inline
  #end
  public function stat(origPath:String) {
    #if USE_DIR_CACHE
    var path = getNormalizedPath(origPath);
    var data = getDirData(path.dir);
    if (data == null) {
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
    #else
    return sys.FileSystem.stat(origPath);
    #end
  }

  #if !USE_DIR_CACHE
  inline
  #end
  public function isDirectory(origPath:String) {
    #if USE_DIR_CACHE
    var path = Path.normalize(origPath);
    var dir = this[path];
    if (dir != null) {
      return true;
    }
    if (this.exists(path)) {
      return true;
    }
    var path = new Path(path);
    var data = getDirData(path.dir);
    if (data == null) {
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
    #else
    return sys.FileSystem.isDirectory(origPath);
    #end
  }

  #if !USE_DIR_CACHE
  inline
  #end
  public function readDirectory(path:String) {
    #if USE_DIR_CACHE
    var data = getDirData(Path.normalize(path));
    if (data == null) {
      throw 'directory $path does not exist';
    }

    return [for (key in data.keys()) key];
    #else
    return sys.FileSystem.readDirectory(path);
    #end
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
      return null;
    }
    return [for (file in contents) file => {}];
  }
}