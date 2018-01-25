package uhx.ue;
import unreal.*;

class RuntimeLibraryDynamic {
  public static function createDynamicWrapperFromStruct(inStruct:UIntPtr):VariantPtr {
		return RuntimeLibrary.createDynamicWrapperFromStruct(inStruct);
	}
}