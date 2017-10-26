package unreal;

#if (UE_VER >= 4.16)
extern class UEnumProperty_Extra {
  public function GetUnderlyingProperty():UNumericProperty;
  public function GetEnum():UEnum;
#if (UE_VER >= 4.18)
  public function SetEnum(InEnum:UEnum):Void;
#end
}
#end