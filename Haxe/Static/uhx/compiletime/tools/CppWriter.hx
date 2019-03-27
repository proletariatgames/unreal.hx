package uhx.compiletime.tools;
using StringTools;

class CppWriter extends BaseWriter {

  public function new(path) {
    super(path);
  }

  override private function getContents(module:String):String {
    var bufContents = this.buf.toString().trim();
    if (bufContents == '')
      return null;
    var cpp = new HelperBuf();

    // unfortunately there's no clean way to deal with deprecated functions for now; there's no
    // way to detect them through UHT, so for now we'll just disable them
    cpp << '#include "uhx/NoDeprecateHeader.h"\n';
    cpp << '#include "$module.h"\n';

    if (!haxe.macro.Context.defined('UHX_NO_UOBJECT')) {
      cpp << '#include "UObject/WeakObjectPtr.h"\n';
      cpp << '#include "CoreMinimal.h"\n';
    }

    getIncludes(cpp);

    cpp << '\n' <<
      bufContents;

    cpp << '\n#include "uhx/NoDeprecateFooter.h"';

    return cpp.toString();
  }
}