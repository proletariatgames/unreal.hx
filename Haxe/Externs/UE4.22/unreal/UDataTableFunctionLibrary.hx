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

@:glueCppIncludes("Kismet/DataTableFunctionLibrary.h")
@:uextern @:uclass extern class UDataTableFunctionLibrary extends unreal.UBlueprintFunctionLibrary {
  @:ufunction(BlueprintCallable) static public function EvaluateCurveTableRow(CurveTable : unreal.UCurveTable, RowName : unreal.FName, InXY : unreal.Float32, OutResult : unreal.Ref<unreal.EEvaluateCurveTableResult>, OutXY : unreal.Float32, ContextString : unreal.FString) : Void;

  /**
    Returns whether or not Table contains a row named RowName
  **/
  @:ufunction(BlueprintCallable) static public function DoesDataTableRowExist(Table : unreal.UDataTable, RowName : unreal.FName) : Bool;
  @:ufunction(BlueprintCallable) static public function GetDataTableRowNames(Table : unreal.UDataTable, OutRowNames : unreal.PRef<unreal.TArray<unreal.FName>>) : Void;

  /**
    Export from the DataTable all the row for one column. Export it as string. The row name is not included.
  **/
  @:ufunction(BlueprintCallable) static public function GetDataTableColumnAsString(DataTable : unreal.Const<unreal.UDataTable>, PropertyName : unreal.FName) : unreal.TArray<unreal.FString>;

  /**
    Get a Row from a DataTable given a RowName
  **/
  @:ufunction(BlueprintCallable) static public function GetDataTableRowFromName(Table : unreal.UDataTable, RowName : unreal.FName, OutRow : unreal.PRef<unreal.FTableRowBase>) : Bool;
  #if WITH_EDITOR

  /**
    Empty and fill a Data Table from CSV string.
    @param       CSVString       The Data that representing the contents of a CSV file.
    @return      True if the operation succeeds, check the log for errors if it didn't succeed.
  **/
  @:ufunction(BlueprintCallable) static public function FillDataTableFromCSVString(DataTable : unreal.UDataTable, CSVString : unreal.FString) : Bool;

  /**
    Empty and fill a Data Table from CSV file.
    @param       CSVFilePath     The file path of the CSV file.
    @return      True if the operation succeeds, check the log for errors if it didn't succeed.
  **/
  @:ufunction(BlueprintCallable) static public function FillDataTableFromCSVFile(DataTable : unreal.UDataTable, CSVFilePath : unreal.FString) : Bool;

  /**
    Empty and fill a Data Table from JSON string.
    @param       JSONString      The Data that representing the contents of a JSON file.
    @return      True if the operation succeeds, check the log for errors if it didn't succeed.
  **/
  @:ufunction(BlueprintCallable) static public function FillDataTableFromJSONString(DataTable : unreal.UDataTable, JSONString : unreal.FString) : Bool;

  /**
    Empty and fill a Data Table from JSON file.
    @param       JSONFilePath    The file path of the JSON file.
    @return      True if the operation succeeds, check the log for errors if it didn't succeed.
  **/
  @:ufunction(BlueprintCallable) static public function FillDataTableFromJSONFile(DataTable : unreal.UDataTable, JSONFilePath : unreal.FString) : Bool;
  #end // WITH_EDITOR

}