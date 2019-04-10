package uhx.compiletime;

@:enum abstract UhxMeta(String) from String to String {
  // Unreal.hx-specific
  /**
    Annotates a class that itself or its parent does not have a default constructor
  **/
  var NoDefaultConstructor = ":noDefaultConstructor";
  /**
    Defines the replication strategy for the property
  **/
  var UReplicate = ':ureplicate';
  /**
    Annotates a class as external in the Haxe context - meaning it was not defined by Haxe
  **/
  var UExtern = ':uextern';
  /**
    Annotates a field as exposed
  **/
  var UExpose = ':uexpose';
  /**
    Calls SetDefaultSubobjectClass on the constructor
  **/
  var UOverrideSubobject = ':uoverrideSubobject';
  /**
    Defines the C++ name of the target type
  **/
  var UName = ":uname";

  // Unreal C++ metadata
  var UProperty = ':uproperty';
  var UFunction = ':ufunction';
  var UClass = ':uclass';

  // C++ equivalence
  /**
    Annotates a function as non-virtual
  **/
  var Final = ':final';
  /**
    Annotates a function as defined with a `const` at the end of the function (meaning that `this*` is `const`)
  **/
  var ThisConst = ':thisConst';

  // UEnum metadata
  /**
    Annotates an enum as a C++ `enum class` type
  **/
  var Class = ':class';
  /**
    Annotates an enum as an UENUM type
  **/
  var UEnum = ':uenum';

  // Internal metadata
  /**
    Annotates a type as defined by cppia
  **/
  var UScript = ':uscript';
  /**
    Annotates a field as compiled, and sets its compiled signature so it can be included in the compiled
  **/
  var UCompiled = ':ucompiled';

  /**
    A list of generated signatures inside a statically-compiled class. It defines these signatures so they can be checked
    when compiling cppia through `compiledScriptGluesExists`
  **/
  var UGenerated = ":ugenerated";


  /**
    Returns whether the metadata changes how a class/property/function is compiled in C++
  **/
  public function changesStaticCompilation():Bool {
    switch (this : UhxMeta) {
      case NoDefaultConstructor | UOverrideSubobject | UClass | UProperty | UFunction | Final | ThisConst | UExpose | UName | Class:
        return true;
      case _:
        return false;
    }
  }

  public static function getStaticMetas(meta:haxe.macro.Expr.Metadata):String {
    if (meta == null) {
      return '';
    }
    var buf = new StringBuf();
    var first = true;
    for (meta in meta) {
      if ( (meta.name : UhxMeta).changesStaticCompilation() ) {
        buf.add(meta.name);
        if (meta.params != null && meta.params.length > 0) {
          buf.addChar('('.code);
          buf.add([for (param in meta.params) haxe.macro.ExprTools.toString(param)].join(','));
          buf.addChar(')'.code);
        }
        buf.addChar(' '.code);
      }
    }
    return buf.toString();
  }
}