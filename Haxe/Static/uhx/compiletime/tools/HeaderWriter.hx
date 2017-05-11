package uhx.compiletime.tools;

class HeaderWriter extends BaseWriter {
  private var fwdMap:Map<String, Bool> = new Map();
  private var forwardDecls:Array<String> = [];

  public function new(path) {
    super(path);
  }

  public function forwardDeclare(decl:String) {
    if (!this.fwdMap.exists(decl)) {
      this.fwdMap[decl] = true;
      this.forwardDecls.push(decl);
    }
  }

  override private function getContents(module:String):String {
    var header = new HelperBuf() <<
      '#pragma once\n';
    for (decl in this.forwardDecls) {
      header << decl << '\n';
    }

    getIncludes(header);

    header << '\n' <<
      this.buf.toString();

    return header.toString();
  }
}

