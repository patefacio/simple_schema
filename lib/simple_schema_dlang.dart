library simple_schema_dlang;

import 'package:ebisu/ebisu.dart';
import 'package:ebisu_dlang/dlang_meta.dart' as dlang;
import 'package:id/id.dart';
import 'package:logging/logging.dart';
import 'package:simple_schema/simple_schema.dart' as schema;
// custom <additional imports>
// end <additional imports>


final _logger = new Logger("simple_schema_dlang");

// custom <library simple_schema_dlang>

var _typeMap = {
  'string' : 'string',
  'integer' : 'int',
  'number' : 'double',
  'boolean' : 'bool',
  'null' : 'null',
  'date' : 'Date',
};

String _type(String type) {
  String result = _typeMap[type];
  var enumMatch;
  if(result != null) return result;
  if((result = schema.listOf(type)) != null) 
    return 'const(${_type(result)})[]';
  if((result = schema.mapOf(type)) != null) 
    return '${_type(result)}[string]';
  if((enumMatch = schema.enumMapOf(type)) != null)
    return '${_type(enumMatch.group(1))}[${_type(enumMatch.group(2))}]';
  return idFromString(type).capCamel;
}

dlang.Package makePackageFromSimpleSchema(schema.Package schemaPackage,
    { 
      List<String> modulePath : const ['models'],
      Map overrideImports : const {},
      Map requiredImports : const {}
    } ) {
  _logger.info("Making D package for ${schemaPackage.id}");

  var id = schemaPackage.id.snake;

  if(modulePath.length == 0) {
    modulePath = [ schemaPackage.id.snake ];
  }

  var imports = [ 'vibe.data.json', 'stdio', 'opmix.ut' ];

  var module = dlang.module('${id}')
    ..customImports = true
    ..unitTest = true
    ..publicSection = true
    ..imports = imports;

  dlang.Package dPackage;

  modulePath
    .reversed
    .forEach((part) {
      dPackage = (dPackage == null)?
        (dlang.package(part)..modules = [ module ]) :
        (dlang.package(part)..packages = [ dPackage ]);
    });

  schemaPackage.imports.forEach((pkg) {
    module.publicImports.add("${modulePath.join('.')}.${pkg.id.snake}");
  });

  schemaPackage.types.forEach((t) {
    var structId = t.id.snake;
    if(structId == 'date') {
      module.imports.add('datetime');
      return;
    }
    if(overrideImports.containsKey(structId)) {
      module.imports.add(overrideImports[structId]);
      return;
    }
    if(requiredImports.containsKey(structId)) {
      module.imports.add(requiredImports[structId]);
    }
    var struct = dlang.struct(structId)
      ..publicSection = true
      ..mixins = [
        //dlang.tmixin('OpEquals')
      ];

    t.properties.forEach((prop) {

      var m = dlang.member(prop.id.snake)
        ..type = _type(prop.type);

      if(prop.init != null)
        m.init = '${prop.init}';

      if(prop.type == 'date')
        module.imports.add('datetime');

      struct.members.add(m);

    });

    module.structs.add(struct);
  });

  schemaPackage.enums.forEach((e) {

    if(overrideImports.containsKey(e.id.snake)) {
      module.imports.add(overrideImports[e.id.snake]);
      return;
    }

    module.enums.add(dlang
        .enum_(e.id.snake)
        ..values = e.valueIds.map((v) => dlang.ev(v.id)).toList());
  });
  
  return dPackage;
}

// end <library simple_schema_dlang>

