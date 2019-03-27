package uhx;

/**
  You can implement this interface to support live reload in a non-UObject derived class
**/
#if (WITH_LIVE_RELOAD || cppia || WITH_CPPIA)
@:build(uhx.compiletime.LiveReloadBuild.injectPrologues())
#end
interface LiveReload {
}
