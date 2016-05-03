package unreal.helpers;
import unreal.helpers.ObjectArrayHelper_Glue;

@:uextern
@:ueGluePath("unreal.helpers.ObjectArrayHelper_Glue")
@:glueCppIncludes("UObject/UObjectArray.h")
// @:ueCppDef("DECLARE_LOG_CATEGORY_EXTERN(HaxeLog, Log, All);\nDEFINE_LOG_CATEGORY(HaxeLog)")
class ObjectArrayHelper implements ue4hx.internal.NeedsGlue {
  @:glueHeaderCode('static void *indexToObject(int index);')
  @:glueCppCode('unreal::UIntPtr unreal::helpers::ObjectArrayHelper_Glue_obj::indexToObject(int index) {\n\tauto ret = GUObjectArray.IndexToObject(index);\n\tif (ret == nullptr) return nullptr;\n\treturn (unreal::UIntPtr) ret->Object;\n}')
  @:glueCppIncludes('UObject/UObjectArray.h')
  // @:glueHeaderIncludes('<hxcpp.h>')
  public static function indexToObject(idx:Int):unreal.UIntPtr {
    return ObjectArrayHelper_Glue.indexToObject(idx);
  }

  @:glueHeaderCode('static int indexToSerial(int index);')
  @:glueCppCode('int unreal::helpers::ObjectArrayHelper_Glue_obj::indexToSerial(int index) {\n\tauto ret = GUObjectArray.IndexToObject(index);\n\tif (ret == nullptr) return 0;\n\treturn ret->SerialNumber;\n}')
  @:glueCppIncludes('UObject/UObjectArray.h')
  // @:glueHeaderIncludes('<hxcpp.h>')
  public static function indexToSerial(idx:Int):Int {
    return ObjectArrayHelper_Glue.indexToSerial(idx);
  }

  @:glueHeaderCode('static int objectToIndex(void *obj);')
  @:glueCppCode('int unreal::helpers::ObjectArrayHelper_Glue_obj::objectToIndex(unreal::UIntPtr obj) {\n\treturn GUObjectArray.ObjectToIndex((const class UObjectBase *) obj);\n}')
  @:glueCppIncludes('UObject/UObjectArray.h')
  // @:glueHeaderIncludes('<hxcpp.h>')
  public static function objectToIndex(obj:unreal.UIntPtr):Int {
    return ObjectArrayHelper_Glue.objectToIndex(obj.rawCast());
  }

  @:glueHeaderCode('static int allocateSerialNumber(int index);')
  @:glueCppCode('int unreal::helpers::ObjectArrayHelper_Glue_obj::allocateSerialNumber(int index) {\n\treturn GUObjectArray.AllocateSerialNumber(index);\n}')
  @:glueCppIncludes('UObject/UObjectArray.h')
  // @:glueHeaderIncludes('<hxcpp.h>')
  public static function allocateSerialNumber(idx:Int):Int {
    return ObjectArrayHelper_Glue.allocateSerialNumber(idx);
  }
}
