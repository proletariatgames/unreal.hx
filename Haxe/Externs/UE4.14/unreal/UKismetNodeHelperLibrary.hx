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
package unreal;

@:glueCppIncludes("Kismet/KismetNodeHelperLibrary.h")
@:uextern @:uclass extern class UKismetNodeHelperLibrary extends unreal.UBlueprintFunctionLibrary {
  
  /**
    Returns whether the bit at index "Index" is set or not in the data
    
    @param Data - The integer containing the bits that are being tested against
    @param Index - The bit index into the Data that we are inquiring
    @return  - Whether the bit at index "Index" is set or not
  **/
  @:ufunction static public function BitIsMarked(Data : unreal.Int32, Index : unreal.Int32) : Bool;
  
  /**
    Sets the bit at index "Index" in the data
    
    @param Data - The integer containing the bits that are being set
    @param Index - The bit index into the Data that we are setting
  **/
  @:ufunction static public function MarkBit(Data : unreal.Int32, Index : unreal.Int32) : Void;
  
  /**
    Clears the bit at index "Index" in the data
    
    @param Data - The integer containing the bits that are being cleared
    @param Index - The bit index into the Data that we are clearing
  **/
  @:ufunction static public function ClearBit(Data : unreal.Int32, Index : unreal.Int32) : Void;
  
  /**
    Clears all of the bit in the data
    
    @param Data - The integer containing the bits that are being cleared
  **/
  @:ufunction static public function ClearAllBits(Data : unreal.Int32) : Void;
  
  /**
    Returns whether there exists an unmarked bit in the data
    
    @param Data - The data being tested against
    @param NumBits - The logical number of bits we want to track
    @return - Whether there is a bit not marked in the data
  **/
  @:ufunction static public function HasUnmarkedBit(Data : unreal.Int32, NumBits : unreal.Int32) : Bool;
  
  /**
    Returns whether there exists a marked bit in the data
    
    @param Data - The data being tested against
    @param NumBits - The logical number of bits we want to track
    @return - Whether there is a bit marked in the data
  **/
  @:ufunction static public function HasMarkedBit(Data : unreal.Int32, NumBits : unreal.Int32) : Bool;
  
  /**
    Gets an already unmarked bit and returns the bit index selected
    
    @param Data - The integer containing the bits that are being set
    @param StartIdx - The index to start with when determining the selection'
    @param NumBits - The logical number of bits we want to track
    @param bRandom - Whether to select a random index or not
    @return - The index that was selected (returns INDEX_NONE if there was no unmarked bits to choose from)
  **/
  @:ufunction static public function GetUnmarkedBit(Data : unreal.Int32, StartIdx : unreal.Int32, NumBits : unreal.Int32, bRandom : Bool) : unreal.Int32;
  
  /**
    Gets a random not already marked bit and returns the bit index selected
    
    @param Data - The integer containing the bits that are being set
    @param NumBits - The logical number of bits we want to track
    @return - The index that was selected (returns INDEX_NONE if there was no unmarked bits to choose from)
  **/
  @:ufunction static public function GetRandomUnmarkedBit(Data : unreal.Int32, StartIdx : unreal.Int32, NumBits : unreal.Int32) : unreal.Int32;
  
  /**
    Gets the first index not already marked starting from a specific index and returns the bit index selected
    
    @param Data - The integer containing the bits that are being set
    @param StartIdx - The index to start looking for an available index from
    @param NumBits - The logical number of bits we want to track
    @return - The index that was selected (returns INDEX_NONE if there was no unmarked bits to choose from)
  **/
  @:ufunction static public function GetFirstUnmarkedBit(Data : unreal.Int32, StartIdx : unreal.Int32, NumBits : unreal.Int32) : unreal.Int32;
  
  /**
    Gets enumerator name.
    
    @param Enum - Enumeration
    @param EnumeratorValue - Value of searched enumeration
    @return - name of the searched enumerator, or NAME_None
  **/
  @:ufunction static public function GetEnumeratorName(Enum : unreal.Const<unreal.UEnum>, EnumeratorValue : unreal.UInt8) : unreal.FName;
  
  /**
    Gets enumerator name as FString. Use DeisplayName when possible.
    
    @param Enum - Enumeration
    @param EnumeratorValue - Value of searched enumeration
    @return - name of the searched enumerator, or NAME_None
  **/
  @:ufunction static public function GetEnumeratorUserFriendlyName(Enum : unreal.Const<unreal.UEnum>, EnumeratorValue : unreal.UInt8) : unreal.FString;
  
  /**
    @param Enum - Enumeration
    @param EnumeratorIndex - Input value
    @return - if EnumeratorIndex is valid return EnumeratorIndex, otherwise return MAX value of Enum
  **/
  @:ufunction static public function GetValidValue(Enum : unreal.Const<unreal.UEnum>, EnumeratorValue : unreal.UInt8) : unreal.UInt8;
  
  /**
    @param Enum - Enumeration
    @param EnumeratorIndex - Input index
    @return - The value of the enumerator, or INDEX_NONE
  **/
  @:ufunction static public function GetEnumeratorValueFromIndex(Enum : unreal.Const<unreal.UEnum>, EnumeratorIndex : unreal.UInt8) : unreal.UInt8;
  
}