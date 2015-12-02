package ue4hx.internal.buf;
import haxe.macro.Expr;

using haxe.macro.Tools;
using StringTools;

@:forward(buf)
abstract CodeFormatter(CodeFormatterImpl) from CodeFormatterImpl {
  inline public function new() {
    this = new CodeFormatterImpl();
  }

  public function newline():CodeFormatter {
    this.hasContent = false;
    this.buf.add('\n');
    this.buf.add(this.indent);

    return this;
  }

  public function begin(br="{"):CodeFormatter {
    this.indent += '  ';
    if (br != '') {
      this.buf.add(br);
      newline();
    }
    return this;
  }

  public function end(br="}"):CodeFormatter {
    this.indent = this.indent.substr(2);
    if (br != '') {
      newline();
      this.buf.add(br);
      newline();
    }
    return this;
  }

  public function addEscaped(txt:String):CodeFormatter {
    for (i in 0...txt.length) {
      var code = txt.fastCodeAt(i);
      switch (code) {
      case '\\'.code:
        this.buf.add('\\\\');
      case '\n'.code:
        this.buf.add('\\n');
      case '\t'.code:
        this.buf.add('\\t');
      case '\''.code:
        this.buf.add('\\\'');
      case '"'.code:
        this.buf.add('\\"');
      case chr:
        this.buf.addChar(chr);
      }
    }
    if (txt.length > 0) {
      this.hasContent = true;
    }

    return this;
  }

  public function addNewlines(text:String, addNewlineAfter=false):CodeFormatter {
    var first = true;
    for (part in text.split('\n')) {
      if (first) first = false; else newline();
      this.buf.add(part.trim());
    }
    if (addNewlineAfter && !first) {
      newline();
    }
    return this;
  }

  public function comment(text:String):CodeFormatter {
    if (text == null) return this;
    if (this.hasContent) {
      newline();
    }
    begin('/**');
    addNewlines(text.replace('*/', '*'), false);
    end('**/');

    return this;
  }

  @:op(A<<B) inline public function add(text:String):CodeFormatter {
    this.buf.add(text);
    this.hasContent = true;
    return this;
  }

  @:op(A<<B) inline public function addBegin(text:Begin):CodeFormatter {
    return begin(cast text);
  }

  @:op(A<<B) inline public function addEnd(text:End):CodeFormatter {
    return end(cast text);
  }

  @:op(A<<B) inline public function addComment(text:Comment):CodeFormatter {
    return comment(cast text);
  }

  @:op(A<<B) inline public function addNewline(text:Newline):CodeFormatter {
    return newline();
  }

  @:op(A<<B) inline public function _addEscaped(text:Escaped):CodeFormatter {
    return addEscaped(cast text);
  }

  @:extern inline public function mapJoin<T>(arr:Iterable<T>, fn:T->String, joinArg=', ') {
    var first = true;
    for (val in arr) {
      if (first) first = false; else add(joinArg);
      add(fn(val));
    }
  }

  @:op(A<<B) public function addMeta(metas:Metadata):CodeFormatter {
    if (metas != null) {
      for (meta in metas) {
        this.buf.add('@' + meta.name);
        if (meta.params != null && meta.params.length > 0) {
          this.buf.add('(');
          var first = true;
          for (param in meta.params) {
            if (first) first = false; else this.buf.add(', ');
            this.buf.add(param.toString());
          }
          this.buf.add(')');
        }
        if (meta.name == ':final')
          this.buf.add(' @:nonVirtual ');
        newline();
      }
    }
    return this;
  }

  inline public function foldJoin<T>(arr:Iterable<T>, fn:T->CodeFormatter->CodeFormatter, joinArg=', ') {
    var first = true;
    var ethis:CodeFormatter = this;
    for (val in arr) {
      if (first) first = false; else add(joinArg);
      ethis = fn(val, ethis);
    }
    return this;
  }

  public function toString() {
    return this.buf.toString();
  }
}

abstract Begin(String) {
  @:extern inline public function new(txt:String) {
    this = txt;
  }
}

abstract End(String) {
  @:extern inline public function new(txt:String) {
    this = txt;
  }
}

abstract Comment(String) {
  @:extern inline public function new(txt:String) {
    this = txt;
  }
}

abstract Escaped(String) {
  @:extern inline public function new(txt:String) {
    this = txt;
  }
}

abstract Newline(Dynamic) {
  @:extern inline public function new() {
    this = null;
  }
}


private class CodeFormatterImpl {
  public var indent:String;
  public var buf:StringBuf;
  public var hasContent:Bool;

  public function new() {
    this.buf = new StringBuf();
    this.indent = '';
    this.hasContent = false;
  }

  public function toString() {
    return this.buf.toString();
  }
}
