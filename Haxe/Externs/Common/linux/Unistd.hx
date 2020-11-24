package linux;

@:glueCppIncludes("<unistd.h>")
@:static
@:uextern
extern class Unistd {
  /**
    read() attempts to read up to count bytes from file descriptor fd
    into the buffer starting at buf.

    On files that support seeking, the read operation commences at the
    file offset, and the file offset is incremented by the number of
    bytes read.  If the file offset is at or past the end of file, no
    bytes are read, and read() returns zero.

    If count is zero, read() may detect the errors described below.  In
    the absence of any errors, or if read() does not check for errors, a
    read() with a count of 0 returns zero and has no other effects.

    According to POSIX.1, if count is greater than SSIZE_MAX, the result
    is implementation-defined; see NOTES for the upper limit on Linux.

    RETURN VALUE

    On success, the number of bytes read is returned (zero indicates end
    of file), and the file position is advanced by this number.  It is
    not an error if this number is smaller than the number of bytes
    requested; this may happen for example because fewer bytes are
    actually available right now (maybe because we were close to end-of-
    file, or because we are reading from a pipe, or from a terminal), or
    because read() was interrupted by a signal.  See also NOTES.

    On error, -1 is returned, and errno is set appropriately.  In this
    case, it is left unspecified whether the file position (if any)
    changes.

    ERRORS

    EAGAIN The file descriptor fd refers to a file other than a socket
    and has been marked nonblocking (O_NONBLOCK), and the read
    would block.  See open(2) for further details on the
    O_NONBLOCK flag.

    EAGAIN or EWOULDBLOCK
    The file descriptor fd refers to a socket and has been marked
    nonblocking (O_NONBLOCK), and the read would block.
    POSIX.1-2001 allows either error to be returned for this case,
    and does not require these constants to have the same value,
    so a portable application should check for both possibilities.

    EBADF  fd is not a valid file descriptor or is not open for reading.

    EFAULT buf is outside your accessible address space.

    EINTR  The call was interrupted by a signal before any data was read;
    see signal(7).

    EINVAL fd is attached to an object which is unsuitable for reading;
    or the file was opened with the O_DIRECT flag, and either the
    address specified in buf, the value specified in count, or the
    file offset is not suitably aligned.

    EINVAL fd was created via a call to timerfd_create(2) and the wrong
    size buffer was given to read(); see timerfd_create(2) for
    further information.

    EIO    I/O error.  This will happen for example when the process is
    in a background process group, tries to read from its
    controlling terminal, and either it is ignoring or blocking
    SIGTTIN or its process group is orphaned.  It may also occur
    when there is a low-level I/O error while reading from a disk
    or tape.  A further possible cause of EIO on networked
    filesystems is when an advisory lock had been taken out on the
    file descriptor and this lock has been lost.  See the Lost
    locks section of fcntl(2) for further details.

    EISDIR fd refers to a directory.

    Other errors may occur, depending on the object connected to fd.
  **/
  @:ublocking
  @:global
  public static function read(fd : Int, buf : unreal.AnyPtr, count : unreal.UIntPtr) : unreal.IntPtr;

  /**
    close() closes a file descriptor, so that it no longer refers to any
    file and may be reused.  Any record locks (see fcntl(2)) held on the
    file it was associated with, and owned by the process, are removed
    (regardless of the file descriptor that was used to obtain the lock).

    If fd is the last file descriptor referring to the underlying open
    file description (see open(2)), the resources associated with the
    open file description are freed; if the file descriptor was the last
    reference to a file which has been removed using unlink(2), the file
    is deleted.

    RETURN VALUE

    close() returns zero on success.  On error, -1 is returned, and errno
    is set appropriately.

    ERRORS

    EBADF  fd isn't a valid open file descriptor.

    EINTR  The close() call was interrupted by a signal; see signal(7).

    EIO    An I/O error occurred.

    ENOSPC, EDQUOT
    On NFS, these errors are not normally reported against the
    first write which exceeds the available storage space, but
    instead against a subsequent write(2), fsync(2), or close(2).

    See NOTES for a discussion of why close() should not be retried after
    an error.
  **/
  @:ublocking
  @:global
  public static function close(fd : Int) : Int;

  /**
    The nice() function shall add the value of incr to the nice value of the calling process. A process' nice value is a non-negative number for which a more positive value shall result in less favorable scheduling.
    A maximum nice value of 2*{NZERO}-1 and a minimum nice value of 0 shall be imposed by the system. Requests for values above or below these limits shall result in the nice value being set to the corresponding limit. Only a process with appropriate privileges can lower the nice value.

    PS|TPS Calling the nice() function has no effect on the priority of processes or threads with policy SCHED_FIFO or SCHED_RR. The effect on processes or threads with other scheduling policies is implementation-defined. 
    The nice value set with nice() shall be applied to the process. If the process is multi-threaded, the nice value shall affect all system scope threads in the process.
    As -1 is a permissible return value in a successful situation, an application wishing to check for error situations should set errno to 0, then call nice(), and if it returns -1, check to see whether errno is non-zero.

    RETURN VALUE
    Upon successful completion, nice() shall return the new nice value -{NZERO}. Otherwise, -1 shall be returned, the process' nice value shall not be changed, and errno shall be set to indicate the error.
    
    ERRORS
    The nice() function shall fail if: 
    EPERM
    The incr argument is negative and the calling process does not have appropriate privileges.
  **/
  @:ublocking
  @:global
  public static function nice(incr : Int) : Int;
}
