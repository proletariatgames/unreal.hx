package ue4hx.internal.buf;

class HeaderWriter extends BaseWriter {

  public function new(path) {
    super(path);
  }

  override private function getContents(module:String):String {
    var header = new HelperBuf() +
      '#pragma once\n';
    getIncludes(header);

    header = header + '\n' +
      this.buf.toString();

    return header.toString();
  }
}

