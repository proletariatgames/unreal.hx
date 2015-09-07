package ue4hx.internal;

abstract GlueType(GlueTypeInfo) from GlueTypeInfo {
}

typedef GlueTypeInfo = {
  public var haxeType:TypeRef;
  public var cppType:TypeRef;
}
