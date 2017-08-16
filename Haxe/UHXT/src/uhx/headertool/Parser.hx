package uhx.headertool;
import uhx.headertool.Data;
using StringTools;

class Parser {
  // var ctx:CppContext;
  var buf:String;
  var pos:Int;
  var max:Int;

  var inWithEditor:Bool;
  var ns:Array<String>;
  var nextToken:CppToken;

  public function new(buf:String, pos:Int, max:Int) {
    this.buf = buf;
    this.pos = pos;
    this.max = max;
    this.ns = [];
  }

  public function parse(onlyDefs:Bool):Array<CppTopLevel> {
    var ret = [];
    return ret;
  }

  public function parseTopLevel(onlyDefs:Bool):CppTopLevel {
    var lastComment = null;
    while(true) {
      var tk = token(false);
      switch(tk) {
      case TEof:
        return null;
      case TComment(c):
        lastComment = c;
      case TMacro(m):
        var firstId = idRegex.match(m) ? idRegex.matched(0) : null;
        trace(firstId);
        if (firstId == 'if') {
          var next = idRegex.match(idRegex.matchedRight()) ? idRegex.matched(0) : null;
          if (next == 'WITH_EDITORONLY_DATA') {
            this.inWithEditor = true;
          } else {
            trace('consume $next');
            this.consume('#endif');
          }
        } else if (firstId == 'endif') {
          if (!inWithEditor) {
            // TODO warn
          }
          inWithEditor = false;
        }
      case TId('namespace'):
        ns.push(id(token(true)));
        expect(TBkOpen);
        lastComment = null;
      case TId('enum'):
        tk = peek(true);
        var name = (tk != TBkOpen) ? id(token()) : null,
            isClass = false,
            enumType = null;
        if (name == 'class' || name == 'struct') {
          isClass = true;
          name = id(token(true));
        }
        switch(token(true)) {
        case TColon:
          enumType = parseType();
        case TBkOpen:
          // expected
        case tk:
          warn('Unexpected token $tk');
          consume('{', true);
          trace(token(true));
        }
        var fields = [];
        var lastComment = null,
            macros = null;
        while(true) {
          trace(peek(false));
          switch(token(false)) {
          case TComment(c):
            lastComment = c;
          case TId(id):
            var ret:CppEnumField = {
              doc: lastComment,
              name: id,
              pos: null,
              macros: macros
            };
            fields.push(ret);
            lastComment = null;
            if (peek(true) == TEq) {
              token(true);
              switch(token(true)) {
              case TConst(c):
                ret.value = c;
              case tk: // unexpected
                warn('Unexpected $tk');
                consume('}', false);
              }
            }
          case TComma:
          case TBkClose:
            break;
          case k:
          trace(k);
            // TODO
          }
        }
        var ret:CppEnum = {
          doc:lastComment,
          ns:this.ns.copy(),
          name:name,
          isClass:isClass,
          fields:fields,
          pos:null,
          macros:null,
        };
        trace(ret);
        return TLEnum(ret);
      case tk:
      trace(tk);
      }
    }
  }

  private function parseType():CppType {
    return null;
  }

  private function id(token:CppToken):String {
    return switch(token) {
    case TId(id):
      id;
    case t:
      err('Expected id, got $t');
    }
  }

  private function expect(tk:CppToken) {
    var etk = token(true);
    if (etk != tk && !Type.enumEq(tk, etk)) {
      err('Expected $tk, got $etk');
    }
  }

  private function err(name:String):Dynamic {
    throw 'Error: $name'; // todo use pos
  }

  private function warn(name:String) {
    trace('warn: $name');
  }

  private function consume(until:String, stopAtIndent:Bool=false) {
    trace('consume $until');
    var p = this.pos,
        max = this.max,
        buf = this.buf;
    var fstChar = until.fastCodeAt(0),
        untilLength = until.length,
        indent = 0;
    while(p < max) {
      var chr = buf.fastCodeAt(p);
      p++;
      if (indent == 0 && chr == fstChar) {
        if (max - p >= untilLength) {
          if (untilLength == 1 || buf.substr(p, untilLength) == until) {
            // found
            this.pos = p + untilLength;
            trace(buf.substr(p, 20));
            return;
          }
        } else {
          // could not find - just set to max
          this.pos = max;
            trace(buf.substr(p, 20));
          return;
        }
      }
      switch(chr) {
        case '{'.code:
          if (stopAtIndent) {
            this.pos = p;
            trace(buf.substr(p, 20));
            return;
          }
          indent++;
        case '}'.code:
          if (indent > 0) {
            indent--;
          }
          // otheriwse, indenting out - it's okay if we're not stopping at } (e.g. #if)
        case '"'.code:
          var escaping = false;
          while (p < max) {
            chr = buf.fastCodeAt(p);
            p++;
            var wasEscaping = escaping;
            escaping = false;
            switch(chr) {
            case '\\'.code:
              if (!wasEscaping) {
                escaping = true;
              }
            case '"'.code:
              if (!wasEscaping) {
                break;
              }
            case _:
              // loop 
            }
          }
        case '\''.code:
          var escaping = false;
          while (p < max) {
            chr = buf.fastCodeAt(p);
            p++;
            var wasEscaping = escaping;
            escaping = false;
            switch(chr) {
            case '\\'.code:
              if (!wasEscaping) {
                escaping = true;
              }
            case '\''.code:
              if (!wasEscaping) {
                break;
              }
            case _:
              // loop 
            }
          }
        case '/'.code:
          if (p < max) {
            var next = buf.fastCodeAt(p);
            if (next == '/'.code) {
              p++;
              // ignore until newline
              while(p < max) {
                chr = buf.fastCodeAt(p);
                p++;
                if (chr == '\n'.code) {
                  break;
                }
              }
            } else if (next == '*'.code) {
              p++;
              while(p < (max-1)) {
                chr = buf.fastCodeAt(p);
                p++;
                if (chr == '*'.code && buf.fastCodeAt(p) == '/'.code) {
                  break;
                }
              }
            }
          }
        case '#'.code:
          if (max - p > 2) {
            if (buf.substr(p,2) == 'if') {
              // assume false, just go through it
              this.pos = p+3;
              trace(buf.substr(pos, 20));
              this.consume('#endif', false);
            } else if (max -p > 'define'.length && buf.substr(p,'define'.length) == 'define') {
              var escaping = false;
              while(p < max) {
                var wasEscaping = escaping;
                escaping = false;
                chr = buf.fastCodeAt(p);
                p++;
                if (chr == '\n'.code && !wasEscaping) {
                  break;
                } else if (chr == '\\'.code && !wasEscaping) {
                  escaping = true;
                }
              }
            }
          }
        case _:
          // just loop
      }
    }

    this.pos = p;
            trace(buf.substr(p, 20));
    return;
  }

  public function peek(discardComment = false) {
    var ret = token(discardComment);
    this.nextToken = ret;
    return ret;
  }

  public function token(discardComment = false):CppToken {
    var discardComment:Bool = discardComment;
    if (nextToken != null) {
      var ret = nextToken;
      nextToken = null;
      if (discardComment) {
        switch(ret) {
        case TComment(_):
        case _:
          return ret;
        }
      } else {
        return ret;
      }
    }

    var p = this.pos,
        max = this.max,
        buf = this.buf,
        ret:CppToken = null;
    while (ret == null && p < max) {
      var chr = buf.fastCodeAt(p);
      p++;
      switch(chr) {
      case ' '.code | '\t'.code | '\n'.code | '\r'.code:
        // empty space
      case '('.code:
        ret = TPOpen;
      case ')'.code:
        ret = TPClose;
      case '['.code:
        ret = TBrOpen;
      case ']'.code:
        ret = TBrClose;
      case '.'.code:
        if (p < max) {
          var next = buf.fastCodeAt(p);
          if (next >= '0'.code && next <= '9'.code) {
            if (numRegex.match(buf.substr(p-1))) {
              p += numRegex.matchedPos().len - 1;
              ret = TConst(CNumber(numRegex.matched(0)));
            }
          }
        }
        if (ret == null) {
          ret = TDot;
        }
      case ','.code:
        ret = TComma;
      case ';'.code:
        ret = TSemicolon;
      case '{'.code:
        ret = TBkOpen;
      case '}'.code:
        ret = TBkClose;
      case '<'.code:
        ret = TLt;
      case '>'.code:
        ret = TGt;
      case '='.code:
        ret = TEq;
      case '*'.code:
        ret = TStar;
      case '&'.code:
        ret = TAnd;
      case ':'.code:
        if (p < max && buf.fastCodeAt(p) == ':'.code) {
          p++;
          ret = TNs;
        } else {
          ret = TColon;
        }
      case '/'.code:
        if (p < max) {
          var next = buf.fastCodeAt(p);
          if (next == '/'.code) {
            p++;
            // ignore until newline
            while(p < max) {
              chr = buf.fastCodeAt(p);
              p++;
              if (chr == '\n'.code) {
                break;
              }
            }
          } else if (next == '*'.code) {
            p++;
            var start = p;
            while(p < (max-1)) {
              chr = buf.fastCodeAt(p);
              p++;
              if (chr == '*'.code && buf.fastCodeAt(p) == '/'.code) {
                p++;
                break;
              }
            }
            if (!discardComment) {
              ret = TComment(buf.substring(start, p - 2));
            }
          }
        }
      case '"'.code:
        var start = p;
        var escaping = false;
        while (p < max) {
          chr = buf.fastCodeAt(p);
          p++;
          var wasEscaping = escaping;
          escaping = false;
          switch(chr) {
          case '\\'.code:
            if (!wasEscaping) {
              escaping = true;
            }
          case '"'.code:
            if (!wasEscaping) {
              break;
            }
          case _:
            // loop 
          }
        }
        ret = TConst(CString(buf.substring(start, p - 1)));
      case '\''.code:
        var start = p;
        var escaping = false;
        while (p < max) {
          chr = buf.fastCodeAt(p);
          p++;
          var wasEscaping = escaping;
          escaping = false;
          switch(chr) {
          case '\\'.code:
            if (!wasEscaping) {
              escaping = true;
            }
          case '\''.code:
            if (!wasEscaping) {
              break;
            }
          case _:
            // loop 
          }
        }
        ret = TConst(CString(buf.substring(start, p - 1)));
      case '#'.code:
        var escaping = false;
        var start = p;
        while(p < max) {
          var wasEscaping = escaping;
          escaping = false;
          chr = buf.fastCodeAt(p);
          p++;
          if (chr == '\n'.code && !wasEscaping) {
            break;
          } else if (chr == '\\'.code && !wasEscaping) {
            escaping = true;
          }
        }
        ret = TMacro(buf.substring(start, p).trim());
      case chr:
        if (chr >= '0'.code && chr <= '9'.code) {
          if (p >= max) {
            ret = TConst(CNumber(String.fromCharCode(chr)));
          } else {
            var next = buf.fastCodeAt(p);
            if (chr == '0'.code && (next == 'X'.code || next == 'x'.code)) {
              if (hexRegex.match(buf.substr(p+1))) {
                p += hexRegex.matchedPos().len - 1;
                ret = TConst(CNumber('0x' + hexRegex.matched(0)));
              } else {
                ret = TConst(CNumber('0'));
              }
            } else {
              if (numRegex.match(buf.substr(p-1))) {
                p += numRegex.matchedPos().len - 1;
                ret = TConst(CNumber(numRegex.matched(0)));
              } else {
                throw 'assert';
              }
            }
          }
        } else if ( (chr >= 'A'.code && chr <= 'Z'.code) || (chr >= 'a'.code && chr <= 'z'.code) ) {
          if (idRegex.match(buf.substr(p-1))) {
            p += idRegex.matchedPos().len - 1;
            ret = TId(idRegex.matched(0));
          } else {
            throw 'assert';
          }
        } else {
          ret = TUnidentified(String.fromCharCode(chr));
        }
      }
    }

    this.pos = p;
    if (ret == null) {
      return TEof;
    }
    return ret;
  }

  private static var numRegex = ~/^(?:[0-9]+)?\.?(?:[0-9]+)(?:[eE][\+\-]?[0-9]+)?[Ff]?/;
  private static var hexRegex = ~/^(?:[0-9A-Fa-f]+)/;
  private static var idRegex = ~/^(?:[A-Za-z0-9_]+)/;
}