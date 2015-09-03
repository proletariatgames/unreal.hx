package ue4hx.internal;
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Context.*;
import haxe.macro.Type;

using haxe.macro.Tools;
using StringTools;
using Lambda;

class ExternGenerator
{
  static var firstCompilation = true;
  static var hasRun = false;
  public static function generate():Array<Field>
  {
    registerMacroCalls();
    return new ExternGenerator().run();
  }

  private var fields:Array<Field>;
  private var cls:ClassType;
  private var helperGlueFields:Array<HelperGlueField>;
  private var thisType:GlueType;
  private var helperType:TypeRef;

  private function new()
  {
    this.fields = getBuildFields();
    this.cls = getLocalClass().get();
    this.helperGlueFields = [];
    this.thisType = GlueType.get( Context.getLocalType(), Context.currentPos() );
  }

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
    Context.onGenerate( GlueCode.onGenerate );
  }

  public function run():Array<Field>
  {
    var typeRef = new TypeRef(cls.pack, cls.name);
    this.helperType = typeRef.getGlueHelperType();

    this.fields = this.fields.filter(function(v) return v.name != 'wrap');
    for (field in this.fields) {
      switch (field.kind) {
      case FFun(f) if (f.expr == null):
        // get type definitions for arguments/return
        var args = [ for (arg in f.args) { name:arg.name, escapedName: arg.name, type: getGlueType(arg.type, field.pos) } ];
        var ret = getGlueType(f.ret, field.pos);

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
        var glueCppBody = if (isStatic)
          thisType.ueType.getCppType() + '::' + field.name + '(';
        else
          cppArgs.shift().escapedName + '->' + field.name + '(';
        glueCppBody += [ for (arg in cppArgs) arg.type.glueToUe(arg.escapedName) ].join(', ') + ')';
        if (!isVoid)
          glueCppBody = 'return ' + ret.ueToGlue( glueCppBody );

        var glueCppCode =
          '${helperType.getCppType()}::${field.name}(' + cppArgDecl + ') {' +
            '\t' + glueCppBody + ';\n}';
        var allTypes = [ for (arg in args) arg.type ];
        allTypes.push(ret);

        // add the glue codes so they can be later added to the glue extern type
        this.helperGlueFields.push({
          name: field.name,
          args: args,
          ret: ret,

          glueHeaderCode:glueHeaderCode,
          glueCppCode:glueCppCode,
          glueHeaderIncludes:getHeaderIncludes(allTypes),
          glueCppIncludes:getCppIncludes(allTypes),
          pos:field.pos
        });
        // add function to helper glue class
        // add Haxe code that calls the glue class
        // add cpp code that generates the glue class
      case FVar(t, expr) if (field.meta.exists(function(meta) return meta.name == ':')):
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

    createHelperType();
    return fields;
  }

  private static function getHeaderIncludes(allTypes:Array<GlueType>) {
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

  private static function getCppIncludes(allTypes:Array<GlueType>) {
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
        // HOWEVER, we will defer this to a latter phase - so we can in the future benefit from DCE
        // to make lighter executables. This way, we'll add the glue code as a metadata
        meta: [
          createMeta('glueHeaderCode', [field.glueHeaderCode], field.pos),
          createMeta('glueCppCode', [field.glueCppCode], field.pos),
          createMeta('glueHeaderIncludes', field.glueHeaderIncludes, field.pos),
          createMeta('glueCppIncludes', field.glueCppIncludes, field.pos)
        ]
      });
    }
    var def:TypeDefinition = {
      pack: this.helperType.pack,
      name: this.helperType.name,
      pos: Context.currentPos(),
      isExtern: true,
      kind: TDClass(),
      fields: fields,
      meta:[ createMeta(':unrealGlue', [], Context.currentPos() ) ]
    };
    Context.defineType(def);
  }


  private static function createMeta(name:String, value:Array<String>, pos:Position) {
    return { name: name, params:[for (v in value) macro @:pos(pos) $v{v}], pos:pos };
  }

  private static function getGlueType(c:ComplexType, pos:Position)
  {
    var t = complexToType(c, pos);
    return GlueType.get(t, pos);
  }

  private static function complexToType(c:ComplexType, pos:Position):Type
  {
    if (c == null) throw new Error('Unreal Glue: All types are required for external glue code functions', pos);
    return typeof({ expr:ECheckType(macro null, c), pos: pos });
  }
}

typedef HelperGlueField = {
  name:String,
  args:Array<{ name:String, escapedName:String, type:GlueType }>,
  ret:GlueType,

  glueHeaderCode:String,
  glueCppCode:String,
  glueHeaderIncludes:Array<String>,
  glueCppIncludes:Array<String>,
  pos:Position
}
