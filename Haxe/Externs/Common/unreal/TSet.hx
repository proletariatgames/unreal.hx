package unreal;

@:glueCppIncludes('Containers/Set.h')
@:uextern extern class TSet<T> {
  /**
   * Removes all elements from the set, potentially leaving space allocated for an expected number of elements about to be added.
   * @param ExpectedNumElements - The number of elements about to be added to the set.
   */
  function Empty(ExpectedNumElements:Int32 /* = 0 */):Void;

  /** Shrinks the set's element storage to avoid slack. */
  function Shrink():Void;

  /** Efficiently empties out the set but preserves all allocations and capacities */
  function Reset():Void;

  /** Compacts the allocated elements into a contiguous range. */
  function Compact():Void;

  /** Preallocates enough memory to contain Number elements */
  function Reserve(Number:Int32):Void;

  /**
   * Helper function to return the amount of memory allocated by this container
   * @return number of bytes allocated by this container
   */
  function GetAllocatedSize():FakeUInt32;

  /** @return the number of elements. */
  function Num():Int32;

  /**
   * Adds an element to the set.
   *
   * @param	InElement					Element to add to set
   * @return	A pointer to the element stored in the set.
   */
  function Add(InElement:Const<PRef<T>>):FSetElementId;

  /**
   * Removes an element from the set.
   * @param Element - A pointer to the element in the set, as returned by Add or Find.
   */
  function Remove(ElementId:FSetElementId):Void;

  @:uname('.ctor') static function create<T>():TSet<T>;
}
