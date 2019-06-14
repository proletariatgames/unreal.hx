package uhx.compiletime.types;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

typedef ClassDataData<T : MemberData> = {
  name:String,
  pack:Array<String>,
  meta:MetaAccess,
  members:Map<String, T>,
  statics:Map<String, T>,
  parent:ClassData<T>
};

typedef MemberData = {
  name:String,
  meta:MetaAccess,
};

class FakeMetaAccess {
  var meta:Metadata;

  public function new(meta) {
    this.meta = meta;
  }

  /**
    Return the wrapped `Metadata` array.
    Modifying this array has no effect on the origin of `this` MetaAccess.
    The `add` and `remove` methods can be used for that.
  **/
  public function get() : Metadata {
    return this.meta;
  }

  /**
    Extract metadata entries by given `name`.
    If there's no metadata with such name, empty array `[]` is returned.
    If `name` is null, compilation fails with an error.
  **/
  public function extract( name : String ) : Array<MetadataEntry> {
    return [ for(meta in this.meta) if (meta.name == name) meta ];
  }

  /**
    Adds the metadata specified by `name`, `params` and `pos` to the origin
    of `this` MetaAccess.
    Metadata names are not unique during compilation, so this method never
    overwrites a previous metadata.
    If a `Metadata` array is obtained through a call to `get`, a subsequent
    call to `add` has no effect on that array.
    If any argument is null, compilation fails with an error.
  **/
  function add( name : String, params : Array<Expr>, pos : Position ) : Void {
    // this.meta.push({ name:name, params:params, pos:pos });
    throw 'Cannot add immutable FakeMetaAccess - it will take no effect';
  }

  /**
    Removes all `name` metadata entries from the origin of `this`
    MetaAccess.
    This method might clear several metadata entries of the same name.
    If a `Metadata` array is obtained through a call to `get`, a subsequent
    call to `remove` has no effect on that array.
    If `name` is null, compilation fails with an error.
  **/
  function remove( name : String ) : Void {
    // this.meta = [ for (meta in this.meta) if (meta.name != name) meta ];
    throw 'Cannot add immutable FakeMetaAccess - it will take no effect';
  }

  /**
    Tells if the origin of `this` MetaAccess has a `name` metadata entry.
    If `name` is null, compilation fails with an error.
  **/
  function has( name : String ) : Bool {
    for (meta in this.meta) {
      if (meta.name == name) {
        return true;
      }
    }
    return false;
  }
}

@:forward
abstract ClassData<T : MemberData>(ClassDataData<T>) from ClassDataData<T> {
  public function findField(field:String, isStatic=false) {
    var data:ClassData<T> = this;
    if (isStatic) {
      return data.statics.get(field);
    }

    while (data != null) {
      var field = data.members.get(field);
      if (field != null) {
        return field;
      }
      data = data.parent;
    }
    return null;
  }
}

abstract ClassCache<T : MemberData>(Map<String, ClassData<T>>) from Map<String, ClassData<T>> {
  inline public function new() {
    this = new Map();
  }

  inline public function findField(cls:ClassType, field:String, isStatic=false) {
    return getClassData(cls).findField(field, isStatic);
  }

  inline public function peekClassData(cls:ClassType) {
    if (cls == null || this == null) {
      return null;
    }

    var name = cls.pack.join('.') + '.' + cls.name;
    return this[name];
  }

  inline public function getClassData(cls:ClassType) {
    if (cls == null) {
      return null;
    }
    if (this == null) {
      this = new Map();
    }

    return getClassData_pvt(cls);
  }

  private function getClassData_pvt(cls:ClassType) {
    var name = cls.pack.join('.') + '.' + cls.name;
    var clsData = this[name];

    if (clsData == null) {
      var sup = null;
      if (cls.superClass != null) {
        sup = getClassData(cls.superClass.t.get());
      }
      var fields = [ for(field in cls.fields.get()) field.name => cast field ];
      var statics = [ for(field in cls.statics.get()) field.name => cast field ];
      this[name] = clsData = { name:cls.name, pack:cls.pack, meta:cls.meta, members:fields, statics:statics, parent:sup };
    }
    return clsData;
  }

  inline public function map() {
    return this;
  }
}

@:forward abstract UntypedClassCache(ClassCache<MemberData>) from ClassCache<MemberData>
{
  inline public function updateFromFields(cls:ClassType, fields:Array<Field>) {
    if (this == null) {
      this = new Map();
    }

    return updateFromFields_pvt(cls, fields);
  }

  public function updateFromFields_pvt(cls:ClassType, fields:Array<Field>) {
    var name = cls.pack.join('.') + '.' + cls.name;
    var clsData = this.map()[name];

    var sup = null;
    if (cls.superClass != null) {
      sup = this.getClassData(cls.superClass.t.get());
    }
    if (clsData == null) {
      this.map()[name] = clsData = { name:cls.name, pack:cls.pack, meta:cls.meta, members:null, statics:null, parent:sup };
    }
    var statics = [ for (field in fields) if (field.access != null && field.access.indexOf(AStatic) < 0) field.name => cast { name:field.name, meta:new FakeMetaAccess(field.meta)} ];
    var fields = [ for(field in fields) if (field.access == null || field.access.indexOf(AStatic) < 0) field.name => cast { name:field.name, meta:new FakeMetaAccess(field.meta)} ];
    clsData.members = fields;
    clsData.statics = statics;
  }
}
