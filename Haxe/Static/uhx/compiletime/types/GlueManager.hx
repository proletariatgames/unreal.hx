package uhx.compiletime.types;
import haxe.macro.Context;
import sys.io.File;
import uhx.compiletime.tools.*;
import uhx.compiletime.main.NativeGlueCode;
using StringTools;

class GlueManager {
  private var touchedFiles:Map<String, TouchKind> = new Map();
  private var modules:Map<String, Array<String>>;
  private var modulesChanged:Map<String, Bool>;
  private var modulesDeleted:Map<String, Map<String, Bool>>;
  private var regenUnityFiles:Bool;
  private var nativeGlueCode:NativeGlueCode;

  public function new(nativeGlueCode) {
    this.nativeGlueCode = nativeGlueCode;
    if (Globals.cur.glueUnityBuild) {
      this.modules = new Map();
      this.modulesChanged = new Map();
      this.modulesDeleted = new Map();
    }
  }

  public function touch(kind:TouchKind, file:String) {
    var ret = this.touchedFiles[file];
    if (ret == null) {
      ret = kind;
    } else {
      ret = ret | kind;
    }
    this.touchedFiles[file] = ret;
  }

  public function addCpp(file:String, module:String, hasChanged:Bool) {
    if (this.modules != null) {
      var arr = this.modules[module];
      if (arr == null) {
        this.modules[module] = arr = [];
      }
      arr.push(file);

      if (hasChanged) {
        this.modulesChanged[module] = true;
      }
    }
  }

  public function setDeleted(file:String, module:String) {
    if (modulesDeleted != null && !modulesChanged.exists(module)) {
      var files = this.modulesDeleted[module];
      if (files == null) {
        this.modulesDeleted[module] = files = new Map();
      }
      files['#include "' + file.replace('"','\\"') +'"'] = true;
    }
  }

  public function cleanDirs() {
    if (Globals.cur.glueUnityBuild) {
      cleanDir(Globals.cur.staticBaseDir + '/Generated/Private', TPrivateCpp, TPrivateHeader, touchedFiles);
      cleanDir(Globals.cur.staticBaseDir + '/Generated/Public', TNone, TPublicHeader, touchedFiles);
      cleanDir(Globals.cur.staticBaseDir + '/Generated/Shared', TNone, TSharedHeader, touchedFiles);
      cleanDir(Globals.cur.unrealSourceDir + '/Generated/Public', TNone, TExportHeader, touchedFiles);
      cleanDir(Globals.cur.unrealSourceDir + '/Generated/Private', TExportCpp, TNone, touchedFiles);
      cleanDir(Globals.cur.unrealSourceDir + '/Generated/Shared', TNone, TNone, touchedFiles);
    } else {
      cleanDir(Globals.cur.unrealSourceDir + '/Generated/Public', TNone, TPublicHeader | TExportHeader, touchedFiles);
      cleanDir(Globals.cur.unrealSourceDir + '/Generated/Shared', TNone, TSharedHeader, touchedFiles);
      cleanDir(Globals.cur.unrealSourceDir + '/Generated/Private', TExportCpp | TPrivateCpp, TPrivateHeader, touchedFiles);
      // delete static base directory if it exists
      cleanDir(Globals.cur.staticBaseDir + '/Generated/Public', TNone, TNone, touchedFiles);
      cleanDir(Globals.cur.staticBaseDir + '/Generated/Shared', TNone, TNone, touchedFiles);
      cleanDir(Globals.cur.staticBaseDir + '/Generated/Private', TNone, TNone, touchedFiles);
    }
  }

  private static function getUniqueDefines() {
    var ret = [];
    switch(Globals.cur.configuration) {
    case 'Development' | 'DebugGame':
      ret.push('UE_BUILD_DEVELOPMENT');
    case 'Shipping':
      ret.push('UE_BUILD_SHIPPING');
    case 'Debug':
      ret.push('UE_BUILD_DEBUG');
    case 'Test':
      ret.push('UE_BUILD_TEST');
    case config:
      throw 'Unknown configuration $config';
    }

    switch(Globals.cur.targetType) {
    case 'Game':
      ret.push('UE_GAME');
      ret.push('WITH_SERVER_CODE');
    case 'Client':
      ret.push('UE_GAME');
      ret.push('!WITH_SERVER_CODE');
    case 'Editor':
      ret.push('WITH_EDITOR');
    case 'Server':
      ret.push('UE_SERVER');
    case 'Program':
      ret.push('IS_PROGRAM');
    case type:
      throw 'Unknown target type $type';
    }

    switch(Globals.cur.targetPlatform) {
    case 'Win32' | 'Win64' | 'WinRT' | 'WinRT_ARM':
      ret.push('PLATFORM_WINDOWS');
    case 'Mac':
      ret.push('PLATFORM_MAC');
    case 'XboxOne':
      ret.push('PLATFORM_XBOXONE');
    case 'PS4':
      ret.push('PLATFORM_PS4');
    case 'IOS':
      ret.push('PLATFORM_IOS');
    case 'Android':
      ret.push('PLATFORM_ANDROID');
    case 'HTML5':
      ret.push('PLATFORM_HTML5');
    case 'Linux':
      ret.push('PLATFORM_LINUX');
    case 'TVOS':
      ret.push('PLATFORM_TVOS');
    case platform:
      throw 'Unknown target platform $platform';
    }

    return ret;
  }

  private function hasAnyInclude(path:String, includes:Map<String, Bool>) {
    var file = sys.io.File.read(path);
    try {
      while(true) {
        var ln = file.readLine();
        if (includes.exists(ln)) {
          file.close();
          return true;
        }
      }
    }
    catch(e:haxe.io.Eof) {
    }
    file.close();
    return false;
  }

  public function makeUnityBuild() {
    var dir = GlueInfo.getUnityDir();
    if (dir == null) {
      return;
    }

    for (module in this.modules.keys()) {
      var targetPath = GlueInfo.getUnityPath(module, false);
      nativeGlueCode.addProducedFile(targetPath);
      if (this.regenUnityFiles || !Globals.cur.fs.exists(targetPath)) {
        this.modulesChanged[module] = true;
      }
    }

    for (deleted in this.modulesDeleted.keys()) {
      if (!this.modulesChanged.exists(deleted)) {
        var target = GlueInfo.getUnityPath(deleted, false);
        if (!Globals.cur.fs.exists(target)) {
          this.modulesChanged[deleted] = true;
        } else {
          if (hasAnyInclude(target, this.modulesDeleted[deleted])) {
            this.modulesChanged[deleted] = true;
          }
        }
      }
    }


    for (changed in this.modulesChanged.keys()) {
      var files = this.modules[changed];
      if (files == null)
      {
        var target = GlueInfo.getUnityPath(changed, true);
        if (Globals.cur.fs.exists(target))
        {
          Globals.cur.fs.deleteFile(target);
        }
        continue;
      }
      files.sort(Reflect.compare);
      var buf = new StringBuf();
      var defines = getUniqueDefines();
      if (defines.length == 0) {
        throw 'assert';
      }
      buf.add('#include "${Globals.cur.module}.h"\n');
      buf.add('#if ' + defines.join(' && ') + '\n');

      for (file in files) {
        if (file.indexOf('"') >= 0) {
          buf.add('#include "${file.replace('"', '\\"')}"\n');
        } else {
          buf.add('#include "$file"\n');
        }
      }

      buf.add('#endif');

      var result = buf.toString();
      var target = GlueInfo.getUnityPath(changed, true);
      if (this.regenUnityFiles) {
        if (!Globals.cur.fs.exists(target) || File.getContent(target) != result) {
          Globals.cur.fs.saveContent(target, result);
        }
      } else {
        Globals.cur.fs.saveContent(target, result);
      }
    }

    if (Globals.cur.fs.exists(dir)) {
      var suffix = '.' + Globals.cur.shortBuildName + GlueInfo.UNITY_CPP_EXT;
      for (file in Globals.cur.fs.readDirectory(dir)) {
        if (file.endsWith('.cpp')) {
          if (!file.endsWith(suffix) || !this.modules.exists(file.substring(GlueInfo.UNITY_CPP_PREFIX.length, file.length - suffix.length))) {
            trace('Deleting unused unity build file $dir/$file');
            Globals.cur.fs.deleteFile('$dir/$file');
          }
        }
      }
    }
  }

  public function updateGameModule() {
    var cur = Globals.cur,
        glueUnityBuild = cur.glueUnityBuild,
        staticTemplate = cur.staticBaseDir + '/Template',
        sourceTemplate = cur.unrealSourceDir + '/Generated/Template',
        srcDir = glueUnityBuild ? staticTemplate : sourceTemplate,
        oldSrcDir = !glueUnityBuild ? staticTemplate : sourceTemplate,
        pluginPath = cur.pluginDir,
        mod = cur.module,
        isProgram = Context.defined('UE_PROGRAM');

    Globals.cur.fs.createDirectory(Globals.cur.staticBaseDir + '/Generated/Private');
    Globals.cur.fs.createDirectory(Globals.cur.staticBaseDir + '/Generated/Public');
    Globals.cur.fs.createDirectory(Globals.cur.staticBaseDir + '/Generated/Shared');
    Globals.cur.fs.createDirectory(Globals.cur.unrealSourceDir + '/Generated/Public');
    Globals.cur.fs.createDirectory(Globals.cur.unrealSourceDir + '/Generated/Private');
    Globals.cur.fs.createDirectory(Globals.cur.unrealSourceDir + '/Generated/Shared');

    // update templates that need to be updated
    function recurse(templatePath:String, toPath:String)
    {
      var checkMap = null;

      if (!Globals.cur.fs.exists(toPath)) {
        Globals.cur.fs.createDirectory(toPath);
      } else {
        checkMap = new Map();
      }

      for (file in Globals.cur.fs.readDirectory(templatePath))
      {
        if (isProgram) {
          switch(file) {
          case 'HaxeGeneratedClass.h', 'CallHelper.h':
            continue;
          }
        }
        if (checkMap != null) checkMap[file] = true;
        var curTemplPath = '$templatePath/$file',
            curToPath = '$toPath/$file';
        if (Globals.cur.fs.isDirectory(curTemplPath))
        {
          recurse(curTemplPath, curToPath);
        } else {
          this.nativeGlueCode.addProducedFile(curToPath);
          var shouldCopy = !Globals.cur.fs.exists(curToPath);
          var contents = File.getContent(curTemplPath);
          if (mod != 'HaxeRuntime') {
            contents = contents.replace('HAXERUNTIME', mod.toUpperCase()).replace('HaxeRuntime', mod);
          }
          if (!shouldCopy) {
            shouldCopy = contents != File.getContent(curToPath);
          }

          if (shouldCopy) {
            Globals.cur.fs.saveContent(curToPath, contents);
          }

          if (glueUnityBuild && file.endsWith('.cpp')) {
            this.addCpp(curToPath, 'HaxeRuntime', shouldCopy);
          }
        }
      }

      if (checkMap != null)
      {
        for (file in Globals.cur.fs.readDirectory(toPath)) {
          if (!checkMap.exists(file)) {
            MacroHelpers.deleteRecursive('$toPath/$file');
          }
        }
      }
    }

    recurse('$pluginPath/Haxe/Templates/Source/HaxeRuntime/Public', '$srcDir/Public');
    recurse('$pluginPath/Haxe/Templates/Source/HaxeRuntime/Private', '$srcDir/Private');
    recurse('$pluginPath/Haxe/Templates/Source/HaxeRuntime/Shared', '$srcDir/Shared');
    var templateExport = '${cur.unrealSourceDir}/Generated/TemplateExport';
    if (!isProgram) {
      recurse('$pluginPath/Haxe/Templates/Source/HaxeRuntime/Export', templateExport);
    } else if (Globals.cur.fs.exists(templateExport)) {
      MacroHelpers.deleteRecursive(templateExport);
    }
    if (Globals.cur.fs.exists(oldSrcDir)) {
      MacroHelpers.deleteRecursive(oldSrcDir);
    }
    return srcDir;
  }

  private function cleanDir(path:String, cppMask:TouchKind, headerMask:TouchKind, touchedFiles:Map<String, TouchKind>) {
    function recurse(path:String, packPath:String) {
      for (file in Globals.cur.fs.readDirectory(path)) {
        var idx = file.lastIndexOf('.');
        if (idx >= 0 && file.charCodeAt(0) != '.'.code) {
          var name = file.substr(0, idx),
              ext = file.substr(idx+1).toLowerCase();
          var shouldDelete = false,
              k:Null<TouchKind> = null,
              mask:Null<TouchKind> = null;
          if (ext == 'cpp') {
            mask = cppMask;
          } else if (ext == 'h' || ext == 'inl') {
            mask = headerMask;
          }
          if (mask != null) {
            if (mask == 0 || (k = touchedFiles[packPath + name]) == null || !k.hasAny(mask)) {
              shouldDelete = true;
            }
          }
          if (shouldDelete) {
            var fullPath = '$path/$file';
            trace('Deleting uneeded file $fullPath');
            if (file.endsWith('.cpp')) {
              regenUnityFiles = true;
            }
            Globals.cur.fs.deleteFile(fullPath);
          }
        } else {
          var fullPath = '$path/$file';
          if (Globals.cur.fs.isDirectory(fullPath)) {
            recurse(fullPath, packPath + file + '.');
          }
        }
      }
    }
    if (Globals.cur.fs.exists(path)) {
      recurse(path, '');
    }
  }
}
