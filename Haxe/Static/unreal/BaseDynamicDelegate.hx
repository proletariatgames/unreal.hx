package unreal;

#if bake_externs
extern class BaseDynamicDelegate<T : haxe.Constraints.Function> extends FScriptDelegate {
}

#else
@:forward abstract BaseDynamicDelegate<T : haxe.Constraints.Function>(FScriptDelegate) to FScriptDelegate to Struct to VariantPtr {
  @:extern inline private function typingHelper(fn:T):BaseDynamicDelegate<T> {
    return cast this;
  }
}

#end
