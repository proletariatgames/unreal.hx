package uhx.compiletime.ser;

class ExprSerializer extends haxe.Serializer {

  override function serializeFields(v:Dynamic) {
    for( f in Reflect.fields(v) ) {
      serializeString(f);
      if (f == 'pos') {
        serialize( haxe.macro.Context.getPosInfos(v.pos) );
      } else {
        serialize(Reflect.field(v,f));
      }
    }
    buf.add("g");
  }

  public static function run( v : Dynamic ) {
    var s = new ExprSerializer();
    s.serialize(v);
    return s.toString();
  }

}
