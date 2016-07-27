package ue4hx.internal.buf;
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
    cpp << '\n#ifdef __clang__\n#pragma clang diagnostic push\n' +
      '#pragma clang diagnostic ignored "-Wdeprecated-declarations"\n' +
      '#endif\n';
    cpp << '#ifdef _MSC_VER\n#pragma warning( disable : 4996 )\n#define _CRT_SECURE_NO_WARNINGS 1\n#define _CRT_SECURE_NO_WARNINGS_GLOBALS 1\n#define _CRT_SECURE_NO_DEPRECATE 1\n#endif\n'
      << '#include <$module.h>\n';

    if (!haxe.macro.Context.defined('UHX_NO_UOBJECT')) {
      cpp << '#include "Engine.h"\n';
    }

    getIncludes(cpp);

    cpp << '\n' <<
      bufContents;

    cpp << '\n#ifdef __clang__\n#pragma clang diagnostic pop\n#endif\n';
    cpp << '#ifdef _MSC_VER\n#undef _CRT_SECURE_NO_WARNINGS\n#undef _CRT_SECURE_NO_WARNINGS_GLOBALS\n#undef _CRT_SECURE_NO_DEPRECATE\n#pragma warning( default : 4996 )\n#endif\n';

    return cpp.toString();
  }
}


