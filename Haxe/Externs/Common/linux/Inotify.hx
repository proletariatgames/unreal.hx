package linux;

@:umodule("Unreal")
@:glueCppIncludes("<sys/inotify.h>")
@:static
@:uextern
extern class Inotify {
  @:global("")
  @:glueCppIncludes("<sys/inotify.h>")
  public static var IN_NONBLOCK(default,never):Int;

  @:global("")
  @:glueCppIncludes("<sys/inotify.h>")
  public static var IN_CLOEXEC(default,never):Int;

  /**
    File was accessed (e.g., read(2), execve(2)).
  **/
  @:global("")
  @:glueCppIncludes("<sys/inotify.h>")
  public static var IN_ACCESS(default, never):Int;

  /**
    Metadata changed—for example, permissions (e.g.,
    chmod(2)), timestamps (e.g., utimensat(2)), extended
    attributes (setxattr(2)), link count (since Linux 2.6.25;
    e.g., for the target of link(2) and for unlink(2)), and
    user/group ID (e.g., chown(2)).
  **/
  @:global("")
  @:glueCppIncludes("<sys/inotify.h>")
  public static var IN_ATTRIB(default, never):Int;

  /**
    File opened for writing was closed.
  **/
  @:global("")
  @:glueCppIncludes("<sys/inotify.h>")
  public static var IN_CLOSE_WRITE(default, never):Int;

  /**
    File or directory not opened for writing was closed.
  **/
  @:global("")
  @:glueCppIncludes("<sys/inotify.h>")
  public static var IN_CLOSE_NOWRITE(default, never):Int;

  /**
    File/directory created in watched directory (e.g., open(2)
    O_CREAT, mkdir(2), link(2), symlink(2), bind(2) on a UNIX
    domain socket).
  **/
  @:global("")
  @:glueCppIncludes("<sys/inotify.h>")
  public static var IN_CREATE(default, never):Int;

  /**
    File/directory deleted from watched directory.
  **/
  @:global("")
  @:glueCppIncludes("<sys/inotify.h>")
  public static var IN_DELETE(default, never):Int;

  // /**
  //   Watched file/directory was itself deleted.  (This event
  //   also occurs if an object is moved to another filesystem,
  //   since mv(1) in effect copies the file to the other
  //   filesystem and then deletes it from the original filesys‐
  //   tem.)  In addition, an IN_IGNORED event will subsequently
  //   be generated for the watch descriptor.
  // **/
  // @:global("")
  // @:glueCppIncludes("<sys/inotify.h>")
  // public static var IN_DELETE_SEL(default, never):Int;

  /**
    File was modified (e.g., write(2), truncate(2)).
  **/
  @:global("")
  @:glueCppIncludes("<sys/inotify.h>")
  public static var IN_MODIFY(default, never):Int;

  // /**
  //   Watched file/directory was itself moved.
  // **/
  // @:global("")
  // @:glueCppIncludes("<sys/inotify.h>")
  // public static var IN_MOVE_SEL(default, never):Int;

  /**
    Generated for the directory containing the old filename
    when a file is renamed.
  **/
  @:global("")
  @:glueCppIncludes("<sys/inotify.h>")
  public static var IN_MOVED_FROM(default, never):Int;

  /**
    Generated for the directory containing the new filename
    when a file is renamed.
  **/
  @:global("")
  @:glueCppIncludes("<sys/inotify.h>")
  public static var IN_MOVED_TO(default, never):Int;

  /**
    File or directory was opened.
  **/
  @:global("")
  @:glueCppIncludes("<sys/inotify.h>")
  public static var IN_OPEN(default, never):Int;

  /**
    inotify_init() initializes a new inotify instance and returns a file
    descriptor associated with a new inotify event queue.

    On success, these system calls return a new file descriptor.  On
    error, -1 is returned, and errno is set to indicate the error.
  **/
  @:global
  public static function inotify_init() : Int;

  /**
       If flags is 0, then inotify_init1() is the same as inotify_init().
       The following values can be bitwise ORed in flags to obtain different
       behavior:

       IN_NONBLOCK Set the O_NONBLOCK file status flag on the open file
                   description (see open(2)) referred to by the new file
                   descriptor.  Using this flag saves extra calls to
                   fcntl(2) to achieve the same result.

       IN_CLOEXEC  Set the close-on-exec (FD_CLOEXEC) flag on the new file
                   descriptor.  See the description of the O_CLOEXEC flag in
                   open(2) for reasons why this may be useful.
  **/
  @:global
  public static function inotify_init1(flags:Int) : Int;

  /**
    inotify_add_watch() adds a new watch, or modifies an existing watch,
    for the file whose location is specified in pathname; the caller must
    have read permission for this file.  The fd argument is a file
    descriptor referring to the inotify instance whose watch list is to
    be modified.  The events to be monitored for pathname are specified
    in the mask bit-mask argument.  See inotify(7) for a description of
    the bits that can be set in mask.

    A successful call to inotify_add_watch() returns a unique watch
    descriptor for this inotify instance, for the filesystem object
    (inode) that corresponds to pathname.  If the filesystem object was
    not previously being watched by this inotify instance, then the watch
    descriptor is newly allocated.  If the filesystem object was already
    being watched (perhaps via a different link to the same object), then
    the descriptor for the existing watch is returned.

    The watch descriptor is returned by later read(2)s from the inotify
    file descriptor.  These reads fetch inotify_event structures (see
    inotify(7)) indicating filesystem events; the watch descriptor inside
    this structure identifies the object for which the event occurred.

    RETURN VALUE

    On success, inotify_add_watch() returns a nonnegative watch
    descriptor.  On error, -1 is returned and errno is set appropriately.

    ERRORS

    EACCES Read access to the given file is not permitted.

    EBADF  The given file descriptor is not valid.

    EFAULT pathname points outside of the process's accessible address
    space.

    EINVAL The given event mask contains no valid events; or mask
    contains both IN_MASK_ADD and IN_MASK_CREATE; or fd is not an
    inotify file descriptor.
    ENAMETOOLONG
    pathname is too long.

    ENOENT A directory component in pathname does not exist or is a
    dangling symbolic link.

    ENOMEM Insufficient kernel memory was available.

    ENOSPC The user limit on the total number of inotify watches was
    reached or the kernel failed to allocate a needed resource.

    ENOTDIR
    mask contains IN_ONLYDIR and pathname is not a directory.

    EEXIST mask contains IN_MASK_CREATE and pathname refers to a file
    already being watched by the same fd.
  **/
  @:ublocking
  @:global
  public static function inotify_add_watch(fd : Int, pathname : cpp.ConstCharStar, mask : cpp.UInt32) : Int;

  /**
    inotify_rm_watch() removes the watch associated with the watch
    descriptor wd from the inotify instance associated with the file
    descriptor fd.

    Removing a watch causes an IN_IGNORED event to be generated for this
    watch descriptor.  (See inotify(7).)

    RETURN VALUE

    On success, inotify_rm_watch() returns zero.  On error, -1 is
    returned and errno is set to indicate the cause of the error.

    ERRORS

    EBADF  fd is not a valid file descriptor.

    EINVAL The watch descriptor wd is not valid; or fd is not an inotify
    file descriptor.
  **/
  @:ublocking
  @:global
  public static function inotify_rm_watch(fd : Int, wd : Int) : Int;
}
