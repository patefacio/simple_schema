part of simple_schema;

/// Represents new shcema type (i.e. a schema itself) where type is object
/// and value schema is referenced by id
///
class JMap {
  JMap(
    this.refId
  ) {

  }

  /// Id of referred to schema for values in map
  Id refId;

  // custom <class JMap>
  String get name => 'map(${refId.camel})';
  String get definition => '#/definitions/$name';
  // end <class JMap>
}

/// Represents new shcema type (i.e. a schema itself) with an items
/// entry that has a reference schema referred to by refId.
///
class JList {
  JList(
    this.refId
  ) {

  }

  /// Id of referred to schema for items in list
  Id refId;

  // custom <class JList>
  String get name => 'list(${refId.camel})';
  String get definition => '#/definitions/$name';
  // end <class JList>
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
  dynamic type;

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

  get jMaps => properties.where((prop) => prop is JMap);

  get jLists => properties.where((prop) => prop is JList);

  get name => id.camel;

  void _finalize(Package pkg) {
    _package = pkg;
    _package._addDefinition(name, {});
    jMaps.forEach((jMap) => _package._addJmap(jMap));
    jLists.forEach((jList) => _package._addJList(jList));
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
      if(prop.init != null) {
          props[name] = {
            "type" : inferTypeFromInit(prop.init),
            "defaultValue": prop.init,
          };
      } else {
        var name = prop.name;
        if(prop.type != null) {
          var type = prop.type;
          if(type is JMap) {
            _package._addJMap(type);
            props[name] = ref(type.name);
          } else if(type is JList) {
            _package._addJList(type);
            props[name] = ref(type.name);
          } else {
            var asKey = idFromString(type).camel;
            if(_package._hasType(asKey)) {
              props[name] = ref(asKey);
            } else {
              var schemaType = SchemaType.fromString(type);
              if(schemaType == null) {
                throw 
                  new FormatException("No schema type for $type in prop $prop ");
              }
              props[name] = { "type": schemaType };
            }
          }
        } else {
          props[name] = _package._hasType(name)? 
            props[name] = ref(name) : { "type":"string" };
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
  /// Set up all schema in package to be required by default
  bool defaultRequired = true;
  /// List of types (analagous to #/definitions/...
  List<SimpleSchema> types = [];
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

  void _addJMap(JMap m) => 
    _addDefinition(m.name, {
      "type" : "object",
      "additionalProperties" : ref(m.refId.camel)
    });

  void _addJList(JList l) =>
    _addDefinition(l.name, {
      "type" : "array",
      "items" : ref(l.refId.camel)
    });

  bool _hasType(String type) => _schemaMap['definitions'].containsKey(type);
  
  void _finalize() {

    _schemaMap = { 'definitions' : {} };

    types.forEach((schema) {
      schema._finalize(this);
    });

    types.forEach((schema) {
      _schema(schema.name).addAll(schema._definition);
    });
  }

  Future<Schema> get schema {
    if(_schemaMap == null) _finalize();
    return Schema.createSchema(_schemaMap);
  }

  // end <class Package>
}
// custom <part simple_schema>

Package package(String id) => new Package(idFromString(id));
SimpleSchema schema(String id) => new SimpleSchema(idFromString(id));
Property property(String id) => new Property(idFromString(id));
var prop = property;
JMap jMap(String id) => new JMap(idFromString(id));
JList jList(String id) => new JList(idFromString(id));
ref(String name) => { r'$ref' : '#/definitions/$name' };

// end <part simple_schema>

