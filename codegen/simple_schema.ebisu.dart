import "dart:io";
import "package:path/path.dart" as path;
import "package:ebisu/ebisu_dart_meta.dart";
import 'package:logging/logging.dart';

String _topDir;

void main() {

  //////////////////////////////////////////////////////////////////////
  // Uncomment to log
  //Logger.root.onRecord.listen((LogRecord r) =>
  //    print("${r.loggerName} [${r.level}]:\t${r.message}"));

  String here = path.absolute(Platform.script.path);
  _topDir = path.dirname(path.dirname(here));
  System ebisu = system('simple_schema')
    ..license = 'boost'
    ..pubSpec.homepage = 'https://github.com/patefacio/simple_schema'
    ..pubSpec.version = '0.0.2'
    ..pubSpec.addDependency(new PubDependency('quiver'))
    ..pubSpec.doc = 'Provide declarative api for creating json schema'
    ..rootPath = '$_topDir'
    ..includesHop = true
    ..doc = 'The idea is provide simple api to provided guided creation of consistent json schema'
    ..testLibraries = [
      library('test_make_schema')
      ..imports = [
        'package:simple_schema/simple_schema.dart',
        'package:json_schema/json_schema.dart',
        "'dart:convert' as convert",
      ]
    ]
    ..libraries = [
      library('simple_schema_dart')
      ..includesLogger = true
      ..imports = [
        'package:ebisu/ebisu.dart',
        'package:ebisu/ebisu_dart_meta.dart',
        'package:id/id.dart',
        'package:simple_schema/simple_schema.dart',
        'package:quiver/iterables.dart',
      ],
      library('simple_schema')
      ..includesLogger = true
      ..variables = [
        variable('list_re')
        ..type = 'RegExp'
        ..isFinal = true
        ..isPublic = false
        ..init = r'new RegExp(r"^\s*\[\s*(\w+)\s*\]\s*$")',
        variable('map_re')
        ..type = 'RegExp'
        ..isFinal = true
        ..isPublic = false
        ..init = r'new RegExp(r"^\s*{\s*(\w+)\s*}\s*$")',
        variable('enum_map_re')
        ..type = 'RegExp'
        ..isFinal = true
        ..isPublic = false
        ..init = r'new RegExp(r"^(\w+)\s*\[\s*(\w+)\s*\]\s*$")',
        variable('normalize_re')
        ..type = 'RegExp'
        ..isFinal = true
        ..isPublic = false
        ..init = r'new RegExp(r"^\s*[\[{]\s*(\w+)\s*[\]}]\s*$")',
      ]
      ..enums = [
      ]
      ..imports = [
        'io',
        'math',
        'convert',
        'package:ebisu/ebisu.dart',
        'package:json_schema/json_schema.dart',
        'package:quiver/iterables.dart',
        'package:id/id.dart',
        'async',
      ]
      ..parts = [
        part('simple_schema')
        ..classes = [
          class_('enum')
          ..members = [
            member('id')
            ..type = 'Id'
            ..ctors = [''],
            member('values')
            ..ctorsOpt = ['']
            ..type = 'List<String>'
            ..classInit = '[]',
            member('value_ids')
            ..access = RO
            ..type = 'List<Id>',
          ],
          class_('property')
          ..doc = 'Property entry in a schema'
          ..members = [
            member('id')
            ..doc = 'Id for property used to generate the name'
            ..type = 'Id'
            ..ctors = [''],
            member('doc')
            ..doc = 'Documentation for the property',
            member('init')
            ..type = 'dynamic'
            ..doc = 'Initial value, as perk type will be gleaned if provided',
            member('schema')
            ..access = RO
            ..type = 'SimpleSchema',
            member('is_required')
            ..type = 'bool',
            member('type')
            ..type = 'var'
            ..doc = 'What type should be stored in the property',
          ],
          class_('simple_schema')
          ..doc = '''
A schema created from a simple, restricted set of rules defined by the
members of this class for easy declarative construction.
'''
          ..hasCtorSansNew = false
          ..members = [
            member('id')
            ..doc = 'Id for property used to generate the name'
            ..type = 'Id'
            ..ctorsOpt = [''],
            member('doc')
            ..doc = 'Documentation for the property',
            member('properties')
            ..doc = 'List of properties for this schema'
            ..type = 'List<Property>'
            ..classInit = '[]',
            member('union')
            ..type = 'List<String>'
            ..classInit = '[]',
            member('package')
            ..access = RO
            ..type = 'Package',
          ],
          class_('package')
          ..doc = '''
A collection of packages
'''
          ..members = [
            member('id')
            ..doc = 'Id for property used to generate the name'
            ..type = 'Id'
            ..ctors = [''],
            member('imports')
            ..type = 'List<Package>'
            ..classInit = '[]',
            member('default_required')
            ..doc = 'Set up all schema in package to be required by default'
            ..type = 'bool'
            ..classInit = 'true',
            member('types')
            ..doc = 'List of types (analagous to #/definitions/...'
            ..type = 'List<SimpleSchema>'
            ..classInit = '[]',
            member('enums')
            ..type = 'List<Enum>'
            ..classInit = '[]',
            member('type_map')
            ..doc = 'Map of defined types'
            ..type = 'Map<String,SimpleSchema>'
            ..access = RO
            ..classInit = '{}',
            member('schema_map')
            ..access = IA
            ..type = 'Map',
          ]
        ],
      ]
    ];
  ebisu.generate();
}
