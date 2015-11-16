package unreal;

/** Adapted from UnrealNames.inl */
@:enum
abstract Names(Int) {
  // Special zero value, meaning no name.
  var None = 0;

  var ByteProperty                    = 1;
  var IntProperty                     = 2;
  var BoolProperty                    = 3;
  var FloatProperty                   = 4;
  var ObjectProperty                  = 5;
  var NameProperty                    = 6;
  var DelegateProperty                = 7;
  var ClassProperty                   = 8;
  var ArrayProperty                   = 9;
  var StructProperty                  = 10;
  var VectorProperty                  = 11;
  var RotatorProperty                 = 12;
  var StrProperty                     = 13;
  var TextProperty                    = 14;
  var InterfaceProperty               = 15;
  var MulticastDelegateProperty       = 16;
  var WeakObjectProperty              = 17;
  var LazyObjectProperty              = 18;
  var AssetObjectProperty             = 19;
  var UInt64Property                  = 20;
  var UInt32Property                  = 21;
  var UInt16Property                  = 22;
  var Int64Property                   = 23;
  var Int16Property                   = 25;
  var Int8Property                    = 26;
  var AssetSubclassOfProp             = 27;

  var Core = 30;
  var Engine = 31;
  var Editor = 32;
  var CoreUObject = 33;

  var Cylinder = 50;
  var BoxSphereBounds = 51;
  var Sphere = 52;
  var Box = 53;
  var Vector2D = 54;
  var IntRect = 55;
  var IntPoint = 56;
  var Vector4 = 57;
  var Name = 58;
  var Vector = 59;
  var Rotator = 60;
  var SHVector = 61;
  var Color = 62;
  var Plane = 63;
  var Matrix = 64;
  var LinearColor = 65;
  var AdvanceFrame = 66;
  var Pointer = 67;
  var Double = 68;
  var Quat = 69;
  var Self = 70;
  var Transform = 71;

  var Object = 100;
  var Camera = 101;
  var Actor = 102;
  var ObjectRedirector = 103;
  var ObjectArchetype = 104;
  var Class = 105;


  var State = 200;
  var TRUE = 201;
  var FALSE = 202;
  var Enum = 203;
  var Default = 204;
  var Skip = 205;
  var Input = 206;
  var Package = 207;
  var Groups = 208;
  var Interface = 209;
  var Components = 210;
  var Global = 211;
  var Super = 212;
  var Outer = 213;
  var Map = 214;
  var Role = 215;
  var RemoteRole = 216;
  var PersistentLevel = 217;
  var TheWorld = 218;
  var PackageMetaData = 219;
  var InitialState = 220;
  var Game = 221;
  var SelectionColor = 222;
  var UI = 223;
  var ExecuteUbergraph = 224;
  var DeviceID = 225;
  var RootStat = 226;
  var MoveActor = 227;
  var All = 230;
  var MeshEmitterVertexColor = 231;
  var TextureOffsetParameter = 232;
  var TextureScaleParameter = 233;
  var ImpactVel = 234;
  var SlideVel = 235;
  var TextureOffset1Parameter = 236;
  var MeshEmitterDynamicParameter = 237;
  var ExpressionInput = 238;
  var Untitled = 239;
  var Timer = 240;
  var Team = 241;
  var Low = 242;
  var High = 243;
  var NetworkGUID = 244;
  var GameThread = 245;
  var RenderThread = 246;
  var OtherChildren = 247;
  var Location = 248;
  var Rotation = 249;
  var BSP = 250;
  var EditorSettings = 251;


  var DGram = 280;
  var Stream = 281;
  var GameNetDriver = 282;
  var PendingNetDriver = 283;
  var BeaconNetDriver = 284;
  var FlushNetDormancy = 285;
  var DemoNetDriver = 286;

  var Linear = 300;
  var Point = 301;
  var Aniso = 302;
  var LightMapResolution = 303;


  var UnGrouped = 311;
  var VoiceChat = 312;

  var Playing = 320;
  var Spectating = 322;
  var Inactive = 325;

  var PerfWarning = 350;
  var Info = 351;
  var Init = 352;
  var Exit = 353;
  var Cmd = 354;
  var Warning = 355;
  var Error = 356;

  var FontCharacter = 400;
  var InitChild2StartBone = 401;
  var SoundCueLocalized = 402;
  var SoundCue = 403;
  var RawDistributionFloat = 404;
  var RawDistributionVector = 405;
  var InterpCurveFloat = 406;
  var InterpCurveVector2D = 407;
  var InterpCurveVector = 408;
  var InterpCurveTwoVectors = 409;
  var InterpCurveQuat = 410;

  var AI = 450;
  var NavMesh = 451;

  var PerformanceCapture = 500;

  var EditorLayout = 600;
  var EditorKeyBindings = 601;
}
