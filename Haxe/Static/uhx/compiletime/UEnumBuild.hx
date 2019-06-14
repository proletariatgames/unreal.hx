package uhx.compiletime;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import uhx.compiletime.tools.*;
import uhx.compiletime.types.*;
import uhx.meta.MetaDef;

using haxe.macro.Tools;
using StringTools;
using uhx.compiletime.tools.MacroHelpers;

/** Processes Haxe enums with :uenum metadata and creates the UENUM C++ definition */
class UEnumBuild
{
  public static function getSignature(e:EnumType) {
    if (!e.meta.has(':uenum')) {
      return null;
    }
    return UhxMeta.getStaticMetas(e.meta.get()) + '@Enum{' + e.names.join(',') + '}';
  }

  public static function processEnum(type:haxe.macro.Type) {
    switch (type) {
    case TEnum(enumType, params):
      var hxPath = enumType.toString();
      var enumType = enumType.get();
      enumType.meta.add(':keep', [], enumType.pos);
      if (enumType.meta.has(':uextern')) {
        enumType.meta.add(':ugenerated', [macro $v{getSignature(enumType)}], enumType.pos);
        return;
      }
      if (!enumType.meta.has(':uenum')) {
        return;
      }
      if (params.length > 0) {
        Context.error("Unreal Glue: uenums cannot have type parameters", enumType.pos);
        return;
      }
      if (!enumType.meta.has(':flatEnum')) {
        Context.error("Unreal Glue: uenums cannot have constructors that take parameters", enumType.pos);
      }

      enumType.meta.add(':ugenerated', [macro $v{getSignature(enumType)}], enumType.pos);

      // Generate the enum C++ definition
      var uname = MacroHelpers.getUName(enumType);
      Globals.cur.staticUTypes[hxPath] = { hxPath:hxPath, uname: uname, type:CompiledClassType.CUEnum };

      var headerPath = GlueInfo.getExportHeaderPath(uname, true);
      var typeRef = TypeRef.fromBaseType(enumType, enumType.pos);
      var enumExpr = Context.parse(typeRef.getClassPath(), enumType.pos);

      var arrCreateName = uname + '_ArrCreate';
      var createArr = macro class {
        public static var arr(get, null):Array<Dynamic>;
        private static function get_arr() {
          if (arr == null) {
            return arr = cast std.Type.allEnums(std.Type.resolveEnum($v{typeRef.withoutModule().toString()}));
          }
          return arr;
        }
      };
      createArr.name = arrCreateName;
      createArr.pack = ['uhx','enums'];

      var expose = macro class {
        public static function getArray():unreal.UIntPtr {
          return uhx.internal.HaxeHelpers.dynamicToPointer( $i{arrCreateName}.arr );
        }
      };
      var ifFeature:MetadataEntry = { name:':ifFeature', params:[macro $v{typeRef.getClassPath(true) + '.*'}], pos:enumType.pos };
      expose.meta.push(ifFeature);
      createArr.meta.push(ifFeature);

      expose.name = uname + '_GetArray';
      expose.pack = ['uhx','enums'];
      Globals.cur.hasUnprocessedTypes = true;
      Context.defineType(createArr);
      Context.getType('uhx.enums.$arrCreateName');
      expose.meta.push({ name:':uexpose', pos:enumType.pos });
      expose.meta.push({ name:':skipUExternCheck', pos:enumType.pos });
      Context.defineType(expose);
      Context.getType('uhx.enums.${uname}_GetArray');

      var writer = new HeaderWriter(headerPath);
      writer.include('uhx/EnumGlue.h');
      writer.include('uhx/enums/${uname}_GetArray.h');
      writer.include('uhx/expose/HxcppRuntime.h');
      writer.include('$uname.generated.h');

      if (enumType.doc != null) {
        writer.buf.add('/**\n${enumType.doc.replace('**/','')}\n**/\n');
      }
      var uenum = enumType.meta.extract(':uenum')[0];
      writer.buf.add('UENUM(');
      MacroHelpers.addHaxeGenerated(uenum, typeRef);
      if (uenum.params != null) {
        var first = true;
        for (param in uenum.params) {
          if (first) first = false; else writer.buf.add(', ');
          writer.buf.add(param.toString().replace('[','(').replace(']',')'));
        }
      }
      writer.buf.add(')\n');

      var enumBaseType = MacroHelpers.extractStrings(enumType.meta, ':class')[0];
      if (enumBaseType == null) enumBaseType = 'uint8';
      writer.buf.add('enum class $uname : $enumBaseType {\n');

      var enumIndex = 0;
      for (constrName in enumType.names) {
        var constr = enumType.constructs[constrName];
        writer.buf.add('\t$constrName = $enumIndex');
        var umeta = constr.meta.extract(':umeta')[0];
        if (umeta != null && umeta.params != null) {
          writer.buf.add(' UMETA(');
          var first = true;
          for (param in umeta.params) {
            if (first) first = false; else writer.buf.add(', ');
            writer.buf.add(param.toString().replace('[','(').replace(']',')'));
          }
          writer.buf.add(')');
        }
        writer.buf.add(',\n');
        ++enumIndex;
      }

      writer.buf.add('};\n');
      writer.buf << 'namespace uhx {\n\n';
      writer.buf << 'template<> struct EnumGlue<$uname> {\n'
        << '\tstatic $uname haxeToUe(unreal::UIntPtr haxe) {\n'
          << '\t\treturn ($uname) uhx::expose::HxcppRuntime::enumIndex(haxe);\n}\n\n'
        << '\tstatic unreal::UIntPtr ueToHaxe($uname ue) {\n'
          << '\t\tstatic unreal::UIntPtr array = uhx::enums::${uname}_GetArray::getArray();\n'
          << '\t\treturn uhx::expose::HxcppRuntime::arrayIndex(array, (int) ue);\n}\n\n'
          << '};\n';
      writer.buf << '}';

      writer.close(Globals.cur.module);


    // case TAbstract(a, params):
    //   var atype = a.get();
    default:
      throw 'assert';
    }
  }

  public static function createEnumIndex(enumType:Expr, index:Expr):Expr {
    var t = Context.follow(Context.typeof(enumType));
    switch(t) {
    case TAnonymous(_.get() => { status: AEnumStatics(e) }):
      var helperName = e.toString() + '_FastIndex';
      try {
        Context.getType(helperName);
      } catch(exc:Dynamic) {
        // create the type
        var en = e.get(),
            fullName = en.module + '.' + en.name;
        var values = [ for (name in en.names) Context.parse(fullName + '.' + name, en.pos) ];
        var expr = { expr:EArrayDecl(values), pos:enumType.pos };
        var cls = macro class {
          public static var all = $expr;
        }
        cls.pack = en.pack;
        cls.name = en.name + '_FastIndex';
        Globals.cur.hasUnprocessedTypes = true;
        Context.defineType(cls);
      }
      var expr = Context.parse(helperName + '.all', enumType.pos);
      return macro $expr[$index];
    case _:
      return macro Type.createEnumIndex($enumType, $index);
    }
  }
}
