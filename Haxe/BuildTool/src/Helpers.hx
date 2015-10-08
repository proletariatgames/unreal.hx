import cs.system.collections.generic.List_1 as Lst;

class Helpers
{
  @:generic public static function addRange<T>(lst:Lst<T>, vals:Array<T>)
  {
    for (v in vals)
      lst.Add(v);
  }
}
