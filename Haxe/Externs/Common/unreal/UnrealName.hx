package unreal;

@:glueCppIncludes("UnrealNames.h")
@:uextern @:uname("EName")
extern enum UnrealName {
  NAME_None;

  NAME_ByteProperty;
  NAME_IntProperty;
  NAME_BoolProperty;
  NAME_FloatProperty;
  NAME_ObjectProperty;
  NAME_NameProperty;
  NAME_DelegateProperty;
  NAME_ArrayProperty;
  NAME_StructProperty;
  NAME_VectorProperty;
  NAME_RotatorProperty;
  NAME_StrProperty;
  NAME_TextProperty;
  NAME_InterfaceProperty;
  NAME_MulticastDelegateProperty;
  NAME_LazyObjectProperty;
  NAME_UInt64Property;
  NAME_UInt32Property;
  NAME_UInt16Property;
  NAME_Int64Property;
  NAME_Int16Property;
  NAME_Int8Property;

  NAME_Core;
  NAME_Engine;
  NAME_Editor;
  NAME_CoreUObject;

  NAME_Cylinder;
  NAME_BoxSphereBounds;
  NAME_Sphere;
  NAME_Box;
  NAME_Vector2D;
  NAME_IntRect;
  NAME_IntPoint;
  NAME_Vector4;
  NAME_Name;
  NAME_Vector;
  NAME_Rotator;
  NAME_SHVector;
  NAME_Color;
  NAME_Plane;
  NAME_Matrix;
  NAME_LinearColor;
  NAME_AdvanceFrame;
  NAME_Pointer;
  NAME_Double;
  NAME_Quat;
  NAME_Self;
  NAME_Transform;

  NAME_Object;
  NAME_Camera;
  NAME_Actor;
  NAME_ObjectRedirector;
  NAME_ObjectArchetype;
  NAME_Class;


  NAME_State;
  NAME_TRUE;
  NAME_FALSE;
  NAME_Enum;
  NAME_Default;
  NAME_Skip;
  NAME_Input;
  NAME_Package;
  NAME_Groups;
  NAME_Interface;
  NAME_Components;
  NAME_Global;
  NAME_Super;
  NAME_Outer;
  NAME_Map;
  NAME_Role;
  NAME_RemoteRole;
  NAME_PersistentLevel;
  NAME_TheWorld;
  NAME_PackageMetaData;
  NAME_InitialState;
  NAME_Game;
  NAME_SelectionColor;
  NAME_UI;
  NAME_ExecuteUbergraph;
  NAME_DeviceID;
  NAME_RootStat;
  NAME_MoveActor;
  NAME_All;
  NAME_MeshEmitterVertexColor;
  NAME_TextureOffsetParameter;
  NAME_TextureScaleParameter;
  NAME_ImpactVel;
  NAME_SlideVel;
  NAME_TextureOffset1Parameter;
  NAME_MeshEmitterDynamicParameter;
  NAME_ExpressionInput;
  NAME_Untitled;
  NAME_Timer;
  NAME_Team;
  NAME_Low;
  NAME_High;
  NAME_NetworkGUID;
  NAME_GameThread;
  NAME_RenderThread;
  NAME_OtherChildren;
  NAME_Location;
  NAME_Rotation;
  NAME_BSP;
  NAME_EditorSettings;


  NAME_DGram;
  NAME_Stream;
  NAME_GameNetDriver;
  NAME_PendingNetDriver;
  NAME_BeaconNetDriver;
  NAME_FlushNetDormancy;
  NAME_DemoNetDriver;

  NAME_Linear;
  NAME_Point;
  NAME_Aniso;
  NAME_LightMapResolution;


  NAME_UnGrouped;
  NAME_VoiceChat;

  NAME_Playing;
  NAME_Spectating;
  NAME_Inactive;

  NAME_PerfWarning;
  NAME_Info;
  NAME_Init;
  NAME_Exit;
  NAME_Cmd;
  NAME_Warning;
  NAME_Error;

  NAME_FontCharacter;
  NAME_InitChild2StartBone;
  NAME_SoundCueLocalized;
  NAME_SoundCue;
  NAME_RawDistributionFloat;
  NAME_RawDistributionVector;
  NAME_InterpCurveFloat;
  NAME_InterpCurveVector2D;
  NAME_InterpCurveVector;
  NAME_InterpCurveTwoVectors;
  NAME_InterpCurveQuat;

  NAME_AI;
  NAME_NavMesh;

  NAME_PerformanceCapture;

  NAME_EditorLayout;
  NAME_EditorKeyBindings;

#if (UE_VER < 4.19)
  NAME_ClassProperty;
  NAME_WeakObjectProperty;
  NAME_AssetObjectProperty;
  NAME_AssetSubclassOfProperty;
#else
  NAME_GameSession;
  NAME_PartySession;
  NAME_GamePort;
  NAME_BeaconPort;
#end
}
