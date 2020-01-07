package unreal.onlinesubsystem;


@:umodule("OnlineSubsystem")
@:glueCppIncludes("OnlineSubsystemTypes.h")
@:uname("EOnlineEnvironment.Type")
@:uextern extern enum EOnlineEnvironmentType {
	/** Dev environment */
	Development;
	/** Cert environment */
	Certification;
	/** Prod environment */
	Production;
	/** Not determined yet */
	Unknown;
}
