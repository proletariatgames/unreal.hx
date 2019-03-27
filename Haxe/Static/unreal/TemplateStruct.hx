package unreal;

@:forward(dispose, toString)
abstract TemplateStruct(Struct) to Struct to VariantPtr {
  #if (!cppia && !debug) inline #end private function getTemplateStruct():unreal.Wrapper.TemplateWrapper {
#if debug
    if ( !(untyped this : VariantPtr).isObject() || !Std.is((untyped this : VariantPtr).getDynamic(), unreal.Wrapper.TemplateWrapper) ) {
      trace('Fatal', 'Assert failure: `this` is not a TemplateWrapper: $this');
    }
#end
    return untyped __cpp__('::hx::ObjectPtr< ::unreal::TemplateWrapper_obj >( (::unreal::TemplateWrapper_obj *) {0}.getGcPointerUnchecked() )', this);
  }
}
