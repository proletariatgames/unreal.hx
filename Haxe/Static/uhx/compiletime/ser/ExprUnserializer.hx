package uhx.compiletime.ser;

class ExprUnserializer extends haxe.Unserializer {
  override function unserializeObject(o) {
    while( true ) {
      if( pos >= length )
        throw "Invalid object";
      if( get(pos) == "g".code )
        break;
      var k = unserialize();
      var v:Dynamic = unserialize();
      if (k == 'pos') {
        v = haxe.macro.Context.makePosition(v);
      }
      Reflect.setField(o,k,v);
    }
    pos++;
  }

  public static function run( v : String ) : Dynamic {
    return new ExprUnserializer(v).unserialize();
  }
}
