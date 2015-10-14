package ue4hx.internal.buf;

class CppWriter extends BaseWriter {

  public function new(path) {
    super(path);
  }

  override private function getContents(module:String):String {
    var cpp = new HelperBuf() +
      '#include <$module.h>\n';
    getIncludes(cpp);

    cpp = cpp + '\n' +
      this.buf.toString();

    return cpp.toString();
  }
}


