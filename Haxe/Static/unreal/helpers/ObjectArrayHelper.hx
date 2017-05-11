package unreal.helpers;
import unreal.helpers.ObjectArrayHelper_Glue;

#if !UHX_NO_UOBJECT
@:uextern
@:ueGluePath("unreal.helpers.ObjectArrayHelper_Glue")
@:glueCppIncludes("UObject/UObjectArray.h")
@:keep
class ObjectArrayHelper implements uhx.NeedsGlue {
  @:glueHeaderCode('static unreal::UIntPtr indexToObject(int index);')
  @:glueCppCode('unreal::UIntPtr unreal::helpers::ObjectArrayHelper_Glue_obj::indexToObject(int index) {\n\tauto ret = GUObjectArray.IndexToObject(index);\n\tif (ret == nullptr) return 0;\n\treturn (unreal::UIntPtr) ret->Object;\n}')
  @:glueCppIncludes('UObject/UObjectArray.h')
  @:glueHeaderIncludes('IntPtr.h')
  public static function indexToObject(idx:Int):unreal.UIntPtr {
    return ObjectArrayHelper_Glue.indexToObject(idx);
  }

  @:glueHeaderCode('static int indexToSerial(int index);')
  @:glueCppCode('int unreal::helpers::ObjectArrayHelper_Glue_obj::indexToSerial(int index) {\n\tauto ret = GUObjectArray.IndexToObject(index);\n\tif (ret == nullptr) return 0;\n\treturn ret->SerialNumber;\n}')
  @:glueCppIncludes('UObject/UObjectArray.h')
  @:glueHeaderIncludes('IntPtr.h')
  public static function indexToSerial(idx:Int):Int {
    return ObjectArrayHelper_Glue.indexToSerial(idx);
  }

  @:glueHeaderCode('static int indexToSerialPendingKill(int index);')
  @:glueCppCode('int unreal::helpers::ObjectArrayHelper_Glue_obj::indexToSerialPendingKill(int index) {\n\tauto ret = GUObjectArray.IndexToObject(index);\n\tif (ret == nullptr || ret->IsPendingKill() || ret->IsUnreachable()) return 0;\n\treturn ret->SerialNumber;\n}')
  @:glueCppIncludes('UObject/UObjectArray.h')
  @:glueHeaderIncludes('IntPtr.h')
  public static function indexToSerialPendingKill(idx:Int):Int {
    return ObjectArrayHelper_Glue.indexToSerialPendingKill(idx);
  }

  @:glueHeaderCode('static int objectToIndex(unreal::UIntPtr obj);')
  @:glueCppCode('int unreal::helpers::ObjectArrayHelper_Glue_obj::objectToIndex(unreal::UIntPtr obj) {\n\treturn GUObjectArray.ObjectToIndex((const class UObjectBase *) obj);\n}')
  @:glueCppIncludes('UObject/UObjectArray.h')
  @:glueHeaderIncludes('IntPtr.h')
  public static function objectToIndex(obj:unreal.UIntPtr):Int {
    return ObjectArrayHelper_Glue.objectToIndex(obj);
  }

  @:glueHeaderCode('static int allocateSerialNumber(int index);')
  @:glueCppCode('int unreal::helpers::ObjectArrayHelper_Glue_obj::allocateSerialNumber(int index) {\n\treturn GUObjectArray.AllocateSerialNumber(index);\n}')
  @:glueCppIncludes('UObject/UObjectArray.h')
  @:glueHeaderIncludes('IntPtr.h')
  public static function allocateSerialNumber(idx:Int):Int {
    return ObjectArrayHelper_Glue.allocateSerialNumber(idx);
  }

  @:glueHeaderCode('static int isValid(int index, int serial, bool evenIfPendingKill);')
  @:glueCppCode(
'int unreal::helpers::ObjectArrayHelper_Glue_obj::isValid(int index, int serial, bool evenIfPendingKill) {
\tFUObjectItem* ObjectItem = GUObjectArray.IndexToObject(index);
\tif(!ObjectItem) { return false; }
\tif(ObjectItem->GetSerialNumber() != serial) { return false; }
\treturn GUObjectArray.IsValid(ObjectItem, evenIfPendingKill);
}')
  @:glueCppIncludes('UObject/UObjectArray.h')
  public static function isValid(index:Int, serial:Int, evenIfPendingKill:Bool):Bool {
    return ObjectArrayHelper_Glue.isValid(index, serial, evenIfPendingKill);
  }

  @:glueHeaderCode('static bool setObjectFlags(int index, int flags);')
  @:glueCppCode('bool unreal::helpers::ObjectArrayHelper_Glue_obj::setObjectFlags(int index, int flags) {\n\tauto item = GUObjectArray.IndexToObject(index);\n\tif(item == nullptr) return false;\n\titem->SetFlags((EInternalObjectFlags) flags);\n\treturn true;\n}')
  @:glueCppIncludes('UObject/UObjectArray.h')
  @:glueHeaderIncludes('IntPtr.h')
  public static function setObjectFlags(idx:Int, flags:unreal.EInternalObjectFlags):Bool {
    return ObjectArrayHelper_Glue.setObjectFlags(idx, flags);
  }

  @:glueHeaderCode('static bool clearObjectFlags(int index, int flags);')
  @:glueCppCode('bool unreal::helpers::ObjectArrayHelper_Glue_obj::clearObjectFlags(int index, int flags) {\n\tauto item = GUObjectArray.IndexToObject(index);\n\tif(item == nullptr) return false;\n\titem->ClearFlags((EInternalObjectFlags) flags);\n\treturn true;\n}')
  @:glueCppIncludes('UObject/UObjectArray.h')
  @:glueHeaderIncludes('IntPtr.h')
  public static function clearObjectFlags(idx:Int, flags:unreal.EInternalObjectFlags):Bool {
    return ObjectArrayHelper_Glue.clearObjectFlags(idx, flags);
  }

  @:glueHeaderCode('static int getObjectFlags(int index);')
  @:glueCppCode('int unreal::helpers::ObjectArrayHelper_Glue_obj::getObjectFlags(int index) {\n\tauto item = GUObjectArray.IndexToObject(index);\n\tif(item == nullptr) return 0;\n\treturn (int) item->Flags;\n}')
  @:glueCppIncludes('UObject/UObjectArray.h')
  @:glueHeaderIncludes('IntPtr.h')
  public static function getObjectFlags(idx:Int):unreal.EInternalObjectFlags {
    return ObjectArrayHelper_Glue.getObjectFlags(idx);
  }
}
#end
