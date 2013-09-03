import 'package:unittest/unittest.dart';
import 'package:unittest/vm_config.dart';
import 'test_make_schema.dart' as test_make_schema;

void testCore(Configuration config) {
  unittestConfiguration = config;
  main();
}

main() {
  test_make_schema.main();
}

