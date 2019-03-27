package unreal;

@:glueCppIncludes("Containers/Map.h")
@:uname("TMap")
@:noEquals
@:keep
@:uextern extern class TMap<K, V>
{
  @:uname('.ctor') static function create<K, V>():TMap<K, V>;
  @:uname('new') static function createNew<K, V>():POwnedPtr<TMap<K, V>>;
  public function Add(InKey:K, InValue:V):Void;
  @:arrayAccess public function FindOrAdd(Key:K):PRef<V>;
  @:arrayAccess
  public function set_Item(key:K, val:PRef<V>):Void;
  public function Contains(InKey:K):Bool;
  public function FindChecked(InKey:K):PRef<V>;
  public function Remove(InKey:K):Int32;
  public function Empty(ExpectedElements:Int32 = 0) : Void;

  @:ueHeaderCode('
    unreal::VariantPtr GenerateKeyArray(unreal::VariantPtr self) override {
      TArray<K> ret;
      ::uhx::TemplateHelper< TMap<K, V> >::getPointer(self)->GenerateKeyArray(ret);
      return ::uhx::TemplateHelper< TArray<K> >::fromStruct(ret);
    }
  ')
  public function GenerateKeyArray():TArray<K>;

  @:ueHeaderCode('
    unreal::VariantPtr GenerateValueArray(unreal::VariantPtr self) override {
      TArray<V> ret;
      ::uhx::TemplateHelper< TMap<K, V> >::getPointer(self)->GenerateValueArray(ret);
      return ::uhx::TemplateHelper< TArray<V> >::fromStruct(ret);
    }
  ')
  public function GenerateValueArray():TArray<V>;

  @:expr({
    var ret = GenerateValueArray(),
        len = ret.length;
    var i = 0;
    return {
      hasNext:function() {
        return i < len;
      },
      next:function() {
        return ret[i++];
      }
    };
  })
  public function iterator():Iterator<V>;

  @:expr({
    var ret = GenerateKeyArray(),
        len = ret.length;
    var i = 0;
    return {
      hasNext:function() {
        return i < len;
      },
      next:function() {
        return ret[i++];
      }
    };
  })
  public function keys():Iterator<K>;
}
