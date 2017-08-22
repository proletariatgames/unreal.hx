package uhx.compiletime.tools;
import haxe.macro.Context;
import haxe.macro.Type;
import uhx.compiletime.tools.MacroHelpers;
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

  public function new() {
    this.stringArray = [];
    this.stringToIndex = new Map();
    this.reverseDeps = new Map();
    this.extraFiles = new Map();
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
    if (module == dependsOn) {
      return;
    }
    this.addDependencyIndex(getIndex(module), getIndex(dependsOn));
  }

  public function save(fileName:String) {
    var buf = new haxe.io.BytesBuffer(),
        rev = this.reverseDeps;
    buf.addByte(1);

    for (arr in stringArray) {
      buf.addString(arr);
      buf.addByte(0);
    }
    buf.addByte(0);

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
    while(true) {
      switch(t) {
      case TAbstract(a,_):
        var a = a.get();
        if (a.meta.has(':enum')) {
          return;
        }
        if (!a.meta.has(':uextern')) {
          if (!a.meta.has(':coreType')) {
            t = Context.followWithAbstracts(t, true);
            continue;
          } else {
            return;
          }
        }
        break;
      case TInst(c,_):
        if (!c.get().meta.has(':uextern')) {
          return;
        }
        break;
      case TEnum(e,_):
        if (!e.get().meta.has(':uextern')) {
          return;
        }
        break;
      case TType(tdef,_):
        var tdef = tdef.get();
        if (tdef.meta.has(':uPrimeTypedef')) {
          break;
        }
        t = Context.follow(t, true);
      case TMono(ref):
        t = ref.get();
        if (t == null) {
          return;
        }
      case TDynamic(_) | TAnonymous(_) | TFun(_):
        return;
      case TLazy(fn):
        t = fn();
        if (t == null) {
          return;
        }
      }
    }
    var dependsOn = switch(t) {
      case TInst(c,_):
        var c = c.get();
        var owner = MacroHelpers.extractStrings(c.meta, ':uownerModule');
        if (owner.length >= 1) {
          owner[0];
        } else {
          c.module;
        }
      case TEnum(e,_):
        e.get().module;
      case TAbstract(a,_):
        var a = a.get();
        var owner = MacroHelpers.extractStrings(a.meta, ':uownerModule');
        if (owner.length >= 1) {
          owner[0];
        } else {
          a.module;
        }
      case _:
        null;
    }

    if (dependsOn != null) {
      this.addDependency(module, dependsOn);
    }
  }
}