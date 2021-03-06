import 'package:logging/logging.dart';
import 'test_make_schema.dart' as test_make_schema;

main() {
  Logger.root.level = Level.OFF;
  Logger.root.onRecord.listen((LogRecord rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });

  test_make_schema.main();
}

