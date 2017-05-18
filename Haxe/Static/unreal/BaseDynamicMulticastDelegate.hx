package unreal;

#if bake_externs
extern class BaseDynamicMulticastDelegate<T : haxe.Constraints.Function> extends FMulticastScriptDelegate {
}

#else
@:forward abstract BaseDynamicMulticastDelegate<T : haxe.Constraints.Function>(FMulticastScriptDelegate) to FMulticastScriptDelegate to Struct to VariantPtr {
  @:extern inline private function typingHelper(fn:T):BaseDynamicMulticastDelegate<T> {
    return cast this;
  }
}

#end
