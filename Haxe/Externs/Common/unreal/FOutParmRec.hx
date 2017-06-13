package unreal;

@:glueCppIncludes("UObject/Stack.h")
@:uextern extern class FOutParmRec {
  public var Property:UProperty;
  public var PropAddr:ByteArray;
  public var NextOutParm:PPtr<FOutParmRec>;
}
