package cpp;
import unreal.*;

@:structInit private class NativeFileHandle {
  public var native:TSharedRef<IFileHandle>;
  public var name:String;
  @:optional public var outputDevice:FOutputDevice;

  // works like the native file_error
  inline public function throwError(msg:String) {
    throw [msg, name];
  }

  inline public function get() {
    return native.Get();
  }
}

/**
  Provides an Unreal-backed implementation of the Haxe File API
**/
class NativeFile
{
  public static function file_open(fname:String,r:String) : Dynamic {
    var platform = FPlatformFileManager.Get().GetPlatformFile();

    var ret:POwnedPtr<IFileHandle> = switch (r) {
      case "r" | "rb":
        platform.OpenRead(fname, true);
      case "w" | "wb":
        platform.OpenWrite(fname, false, false);
      case "a" | "ab":
        platform.OpenWrite(fname, true, false);
      case "r+" | "rb+":
        var ret = platform.OpenWrite(fname, true, false);
        if (ret != null) {
          ret.getRaw().Seek(0);
        }
        ret;
      case _:
        null;
    };
    if (ret == null) {
      throw 'file_open($fname,$r)';
    }

    return ( { native:ret.toSharedRef(), name:fname } : NativeFileHandle );
  }

  public static function file_close(handle:Dynamic) : Void {
    var handle:NativeFileHandle = handle;
    handle.native.dispose();
    handle.native = null;
  }

  public static function file_write(handle:Dynamic,s:haxe.io.BytesData,p:Int,len:Int) : Int {
    var handle:NativeFileHandle = handle;
    if (handle.native == null) {
      if (handle.outputDevice != null) {
        handle.outputDevice.Log(haxe.io.Bytes.ofData(s).getString(p, len));
        return len;
      }
      handle.throwError("file_write"); // already closed
    }
    var buflen = s.length;
    if( p < 0 || len < 0 || p > buflen || p + len > buflen ) {
      return 0;
    }
    var ptr = AnyPtr.fromBytesData(s) + p;
    if (!handle.get().WritePtr(Ptr.fromAnyPtr(ptr), len)) {
      handle.throwError('file_write');
    }
    return len;
  }

  public static function file_write_char(handle:Dynamic,c:Int) : Void {
    var handle:NativeFileHandle = handle;
    if (handle.native == null) {
      if (handle.outputDevice != null) {
        handle.outputDevice.Log(String.fromCharCode(c));
        return;
      }
      handle.throwError("file_write_char"); // already closed
    }
    var ptr:Ptr<UInt8> = Ptr.createStack();
    ptr.set(c);
    if (!handle.get().WritePtr(ptr, 1)) {
      handle.throwError('file_write_char');
    }
  }

  public static function file_read(handle:Dynamic,s:haxe.io.BytesData,p:Int,len:Int) : Int {
    var handle:NativeFileHandle = handle;
    if (handle.native == null) {
      handle.throwError("file_read"); // already closed
    }

    var buflen = s.length;
    if( p < 0 || len < 0 || p > buflen || p + len > buflen ) {
      return 0;
    }
    var native = handle.get();
    // we may want to read just a part of this, so let's record the current position
    var initialPosition = native.Tell();

    var ptr = AnyPtr.fromBytesData(s) + p;
    if (!handle.get().ReadPtr(Ptr.fromAnyPtr(ptr), len)) {
      var ret:Int = cast (native.Tell() - initialPosition);
      if (ret == 0) {
        handle.throwError("file_read");
      }
      return ret;
    }
    return len;
  }

  public static function file_read_char(handle:Dynamic) : Int {
    var handle:NativeFileHandle = handle;
    var ptr:Ptr<UInt8> = Ptr.createStack();
    if (!handle.get().ReadPtr(ptr, 1)) {
      handle.throwError('file_read_char');
    }
    return ptr.get();
  }

  public static function file_seek(handle:Dynamic,pos:Int,kind:Int) : Void {
    var handle:NativeFileHandle = handle;
    var native = handle.get();
    var ret = switch(kind) {
      case 0: // SeekBegin
        native.Seek(pos);
      case 1: // SeekCur
        native.Seek(pos + native.Tell());
      case 2:
        native.SeekFromEnd(pos);
      case _:
        false;
    };
    if (!ret) {
      handle.throwError('file_seek');
    }
  }

  public static function file_tell(handle:Dynamic) : Int {
    var handle:NativeFileHandle = handle;
    return cast handle.get().Tell();
  }

  public static function file_eof(handle:Dynamic) : Bool {
    var handle:NativeFileHandle = handle;
    var native = handle.get();
    return native.Tell() == native.Size();
  }

  public static function file_flush(handle:Dynamic) : Void {
    var handle:NativeFileHandle = handle;
    handle.get().Flush();
  }

  public static function file_contents_string(name:String) : String {
    var ret:FString = "";
    if (!FFileHelper.LoadFileToString(ret, name)) {
      throw 'file_contents_string($name)';
    }
    return ret.toString();
  }

  public static function file_contents_bytes(name:String) : haxe.io.BytesData {
    var tarray:TArray<UInt8> = TArray.create();
    if (!FFileHelper.LoadFileToArray(tarray, name)) {
      throw 'file_contents_bytes($name)';
    }
    var ret:haxe.io.BytesData = cpp.NativeArray.create(tarray.length);
    FMemory.Memcpy(AnyPtr.fromBytesData(ret), tarray.GetData(), tarray.length);
    return ret;
  }

  public static function file_stdin() : Dynamic {
    // treat it as always closed
    return ( { native:null, name:'stdin' } : NativeFileHandle );
  }

  public static function file_stdout() : Dynamic {
    return ( { native:null, outputDevice:FOutputDevice.GLog, name:'stdout' } : NativeFileHandle );
  }

  public static function file_stderr() : Dynamic {
    return ( { native:null, outputDevice:FOutputDevice.GWarn, name:'stderr' } : NativeFileHandle );
  }
}