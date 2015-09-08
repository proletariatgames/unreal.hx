package ue4hx.internal;
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Context.*;
import haxe.macro.Type;

using haxe.macro.Tools;
using StringTools;
using Lambda;

class ExternGenerator {
  static var firstCompilation = true;
  static var hasRun = false;
  public static function generate():Array<Field> {
    registerMacroCalls();
    return new ExternGenerator().run();
  }

  private var fields:Array<Field>;
  private var cls:ClassType;
  private var helperGlueFields:Array<HelperGlueField>;
  private var thisType:TypeConv;
  private var helperType:TypeRef;

  private function new() {
    this.fields = getBuildFields();
    this.cls = getLocalClass().get();
    this.helperGlueFields = [];
    this.thisType = TypeConv.get( Context.getLocalType(), Context.currentPos() );
  }

  /**
    Registers onGenerate handler once per compilation
   **/
  public static function registerMacroCalls() {
    if (hasRun) return;
    hasRun = true;
    if (firstCompilation) {
      firstCompilation = false;
      Context.onMacroContextReused(function() {
        trace('reusing macro context');
        hasRun = false;
        return true;
      });
    }
    var nativeGlue = new NativeGlueCode();
    Context.onGenerate( nativeGlue.onGenerate );
    Context.onAfterGenerate( function() nativeGlue.onAfterGenerate() );
    haxe.macro.Compiler.include('unreal.helpers');
  }

  public function run():Array<Field> {
    var typeRef = new TypeRef(cls.pack, cls.name);
    var fieldsToAdd:Array<Field> = [];
    this.helperType = typeRef.getGlueHelperType();

    this.fields = this.fields.filter(function(v) return v.name != 'wrap');
    for (field in this.fields) {
      switch (field.kind) {
      case FFun(f) if (f.expr == null):
        // get type definitions for arguments/return
        var args = [ for (arg in f.args) { name:arg.name, escapedName: arg.name, type: getTypeConv(arg.type, field.pos) } ];
        var ret = getTypeConv(f.ret, field.pos);

        var isStatic = (field.access != null && field.access.has(AStatic));
        if (!isStatic)
          args.unshift({ name: 'this', escapedName: 'self', type: thisType });

        // generate this function's expression
        var expr =
          helperType.getRefName() + '.' + field.name + '(' +
            [ for (arg in args) arg.type.haxeToGlue(arg.name) ].join(',') +
          ')';
        var isVoid = ret.haxeType.isVoid();
        if (!isVoid)
          expr = 'return ' + ret.glueToHaxe(expr);
        f.expr = Context.parse(expr, field.pos);

        // generate the header and cpp glue code
        //TODO: optimization: use StringBuf instead of all these string concats
        var cppArgDecl = [ for ( arg in args ) arg.type.glueType.getCppType() + ' ' + arg.escapedName ].join(', ');
        var glueHeaderCode = 'static ${ret.glueType.getCppType()} ${field.name}(' + cppArgDecl + ');';

        var cppArgs = args.copy();
        var glueCppBody = if (isStatic) {
          thisType.ueType.getCppRefName() + '::' + field.name + '(';
        } else {
          var self = cppArgs.shift();
          self.type.glueToUe(self.escapedName) + '->' + field.name + '(';
        }
        glueCppBody += [ for (arg in cppArgs) arg.type.glueToUe(arg.escapedName) ].join(', ') + ')';
        if (!isVoid)
          glueCppBody = 'return ' + ret.ueToGlue( glueCppBody );

        var glueCppCode =
          ret.glueType.getCppType() +
          ' ${helperType.getCppType()}_obj::${field.name}(' + cppArgDecl + ') {' +
            '\n\t' + glueCppBody + ';\n}';
        var allTypes = [ for (arg in args) arg.type ];
        allTypes.push(ret);

        // add the glue codes so they can be later added to the glue extern type
        this.helperGlueFields.push({
          name: field.name,
          args: args,
          ret: ret,

          glueHeaderCode:glueHeaderCode,
          glueCppCode:glueCppCode,
          glueHeaderIncludes:collectHeaderIncludes(allTypes),
          glueCppIncludes:collectCppIncludes(allTypes),
          pos:field.pos
        });
      case FVar(t, expr) if (!field.meta.exists(function(meta) return meta.name == ':skip')):
        if (expr != null) throw new Error('Unreal Glue: External C++ properties cannot contain expression initializers', field.pos);
        var tconv = getTypeConv(t, field.pos);
        // this is going to be a property that gets/sets the actual variable
        field.kind = FProp("get", "set", t, expr);

        var isStatic = (field.access != null && field.access.has(AStatic));

        // generate getter and setter
        // TODO: cleanup and unify function / property generation
        function createField(prefix:String)
        {
          var args = prefix == "set_" ? [{ name:'value', escapedName: 'value', type:tconv }] : [];
          if (!isStatic)
            args.unshift({ name:'this', escapedName: 'self', type: thisType });

          var glueCppBody = if (isStatic) {
            thisType.ueType.getCppRefName() + '::' + field.name;
          } else {
            thisType.glueToUe('self') + '->' + field.name;
          }

          var ret = tconv,
              hxExpr = helperType.getRefName() + '.' + prefix + field.name + '(' +
                [ for (arg in args) arg.type.haxeToGlue(arg.name) ].join(', ') + ')';
          switch(prefix) {
          case 'get_':
            glueCppBody = 'return ' + tconv.ueToGlue(glueCppBody);
            hxExpr = 'return ' + tconv.glueToHaxe(hxExpr);
          case 'set_':
            glueCppBody = glueCppBody + ' = ' + tconv.glueToUe('value');
            ret = TypeConv.get( Context.getType('Void'), field.pos );
            hxExpr = '{\n\t' + hxExpr + ';\n\t' + 'return value;\n}';
          case _: throw 'assert';
          }

          var cppArgDecl = [ for (arg in args) arg.type.glueType.getCppType() + ' ' + arg.escapedName ].join(', ');
          var retType = ret.glueType.getCppType().toString();
          var glueHeaderCode = 'static $retType $prefix${field.name}(' + cppArgDecl + ');';

          var glueCppCode = retType + ' ${helperType.getCppType()}_obj::$prefix${field.name}(' + cppArgDecl + ') {\n' +
            '\t' + glueCppBody + ';\n}';
          var allTypes = [ thisType, tconv ];
          this.helperGlueFields.push({
            name: prefix + field.name,
            args: args,
            ret: ret,

            glueHeaderCode: glueHeaderCode,
            glueCppCode: glueCppCode,
            glueHeaderIncludes: collectHeaderIncludes(allTypes),
            glueCppIncludes: collectCppIncludes(allTypes),
            pos: field.pos
          });

          fieldsToAdd.push({
            name: prefix + field.name,
            access: isStatic ? [AStatic] : null,
            kind: FFun({
              args: [ for (arg in ( isStatic ? args : args.slice(1) )) { name: arg.name, type: arg.type.haxeType.toComplexType() } ],
              ret: tconv.haxeType.toComplexType(),
              expr: Context.parse(hxExpr, field.pos)
            }),
            pos: field.pos
          });
        }
        createField('get_');
        createField('set_');
      case _:
      }
    }

    fields.push({
      name: 'wrap',
      access: [APublic,AStatic],
      kind: FFun({
        args: [{ name:'native', type:null }],
        ret: thisType.haxeType.toComplexType(),
        expr: Context.parse('{
          if (native == null) return null;
          return new ${thisType.haxeType.getRefName()}(native);
        }', currentPos())
      }),
      pos: currentPos()
    });
    for (f in fieldsToAdd)
      fields.push(f);

    createHelperType();
    return fields;
  }

  private static function collectHeaderIncludes(allTypes:Array<TypeConv>) {
    var ret = new Map();
    for (t in allTypes) {
      if (t.glueHeaderIncludes != null) {
        for (inc in t.glueHeaderIncludes) {
          ret[inc] = inc;
        }
      }
    }
    return ret.array();
  }

  private static function collectCppIncludes(allTypes:Array<TypeConv>) {
    var ret = new Map();
    for (t in allTypes) {
      if (t.glueCppIncludes != null) {
        for (inc in t.glueCppIncludes) {
          ret[inc] = inc;
        }
      }
    }
    return ret.array();
  }

  private function createHelperType() {
    var fields = [];
    for (field in this.helperGlueFields) {
      fields.push({
        name: field.name,
        access: [APublic, AStatic],
        kind: FFun({
          args: [ for (arg in field.args) { name:arg.name, type:arg.type.haxeGlueType.toComplexType() } ],
          ret: field.ret.haxeGlueType.toComplexType(),
          expr: null
        }),
        pos: field.pos,

        // we could at this time just write the cpp/header code directly to the output file
        // however, we will defer this to a latter phase - so we can in the future benefit from DCE
        // to make lighter executables. This way, we'll add the glue code as a metadata
        // (see NativeGlueCode)
        meta: [
          createMeta('glueHeaderCode', [field.glueHeaderCode], field.pos),
          createMeta('glueCppCode', [field.glueCppCode], field.pos),
          createMeta('glueHeaderIncludes', field.glueHeaderIncludes, field.pos),
          createMeta('glueCppIncludes', field.glueCppIncludes, field.pos)
        ]
      });
    }
    var pos = Context.currentPos();
    var def:TypeDefinition = {
      pack: this.helperType.pack,
      name: this.helperType.name,
      pos: Context.currentPos(),
      isExtern: true,
      kind: TDClass(),
      fields: fields,
      meta:[
        createMeta(':unrealGlue', [], pos ),
        createMeta('glueHeaderIncludes', this.thisType.glueHeaderIncludes, pos),
        createMeta('glueCppIncludes', this.thisType.glueCppIncludes, pos),
      ]
    };
    Context.defineType(def);
  }


  private static function createMeta(name:String, value:Array<String>, pos:Position) {
    if (value == null)
      return { name: name, params:[], pos:pos };
    return { name: name, params:[for (v in value) macro @:pos(pos) $v{v}], pos:pos };
  }

  private static function getTypeConv(c:ComplexType, pos:Position) {
    var t = complexToType(c, pos);
    return TypeConv.get(t, pos);
  }

  private static function complexToType(c:ComplexType, pos:Position):Type {
    if (c == null) throw new Error('Unreal Glue: All types are required for external glue code functions', pos);
    return typeof({ expr:ECheckType(macro null, c), pos: pos });
  }
}

typedef HelperGlueField = {
  name:String,
  args:Array<{ name:String, escapedName:String, type:TypeConv }>,
  ret:TypeConv,

  glueHeaderCode:String,
  glueCppCode:String,
  glueHeaderIncludes:Array<String>,
  glueCppIncludes:Array<String>,
  pos:Position
}
