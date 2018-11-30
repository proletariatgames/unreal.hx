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
package unreal;

/**
  Handle to a particular row in a table
**/
@:glueCppIncludes("Classes/Engine/DataTable.h")
@:uextern @:ustruct extern class FDataTableRowHandle {
  
  /**
    Name of row in the table that we want
  **/
  @:uproperty public var RowName : unreal.FName;
  
  /**
    Pointer to table we want a row from
  **/
  @:uproperty public var DataTable : unreal.UDataTable;
  
}