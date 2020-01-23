package unreal.slatecore;

#if proletariat
/**
  Used to specify case conversion styles on TextBlocks
**/
@:umodule("SlateCore")
@:glueCppIncludes("Public/Styling/SlateTypes.h")
@:uname("ETextConvertCaseMode")
@:class @:uextern @:uenum extern enum ETextConvertCaseMode {
  
  /**
    Default
  **/
  Default;
  
  /**
    Convert all characters to lowercase
  **/
  Lowercase;
  
  /**
    Convert all characters to uppercase
  **/
  Uppercase;
  
}
#end