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
package unreal.paper2d;

@:umodule("Paper2D")
@:glueCppIncludes("PaperFlipbookComponent.h")
@:uextern @:uclass extern class UPaperFlipbookComponent extends unreal.UMeshComponent {
  
  /**
    Event called whenever a non-looping flipbook finishes playing (either reaching the beginning or the end, depending on the play direction)
  **/
  @:uproperty public var OnFinishedPlaying : unreal.paper2d.FFlipbookFinishedPlaySignature;
  
  /**
    The cached body setup
  **/
  @:uproperty private var CachedBodySetup : unreal.UBodySetup;
  
  /**
    Vertex color to apply to the frames
  **/
  @:uproperty private var SpriteColor : unreal.FLinearColor;
  
  /**
    Last frame index calculated
  **/
  @:uproperty private var CachedFrameIndex : unreal.Int32;
  
  /**
    Current position in the timeline
  **/
  @:uproperty private var AccumulatedTime : unreal.Float32;
  
  /**
    Current play rate of the flipbook
  **/
  @:uproperty private var PlayRate : unreal.Float32;
  
  /**
    DEPRECATED in 4.5: The material override for this flipbook component (if any); replaced by the Materials array inherited from UMeshComponent
  **/
  @:deprecated @:uproperty private var Material_DEPRECATED : unreal.UMaterialInterface;
  
  /**
    Flipbook currently being played
  **/
  @:uproperty private var SourceFlipbook : unreal.paper2d.UPaperFlipbook;
  
  /**
    Change the flipbook used by this instance (will reset the play time to 0 if it is a new flipbook).
  **/
  @:ufunction public function SetFlipbook(NewFlipbook : unreal.paper2d.UPaperFlipbook) : Bool;
  
  /**
    Gets the flipbook used by this instance.
  **/
  @:ufunction public function GetFlipbook() : unreal.paper2d.UPaperFlipbook;
  @:ufunction @:thisConst @:final public function GetSpriteMaterial() : unreal.UMaterialInterface;
  
  /**
    Set color of the sprite
  **/
  @:ufunction @:final public function SetSpriteColor(NewColor : unreal.FLinearColor) : Void;
  
  /**
    Start playback of flipbook
  **/
  @:ufunction @:final public function Play() : Void;
  
  /**
    Start playback of flipbook from the start
  **/
  @:ufunction @:final public function PlayFromStart() : Void;
  
  /**
    Start playback of flipbook in reverse
  **/
  @:ufunction @:final public function Reverse() : Void;
  
  /**
    Start playback of flipbook in reverse from the end
  **/
  @:ufunction @:final public function ReverseFromEnd() : Void;
  
  /**
    Stop playback of flipbook
  **/
  @:ufunction @:final public function Stop() : Void;
  
  /**
    Get whether this flipbook is playing or not.
  **/
  @:ufunction @:thisConst @:final public function IsPlaying() : Bool;
  
  /**
    Get whether we are reversing or not
  **/
  @:ufunction @:thisConst @:final public function IsReversing() : Bool;
  
  /**
    Jump to a position in the flipbook (expressed in frames). If bFireEvents is true, event functions will fire, otherwise they will not.
  **/
  @:ufunction @:final public function SetPlaybackPositionInFrames(NewFramePosition : unreal.Int32, bFireEvents : Bool) : Void;
  
  /**
    Get the current playback position (in frames) of the flipbook
  **/
  @:ufunction @:thisConst @:final public function GetPlaybackPositionInFrames() : unreal.Int32;
  
  /**
    Jump to a position in the flipbook (expressed in seconds). If bFireEvents is true, event functions will fire, otherwise they will not.
  **/
  @:ufunction @:final public function SetPlaybackPosition(NewPosition : unreal.Float32, bFireEvents : Bool) : Void;
  
  /**
    Get the current playback position (in seconds) of the flipbook
  **/
  @:ufunction @:thisConst @:final public function GetPlaybackPosition() : unreal.Float32;
  
  /**
    true means we should loop, false means we should not.
  **/
  @:ufunction @:final public function SetLooping(bNewLooping : Bool) : Void;
  
  /**
    Get whether we are looping or not
  **/
  @:ufunction @:thisConst @:final public function IsLooping() : Bool;
  
  /**
    Sets the new play rate for this flipbook
  **/
  @:ufunction @:final public function SetPlayRate(NewRate : unreal.Float32) : Void;
  
  /**
    Get the current play rate for this flipbook
  **/
  @:ufunction @:thisConst @:final public function GetPlayRate() : unreal.Float32;
  
  /**
    Set the new playback position time to use
  **/
  @:ufunction @:final public function SetNewTime(NewTime : unreal.Float32) : Void;
  
  /**
    Get length of the flipbook (in seconds)
  **/
  @:ufunction @:thisConst @:final public function GetFlipbookLength() : unreal.Float32;
  
  /**
    Get length of the flipbook (in frames)
  **/
  @:ufunction @:thisConst @:final public function GetFlipbookLengthInFrames() : unreal.Int32;
  
  /**
    Get the nominal framerate that the flipbook will be played back at (ignoring PlayRate), in frames per second
  **/
  @:ufunction @:thisConst @:final public function GetFlipbookFramerate() : unreal.Float32;
  @:ufunction @:final private function OnRep_SourceFlipbook(OldFlipbook : unreal.paper2d.UPaperFlipbook) : Void;
  
}