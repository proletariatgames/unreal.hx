package uhx.ue;
import unreal.*;

class RuntimeLibraryDynamic {
  public static function createDynamicWrapperFromStruct(inStruct:UIntPtr):VariantPtr {
		return RuntimeLibrary.createDynamicWrapperFromStruct(inStruct);
	}

	public static function getAndFlushPrintf():String {
		return uhx.internal.HaxeHelpers.pointerToDynamic(PrintfHelper.getAndFlush());
	}
}