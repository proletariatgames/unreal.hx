package uhx.internal;
import uhx.internal.ObjectArrayHelper_Glue;

#if !UHX_NO_UOBJECT
@:uextern
@:ueGluePath("uhx.internal.ObjectArrayHelper_Glue")
@:glueCppIncludes("UObject/UObjectArray.h")
@:keep
class ObjectArrayHelper implements uhx.NeedsGlue {
  @:glueHeaderCode('static unreal::UIntPtr indexToObject(int index);')
  @:glueCppCode('unreal::UIntPtr uhx::internal::ObjectArrayHelper_Glue_obj::indexToObject(int index) {\n\tauto ret = GUObjectArray.IndexToObject(index);\n\tif (ret == nullptr) return 0;\n\treturn (unreal::UIntPtr) ret->Object;\n}')
  @:glueCppIncludes('UObject/UObjectArray.h')
  @:glueHeaderIncludes('IntPtr.h')
  public static function indexToObject(idx:Int):unreal.UIntPtr {
    return ObjectArrayHelper_Glue.indexToObject(idx);
  }

  @:glueHeaderCode('static int indexToSerial(int index);')
  @:glueCppCode('int uhx::internal::ObjectArrayHelper_Glue_obj::indexToSerial(int index) {\n\tauto ret = GUObjectArray.IndexToObject(index);\n\tif (ret == nullptr) return 0;\n\treturn ret->SerialNumber;\n}')
  @:glueCppIncludes('UObject/UObjectArray.h')
  @:glueHeaderIncludes('IntPtr.h')
  public static function indexToSerial(idx:Int):Int {
    return ObjectArrayHelper_Glue.indexToSerial(idx);
  }

  @:glueHeaderCode('static int indexToSerialChecked(int index, unreal::UIntPtr obj);')
  @:glueCppCode('int uhx::internal::ObjectArrayHelper_Glue_obj::indexToSerialChecked(int index, unreal::UIntPtr obj) {\n\tauto ret = GUObjectArray.IndexToObject(index);\n\tif (ret == nullptr || ret->Object != (UObject*) obj || ret->IsUnreachable()) return -1;\n\treturn ret->SerialNumber;\n}')
  @:glueCppIncludes('UObject/UObjectArray.h')
  @:glueHeaderIncludes('IntPtr.h')
  public static function indexToSerialChecked(idx:Int, obj:unreal.UIntPtr):Int {
    return ObjectArrayHelper_Glue.indexToSerialChecked(idx, obj);
  }

  @:glueHeaderCode('static int indexToSerialReachable(int index, unreal::UIntPtr obj);')
  @:glueCppCode('int uhx::internal::ObjectArrayHelper_Glue_obj::indexToSerialReachable(int index, unreal::UIntPtr obj) {\n\tauto ret = GUObjectArray.IndexToObject(index);\n\tif (ret == nullptr || (ret->Object != (UObject *) obj) || ret->IsUnreachable()) return 0;\n\treturn ret->SerialNumber;\n}')
  @:glueCppIncludes('UObject/UObjectArray.h')
  @:glueHeaderIncludes('IntPtr.h')
  public static function indexToSerialReachable(idx:Int, obj:unreal.UIntPtr):Int {
    return ObjectArrayHelper_Glue.indexToSerialReachable(idx, obj);
  }

  @:glueHeaderCode('static int objectToIndex(unreal::UIntPtr obj);')
  @:glueCppCode('int uhx::internal::ObjectArrayHelper_Glue_obj::objectToIndex(unreal::UIntPtr obj) {\n\treturn GUObjectArray.ObjectToIndex((const class UObjectBase *) obj);\n}')
  @:glueCppIncludes('UObject/UObjectArray.h')
  @:glueHeaderIncludes('IntPtr.h')
  public static function objectToIndex(obj:unreal.UIntPtr):Int {
    return ObjectArrayHelper_Glue.objectToIndex(obj);
  }

  @:glueHeaderCode('static int allocateSerialNumber(int index);')
  @:glueCppCode('int uhx::internal::ObjectArrayHelper_Glue_obj::allocateSerialNumber(int index) {\n\treturn GUObjectArray.AllocateSerialNumber(index);\n}')
  @:glueCppIncludes('UObject/UObjectArray.h')
  @:glueHeaderIncludes('IntPtr.h')
  public static function allocateSerialNumber(idx:Int):Int {
    return ObjectArrayHelper_Glue.allocateSerialNumber(idx);
  }

  @:glueHeaderCode('static int isValid(unreal::UIntPtr obj, int index, int serial, bool evenIfPendingKill);')
  @:glueCppCode(
'int uhx::internal::ObjectArrayHelper_Glue_obj::isValid(unreal::UIntPtr obj, int index, int serial, bool evenIfPendingKill) {
\tFUObjectItem* ObjectItem = GUObjectArray.IndexToObject(index);
\tif(!ObjectItem || ((unreal::UIntPtr) ObjectItem->Object) != obj || ObjectItem->GetSerialNumber() != serial) { return false; }
\treturn evenIfPendingKill ? !ObjectItem->IsUnreachable() : !(ObjectItem->IsUnreachable() || ObjectItem->IsPendingKill());
}')
  @:glueCppIncludes('UObject/UObjectArray.h')
  public static function isValid(obj:unreal.UIntPtr, index:Int, serial:Int, evenIfPendingKill:Bool):Bool {
    return ObjectArrayHelper_Glue.isValid(obj, index, serial, evenIfPendingKill);
  }

  @:glueHeaderCode('static bool setObjectFlags(int index, int flags);')
  @:glueCppCode('bool uhx::internal::ObjectArrayHelper_Glue_obj::setObjectFlags(int index, int flags) {\n\tauto item = GUObjectArray.IndexToObject(index);\n\tif(item == nullptr) return false;\n\titem->SetFlags((EInternalObjectFlags) flags);\n\treturn true;\n}')
  @:glueCppIncludes('UObject/UObjectArray.h')
  @:glueHeaderIncludes('IntPtr.h')
  public static function setObjectFlags(idx:Int, flags:unreal.EInternalObjectFlags):Bool {
    return ObjectArrayHelper_Glue.setObjectFlags(idx, flags);
  }

  @:glueHeaderCode('static bool clearObjectFlags(int index, int flags);')
  @:glueCppCode('bool uhx::internal::ObjectArrayHelper_Glue_obj::clearObjectFlags(int index, int flags) {\n\tauto item = GUObjectArray.IndexToObject(index);\n\tif(item == nullptr) return false;\n\titem->ClearFlags((EInternalObjectFlags) flags);\n\treturn true;\n}')
  @:glueCppIncludes('UObject/UObjectArray.h')
  @:glueHeaderIncludes('IntPtr.h')
  public static function clearObjectFlags(idx:Int, flags:unreal.EInternalObjectFlags):Bool {
    return ObjectArrayHelper_Glue.clearObjectFlags(idx, flags);
  }

  @:glueHeaderCode('static int getObjectFlags(int index);')
  @:glueCppCode('int uhx::internal::ObjectArrayHelper_Glue_obj::getObjectFlags(int index) {\n\tauto item = GUObjectArray.IndexToObject(index);\n\tif(item == nullptr) return 0;\n\treturn (int) item->Flags;\n}')
  @:glueCppIncludes('UObject/UObjectArray.h')
  @:glueHeaderIncludes('IntPtr.h')
  public static function getObjectFlags(idx:Int):unreal.EInternalObjectFlags {
    return ObjectArrayHelper_Glue.getObjectFlags(idx);
  }
}
#end
