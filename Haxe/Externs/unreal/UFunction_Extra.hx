package unreal;

extern class UFunction_Extra {
  var NumParms:UInt8;
  var ParmsSize:UInt16;
  var ReturnValueOffset:UInt16;
  var FunctionFlags:EFunctionFlags;
  var FirstPropertyToInit:UProperty;

  function HasAnyFunctionFlags(FlagsToCheck:EFunctionFlags):Bool;
  function HasAllFunctionFlags(FlagsToCheck:EFunctionFlags):Bool;
}
