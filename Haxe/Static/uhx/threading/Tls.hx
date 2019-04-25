package uhx.threading;
import uhx.ue.RuntimeLibrary;

class Tls<T> {
  public var value(get,set):T;
  private var slot:Int;

  public function new() {
    this.slot = RuntimeLibrary.allocTlsSlot();
  }

  #if !cppia
  inline
  #end
  private function get_value():T {
    var arr:Array<Dynamic> = uhx.internal.HaxeHelpers.pointerToDynamic(RuntimeLibrary.getTlsObj());
    return arr[this.slot];
  }

  #if !cppia
  inline
  #end
  private function set_value(val:T) {
    var arr:Array<Dynamic> = uhx.internal.HaxeHelpers.pointerToDynamic(RuntimeLibrary.getTlsObj());
    arr[this.slot] = val;
    return val;
  }
}