package unreal.gameplaytags;

extern class FGameplayTagContainer_Extra
{
	public function new();
	@:uname('.ctor') public static function createEmpty() : FGameplayTagContainer;
  	@:uname('.ctor') public static function createFromTag(Tag:Const<PRef<FGameplayTag>>) : FGameplayTagContainer;

	public static function CreateFromArray(SourceTags:Const<PRef<TArray<FGameplayTag>>>) : FGameplayTagContainer;
	public static var EmptyContainer(get, never) : Const<FGameplayTagContainer>;

	/**
	 * Determine if TagToCheck is present in this container, also checking against parent tags
	 * {"A.1"}.HasTag("A") will return True, {"A"}.HasTag("A.1") will return False
	 * If TagToCheck is not Valid it will always return False
	 * 
	 * @return True if TagToCheck is in this container, false if it is not
	 */
	@:thisConst
	public function HasTag(TagToCheck:Const<PRef<FGameplayTag>>) : Bool;

	/**
	 * Determine if TagToCheck is explicitly present in this container, only allowing exact matches
	 * {"A.1"}.HasTagExact("A") will return False
	 * If TagToCheck is not Valid it will always return False
	 * 
	 * @return True if TagToCheck is in this container, false if it is not
	 */
	@:thisConst
	public function HasTagExact(TagToCheck:Const<PRef<FGameplayTag>>) : Bool;

	/**
	 * Checks if this container contains ANY of the tags in the specified container, also checks against parent tags
	 * {"A.1"}.HasAny({"A","B"}) will return True, {"A"}.HasAny({"A.1","B"}) will return False
	 * If ContainerToCheck is empty/invalid it will always return False
	 *
	 * @return True if this container has ANY of the tags of in ContainerToCheck
	 */
	@:thisConst
	public function HasAny(ContainerToCheck:Const<PRef<FGameplayTagContainer>>) : Bool;

	/**
	 * Checks if this container contains ANY of the tags in the specified container, only allowing exact matches
	 * {"A.1"}.HasAny({"A","B"}) will return False
	 * If ContainerToCheck is empty/invalid it will always return False
	 *
	 * @return True if this container has ANY of the tags of in ContainerToCheck
	 */
	@:thisConst
	public function HasAnyExact(ContainerToCheck:Const<PRef<FGameplayTagContainer>>) : Bool;

	/**
	 * Checks if this container contains ALL of the tags in the specified container, also checks against parent tags
	 * {"A.1","B.1"}.HasAll({"A","B"}) will return True, {"A","B"}.HasAll({"A.1","B.1"}) will return False
	 * If ContainerToCheck is empty/invalid it will always return True, because there were no failed checks
	 *
	 * @return True if this container has ALL of the tags of in ContainerToCheck, including if ContainerToCheck is empty
	 */
	@:thisConst
	public function HasAll(ContainerToCheck:Const<PRef<FGameplayTagContainer>>) : Bool;

	/**
	 * Checks if this container contains ALL of the tags in the specified container, only allowing exact matches
	 * {"A.1","B.1"}.HasAll({"A","B"}) will return False
	 * If ContainerToCheck is empty/invalid it will always return True, because there were no failed checks
	 *
	 * @return True if this container has ALL of the tags of in ContainerToCheck, including if ContainerToCheck is empty
	 */
	@:thisConst
	public function HasAllExact(ContainerToCheck:Const<PRef<FGameplayTagContainer>>) : Bool;

	/** Returns the number of explicitly added tags */
	@:thisConst
	public function Num() : Int32;

	/** Returns whether the container has any valid tags */
	@:thisConst
	public function IsValid() : Bool;

	/** Returns true if container is empty */
	@:thisConst
	public function IsEmpty() : Bool;

	/** Returns a new container explicitly containing the tags of this container and all of their parent tags */
	@:thisConst
	public function GetGameplayTagParents() : FGameplayTagContainer;

	/**
	 * Returns a filtered version of this container, returns all tags that match against any of the tags in OtherContainer, expanding parents
	 *
	 * @param OtherContainer		The Container to filter against
	 *
	 * @return A FGameplayTagContainer containing the filtered tags
	 */
	@:thisConst
	public function Filter(OtherContainer:Const<PRef<FGameplayTagContainer>>) : FGameplayTagContainer;

	/**
	 * Returns a filtered version of this container, returns all tags that match exactly one in OtherContainer
	 *
	 * @param OtherContainer		The Container to filter against
	 *
	 * @return A FGameplayTagContainer containing the filtered tags
	 */
	@:thisConst
	public function FilterExact(OtherContainer:Const<PRef<FGameplayTagContainer>>) : FGameplayTagContainer;

	/** 
	 * Checks if this container matches the given query.
	 *
	 * @param Query		Query we are checking against
	 *
	 * @return True if this container matches the query, false otherwise.
	 */
	@:thisConst
	public function MatchesQuery(Query:Const<PRef<FGameplayTagQuery>>) : Bool;

	/** 
	 * Adds all the tags from one container to this container 
	 * NOTE: From set theory, this effectively is the union of the container this is called on with Other.
	 *
	 * @param Other TagContainer that has the tags you want to add to this container 
	 */
	public function AppendTags(Other:Const<PRef<FGameplayTagContainer>>) : Void;

	/** 
	 * Adds all the tags that match between the two specified containers to this container.  WARNING: This matches any
	 * parent tag in A, not just exact matches!  So while this should be the union of the container this is called on with
	 * the intersection of OtherA and OtherB, it's not exactly that.  Since OtherB matches against its parents, any tag
	 * in OtherA which has a parent match with a parent of OtherB will count.  For example, if OtherA has Color.Green
	 * and OtherB has Color.Red, that will count as a match due to the Color parent match!
	 * If you want an exact match, you need to call A.FilterExact(B) (above) to get the intersection of A with B.
	 * If you need the disjunctive union (the union of two sets minus their intersection), use AppendTags to create
	 * Union, FilterExact to create Intersection, and then call Union.RemoveTags(Intersection).
	 *
	 * @param OtherA TagContainer that has the matching tags you want to add to this container, these tags have their parents expanded
	 * @param OtherB TagContainer used to check for matching tags.  If the tag matches on any parent, it counts as a match.
	 */
	public function AppendMatchingTags(OtherA:Const<PRef<FGameplayTagContainer>>, OtherB:Const<PRef<FGameplayTagContainer>>) : Void;

	/**
	 * Add the specified tag to the container
	 *
	 * @param TagToAdd Tag to add to the container
	 */
	public function AddTag(TagToAdd:Const<PRef<FGameplayTag>>) : Void;

	/**
	 * Add the specified tag to the container without checking for uniqueness
	 *
	 * @param TagToAdd Tag to add to the container
	 * 
	 * Useful when building container from another data struct (TMap for example)
	 */
	public function AddTagFast(TagToAdd:Const<PRef<FGameplayTag>>) : Void;

	/**
	 * Adds a tag to the container and removes any direct parents, wont add if child already exists
	 *
	 * @param Tag			The tag to try and add to this container
	 * 
	 * @return True if tag was added
	 */
	public function AddLeafTag(TagToAdd:Const<PRef<FGameplayTag>>) : Bool;

	/**
	 * Tag to remove from the container
	 * 
	 * @param TagToRemove	Tag to remove from the container
	 */
	public function RemoveTag(TagToRemove:FGameplayTag) : Bool;

	/**
	 * Removes all tags in TagsToRemove from this container
	 *
	 * @param TagsToRemove	Tags to remove from the container
	 */
	public function RemoveTags(TagsToRemove:FGameplayTagContainer) : Void;

	/** Remove all tags from the container. Will maintain slack by default */
	public function Reset(Slack:Int32 = 0) : Void;

	/** Returns string version of container in ImportText format */
	@:thisConst
	public function ToString() : FString;
	
	/** Returns abbreviated human readable Tag list without parens or property names. If bQuoted is true it will quote each tag */
	@:thisConst
	public function ToStringSimple(bQuoted:Bool = false) : FString;
	
	/** Gets the explicit list of gameplay tags */
	@:thisConst
	public function GetGameplayTagArray(InOutGameplayTags:PRef<TArray<FGameplayTag>>) : Void;
	@:thisConst
	public function IsValidIndex(Index:Int32) : Bool;
	@:thisConst
	public function GetByIndex(Index:Int32) : FGameplayTag;

	@:thisConst
	public function First() : FGameplayTag;
	@:thisConst
	public function Last() : FGameplayTag;
}