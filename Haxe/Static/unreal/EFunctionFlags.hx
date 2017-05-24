package unreal;

@:uextern
@:enum abstract EFunctionFlags(Int) from Int to Int {
  // Function flags.
  /**
    Function is final (prebindable, non-overridable function).
   **/
  var FUNC_Final = 0x00000001;
  /**
    Indicates this function is DLL exported/imported.
   **/
  var FUNC_RequiredAPI = 0x00000002;
  /**
    Function will only run if the object has network authority
   **/
  var FUNC_BlueprintAuthorityOnly= 0x00000004;
  /**
    Function is cosmetic in nature and should not be invoked on dedicated servers
   **/
  var FUNC_BlueprintCosmetic = 0x00000008;
  /**
     Function is network-replicated.
  **/
  var FUNC_Net = 0x00000040;
  /**
     Function should be sent reliably on the network.
  **/
  var FUNC_NetReliable = 0x00000080;
  /**
     Function is sent to a net service
  **/
  var FUNC_NetRequest = 0x00000100;
  /**
     Executable from command line.
  **/
  var FUNC_Exec = 0x00000200;
  /**
     Native function.
  **/
  var FUNC_Native = 0x00000400;
  /**
     Event function.
  **/
  var FUNC_Event = 0x00000800;
  /**
     Function response from a net service
  **/
  var FUNC_NetResponse = 0x00001000;
  /**
     Static function.
  **/
  var FUNC_Static = 0x00002000;
  /**
     Function is networked multicast Server -> All Clients
  **/
  var FUNC_NetMulticast = 0x00004000;
  /**
     Function is a multi-cast delegate signature (also requires FUNC_Delegate to be set!)
  **/
  var FUNC_MulticastDelegate = 0x00010000;
  /**
     Function is accessible in all classes (if overridden, parameters must remain unchanged).
  **/
  var FUNC_Public = 0x00020000;
  /**
     Function is accessible only in the class it is defined in (cannot be overridden, but function name may be reused in subclasses.  IOW: if overridden, parameters don't need to match, and Super.Func() cannot be accessed sin ce it's private.)
  **/
  var FUNC_Private = 0x00040000;
  /**
     Function is accessible only in the class it is defined in and subclasses (if overridden, parameters much remain unchanged).
  **/
  var FUNC_Protected = 0x00080000;
  /**
     Function is delegate signature (either single-cast or multi-cast, depending on whether FUNC_MulticastDelegate is set.)
  **/
  var FUNC_Delegate = 0x00100000;
  /**
     Function is executed on servers (set by replication code if passes check)
  **/
  var FUNC_NetServer = 0x00200000;
  /**
     function has out (pass by reference) parameters
  **/
  var FUNC_HasOutParms = 0x00400000;
  /**
     function has structs that contain defaults
  **/
  var FUNC_HasDefaults = 0x00800000;
  /**
     function is executed on clients
  **/
  var FUNC_NetClient = 0x01000000;
  /**
     function is imported from a DLL
  **/
  var FUNC_DLLImport = 0x02000000;
  /**
     function can be called from blueprint code
  **/
  var FUNC_BlueprintCallable = 0x04000000;
  /**
     function can be overridden/implemented from a blueprint
  **/
  var FUNC_BlueprintEvent = 0x08000000;
  /**
     function can be called from blueprint code, and is also pure (produces no side effects). If you set this, you should set FUNC_BlueprintCallable as well.
  **/
  var FUNC_BlueprintPure = 0x10000000;
  /**
     function can be called from blueprint code, and only reads state (never writes state)
  **/
  var FUNC_Const = 0x40000000;
  /**
     function must supply a _Validate implementation
  **/
  var FUNC_NetValidate = 0x80000000;

  // Combinations of flags.
  var FUNC_FuncInherit = FUNC_Exec | FUNC_Event | FUNC_BlueprintCallable | FUNC_BlueprintEvent | FUNC_BlueprintAuthorityOnly | FUNC_BlueprintCosmetic;
  var FUNC_FuncOverrideMatch = FUNC_Exec | FUNC_Final | FUNC_Static | FUNC_Public | FUNC_Protected | FUNC_Private;
  var FUNC_NetFuncFlags = FUNC_Net | FUNC_NetReliable | FUNC_NetServer | FUNC_NetClient | FUNC_NetMulticast;
  var FUNC_AccessSpecifiers = FUNC_Public | FUNC_Private | FUNC_Protected;

  var FUNC_AllFlags = 0xFFFFFFFF;


  @:extern inline private function t() {
    return this;
  }

  @:op(A | B) @:extern inline public function add(flag:EFunctionFlags):EFunctionFlags {
    return this | flag.t();
  }

  @:op(A & B) @:extern inline public function and(mask:EFunctionFlags):EFunctionFlags {
    return this & mask.t();
  }

  inline public function hasAny(mask:EFunctionFlags):Bool {
    return this & mask.t() != 0;
  }

  inline public function hasAll(mask:EFunctionFlags):Bool {
    return this & mask.t() == mask.t();
  }

  @:op(~A) @:extern inline public function bitNot():EFunctionFlags {
    return ~this;
  }
}
