package unreal;

@:glueCppIncludes("Misc/FileHelper.h")
@:uname("FFileHelper.EEncodingOptions")
@:class
@:uextern extern enum EEncodingOptions {
	AutoDetect;
	ForceAnsi;
	ForceUnicode;
	ForceUTF8;
	ForceUTF8WithoutBOM;
}
