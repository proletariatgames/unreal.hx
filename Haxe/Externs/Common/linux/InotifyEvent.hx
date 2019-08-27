package linux;

@:glueCppIncludes("<sys/inotify.h>")
@:uname("inotify_event")
@:noEquals
@:uextern
extern class InotifyEvent {
  @:uname('.sizeof') public static var size(default, never):Int;
  public var wd:Int;
  public var mask:cpp.UInt32;
  public var cookie:cpp.UInt32;
  public var len:cpp.UInt32;
  public var name(default, never):cpp.ConstCharStar;
}
