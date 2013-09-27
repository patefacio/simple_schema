import 'dart:convert' as convert;
import 'dart:io';
import 'package:ebisu/ebisu.dart';
import 'package:ebisu_dlang/dlang_meta.dart' as dlang_meta;
import 'package:path/path.dart';
import 'package:simple_schema/simple_schema.dart';
import 'package:simple_schema/simple_schema_dart.dart';
import 'package:simple_schema/simple_schema_dlang.dart' as dlang;
import 'package:json_schema/json_schema.dart';
import 'package:json_schema/schema_dot.dart';

main() {

  var outPath = './assets';

  var package = package('quantity_bin')
    ..defaultRequired = true
    ..enums = [
      enum('interpolation_type', 
          [ 'linear', 'step', 'cubic' ]),
      enum('payment_frequency_type',
          [
            'monthly',
            'annual',
            'semiannual',
            'once',
          ]),
    ]
    ..types = [
      schema('point')
      ..properties = [
        prop('x')..init = 0.0,
        prop('y')..init = 0.0,      
      ],
      schema('quantity_bin')
      ..properties = [
        prop('interpolation_type'),
        prop('data')..type = '[point]'
      ],
    ];     

  package..finalize();
  {
    var library = makeLibraryFromSimpleSchema(package);
    library.path = join(outPath, 'dart_generated');
    library.generate();
  }
  {
    var dPackage = dlang.makePackageFromSimpleSchema(package, []);
    dlang_meta.system('quantity_bin')
    ..rootPath = join(outPath, 'dlang_generated')
    ..packages = [ dPackage ]
    ..generate();
  }

  package
    .schema
    .then((schema) {
      mergeWithFile(createDot(schema), join(outPath, 'quantity_bin.dot'));
      var pngPath = join(outPath, 'quantity_bin.png');
      var dotPath = join(outPath, 'quantity_bin.dot');
      Process
        .run('dot', ['-Tpng', '-o$pngPath', dotPath])
        .then((ProcessResult processResult) {
          if(processResult.exitCode == 0) {
            print('Finished running dot -Tpng -o$pngPath $dotPath');
          } else {
            print('FAILED: running dot -Tpng -o$pngPath $dotPath');
            print(processResult.stdout);
            print(processResult.stderr);
          }
        })
        .catchError((e) {
          print('Failed to create image with dot!');
          stderr.write(e);
        });
    });
}
