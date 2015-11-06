package unreal;

/**
 * The network mode the game is currently running.
 * @see https://docs.unrealengine.com/latest/INT/Gameplay/Networking/Replication/
 */
@:glueCppIncludes("Engine/EngineTypes.h")
@:uname("ENetMode")
@:uextern extern enum ENetMode {
	/** Standalone: a game without networking, with one or more local players. Still considered a server because it has all server functionality. */
	NM_Standalone;

	/** Dedicated server: server with no local players. */
	NM_DedicatedServer;

	/** Listen server: a server that also has a local player who is hosting the game; available to other players on the network. */
	NM_ListenServer;

	/**
	 * Network client: client connected to a remote server.
	 * Note that every mode less than this value is a kind of server; so checking NetMode < NM_Client is always some variety of server.
	 */
	NM_Client;

	NM_MAX;
}