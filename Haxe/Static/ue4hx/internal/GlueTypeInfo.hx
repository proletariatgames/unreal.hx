package ue4hx.internal;
import haxe.macro.Type;

class GlueTypeInfo
{
  public var type(default,null):Type;
  public function new(t:Type)
  {
    this.type = t;
  }
}
