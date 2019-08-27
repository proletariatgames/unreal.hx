package linux;
@:glueCppIncludes("<errno.h>")
@:uextern
@:static
extern class Error {
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var errno(default,never):Int;

  /**
    Argument list too long (POSIX.1-2001).
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var E2BIG(default,never):Int;

  /**
    Permission denied (POSIX.1-2001).
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var EACCES(default,never):Int;

  /**
    Address already in use (POSIX.1-2001).
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var EADDRINUSE(default,never):Int;

  /**
    Address not available (POSIX.1-2001).
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var EADDRNOTAVAIL(default,never):Int;

  /**
    Address family not supported (POSIX.1-2001).
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var EAFNOSUPPORT(default,never):Int;

  /**
    Resource temporarily unavailable (may be the same
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var EAGAIN(default,never):Int;

  /**
    Connection already in progress (POSIX.1-2001).
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var EALREADY(default,never):Int;

  /**
    Invalid exchange.
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var EBADE(default,never):Int;

  /**
    Bad file descriptor (POSIX.1-2001).
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var EBADF(default,never):Int;

  /**
    File descriptor in bad state.
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var EBADFD(default,never):Int;

  /**
    Bad message (POSIX.1-2001).
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var EBADMSG(default,never):Int;

  /**
    Invalid request descriptor.
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var EBADR(default,never):Int;

  /**
    Invalid request code.
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var EBADRQC(default,never):Int;

  /**
    Invalid slot.
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var EBADSLT(default,never):Int;

  /**
    Device or resource busy (POSIX.1-2001).
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var EBUSY(default,never):Int;

  /**
    Operation canceled (POSIX.1-2001).
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var ECANCELED(default,never):Int;

  /**
    No child processes (POSIX.1-2001).
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var ECHILD(default,never):Int;

  /**
    Channel number out of range.
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var ECHRNG(default,never):Int;

  /**
    Communication error on send.
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var ECOMM(default,never):Int;

  /**
    Connection aborted (POSIX.1-2001).
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var ECONNABORTED(default,never):Int;

  /**
    Connection refused (POSIX.1-2001).
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var ECONNREFUSED(default,never):Int;

  /**
    Connection reset (POSIX.1-2001).
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var ECONNRESET(default,never):Int;

  /**
    Resource deadlock avoided (POSIX.1-2001).
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var EDEADLK(default,never):Int;

  /**
    Synonym for EDEADLK.
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var EDEADLOCK(default,never):Int;

  /**
    Destination address required (POSIX.1-2001).
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var EDESTADDRREQ(default,never):Int;

  /**
    Mathematics argument out of domain of function
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var EDOM(default,never):Int;

  /**
    Disk quota exceeded (POSIX.1-2001).
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var EDQUOT(default,never):Int;

  /**
    File exists (POSIX.1-2001).
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var EEXIST(default,never):Int;

  /**
    Bad address (POSIX.1-2001).
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var EFAULT(default,never):Int;

  /**
    File too large (POSIX.1-2001).
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var EFBIG(default,never):Int;

  /**
    Host is down.
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var EHOSTDOWN(default,never):Int;

  /**
    Host is unreachable (POSIX.1-2001).
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var EHOSTUNREACH(default,never):Int;

  /**
    Memory page has hardware error.
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var EHWPOISON(default,never):Int;

  /**
    Identifier removed (POSIX.1-2001).
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var EIDRM(default,never):Int;

  /**
    Invalid or incomplete multibyte or wide character
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var EILSEQ(default,never):Int;

  /**
    Operation in progress (POSIX.1-2001).
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var EINPROGRESS(default,never):Int;

  /**
    Interrupted function call (POSIX.1-2001); see
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var EINTR(default,never):Int;

  /**
    Invalid argument (POSIX.1-2001).
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var EINVAL(default,never):Int;

  /**
    Input/output error (POSIX.1-2001).
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var EIO(default,never):Int;

  /**
    Socket is connected (POSIX.1-2001).
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var EISCONN(default,never):Int;

  /**
    Is a directory (POSIX.1-2001).
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var EISDIR(default,never):Int;

  /**
    Is a named type file.
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var EISNAM(default,never):Int;

  /**
    Key has expired.
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var EKEYEXPIRED(default,never):Int;

  /**
    Key was rejected by service.
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var EKEYREJECTED(default,never):Int;

  /**
    Key has been revoked.
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var EKEYREVOKED(default,never):Int;

  /**
    Level 2 halted.
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var EL2HLT(default,never):Int;

  /**
    Level 2 not synchronized.
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var EL2NSYNC(default,never):Int;

  /**
    Level 3 halted.
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var EL3HLT(default,never):Int;

  /**
    Level 3 reset.
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var EL3RST(default,never):Int;

  /**
    Cannot access a needed shared library.
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var ELIBACC(default,never):Int;

  /**
    Accessing a corrupted shared library.
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var ELIBBAD(default,never):Int;

  /**
    Attempting to link in too many shared libraries.
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var ELIBMAX(default,never):Int;

  /**
    .lib section in a.out corrupted
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var ELIBSCN(default,never):Int;

  /**
    Cannot exec a shared library directly.
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var ELIBEXEC(default,never):Int;

  // /**
  //   Link number out of range.
  // **/
  // @:global("")
  // @:glueCppIncludes("<errno.h>")
  // public static var ELNRANGE(default,never):Int;

  /**
    Too many levels of symbolic links (POSIX.1-2001).
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var ELOOP(default,never):Int;

  /**
    Wrong medium type.
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var EMEDIUMTYPE(default,never):Int;

  /**
    Too many open files (POSIX.1-2001)
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var EMFILE(default,never):Int;

  /**
    Too many links (POSIX.1-2001).
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var EMLINK(default,never):Int;

  /**
    Message too long (POSIX.1-2001).
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var EMSGSIZE(default,never):Int;

  /**
    Multihop attempted (POSIX.1-2001).
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var EMULTIHOP(default,never):Int;

  /**
    Filename too long (POSIX.1-2001).
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var ENAMETOOLONG(default,never):Int;

  /**
    Network is down (POSIX.1-2001).
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var ENETDOWN(default,never):Int;

  /**
    Connection aborted by network (POSIX.1-2001).
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var ENETRESET(default,never):Int;

  /**
    Network unreachable (POSIX.1-2001).
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var ENETUNREACH(default,never):Int;

  /**
    Too many open files in system (POSIX.1-2001).
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var ENFILE(default,never):Int;

  /**
    No anode.
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var ENOANO(default,never):Int;

  /**
    No buffer space available (POSIX.1 (XSI STREAMS
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var ENOBUFS(default,never):Int;

  /**
    No message is available on the STREAM head read queue
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var ENODATA(default,never):Int;

  /**
    No such device (POSIX.1-2001).
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var ENODEV(default,never):Int;

  /**
    No such file or directory (POSIX.1-2001).
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var ENOENT(default,never):Int;

  /**
    Exec format error (POSIX.1-2001).
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var ENOEXEC(default,never):Int;

  /**
    Required key not available.
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var ENOKEY(default,never):Int;

  /**
    No locks available (POSIX.1-2001).
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var ENOLCK(default,never):Int;

  /**
    Link has been severed (POSIX.1-2001).
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var ENOLINK(default,never):Int;

  /**
    No medium found.
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var ENOMEDIUM(default,never):Int;

  /**
    Not enough space/cannot allocate memory
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var ENOMEM(default,never):Int;

  /**
    No message of the desired type (POSIX.1-2001).
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var ENOMSG(default,never):Int;

  /**
    Machine is not on the network.
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var ENONET(default,never):Int;

  /**
    Package not installed.
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var ENOPKG(default,never):Int;

  /**
    Protocol not available (POSIX.1-2001).
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var ENOPROTOOPT(default,never):Int;

  /**
    No space left on device (POSIX.1-2001).
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var ENOSPC(default,never):Int;

  /**
    No STREAM resources (POSIX.1 (XSI STREAMS option)).
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var ENOSR(default,never):Int;

  /**
    Not a STREAM (POSIX.1 (XSI STREAMS option)).
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var ENOSTR(default,never):Int;

  /**
    Function not implemented (POSIX.1-2001).
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var ENOSYS(default,never):Int;

  /**
    Block device required.
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var ENOTBLK(default,never):Int;

  /**
    The socket is not connected (POSIX.1-2001).
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var ENOTCONN(default,never):Int;

  /**
    Not a directory (POSIX.1-2001).
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var ENOTDIR(default,never):Int;

  /**
    Directory not empty (POSIX.1-2001).
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var ENOTEMPTY(default,never):Int;

  /**
    State not recoverable (POSIX.1-2008).
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var ENOTRECOVERABLE(default,never):Int;

  /**
    Not a socket (POSIX.1-2001).
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var ENOTSOCK(default,never):Int;

  /**
    Operation not supported (POSIX.1-2001).
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var ENOTSUP(default,never):Int;

  /**
    Inappropriate I/O control operation (POSIX.1-2001).
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var ENOTTY(default,never):Int;

  /**
    Name not unique on network.
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var ENOTUNIQ(default,never):Int;

  /**
    No such device or address (POSIX.1-2001).
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var ENXIO(default,never):Int;

  /**
    Operation not supported on socket (POSIX.1-2001).
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var EOPNOTSUPP(default,never):Int;

  /**
    Value too large to be stored in data type
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var EOVERFLOW(default,never):Int;

  /**
    Owner died (POSIX.1-2008).
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var EOWNERDEAD(default,never):Int;

  /**
    Operation not permitted (POSIX.1-2001).
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var EPERM(default,never):Int;

  /**
    Protocol family not supported.
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var EPFNOSUPPORT(default,never):Int;

  /**
    Broken pipe (POSIX.1-2001).
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var EPIPE(default,never):Int;

  /**
    Protocol error (POSIX.1-2001).
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var EPROTO(default,never):Int;

  /**
    Protocol not supported (POSIX.1-2001).
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var EPROTONOSUPPORT(default,never):Int;

  /**
    Protocol wrong type for socket (POSIX.1-2001).
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var EPROTOTYPE(default,never):Int;

  /**
    Result too large (POSIX.1, C99).
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var ERANGE(default,never):Int;

  /**
    Remote address changed.
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var EREMCHG(default,never):Int;

  /**
    Object is remote.
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var EREMOTE(default,never):Int;

  /**
    Remote I/O error.
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var EREMOTEIO(default,never):Int;

  /**
    Interrupted system call should be restarted.
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var ERESTART(default,never):Int;

  /**
    Operation not possible due to RF-kill.
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var ERFKILL(default,never):Int;

  /**
    Read-only filesystem (POSIX.1-2001).
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var EROFS(default,never):Int;

  /**
    Cannot send after transport endpoint shutdown.
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var ESHUTDOWN(default,never):Int;

  /**
    Invalid seek (POSIX.1-2001).
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var ESPIPE(default,never):Int;

  /**
    Socket type not supported.
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var ESOCKTNOSUPPORT(default,never):Int;

  /**
    No such process (POSIX.1-2001).
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var ESRCH(default,never):Int;

  /**
    Stale file handle (POSIX.1-2001).
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var ESTALE(default,never):Int;

  /**
    Streams pipe error.
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var ESTRPIPE(default,never):Int;

  /**
    Timer expired (POSIX.1 (XSI STREAMS option)).
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var ETIME(default,never):Int;

  /**
    Connection timed out (POSIX.1-2001).
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var ETIMEDOUT(default,never):Int;

  /**
    Too many references: cannot splice.
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var ETOOMANYREFS(default,never):Int;

  /**
    Text file busy (POSIX.1-2001).
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var ETXTBSY(default,never):Int;

  /**
    Structure needs cleaning.
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var EUCLEAN(default,never):Int;

  /**
    Protocol driver not attached.
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var EUNATCH(default,never):Int;

  /**
    Too many users.
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var EUSERS(default,never):Int;

  /**
    Operation would block (may be same value as EAGAIN)
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var EWOULDBLOCK(default,never):Int;

  /**
    Improper link (POSIX.1-2001).
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var EXDEV(default,never):Int;

  /**
    Exchange full.
  **/
  @:global("")
  @:glueCppIncludes("<errno.h>")
  public static var EXFULL(default,never):Int;

  @:global @:glueCppIncludes("<string.h>")
  public static function strerror(errnum:Int):cpp.ConstCharStar;
}
