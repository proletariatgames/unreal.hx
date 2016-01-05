package ue4hx.internal;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import ue4hx.internal.buf.HeaderWriter;
import sys.FileSystem;

using haxe.macro.Tools;
using StringTools;

/** Processes Haxe enums with :uenum metadata and creates the UENUM C++ definition */
class UEnumBuild
{
  public static function processEnum(type:haxe.macro.Type) {
    switch (type) {
    case TEnum(enumType, params):
      var enumType = enumType.get();
      if (enumType.meta.has(':uextern') || !enumType.meta.has(':uenum')) {
        return;
      }
      if (params.length > 0) {
        Context.error("Unreal Glue: uenums cannot have type parameters", enumType.pos);
        return;
      }
      if (!enumType.meta.has(':flatEnum')) {
        Context.error("Unreal Glue: uenums cannot have constructors that take parameters", enumType.pos);
      }

      // Generate the enum C++ definition
      var uname = MacroHelpers.extractStrings(enumType.meta, ":uname")[0];
      if (uname == null) uname = enumType.name;
      var headerDir = Globals.cur.haxeRuntimeDir;
      var target = MacroHelpers.extractStrings(enumType.meta, ":utargetmodule")[0];
      if (target == null) {
        target = Globals.cur.module;
      }
      if (target != null) {
        headerDir += '/../$target';
        if (!enumType.meta.has(':utargetmodule')) {
          enumType.meta.add(':utargetmodule', [macro $v{target}], enumType.pos);
          if (target == Globals.cur.module) {
            enumType.meta.add(':umainmodule', [], enumType.pos);
          }
        }
      }
      var headerPath = '$headerDir/Generated/Public/${uname.replace('.','/')}.h';
      if (!FileSystem.exists('$headerDir/Generated/Public')) {
        FileSystem.createDirectory('$headerDir/Generated/Public');
      }

      var writer = new HeaderWriter(headerPath);
      writer.include('$uname.generated.h');

      var uenum = enumType.meta.extract(':uenum')[0];
      writer.buf.add('UENUM(');
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
      writer.close(Globals.cur.module);

    default:
      throw 'assert';
    }
  }
}
