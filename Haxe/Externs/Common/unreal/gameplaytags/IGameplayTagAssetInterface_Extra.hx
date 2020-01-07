package unreal.gameplaytags;

extern class IGameplayTagAssetInterface_Extra {

	@:thisConst
	public function HasMatchingGameplayTag(TagToCheck:FGameplayTag) : Bool;
	@:thisConst
	public function HasAllMatchingGameplayTags(TagContainer:Const<PRef<FGameplayTagContainer>>) : Bool;
	@:thisConst
	public function HasAnyMatchingGameplayTags(TagContainer:Const<PRef<FGameplayTagContainer>>) : Bool;

}
