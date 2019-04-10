enum Result<T>
{
  Success(s:T);
  Error(err:js.Error);
}