part of simple_schema;

class Enum {
  Enum(
    this.id,
    [
      this.values
    ]
  ) {

  }

  Id id;
  List<String> values = [];
  List<Id> _valueIds;
  List<Id> get valueIds => _valueIds;

  // custom <class Enum>
  
  String get name => id.camel;

  void _finalize() {
    _valueIds = values.map((i) => new Id(i)).toList();
  }

  // end <class Enum>
}

/// Property entry in a schema
class Property {
  Property(
    this.id
  ) {

  }

  /// Id for property used to generate the name
  Id id;
  /// Initial value, as perk type will be gleaned if provided
  dynamic init;
  SimpleSchema _schema;
  SimpleSchema get schema => _schema;
  bool isRequired;
  /// What type should be stored in the property
  String type;

  // custom <class Property>

  void _finalize(SimpleSchema schema) {
    _schema = schema;
  }

  String get name => id.camel;

  // end <class Property>
}

/// A schema created from a simple, restricted set of rulesd defined by the
/// members of this class for easy declarative construction.
///
class SimpleSchema {
  SimpleSchema(
    [
      this.id
    ]
  ) {

  }

  /// Id for property used to generate the name
  Id id;
  /// List of properties for this schema
  List<Property> properties = [];
  Package _package;
  Package get package => _package;

  // custom <class SimpleSchema>

  get name => id.camel;

  void _finalize(Package pkg) {
    _package = pkg;
    properties.forEach((prop) => prop._finalize(this));
  }

  String inferTypeFromInit(dynamic init) {
    var type;
    if(init is List) {
      type = "array";
    } else if(init is bool) {
      type = "boolean";
    } else if(init is int) {
      type = "integer";
    } else if(init is num) {
      type = "number";
    } else if(init is Map) {
      type = "object";
    } else if(init is String) {
      type = "string";
    } else {
      type = "unknown";
    }
    return type;
  }
  
  Map get _definition {
    var props = {};

    properties.forEach((prop) {
      var name = prop.name;
      if(prop.init != null) {
        prop.type = inferTypeFromInit(prop.init);
        props[name] = {
          "type" : prop.type,
          "defaultValue": prop.init,
        };
      } else {
        if(prop.type != null) {
          var schemaType = SchemaType.fromString(prop.type);
          if(schemaType != null) {
            props[name] = { "type": schemaType };
          } else {
            props[name] = ref(prop.type);
          }
        } else {
          if(_package._hasType(name)) {
            prop.type = name;
            props[name] = ref(name);
          } else {
            prop.type = 'string';
            props[name] = { "type":"string" };
          }
        }
      }
    });


    var schemaMap = {'properties' : props};

    var requiredProps = properties
    .where((prop) => 
        prop.isRequired == null? 
        _package.defaultRequired : prop.isRequired)
    .map((prop) => prop.name)
    .toList();

    if(requiredProps.length > 0) {
      schemaMap['required'] = requiredProps;
    }

    return schemaMap;
  }


  // end <class SimpleSchema>
}

/// A collection of packages
///
class Package {
  Package(
    this.id
  ) {

  }

  /// Id for property used to generate the name
  Id id;
  List<Package> imports = [];
  /// Set up all schema in package to be required by default
  bool defaultRequired = true;
  /// List of types (analagous to #/definitions/...
  List<SimpleSchema> types = [];
  List<Enum> enums = [];
  Map<String,SimpleSchema> _typeMap = {};
  /// Map of defined types
  Map<String,SimpleSchema> get typeMap => _typeMap;
  Map _schemaMap;

  // custom <class Package>

  Map _schema(String id) => _schemaMap['definitions'][id];

  void _addDefinition(String key, dynamic definition) {
    var definitions = _schemaMap['definitions'];
    if(!definitions.containsKey(key)) {
      definitions[key]=definition;
    }
  }

  void _addJMap(String t) {
    _addDefinition('{$t}', {
      "type" : "object",
      "additionalProperties" : ref(t)
    });
  }

  void _addJList(String t) {
    _addDefinition('[$t]', {
      "type" : "array",
      "items" : ref(t)
    });
  }

  bool _hasType(String type) => _schemaMap['definitions'].containsKey(type);
  
  void finalize() {

    if(_schemaMap != null) return;

    _schemaMap = { 'definitions' : {} };

    enums.forEach((e) => e._finalize());

    // Put empty stub entry for all schema types, including jMaps and jLists
    types.forEach((schema) {
      schema._finalize(this);
      _addDefinition(schema.name, {});
      String refType;
      schema.properties.where((prop) => prop.type != null).forEach((prop) {
        prop.type = _normalize(prop.type);
        if((refType = mapOf(prop.type)) != null) {
          _addJMap(refType);
        } else if((refType = listOf(prop.type)) != null) {
          _addJList(refType);
        } else {
        }
      });
    });

    enums.forEach((enum) {
      _addDefinition(enum.name, 
          { 
            "enum" : range(enum.values.length).toList()
          }
                     );
    });

    types.forEach((schema) {
      _schema(schema.name).addAll(schema._definition);
    });
  }

  Future<Schema> get schema {
    if(_schemaMap == null) finalize();
    _logger.info(jp(_schemaMap));
    return Schema.createSchema(_schemaMap);
  }

  // end <class Package>
}
// custom <part simple_schema>

Enum enum(String id, [ List<String> values ]) {
  return new Enum(new Id(id), values);
}
Package package(String id) => new Package(idFromString(id));
SimpleSchema schema(String id) => new SimpleSchema(idFromString(id));
Property property(String id) => new Property(idFromString(id));
var prop = property;
ref(String name) => { r'$ref' : '#/definitions/$name' };

// end <part simple_schema>

