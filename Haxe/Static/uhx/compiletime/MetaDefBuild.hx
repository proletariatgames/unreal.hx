package uhx.compiletime;
import haxe.macro.Compiler;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import uhx.compiletime.types.*;
import uhx.meta.MetaDef;

using uhx.compiletime.tools.MacroHelpers;
using StringTools;
using Lambda;

/**
  Generates the metadata definitions (MetaDef) for the uproperties and ufunctions that will be added at runtime by cppia
 **/
class MetaDefBuild {
  public static function addUDelegateMetaDef(data:{ uname:String, hxName:String, isMulticast:Bool, args:Array<{ name:String, conv:TypeConv}>, ret:TypeConv, pos:Position }) {
    var func:UFunctionDef = {
      hxName: null,
      uname: null,
      args:[],
      ret:null,
    };
    for (arg in data.args) {
      var prop = arg.conv.toUPropertyDef();
      if (prop == null) {
        Context.warning('The type of delegate ${data.uname}\'s argument called ${arg.name} is not supported. This delegate will be ignored', data.pos);
        return;
      }
      prop.uname = arg.name;
      prop.hxName = arg.name;
      func.args.push(prop);
    }

    if (data.ret != null) {
      var retProp = data.ret.toUPropertyDef();
      if (retProp == null) {
        Context.warning('The return type of delegate ${data.uname} is not supported. This delegate will be ignored', data.pos);
        return;
      }
      retProp.uname = 'ReturnValue';
      func.ret = retProp;
    }

    var sigArr = func.args;
    if (func.ret != null) {
      sigArr = sigArr.copy();
      sigArr.push(func.ret);
    }

    var argsSig = Context.signature(sigArr);
    func.propSig = argsSig;

    var delDef:UDelegateDef = {
      uname: data.uname,
      isMulticast: data.isMulticast,
      signature: func
    };
    Globals.cur.scriptDelegateDefs.set(data.uname, delDef);
  }

  public static function addUClassMetaDef(base:ClassType) {
    var classDef:UClassDef = null;
    var superStructName = null;
    if (base.superClass != null) {
      var superClass = base.superClass.t.get();
      superStructName = MacroHelpers.getUName(superClass);
    }
    classDef = {
      uname: MacroHelpers.getUName(base),
      uprops: [],
      superStructUName: superStructName,

      metas:base.meta.extractMetaDef(':uclass', base.doc),

      isClass:base.meta.has(":uclass"),
    };
    if (classDef.uname == null) {
      classDef.uname = base.name;
    }

    for (field in base.fields.get()) {
      if (field.meta.has(':uproperty') && field.kind.match(FVar(_))) {
        var prop = TypeConv.get(field.type, field.pos).toUPropertyDef();
        if (prop == null) {
          Context.warning('This field (${field.name}) is marked as a uproperty but its type is not supported. It will be ignored', field.pos);
          continue;
        }
        prop.hxName = field.name;
        prop.uname = MacroHelpers.getUName(field);
        if (field.meta.has(':ureplicate')) {
          var repl:Null<UPropReplicationKind> = Always;
          var kind = field.meta.extractStrings(':ureplicate')[0];
          if (kind != null) {
            repl = UPropReplicationKind.fromString(kind);
            if (repl == null)
            {
              repl = Always;
              // check if the function really exists
              var fn = haxe.macro.TypeTools.findField(base, kind);
              if (fn == null)
              {
                throw new Error('The field ${field.name} defined a ureplicate function call ${kind}, but that function was not found in ${base.name}', field.pos);
              }
              prop.customReplicationName = kind;
            }
          }
          prop.replication = repl;
        }
        classDef.uprops.push(prop);
        var metas = field.meta.extractMetaDef(':uproperty', field.doc);
        if (metas.length != 0) {
          prop.metas = metas;
        }
        if (field.meta.has(':uexpose')) {
          if (prop.metas == null) {
            prop.metas = [];
          }
          prop.isCompiled = true;
          prop.metas.push({ name:'UnrealHxExpose', isMeta: true });
        }
      } else if (field.meta.has(':ufunction') && field.kind.match(FMethod(_))) {
        switch(Context.follow(field.type)) {
        case TFun(args,ret):
          var func:UFunctionDef = {
            hxName: field.name,
            uname: MacroHelpers.getUName(field),
            args:[],
            ret:null,
          };
          var supported = true;
          for (arg in args) {
            var prop = TypeConv.get(arg.t, field.pos).toUPropertyDef();
            if (prop == null) {
              Context.warning('The type of field ${field.name}\'s argument called ${arg.name} is not supported. This ufunction will be ignored', field.pos);
              supported = false;
              break;
            }
            prop.uname = arg.name;
            prop.hxName = arg.name;
            func.args.push(prop);
          }
          var sigArr = func.args;
          if (func.ret != null) {
            sigArr = sigArr.copy();
            sigArr.push(func.ret);
          }

          var metas = field.meta.extractMetaDef(':ufunction', field.doc);
          if (metas.length != 0) {
            func.metas = metas;
          }
          if (field.meta.has(':uexpose')) {
            if (func.metas == null) {
              func.metas = [];
            }
            func.isCompiled = true;
            func.metas.push({ name:'UnrealHxExpose', isMeta: true });
          }
          if (field.meta.has(':thisConst') && func.metas != null && func.metas.exists(function(meta) return meta.name.toLowerCase() == 'blueprintcallable')) {
            func.metas.push({ name: 'BlueprintPure', isMeta: false });
          }
          var relevantMeta = null;
          if (metas.length > 0) {
            relevantMeta = [for (meta in metas) if (!meta.isMeta) meta];
          }
          var argsSig = Context.signature({ sig:sigArr, meta:relevantMeta });
          func.propSig = argsSig;

          if (!supported) {
            continue;
          }

          var retProp = TypeConv.get(ret, field.pos).toUPropertyDef();
          if (retProp == null) {
            if (!TypeRef.fromType(ret, field.pos).isVoid()) {
              Context.warning('The return type of field ${field.name} is not supported. This ufunction will be ignored', field.pos);
              continue;
            }
          } else {
            retProp.uname = 'ReturnValue';
          }
          func.ret = retProp;

          if (classDef.ufuncs == null) {
            classDef.ufuncs = [];
          }
          classDef.ufuncs.push(func);
        case _:
          throw new Error('assert', field.pos);
        }
      }
    }
    var upropExpose = base.meta.has(':upropertyExpose');
    var relevantProps = [for (prop in classDef.uprops) {
      hxName:prop.hxName,
      uname:prop.uname,
      flags:prop.flags,
      isCompiled: upropExpose,
      typeUName:prop.typeUName,
      replication:prop.replication,
      customReplicationName:prop.customReplicationName,
      repNotify:prop.repNotify,
      metas:prop.metas == null ? null : [for (meta in prop.metas) if (!meta.isMeta) meta],
      params:prop.params,
    }];
    var propSignature = Context.signature(relevantProps);
    var crc = haxe.crypto.Crc32.make(haxe.io.Bytes.ofString(propSignature));
    if (crc == 0) {
      crc = 1; // don't let it be 0
    }
    classDef.propCrc = crc;
    classDef.propSig = propSignature;
    classDef.upropExpose = upropExpose;

    for (uprop in classDef.uprops) {
      if (uprop.replication != null || uprop.customReplicationName != null) {
        var ufunc = null;
        if (classDef.ufuncs != null && (ufunc = classDef.ufuncs.find(function(f) return f.uname.toLowerCase().startsWith('onrep_') &&
            f.uname.substr('onrep_'.length) == uprop.uname)) != null) {
          uprop.repNotify = ufunc.uname;
        }
      }
    }
    var meta:uhx.meta.MetaDef = { uclass:classDef };
    Globals.cur.addScriptDef(classDef.uname, { className:TypeRef.fromBaseType(base, base.pos).withoutModule().toString(), meta:meta });

    base.meta.remove('UMetaDef');
    base.meta.add('UMetaDef', [Context.makeExpr(meta, base.pos)], base.pos);
  }

  public static function writeStaticDefs() {
    var map = Globals.cur.staticUTypes;

    switch(Context.getType('uhx.meta.StaticMetaData')) {
    case TInst(c,_):
      var c = c.get();
      var oldMeta = c.meta.extract('UTypes');
      var oldDefs = [];
      for (meta in oldMeta) {
        if (meta.params != null) {
          for (param in meta.params) {
            var field = objGetField(param, "hxPath");
            if (field != null && !map.exists(field)) {
              oldDefs.push(param);
            }
          }
        }
      }
      c.meta.remove('UTypes');
      c.meta.add('UTypes', oldDefs.concat([for (val in map) macro $v{val}]), Context.currentPos());
    case _:
      Context.warning('Invalid type for StaticMetaData', Context.currentPos());
    }
  }

  private static function getClassHelper():ClassType {
    switch(Context.getType('uhx.meta.MetaDataHelper')) {
    case TInst(c,_):
      return c.get();
    case _:
      throw 'assert';
    }
  }

  public static function writeClassDefs() {
    var outputDir = haxe.io.Path.directory(Compiler.getOutput());
    var ntry = Std.int(Math.random() * 0x7FFFFFFF);
    var file = outputDir + '/gameCrcs.data';
    if (sys.FileSystem.exists(file)) {
      try {
        var reader = sys.io.File.read(file, true);
        reader.readInt32();
        ntry = reader.readInt32();
        ntry++;
        reader.close();
      }
      catch(e:Dynamic) {
        Context.warning('Error while reading old gameCrcs: $e', Context.currentPos());
      }
    }
    var file = sys.io.File.write(file, true);
    file.writeInt32(0xC5CC991A);
    file.writeInt32(ntry);

    var helper = Globals.cur.inCompilationServer ? getClassHelper() : null;
    var newData = [];
    var keys = Globals.cur.scriptClasses;
    var map = Globals.cur.scriptClassesDefs;
    var arr = [];

    var i = keys.length;
    // on the current implementation, the types array is reversed
    // so we'll add this in the right order. However, to be sure,
    // we also check the order at runtime at UnrealInit
    while(i --> 0) {
      var key = keys[i];
      var entry = map[key];
      var meta = entry.meta;
      if (meta.uclass != null && meta.uclass.propCrc != null) {
        arr.push({ haxeClass:entry.className, uclass:meta.uclass.uname });
        if (key.length > 255) {
          Context.warning('UClass key ${key} exceeds 255 characters', Context.currentPos());
          continue;
        }

        newData.push({ key:key, crc:meta.uclass.propCrc });
        file.writeInt8(key.length);
        file.writeString(key);
        file.writeInt32(meta.uclass.propCrc);
      }
    }

    if (helper != null) {
      var allMeta = helper.meta.extract('crcs')[0],
          newParams = [];
      if (allMeta != null && allMeta.params != null) {
        for (meta in allMeta.params) {
          switch(meta.expr) {
            case EObjectDecl(obj):
              var key = null,
                  crc = null;
              for (v in obj) {
                if (v.field == 'key') {
                  key = switch(v.expr.expr) {
                    case EConst(CString(s)):
                      s;
                    case e: trace('Bad meta value: $e'); break;
                  };
                } else if (v.field == 'crc') {
                  crc = switch(v.expr.expr) {
                    case EConst(CInt(i)):
                      Std.parseInt(i);
                    case e: trace('Bad meta value: $e'); break;
                  };
                }
              }
              if (!map.exists(key)) {
                file.writeInt8(key.length);
                file.writeString(key);
                file.writeInt32(crc);
                newParams.push(meta);
              }
            case _:
              trace('Bad metadata: $meta');
              continue;
          }
        }
      }
      for (data in newData) {
        newParams.push(macro $v{data});
      }
      helper.meta.remove('crcs');
      helper.meta.add('crcs', newParams, helper.pos);
    }
    file.writeInt8(0);
    file.close();

    switch(Context.getType('uhx.meta.CppiaMetaData')) {
    case TInst(c,_):
      var c = c.get();
      var oldMeta = c.meta.extract('DynamicClasses');
      var oldDefs = [];
      for (dyn in oldMeta) {
        if (dyn.params != null) {
          for (param in dyn.params) {
            var uclass = objGetField(param, 'uclass');
            if (uclass != null && !arr.exists(function(v) return v.uclass == uclass)) {
              oldDefs.push(param);
            }
          }
        }
      }
      c.meta.remove("DynamicClasses");
      c.meta.add('DynamicClasses', oldDefs.concat([for (v in arr) macro $v{v}]), Context.currentPos());

      var oldMeta = c.meta.extract('UDelegates');
      var oldDefs = [];
      for (meta in oldMeta) {
        if (meta.params != null) {
          for (param in meta.params) {
            var uname = objGetField(param, "uname");
            if (uname != null && !Globals.cur.scriptDelegateDefs.exists(uname)) {
              oldDefs.push(param);
            }
          }
        }
      }

      c.meta.remove("UDelegates");
      c.meta.add('UDelegates', oldDefs.concat([for (val in Globals.cur.scriptDelegateDefs) macro $v{val}]), Context.currentPos());
    case _:
      Context.warning('Invalid type for CppiaMetaData', Context.currentPos());
    }
  }

  private static function objGetField(objExpr:Expr, field:String):Null<String> {
    switch(objExpr.expr) {
    case EObjectDecl(obj):
      for (param in obj) {
        if (param.field == field) {
          switch(param.expr.expr) {
          case EConst(CString(s)):
            return s;
          case _:
            Context.warning('Unexpected expr ${param.expr} for field $field', objExpr.pos);
          }
        }
      }
    case _:
      Context.warning('Unexpected expr $objExpr', objExpr.pos);
    }

    return null;
  }

}
