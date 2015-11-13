/**
   * 
   * WARNING! This file was autogenerated by: 
   *  _   _ _____     ___   _   _ __   __ 
   * | | | |  ___|   /   | | | | |\ \ / / 
   * | | | | |__    / /| | | |_| | \ V /  
   * | | | |  __|  / /_| | |  _  | /   \  
   * | |_| | |___  \___  | | | | |/ /^\ \ 
   *  \___/\____/      |_/ \_| |_/\/   \/ 
   * 
   * This file was autogenerated by UE4HaxeExternGenerator using UHT definitions. It only includes UPROPERTYs and UFUNCTIONs. Do not modify it!
   * In order to add more definitions, create or edit a type with the same name/package, but with an `_Extra` suffix
**/
package unreal.umg;


/**
  Is an entity visible?
**/
@:umodule("UMG")
@:glueCppIncludes("UMG.h")
@:uname("ESlateVisibility")
@:class @:uextern extern enum ESlateVisibility {
  
  /**
    Default widget visibility - visible and can interactive with the cursor
  **/
  Visible;
  
  /**
    Not visible and takes up no space in the layout; can never be clicked on because it takes up no space.
  **/
  Collapsed;
  
  /**
    Not visible, but occupies layout space. Not interactive for obvious reasons.
  **/
  Hidden;
  
  /**
    Visible to the user, but only as art. The cursors hit tests will never see this widget.
  **/
  HitTestInvisible;
  
  /**
    Same as HitTestInvisible, but doesn't apply to child widgets.
  **/
  SelfHitTestInvisible;
  
}
