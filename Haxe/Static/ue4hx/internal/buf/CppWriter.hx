package ue4hx.internal.buf;

class CppWriter extends BaseWriter {

  public function new(path) {
    super(path);
  }

  override private function getContents(module:String):String {
    var bufContents = this.buf.toString();
    if (bufContents == '')
      return null;
    var cpp = new HelperBuf() <<
      '#include <$module.h>\n#include "Engine.h"\n';
    getIncludes(cpp);

    cpp << '\n' <<
      bufContents;

    return cpp.toString();
  }
}


