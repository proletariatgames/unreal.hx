package uhx.compiletime;
import uhx.compiletime.types.*;
import uhx.compiletime.tools.*;
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;

using haxe.macro.Tools;
using uhx.compiletime.tools.MacroHelpers;
using Lambda;
using StringTools;

class AutomationBuild {
  public static function build() {
    var localClass = Context.getLocalClass(),
        cls = localClass.get(),
        thisType = TypeRef.fromBaseType(cls, cls.pos);
    var pos = cls.pos;
#if bake_externs
    throw new Error('Do not use AutomationBuild on your "Externs" folder - instead, you can directly declare an extern class that extends unreal.automation.FAutomationTestBase', pos);
#end

    if (cls.superClass == null) {
      throw new Error('Invalid class. Should subclass unreal.automation.AutomationTest', pos);
    }

    if (Globals.cur.inScriptPass) {
      cls.meta.add(':uscript', [], cls.pos);
    }
    var fields:Array<Field> = Context.getBuildFields(),
        toAdd = [],
        changed = false;
    var overrides = new Map();
    for (f in fields) {
      if (f.access != null && f.access.has(AOverride)) {
        overrides[f.name] = true;
      }
      if (f.meta.hasMeta(':live')) {
        changed = true;
        uhx.compiletime.LiveReloadBuild.changeField(thisType, f, toAdd);
      }
    }

    if (cls.meta.has(':abstract')) {
      if (changed || toAdd.length > 0) {
        return fields.concat(toAdd);
      } else {
        return null;
      }
    }

    for (fn in ['RunTest', 'GetTestFlags']) {
      if (!overrides[fn]) {
        throw new Error('Automation classes must override `$fn`', pos);
      }
    }

    if (!overrides['GetTestSourceFileName']) {
      var dummy = macro class {
        override function GetTestSourceFileName():unreal.FString {
          return @:pos(pos) here().fileName;
        }

        override function GetTestSourceFileLine():Int {
          return @:pos(pos) here().lineNumber;
        }
      };
      for (f in dummy.fields) {
        toAdd.push(f);
      }
    }

    var uname = cls.getUName();
    if (!overrides['GetBeautifiedTestName']) {
      var dummy = macro class {
        override function GetBeautifiedTestName():unreal.FString {
          return $v{uname};
        }
      };
      toAdd.push(dummy.fields[0]);
    }

    if (overrides['GetTests'] && !overrides['IsComplexTask']) {
      var dummy = macro class {
        override function IsComplexTask():Bool {
          return true;
        }
      };
      toAdd.push(dummy.fields[0]);
    }

    if (!Context.defined('cppia')) {
      writeDef(cls);
    }
    if (toAdd.length > 0 || changed) {
      return fields.concat(toAdd);
    } else {
      return null;
    }
  }

  private static function writeDef(cls:ClassType) {
    if (Globals.cur.glueTargetModule != null && !cls.meta.has(':uextension')) {
      cls.meta.add(':utargetmodule', [macro $v{Globals.cur.glueTargetModule}], cls.pos);
      cls.meta.add(':uextension', [], cls.pos);
    }
    var info = GlueInfo.fromBaseType(cls),
        tref = TypeRef.fromBaseType(cls, cls.pos);
    var uname = info.uname.getClassPath(),
        nameWithout = info.uname.getClassPath();
    var cppPath = info.getCppPath(true),
        headerPath = info.getHeaderPath(false);

    if (sys.FileSystem.exists(headerPath)) {
      // delete a perhaps previous header path (e.g. before the file was converted to a struct)
      // we need this since NativeGlueCode will keep this file because of @:ufiledependency
      sys.FileSystem.deleteFile(headerPath);
    }
    var writer = new CppWriter(cppPath);
    writer.include("Engine.h");
    writer.include("uhx/HaxeAutomationTest.h");
    writer.include("uhx/internal/AutomationExpose.h");
    writer.include("uhx/ue/ClassMap.h");

    writer.buf.add('
    static void initAutomation${cls.name}() {
      static unreal::UIntPtr haxePtr = uhx::internal::AutomationExpose::createAutomation("${tref.getClassPath(true)}");
      if (haxePtr) {
        static uhx::FHaxeAutomationTest automationTest(haxePtr);
      }
    }
#if WITH_AUTOMATION_WORKER
    static uhx::ue::InitAdd init${cls.name}Helper(&initAutomation${cls.name});
#endif
    ');

    writer.close(info.targetModule);
    cls.meta.add(':ufiledependency', [macro $v{nameWithout + "@" + Globals.cur.module}], cls.pos);
    cls.meta.add(':ueGluePath', [], cls.pos);
  }
}
