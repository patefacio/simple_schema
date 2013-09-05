import "dart:io";
import "package:path/path.dart" as path;
import "package:ebisu/ebisu_dart_meta.dart";
import 'package:logging/logging.dart';
import 'package:logging_handlers/logging_handlers_shared.dart';

String _topDir;

void main() {

  Logger.root.onRecord.listen(new PrintHandler());
  Logger.root.level = Level.INFO;

  Options options = new Options();
  String here = path.absolute(options.script);
  _topDir = path.dirname(path.dirname(here));
  System ebisu = system('simple_schema')
    ..license = 'boost'
    ..includeReadme = true
    ..includeHop = true
    ..pubSpec.homepage = 'https://github.com/patefacio/simple_schema'
    ..pubSpec.version = '0.0.1'
    ..pubSpec.addDependency(new PubDependency('id'))
    ..pubSpec.addDependency(new PubDependency('json_schema'))
    ..pubSpec.addDependency(new PubDependency('ebisu'))
    ..pubSpec.doc = 'Provide declarative api for creating json schema'
    ..rootPath = '$_topDir'
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
      library('simple_schema_ebisu')
      ..includeLogger = true
      ..imports = [
        'package:ebisu/ebisu.dart',
        'package:ebisu/ebisu_dart_meta.dart',
      ],
      library('simple_schema')
      ..includeLogger = true
      ..variables = [
      ]
      ..enums = [
      ]
      ..imports = [
        'io',
        'math',
        'convert',
        '"dart:json" as JSON',
        '"package:path/path.dart" as PATH',
        'package:json_schema/json_schema.dart',
        'package:id/id.dart',
        'async',
      ]
      ..parts = [
        part('simple_schema')
        ..classes = [
          class_('j_map')
          ..doc = '''
Represents new shcema type (i.e. a schema itself) where type is object
and value schema is referenced by id
'''
          ..members = [
            member('ref_id')
            ..doc = 'Id of referred to schema for values in map'
            ..type = 'Id'
            ..ctors = [''],
          ],
          class_('j_list')
          ..doc = '''
Represents new shcema type (i.e. a schema itself) with an items
entry that has a reference schema referred to by refId.
'''
          ..members = [
            member('ref_id')
            ..doc = 'Id of referred to schema for items in list'
            ..type = 'Id'
            ..ctors = [''],
          ],
          class_('property')
          ..doc = 'Property entry in a schema'
          ..members = [
            member('id')
            ..doc = 'Id for property used to generate the name'
            ..type = 'Id'
            ..ctors = [''],
            member('init')
            ..type = 'dynamic'
            ..doc = 'Initial value, as perk type will be gleaned if provided',
            member('schema')
            ..access = RO
            ..type = 'SimpleSchema',
            member('is_required')
            ..type = 'bool',
            member('type')
            ..doc = 'What type should be stored in the property'
            ..type = 'dynamic',
          ],
          class_('simple_schema')
          ..doc = '''
A schema created from a simple, restricted set of rulesd defined by the
members of this class for easy declarative construction.
'''
          ..ctorSansNew = false
          ..members = [
            member('id')
            ..doc = 'Id for property used to generate the name'
            ..type = 'Id'
            ..ctorsOpt = [''],
            member('properties')
            ..doc = 'List of properties for this schema'
            ..type = 'List<Property>'
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
            member('default_required')
            ..doc = 'Set up all schema in package to be required by default'
            ..type = 'bool'
            ..classInit = 'true',
            member('types')
            ..doc = 'List of types (analagous to #/definitions/...'
            ..type = 'List<SimpleSchema>'
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
