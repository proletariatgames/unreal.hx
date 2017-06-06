package uhx.compiletime;
import haxe.macro.Compiler;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import uhx.compiletime.types.*;
import uhx.meta.MetaDef;

using uhx.compiletime.tools.MacroHelpers;

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

      metas:base.meta.extractMetaDef(':uclass'),

      isClass:base.meta.has(":uclass"),
    };
    if (classDef.uname == null) {
      classDef.uname = base.name;
    }

    for (field in base.fields.get()) {
      if (field.meta.has(':uproperty') && !field.meta.has(':uexpose') && field.kind.match(FVar(_))) {
        var prop = TypeConv.get(field.type, field.pos).toUPropertyDef();
        if (prop == null) {
          Context.warning('This field (${field.name}) is marked as a uproperty but its type is not supported. It will be ignored', field.pos);
          continue;
        }
        prop.hxName = field.name;
        prop.uname = MacroHelpers.getUName(field);
        if (field.meta.has(':ureplicate')) {
          var repl:UPropReplicationKind = Always;
          var kind = field.meta.extractStrings(':ureplicate')[0];
          if (kind != null) {
            switch(kind.toLowerCase()) {
            case 'initialonly':
              repl = InitialOnly;
            case 'owneronly':
              repl = OwnerOnly;
            case 'skipowner':
              repl = SkipOwner;
            case 'simulatedonly':
              repl = SimulatedOnly;
            case 'autonomousonly':
              repl = AutonomousOnly;
            case 'simulatedorphysics':
              repl = SimulatedOrPhysics;
            case 'initialorowner':
              repl = InitialOrOwner;
            case _:
              prop.customReplicationName = kind;
            }
          }
          prop.replication = repl;
        }
        classDef.uprops.push(prop);
        var metas = field.meta.extractMetaDef(':uproperty');
        if (metas.length != 0) {
          prop.metas = metas;
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

          var argsSig = Context.signature(sigArr);
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

          var metas = field.meta.extractMetaDef(':ufunction');
          if (metas.length != 0) {
            func.metas = metas;
          }
          if (classDef.ufuncs == null) {
            classDef.ufuncs = [];
          }
          classDef.ufuncs.push(func);
        case _:
          throw new Error('assert', field.pos);
        }
      }
    }
    var propSignature = Context.signature(classDef.uprops);
    var crc = haxe.crypto.Crc32.make(haxe.io.Bytes.ofString(propSignature));
    if (crc == 0) {
      crc = 1; // don't let it be 0
    }
    classDef.propCrc = crc;
    classDef.propSig = propSignature;

    var meta:uhx.meta.MetaDef = { uclass:classDef };
    Globals.cur.addScriptDef(classDef.uname, { className:TypeRef.fromBaseType(base, base.pos).withoutModule().toString(), meta:meta });

    base.meta.add('UMetaDef', [Context.makeExpr(meta, base.pos)], base.pos);
  }

  public static function writeStaticDefs() {
    var map = Globals.cur.staticUTypes;
    var arr = [ for (val in map) val ];

    switch(Context.getType('uhx.meta.StaticMetaData')) {
    case TInst(c,_):
      var c = c.get();
      c.meta.remove('UTypes');
      c.meta.add('UTypes', [for (val in map) macro $v{val}], Context.currentPos());
    case _:
      Context.warning('Invalid type for StaticMetaData', Context.currentPos());
    }
  }

  public static function writeClassDefs() {
    var outputDir = haxe.io.Path.directory(Compiler.getOutput());
    var ntry = 0;
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

        file.writeInt8(key.length);
        file.writeString(key);
        file.writeInt32(meta.uclass.propCrc);
      }
    }
    file.writeInt8(0);
    file.close();

    switch(Context.getType('uhx.meta.CppiaMetaData')) {
    case TInst(c,_):
      var c = c.get();
      c.meta.remove('DynamicClasses');
      c.meta.add('DynamicClasses', [for (v in arr) macro $v{v}], Context.currentPos());
      c.meta.remove('UDelegates');
      c.meta.add('UDelegates', [for (val in Globals.cur.scriptDelegateDefs) macro $v{val}], Context.currentPos());
    case _:
      Context.warning('Invalid type for CppiaMetaData', Context.currentPos());
    }
  }

}
