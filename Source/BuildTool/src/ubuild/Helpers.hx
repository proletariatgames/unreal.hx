package ubuild;

class Helpers
{
  @:generic public static function addRange<T>(lst:cs.system.collections.generic.List_1<T>, vals:Array<T>)
  {
    for (v in vals)
      lst.Add(v);
  }
}
