package ue4hx.internal;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

using haxe.macro.Tools;
using StringTools;

/**
  Generates the Haxe @:uexpose class which allows Unreal types to access Haxe types
 **/
class BuildExpose {
  public static function build():Type {
    return switch (Context.getLocalType()) {
      case TInst(_, [typeToGen]):
        new BuildExpose(Context.currentPos()).generate(typeToGen);
      case _:
        throw 'assert';
    }
  }

  private var pos:Position;
  private function new(pos) {
    this.pos = pos;
  }

  public function generate(t:Type):Type {
    switch (Context.follow(t)) {
    case TInst(cl,tl):
      var clt = cl.get();
      var nativeUeName = getNativeUeName(clt);
      var typeRef = TypeRef.fromBaseType(clt, this.pos),
          thisConv = TypeConv.get(t, this.pos);
      var expose = typeRef.getExposeHelperType();
      var toExpose = [];
      for (field in clt.statics.get()) {
        if (shouldExpose(field))
          toExpose.push(getMethodDef(field, Static));
      }

      var nativeMethods = collectNativeMethods(clt),
          haxeMethods = collectHaxeMethods(clt);
      for (field in clt.fields.get()) {
        if (haxeMethods.exists(field.name))
          continue; // our methods are already virtual and we don't need to override anything

        var isOverride = nativeMethods.exists(field.name);
        if (isOverride || shouldExpose(field)) {
          toExpose.push(getMethodDef(field, isOverride ? Override : Member));
        }
      }

      var buildFields = [];
      for (field in toExpose) {
        var callExpr = if (field.type.isStatic())
          typeRef.getRefName() + '.' + field.cf.name + '(';
        else
          thisConv.glueToHaxe('self') + '.' + field.cf.name + '(';
        callExpr += [ for (arg in field.args) arg.type.glueToHaxe(arg.name) ].join(', ') + ')';

        if (!field.ret.haxeType.isVoid())
          callExpr = 'return ' + field.ret.haxeToGlue( callExpr );

        var fnArgs:Array<FunctionArg> =
          [ for (arg in field.args) { name: arg.name, type: arg.type.haxeGlueType.toComplexType() } ];
        if (!field.type.isStatic())
          fnArgs.unshift({ name: 'self', type: thisConv.haxeGlueType.toComplexType() });

        var headerDef = new HelperBuf(),
            cppDef = new HelperBuf();
        var ret = field.ret.ueType.getCppType().toString();
        cppDef = cppDef + ret + ' ::' + nativeUeName + '::' + field.cf.name + '(';
        var modifier = field.type.isStatic() ? 'static ' : 'virtual ';
        headerDef = headerDef + modifier + ret + ' ' + field.cf.name + '(';
        var args = [ for (arg in field.args) arg.type.ueType.getCppType() + ' ' + arg.name ].join(', ') + ')';
        cppDef += args; headerDef += args;
        if (field.type == Override)
          headerDef += ' override';
        headerDef += ';\n';
        cppDef += '{\n\t';
        var args = [ for (arg in field.args) arg.type.ueToGlue( arg.name ) ];
        if (!field.type.isStatic())
          args.unshift( thisConv.ueToGlue('this') );
        var cppBody = expose.getCppRefName() + '::' + field.cf.name + '(' +
          args.join(', ') + ')';
        if (!field.ret.haxeType.isVoid())
          cppBody = 'return ' + field.ret.glueToUe( cppBody );
        cppDef += cppBody + ';\n}\n';

        var metas:Metadata = [
          { name: ':glueHeaderCode', params:[macro $v{headerDef.toString()}], pos: field.cf.pos },
          { name: ':glueCppCode', params:[macro $v{cppDef.toString()}], pos: field.cf.pos }
        ];
        if (field.ret.haxeType.isVoid())
          metas.push({ name: ':void', pos: field.cf.pos });
        buildFields.push({
          name: field.cf.name,
          access: [APublic, AStatic],
          kind: FFun({
            args: fnArgs,
            ret: field.ret.haxeGlueType.toComplexType(),
            expr: Context.parse(callExpr, field.cf.pos)
          }),
          meta: metas,
          pos: field.cf.pos
        });
      }

      var metas = [
        { name: ':uexpose', params:[], pos:clt.pos },
        { name: ':keep', params:[], pos:clt.pos },
        { name: ':uextern', params:[], pos:clt.pos },
      ];

      var includes = ['<unreal/helpers/GcRef.h>', '<' + expose.getRefName().replace('.','/') + '.h>'];
      var info = addNativeUeClass(clt, includes, metas);

      // add createHaxeWrapper
      {
        var headerCode = 'virtual void *createHaxeWrapper()' + (info.hasHaxeSuper ? ' override;' : ';');
        var cppCode = 'void *::$nativeUeName::createHaxeWrapper() {\n\treturn ${expose.getCppRefName()}::createHaxeWrapper((void *) this);\n}\n';

        var metas = [
          { name: ':glueHeaderCode', params: [macro $v{headerCode}], pos: this.pos },
          { name: ':glueCppCode', params: [macro $v{cppCode}], pos: this.pos }
        ];
        buildFields.push({
          name: 'createHaxeWrapper',
          access: [APublic, AStatic],
          kind: FFun({
            args: [{ name: 'ueType', type: thisConv.haxeGlueType.toComplexType() }],
            ret: thisConv.glueType.toComplexType(),
            expr: Context.parse(
              'return ' + thisConv.haxeToGlue('@:privateAccess new ${typeRef.getRefName()}( cpp.Pointer.fromRaw(cast ueType) )'), this.pos)
          }),
          meta: metas,
          pos: this.pos
        });
      }

      Context.defineType({
        pack: expose.pack,
        name: expose.name,
        pos: clt.pos,
        meta: metas,
        kind: TDClass(),
        fields: buildFields
      });
      return Context.getType(expose.getRefName());
    case _:
      throw new Error('Unreal Haxe Glue: Type $t not supported', Context.currentPos());
    }
  }

  private static function getNativeUeName(clt:ClassType) {
    // TODO: add A/U/F prefix
    return clt.name;
  }

  private static function addNativeUeClass(clt:ClassType, includes:Array<String>, metas:Metadata):{ hasHaxeSuper:Bool } {
    var typeRef = TypeRef.fromBaseType(clt, clt.pos);
    var extendsAndImplements = [];
    var name = getNativeUeName(clt);
    metas.push({ name: ':ueGluePath', params: [macro $v{name}], pos: clt.pos });
    includes.push('$name.generated.h');

    var hasHaxeSuper = false;
    if (clt.superClass != null) {
      // TESTME - test extending Haxe classes
      var tconv = TypeConv.get( TInst(clt.superClass.t, clt.superClass.params), clt.pos );
      // any superclass here should also be present in the native side
      extendsAndImplements.push('public ' + tconv.ueType.getCppRefName(false));

      hasHaxeSuper =  !clt.superClass.t.get().meta.has(':uextern');
      // we're using the ueType so we'll include the glueCppIncludes
      if (tconv.glueCppIncludes != null) {
        for (inc in tconv.glueCppIncludes)
          includes.push(inc);
      }
    }
    for (iface in clt.interfaces) {
      var impl = iface.t.get();
      // TODO: support UE4 interface declaration in Haxe; for now we'll only add @:uextern interfaces
      // look into @:uextern.
      if (impl.meta.has(':uextern')) {
        var tconv = TypeConv.get( TInst(iface.t, iface.params), clt.pos );
        extendsAndImplements.push('public ' + tconv.ueType.getCppRefName(false));
        if (tconv.glueCppIncludes != null) {
          for (inc in tconv.glueCppIncludes)
            includes.push(inc);
        }
      }
    }

    var headerDef = new StringBuf(),
        cppDef = new StringBuf();
    var uclass = clt.meta.extract(':uclass')[0];
    if (uclass != null) {
      headerDef.add('UCLASS(');
      if (uclass.params != null) {
        var first = true;
        for (param in uclass.params) {
          if (first) first = false; else headerDef.add(', ');
          headerDef.add(param.toString());
        }
      }
      headerDef.add(')\n');
    }
    headerDef.add('class HAXERUNTIME_API $name ');
    if (extendsAndImplements.length > 0) {
      headerDef.add(' : ');
      headerDef.add(extendsAndImplements.join(', '));
    }
    headerDef.add(' {\n\tGENERATED_BODY()\n\n');
    // headerDef.add(' {\n\t');
    headerDef.add('public:\n');
    if (!hasHaxeSuper) {
      headerDef.add('\t\t::unreal::helpers::GcRef haxeGcRef;\n');
      // headerDef.add('\t\tpublic virtual void *createHaxeWrapper();\n');
      headerDef.add('\t\t$name() { this->haxeGcRef.set(this->createHaxeWrapper()); }\n');
    } else {
      // headerDef.add('\t\tpublic virtual void *createHaxeWrapper() override;\n');
    }

    metas.push({ name: ':glueHeaderIncludes', params:[for (inc in includes) macro $v{inc}], pos: clt.pos });
    metas.push({ name: ':ueHeaderDef', params:[macro $v{headerDef.toString()}], pos: clt.pos });

    return { hasHaxeSuper: hasHaxeSuper };
  }

  private static function getMethodDef(field:ClassField, fieldType:FieldType) {
    var args = null, ret = null;
    switch(Context.follow(field.type)) {
      case TFun(a,r):
        args = [ for (arg in a) { name:arg.name, type: TypeConv.get(arg.t, field.pos) } ];
        ret = TypeConv.get(r, field.pos);
      case _: throw 'assert'; // we only allow FMethod here
    }

    return {
      cf: field,
      args: args,
      ret: ret,
      type: fieldType
    };
  }

  private static function collectNativeMethods(cls:ClassType) {
    var ret = new Map();
    var sclass = cls.superClass;
    while (sclass != null) {
      var cur = sclass.t.get();
      if (cur.meta.has(':uextern')) {
        for (field in cur.fields.get())
          ret[field.name] = true;
      }
      sclass = cur.superClass;
    }
    return ret;
  }

  private static function collectHaxeMethods(cls:ClassType) {
    var ret = new Map();
    var sclass = cls.superClass;
    while (sclass != null) {
      var cur = sclass.t.get();
      if (cur.meta.has(':uextern')) {
        break;
      }
      for (field in cur.fields.get())
        ret[field.name] = true;
      sclass = cur.superClass;
    }
    return ret;
  }

  private static function shouldExpose(cf:ClassField):Bool {
    // we will only expose methods that either have @:uexpose metadata
    // or that override or implement an unreal method
    switch (cf.kind) {
    case FMethod(_):
    case _:
      // we won't expose our non-@:uproperty vars;
      // and uproperty vars will be already generated in the UE side
      return false;
    }

    if (cf.meta.has(':uexpose'))
      return true;
    return false;
  }
}

@:enum abstract FieldType(Int) to Int {
  var Static = 1;
  var Member = 2;
  var Override = 3;

  inline public function isStatic() {
    return this == Static;
  }
}
