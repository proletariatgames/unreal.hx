package unreal;

#if PLATFORM_XBOXONE
@:glueCppIncludes("XboxOne/XboxOneMisc.h")
@:uname("EXboxOneConsoleType")
@:class @:uextern extern enum EXboxOneConsoleType {
	Invalid;
	XboxOne;
	XboxOneS;
	Scorpio;
}
#end
