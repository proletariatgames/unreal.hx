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
  Represents the appearance of an SHeaderRow
**/
@:umodule("SlateCore")
@:glueCppIncludes("Public/Styling/SlateTypes.h")
@:uextern @:ustruct extern class FHeaderRowStyle extends unreal.slatecore.FSlateWidgetStyle {
  
  /**
    Color used to draw the header row foreground
  **/
  @:uproperty public var ForegroundColor : unreal.slatecore.FSlateColor;
  
  /**
    Brush used to draw the header row background
  **/
  @:uproperty public var BackgroundBrush : unreal.slatecore.FSlateBrush;
  
  /**
    Style of the splitter used between the columns
  **/
  @:uproperty public var ColumnSplitterStyle : unreal.slatecore.FSplitterStyle;
  
  /**
    Style of the last header row column
  **/
  @:uproperty public var LastColumnStyle : unreal.slatecore.FTableColumnHeaderStyle;
  
  /**
    Style of the normal header row columns
  **/
  @:uproperty public var ColumnStyle : unreal.slatecore.FTableColumnHeaderStyle;
  
}
