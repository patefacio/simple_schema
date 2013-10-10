library simple_schema_dart;

import 'package:ebisu/ebisu.dart';
import 'package:ebisu/ebisu_dart_meta.dart';
import 'package:id/id.dart';
import 'package:logging/logging.dart';
import 'package:simple_schema/simple_schema.dart';
// custom <additional imports>
// end <additional imports>


final _logger = new Logger("simple_schema_dart");

// custom <library simple_schema_dart>

var _typeMap = {
  'string' : 'String',
  'integer' : 'int',
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

Library makeLibraryFromSimpleSchema(Package package) {
  _logger.info("Making library for ${package.id}");
  var lib = library('${package.id.snake}');
  package.types.forEach((t) {

    var classId = t.id.snake;
    if(classId == 'date') return;

    var klass = class_(classId)
      ..ctorSansNew = true
      ..hasRandJson = true
      ..jsonSupport = true;

    t.properties.forEach((prop) {

      var m = member(prop.id.snake)
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
      'math'
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

