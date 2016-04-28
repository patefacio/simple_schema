part of simple_schema.simple_schema;

class Enum {

  Enum
  (
  this.id
  ,
  [
  values
  ])
  : values = values
   ?? []

  ;

  Id id
  ;
  List<String> values
   = [];
  List<Id> get valueIds => _valueIds;

  // custom <class Enum>

  String get name => id.camel;

  toString() => '''
Enum($id) => [\n\t${zip([_valueIds, values]).map((l) => '${l[0]} -> ${l[1]}').join('\n\t')}]
''';

  void _finalize() {
    _valueIds = values.map((i) => new Id(i)).toList();
  }

  // end <class Enum>

  List<Id> _valueIds
  ;

}


/// Property entry in a schema
class Property {

  Property
  (
  this.id
  )
  ;

  /// Id for property used to generate the name
  Id id
  ;
  /// Documentation for the property
  String doc
  ;
  /// Initial value, as perk type will be gleaned if provided
  dynamic init
  ;
  SimpleSchema get schema => _schema;
  bool isRequired
  ;
  /// What type should be stored in the property
  var type
  ;

  // custom <class Property>

  void _finalize(SimpleSchema schema) {
    _schema = schema;
  }

  String get name => id.camel;

  // end <class Property>

  SimpleSchema _schema
  ;

}


/// A schema created from a simple, restricted set of rules defined by the
/// members of this class for easy declarative construction.
class SimpleSchema {

  SimpleSchema
  (
  [
  this.id
  ])
  ;

  /// Id for property used to generate the name
  Id id
  ;
  /// Documentation for the property
  String doc
  ;
  /// List of properties for this schema
  List<Property> properties
   = [];
  List<String> union
   = [];
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
      var propType = (prop.type == null)?
        ((prop.init != null)? inferTypeFromInit(prop.init) :
            (_package._hasType(name)? name : 'string')
         ) : prop.type;

      prop.type = propType;
      var schemaType = SchemaType.fromString(propType);
      if(schemaType != null) {
        props[name] = { "type": propType };
      } else {
        props[name] = ref(propType);
      }
    });


    var schemaMap = {};
    if(properties.length > 0) schemaMap['properties'] = props;

    union.forEach((entry) {
      schemaMap.putIfAbsent('oneOf', () => [])
        .add(ref(idFromString(entry).camel));
    });

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

  Package _package
  ;

}


/// A collection of packages
class Package {

  Package
  (
  this.id
  )
  ;

  /// Id for property used to generate the name
  Id id
  ;
  List<Package> imports
   = [];
  /// Set up all schema in package to be required by default
  bool defaultRequired
   = true;
  /// List of types (analagous to #/definitions/...
  List<SimpleSchema> types
   = [];
  List<Enum> enums
   = [];
  /// Map of defined types
  Map<String,SimpleSchema> get typeMap => _typeMap;

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

  void _addEnumMap(String k, String v) {
    _addDefinition('${idFromString(v).camel}[${idFromString(k).camel}]', {
      "type" : "object",
      "additionalProperties" : ref(v)
    });
  }

  bool _hasType(String type) =>
    _schemaMap['definitions'].containsKey(type) ||
    imports.any((package) => package._hasType(type));


  void finalize() {

    if(_schemaMap != null) return;

    _schemaMap = { 'definitions' : {} };

    imports.forEach((package) {
      package._schemaMap['definitions'].forEach((k,v) {
        if(_schemaMap['definitions'].containsKey(k)) {
          assert(_schemaMap['definitions'][k].toString() == v.toString());
        }
        _addDefinition(k, v);
      });
    });

    enums.forEach((e) => e._finalize());

    // Put empty stub entry for all schema types, including jMaps and jLists
    types.forEach((schema) {
      schema._finalize(this);
      _addDefinition(schema.name, {});
      String refType;
      schema.properties.where((prop) => prop.type != null).forEach((prop) {
        if(prop.type is String) {
          prop.type = _normalize(prop.type);
          if((refType = mapOf(prop.type)) != null) {
            _addJMap(refType);
          } else if((refType = listOf(prop.type)) != null) {
            _addJList(refType);
          } else {
            var enumMatch = enumMapOf(prop.type);
            if(enumMatch != null) {
              _addEnumMap(enumMatch.group(2), enumMatch.group(1));
            } else {
            }
          }
        } else if(prop.type is SimpleSchema) {
          _addDefinition(prop.type.name, prop.type._definition);
          prop.type = prop.type.name;
        }
      });
    });

    enums.forEach((e) {
      _addDefinition(e.name,
          {
            "enum" : e.valueIds.map((ev) => ev.capCamel).toList()
          }
                     );
    });

    types.forEach((schema) {
      _schema(schema.name).addAll(schema._definition);
    });
  }

  Future<Schema> get schema {
    if(_schemaMap == null) finalize();
    _logger.info(prettyJsonMap(_schemaMap));
    return Schema.createSchema(_schemaMap);
  }

  // end <class Package>

  Map<String,SimpleSchema> _typeMap
   = {};
  Map _schemaMap
  ;

}

// custom <part simple_schema>

Enum ssEnum(String id, [ List<String> values ]) {
  return new Enum(new Id(id), values);
}
Package package(String id) => new Package(idFromString(id));
SimpleSchema schema(String id) => new SimpleSchema(idFromString(id));
Property property(String id) => new Property(idFromString(id));
var prop = property;

var _jsonTypes =
  const [ 'array', 'integer', 'null', 'number', 'object', 'string', ];

ref(String name) => (_jsonTypes.indexOf(name) != -1)?
  { "type" : name } :
  { r'$ref' : '#/definitions/$name' };

SimpleSchema union(String id, List<String> oneOf) =>
  schema(id)
  ..union = oneOf;

// end <part simple_schema>

