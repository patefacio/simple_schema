import 'utils.dart';
import 'package:unittest/unittest.dart';
import 'test_make_schema.dart' as test_make_schema;

get rootPath => packageRootPath;

void testCore(Configuration config) {
  unittestConfiguration = config;
  main();
}

main() {
  test_make_schema.main();
}

