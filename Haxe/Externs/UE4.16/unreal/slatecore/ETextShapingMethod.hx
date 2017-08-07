/**
 * 
 * WARNING! This file was autogenerated by: 
 *  _   _ _   _ __   __ 
 * | | | | | | |\ \ / / 
 * | | | | |_| | \ V /  
 * | | | |  _  | /   \  
 * | |_| | | | |/ /^\ \ 
 *  \___/\_| |_/\/   \/ 
 * 
 * This file was autogenerated by UnrealHxGenerator using UHT definitions.
 * It only includes UPROPERTYs and UFUNCTIONs. Do not modify it!
 * In order to add more definitions, create or edit a type with the same name/package, but with an `_Extra` suffix
**/
package unreal.slatecore;

/**
  Methods that can be used to shape text.
  @note If you change this enum, make sure and update CVarDefaultTextShapingMethod and GetDefaultTextShapingMethod.
**/
@:umodule("SlateCore")
@:glueCppIncludes("Fonts/FontCache.h")
@:uname("ETextShapingMethod")
@:class @:uextern @:uenum extern enum ETextShapingMethod {
  
  /**
    Automatically picks the fastest possible shaping method (either KerningOnly or FullShaping) based on the reading direction of the text.
    Left-to-right text uses the KerningOnly method, and right-to-left text uses the FullShaping method.
  **/
  Auto;
  
  /**
    Provides fake shaping using only kerning data.
    This can be faster than full shaping, but won't render complex right-to-left or bi-directional glyphs (such as Arabic) correctly.
    This can be useful as an optimization when you know your text block will only show simple glyphs (such as numbers).
  **/
  KerningOnly;
  
  /**
    Provides full text shaping, allowing accurate rendering of complex right-to-left or bi-directional glyphs (such as Arabic).
    This mode will perform ligature replacement for all languages (such as the combined "fi" glyph in English).
  **/
  FullShaping;
  
}