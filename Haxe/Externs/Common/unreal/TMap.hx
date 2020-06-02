package unreal;

@:glueCppIncludes("Containers/Map.h")
@:uname("TMap")
@:noEquals
@:keep
@:uextern extern class TMap<K, V>
{
  @:uname('.ctor') static function create<K, V>():TMap<K, V>;
  @:uname('new') static function createNew<K, V>():POwnedPtr<TMap<K, V>>;
  @:arrayAccess public function Add(InKey:K, InValue:V):Void;
  @:arrayAccess public function FindOrAdd(Key:K):PRef<V>;
  public function Contains(InKey:K):Bool;
  public function FindChecked(InKey:K):PRef<V>;
  public function Remove(InKey:K):Int32;
  public function Empty(ExpectedElements:Int32 = 0) : Void;
  public function Num():Int32;

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
    var keyList = GenerateKeyArray();
    var valList = GenerateValueArray();
    var i = 0, len = keyList.length;
    return {
      hasNext:function() {
        return i < len;
      },
      next:function() {
        final ret = {
          key: keyList[i],
          value: valList[i],
        };
        i++;
        return ret;
      }
    };
  })
  public function keyValueIterator():KeyValueIterator<K, V>;

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
