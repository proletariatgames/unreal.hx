package unreal;

@:uextern
@:glueCppIncludes("ObjectMacros.h")
@:enum abstract EInternalObjectFlags(Int) from Int to Int {
  var None = 0;
  // All the other bits are reserved, DO NOT ADD NEW FLAGS HERE!
  var ReachableInCluster = 1 << 23; /// External reference to object in cluster exists
  var ClusterRoot = 1 << 24; ///< Root of a cluster
  var Native = 1 << 25; ///< Native (UClass only).
  var Async = 1 << 26; ///< Object exists only on a different thread than the game thread.
  var AsyncLoading = 1 << 27; ///< Object is being asynchronously loaded.
  var Unreachable = 1 << 28; ///< Object is not reachable on the object graph.
  var PendingKill = 1 << 29; ///< Objects that are pending destruction (invalid for gameplay but valid objects)
  var RootSet = 1 << 30; ///< Object will not be garbage collected, even if unreferenced.
  var NoStrongReference = 1 << 31; ///< The object is not referenced by any strong reference. The flag is used by GC.

  @:extern inline private function t() {
    return this;
  }

  @:extern inline public function hasAny(flag:EInternalObjectFlags):Bool {
    return this & flag.t() != 0;
  }

  @:extern inline public function hasAll(flag:EInternalObjectFlags):Bool {
    return this & flag.t() == flag.t();
  }

  @:op(A | B) @:extern inline public function add(flag:EInternalObjectFlags):EInternalObjectFlags {
    return this | flag.t();
  }

  @:op(A & B) @:extern inline public function and(mask:EInternalObjectFlags):EInternalObjectFlags {
    return this & mask.t();
  }
}

