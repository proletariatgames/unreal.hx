package unreal;

extern class FFastArraySerializer_Extra
{
	@:uproperty public function MarkItemDirty(Item:FFastArraySerializerItem):Void;
	@:uproperty public function MarkArrayDirty():Void;
}
