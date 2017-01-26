package unreal.httpretrysystem;
import unreal.IHttpRequest;

/**
 * class FRequest is what the retry system accepts as inputs
 */
@:glueCppIncludes('HttpRetrySystem.h')
@:uname('FHttpRetrySystem.FRequest')
@:noCreate @:noCopy
@:uextern extern class FRequest extends IHttpRequest {
  @:thisConst
  public function GetRetryStatus() : EStatus;
}
