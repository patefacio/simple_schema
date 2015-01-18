library simple_schema.simple_schema_dart;

import 'package:ebisu/ebisu.dart';
import 'package:ebisu/ebisu_dart_meta.dart';
import 'package:id/id.dart';
import 'package:logging/logging.dart';
import 'package:quiver/iterables.dart';
import 'package:simple_schema/simple_schema.dart';
// custom <additional imports>
// end <additional imports>

final _logger = new Logger('simple_schema_dart');

// custom <library simple_schema_dart>

var _typeMap = {
  'string' : 'String',
  'integer' : 'int',
  'double' : 'double',
  'dynamic' : 'dynamic',
  'number' : 'num',
  'object' : 'Map',
  'boolean' : 'bool',
  'date' : 'Date',
  'null' : 'null'
};

String _type(String type) {
  String result = _typeMap[type];
  var enumMatch;
  if(result != null) return result;
  if((result = listOf(type)) != null)
    return 'List<${_type(result)}>';
  if((result = mapOf(type)) != null)
    return 'Map<String,${_type(result)}>';
  if((enumMatch = enumMapOf(type)) != null)
    return 'Map<${_type(enumMatch.group(2))},${_type(enumMatch.group(1))}>';
  return idFromString(type).capCamel;
}

Library makeLibraryFromSimpleSchema(Package package,
    {
      Map overrideImports : const {},
      Set noDefaultCtorSet,
      Set opEqualsSet,
      Set immutablesSet,
      bool immutableByDefault : false
    }) {
  _logger.info("Making library for ${package.id}");
  var lib = library('${package.id.snake}')
    ..includeLogger = true;
  package.types.forEach((t) {

    var schemaClassId = t.id.camel;
    var classId = t.id.snake;

    if(overrideImports.containsKey(schemaClassId)) {
      if(overrideImports[schemaClassId] != null) {
        lib.imports.add(overrideImports[schemaClassId]);
      }
      return;
    }

    bool defaultCtor = (noDefaultCtorSet == null) ||
      !noDefaultCtorSet.contains(schemaClassId);

    bool opEquals = (opEqualsSet == null)? false :
      opEqualsSet.contains(schemaClassId);

    bool immutable = immutableByDefault ||
      ((immutablesSet == null)? false :
          immutablesSet.contains(schemaClassId));

    var klass = class_(classId)
      ..doc = t.doc
      ..opEquals = true
      ..copyable = true
      ..jsonSupport = true
      ..ctorSansNew = !immutable
      ..defaultCtor = defaultCtor && !immutable
      ..courtesyCtor = immutable
      ..builder = immutable
      ..allMembersFinal = immutable
      ..jsonToString = true;

    t.properties.forEach((prop) {

      var m = member(prop.id.snake)
        ..doc = prop.doc
        ..type = _type(prop.type);

      if(prop.init != null) {
        m.classInit = '${prop.init}';
      } else {
        if(m.type.contains('List<')) {
          m.classInit = '[]';
        } else if(m.type.contains('Map<')) {
          m.classInit = '{}';
        }
      }

      if(overrideImports.containsKey(prop.type)) {
        if(overrideImports[schemaClassId] != null) {
          lib.imports.add(overrideImports[prop.type]);
        }
      }

      klass.members.add(m);
    });
    lib.classes.add(klass);
  });

  lib
    ..variables.add(
      variable('random_json_generator')
      ..type = 'Random'
      ..isPublic = false
      ..init = 'new Random(0)')
    ..imports.addAll([
      'math',
      'package:plus/map_utilities.dart',
    ]);

  package.imports.forEach((pkg) {
    lib.imports.add('${pkg.id.snake}.dart');
  });

  package.enums.forEach((e) {
    lib.enums.add(
      enum_(e.id.snake)
      ..hasRandJson = true
      ..values = e.valueIds
      ..jsonSupport = true);
  });

  return lib;
}

// end <library simple_schema_dart>
