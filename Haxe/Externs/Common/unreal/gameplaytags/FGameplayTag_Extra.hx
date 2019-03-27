package unreal.gameplaytags;

extern class FGameplayTag_Extra
{
	public static var EmptyTag (get,never) : Const<FGameplayTag>;

	public function new();
	@:uname('.ctor') public static function create() : FGameplayTag;

	/**
	 * Gets the FGameplayTag that corresponds to the TagName
	 *
	 * @param TagName The Name of the tag to search for
	 * 
	 * @param ErrorIfNotfound: ensure() that tag exists.
	 * 
	 * @return Will return the corresponding FGameplayTag or an empty one if not found.
	 */
	public static function RequestGameplayTag(TagName:FName, ErrorIfNotFound:Bool =true) : FGameplayTag;

	/**
	 * Determine if this tag matches TagToCheck, expanding our parent tags
	 * "A.1".MatchesTag("A") will return True, "A".MatchesTag("A.1") will return False
	 * If TagToCheck is not Valid it will always return False
	 * 
	 * @return True if this tag matches TagToCheck
	 */
	@:thisConst
	public function MatchesTag(TagToCheck:Const<PRef<FGameplayTag>>) : Bool;

	/**
	 * Determine if TagToCheck is valid and exactly matches this tag
	 * "A.1".MatchesTagExact("A") will return False
	 * If TagToCheck is not Valid it will always return False
	 * 
	 * @return True if TagToCheck is Valid and is exactly this tag
	 */
	@:thisConst
	public function MatchesTagExact(TagToCheck:Const<PRef<FGameplayTag>>) : Bool;
	
	/**
	 * Check to see how closely two FGameplayTags match. Higher values indicate more matching terms in the tags.
	 *
	 * @param TagToCheck	Tag to match against
	 *
	 * @return The depth of the match, higher means they are closer to an exact match
	 */
	@:thisConst
	public function MatchesTagDepth(TagToCheck:Const<PRef<FGameplayTag>>) : Int32;

	/**
	 * Checks if this tag matches ANY of the tags in the specified container, also checks against our parent tags
	 * "A.1".MatchesAny({"A","B"}) will return True, "A".MatchesAny({"A.1","B"}) will return False
	 * If ContainerToCheck is empty/invalid it will always return False
	 *
	 * @return True if this tag matches ANY of the tags of in ContainerToCheck
	 */
	@:thisConst
	public function MatchesAny(ContainerToCheck:Const<PRef<FGameplayTagContainer>>) : Bool;

	/**
	 * Checks if this tag matches ANY of the tags in the specified container, only allowing exact matches
	 * "A.1".MatchesAny({"A","B"}) will return False
	 * If ContainerToCheck is empty/invalid it will always return False
	 *
	 * @return True if this tag matches ANY of the tags of in ContainerToCheck exactly
	 */
	@:thisConst
	public function MatchesAnyExact(ContainerToCheck:Const<PRef<FGameplayTagContainer>>) : Bool;

	/** Returns whether the tag is valid or not; Invalid tags are set to NAME_None and do not exist in the game-specific global dictionary */
	@:thisConst
	public function IsValid() : Bool;

	/** Returns reference to a GameplayTagContainer containing only this tag */
	@:thisConst
	public function GetSingleTagContainer() : Const<PRef<FGameplayTagContainer>>;

	/** Returns direct parent GameplayTag of this GameplayTag, calling on x.y will return x */
	@:thisConst
	public function RequestDirectParent() : FGameplayTag;

	/** Returns a new container explicitly containing the tags of this tag */
	@:thisConst
	public function GetGameplayTagParents() : FGameplayTagContainer;

	/** Displays gameplay tag as a string for blueprint graph usage */
	@:thisConst 
	public function ToString() : FString;

	/** Get the tag represented as a name */
	@:thisConst
	public function GetTagName() : FName;
}