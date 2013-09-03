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
  String get label => 'map(${refId.camel})';
  String get definition => '#/definitions/$label';
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
  String get label => 'list(${refId.camel})';
  String get definition => '#/definitions/$label';
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
  bool isRequired = true;
  /// What type should be stored in the property
  dynamic type;
  /// Define property type by id
  String ref;

  // custom <class Property>

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

  // custom <class SimpleSchema>

  get jMaps => properties.where((prop) => prop is JMap);

  get jLists => properties.where((prop) => prop is JList);

  Map get _definition {
    var props = {};
    properties.forEach((prop) {
      var id = prop.id.camel;
      if(prop.ref != null) {
        props[id] = { r'$ref' : '#/definitions/$id' };
      } else if(prop.type != null) {
        var type = prop.type;
        if(type is JMap) {
          _package._addJMap(type);
          props[id] = { r'$ref' : "${type.definition}" };
        } else if(type is JList) {
          _package._addJList(type);
          props[id] = { r'$ref' : "${type.definition}" };
        } else {
          if(_package._hasType(type)) {
            props[id] = {
              r'$ref' : '#/definitions/${type}'
            };
          } else {
            var schemaType = SchemaType.fromString(type);
            if(schemaType == null) {
              print("GOOG $type");
            }
            props[id] = { "type": schemaType };
          }
        }
      } else {
        if(_package._hasType(id)) {
          props[id] = { r'$ref' : '#/definitions/$id' };
        } else if(prop.init != null) {
          var init = prop.init;
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
          props[id] = {
            "type" : type,
            "defaultValue": init,
          };
        } else {
          props[id] = { "type":"string" };
        }
      }
    });
    return {'properties' : props};
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
    if(definitions.containsKey(key)) {
      throw new FormatException("Error $key already defined");
    }
    definitions[key]=definition;
  }

  void _addJMap(JMap m) => 
    _addDefinition(m.label, {
      "type" : "object",
      "additionalProperties" : { 
        r'$ref' : '#/definitions/${m.refId.camel}' 
      }
    });

  void _addJList(JList l) =>
    _addDefinition(l.label, {
      "type" : "array",
      "items" : { 
        r'$ref' : '#/definitions/${l.refId.camel}' 
      }
    });

  bool _hasType(String type) => _schemaMap['definitions'].containsKey(type);
  
  void _finalize() {

    _schemaMap = { 'definitions' : {} };

    types.forEach((schema) {
      _addDefinition(schema.id.camel, {});
      schema.jMaps.forEach((jMap) => _addJmap(jMap));
      schema.jLists.forEach((jList) => _addJList(jList));
    });

    types.forEach((schema) {
      schema._package = this;
      var id = schema.id.camel;
      _schema(id).addAll(schema._definition);
    });
  }

  Future<Schema> get schema {
    if(_schemaMap == null) _finalize();
    print(jp(_schemaMap));
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

// end <part simple_schema>

