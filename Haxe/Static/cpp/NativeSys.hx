package cpp;
import unreal.*;

/**
  Provides an Unreal-backed implementation of the Haxe Sys API
**/
class NativeSys
{
  public static function print( v : Dynamic ) : Void {
    FOutputDevice.GLog.Log(Std.string(v));
  }

  public static function println( v : Dynamic ) : Void {
    FOutputDevice.GLog.Log(Std.string(v) + '\n');
  }

  public static function get_env(v:String) : String {
    var ret = FPlatformMisc.GetEnvironmentVariable(v).toString();
    if (ret == '') {
      return null;
    }
    return ret;
  }

  public static function put_env(e:String,v:String) : Void {
    FPlatformMisc.SetEnvironmentVar(e, v);
  }

  public static function sys_sleep(f:Float) : Void {
    FPlatformProcess.Sleep(f);
  }

  public static function set_time_locale(l:String) : Bool {
    return false;
  }

  public static function get_cwd() : String {
    return FPlatformProcess.GetCurrentWorkingDirectory().toString();
  }

  public static function set_cwd(d:String) : Void {
    trace('Error', 'Unsupported set_cwd used (to: $d)');
  }

  public static function sys_string() : String {
    #if PLATFORM_WINDOWS
    return 'Windows';
    #elseif PLATFORM_LINUX
    return 'Linux';
    #elseif PLATFORM_MAC
    return 'Mac';
    #elseif PLATFORM_ANDROID
    return 'Android';
    #elseif PLATFORM_XBOXONE
    return 'XBox';
    #elseif PLATFORM_IOS
    return 'iOs';
    #elseif PLATFORM_HTML5
    return 'Emscripten';
    #elseif PLATFORM_PS4
    return 'PS4';
    #else
    return haxe.macro.Compiler.getDefine('UHX_UE_TARGET_PLATFORM');
    #end
  }

  @:functionCode("return sizeof(void*) != 4;")
  public static function sys_is64() : Bool {
    return true;
  }

  public static function sys_command(cmd:String) : Int {
    var cur = 0, len = cmd.length;
    var buf = new StringBuf();
    while (cur < len)
    {
      var chr = StringTools.fastCodeAt(cmd, cur++);
      switch(chr)
      {
        case '"'.code:
          while (cur < len)
          {
            var chr = StringTools.fastCodeAt(cmd, cur++);
            switch(chr)
            {
              case '"'.code:
                break;
              case '\\'.code:
                buf.addChar(StringTools.fastCodeAt(cmd, cur++));
              case _:
                buf.addChar(chr);
            }
          }
        case ' '.code:
          break;
        case '\\'.code:
          var next = StringTools.fastCodeAt(cmd, cur);
          if (next == '"'.code)
          {
            cur++;
            buf.addChar(next);
          } else {
            buf.addChar(chr);
          }
        case _:
          buf.addChar(chr);
      }
    }
    trace(cmd);
    var url = buf.toString();
    var args = cmd.substr(cur-1);
    trace(url, args);
    var ret:Ptr<Int> = Ptr.createStack();
    var stdout = new FString("");
    var stderr = new FString("");
    var success = FPlatformProcess.ExecProcess(url, args, ret, stdout, stderr);
    if (!stdout.IsEmpty())
    {
      FOutputDevice.GLog.Log(Std.string(stdout.toString()) + '\n');
    }
    if (!stderr.IsEmpty())
    {
      FOutputDevice.GWarn.Log(Std.string(stderr.toString()) + '\n');
    }
    if (!success)
    {
      return -1;
    }
    return ret.get();
  }

  public static function sys_exit(code:Int) : Void {
    // unfortunately we have to force it since code may rely
    if (code != 0) {
      FPlatformMisc.RequestExitWithStatus(true, code);
    } else {
      FPlatformMisc.RequestExit(true);
    }
  }

  public static function sys_exists(path:String) : Bool {
    var platform = FPlatformFileManager.Get().GetPlatformFile();
    return platform.FileExists(path) || platform.DirectoryExists(path);
  }

  public static function file_delete(path:String) : Void {
    if (!FPlatformFileManager.Get().GetPlatformFile().DeleteFile(path)) {
      throw 'file_delete($path)';
    }
  }

  public static function sys_rename(path:String,newname:String) : Bool {
    return FPlatformFileManager.Get().GetPlatformFile().MoveFile(newname, path);
  }

  public static function sys_stat(path:String) : Dynamic {
    var stat = FPlatformFileManager.Get().GetPlatformFile().GetStatData(path);
    if (!stat.bIsValid) {
      return null;
    }

    return {
      atime: (stat.AccessTime.ToUnixTimestamp()),
      mtime: (stat.ModificationTime.ToUnixTimestamp()),
      ctime: (stat.CreationTime.ToUnixTimestamp()),
      size: cast(stat.FileSize, Int),
      mode: stat.bIsReadOnly ? 292 /* 0444 */ : 438 /*0666*/,
    };
  }

  public static function sys_file_type(path:String) : String {
    var stat = FPlatformFileManager.Get().GetPlatformFile().GetStatData(path);
    if (!stat.bIsValid) {
      return null;
    }
    return stat.bIsDirectory ? 'dir' : 'file';
  }

  public static function sys_create_dir(path:String,mode:Int) : Bool {
    return FPlatformFileManager.Get().GetPlatformFile().CreateDirectory(path);
  }

  public static function sys_remove_dir(path:String) : Void {
    if(!FPlatformFileManager.Get().GetPlatformFile().DeleteDirectory(path)) {
      throw 'sys_remove_dir($path)';
    }
  }

  public static function sys_time() : Float {
    var ticks = FDateTime.UtcNow().GetTicks();
    var ticks1970 = FDateTime.create(1970, 1, 1).GetTicks();
    var ticksPerSec:Float = cast ETimespan.TicksPerSecond;
    return (ticks - ticks1970) / ticksPerSec;
  }

  public static function sys_cpu_time() : Float {
    trace('Error', 'Called unsupported sys_cpu_time');
    return .0;
  }

  public static function sys_read_dir(p:String) : Array<String> {
    var platform = FPlatformFileManager.Get().GetPlatformFile();
    if (!platform.DirectoryExists(p)) {
      throw 'sys_read_dir($p): Directory does not exist';
    }

    var files:TArray<FString> = TArray.create();
    platform.FindFiles(files, p, "");
    return [ for (file in files) file.toString() ];
  }

  public static function file_full_path(path:String) : String {
    return FPaths.ConvertRelativePathToFull(FPlatformFileManager.Get().GetPlatformFile().GetFilenameOnDisk(path)).toString();
  }

  public static function sys_exe_path() : String {
    return FPlatformProcess.ExecutableName(false);
  }

  public static function sys_env() : Array<String> {
    trace('Error', 'Called unsupported sys_env');
    return [];
  }

  public static function sys_getch(b:Bool) : Int {
    trace('Error', 'Called unsupported sys_getch');
    return -1;
  }

  public static function sys_get_pid() : Int {
    return FPlatformProcess.GetCurrentProcessId();
  }
}
