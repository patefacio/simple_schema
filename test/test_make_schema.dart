library simple_schema.test_make_schema;

import 'dart:convert' as convert;
import 'package:json_schema/json_schema.dart';
import 'package:logging/logging.dart';
import 'package:simple_schema/simple_schema.dart';
import 'package:test/test.dart';

// custom <additional imports>
import 'package:json_schema/schema_dot.dart';
import 'package:logging/logging.dart';
// end <additional imports>

final _logger = new Logger('test_make_schema');

// custom <library test_make_schema>
// end <library test_make_schema>

main([List<String> args]) {
  Logger.root.onRecord.listen((LogRecord r) =>
      print("${r.loggerName} [${r.level}]:\t${r.message}"));
  Logger.root.level = Level.OFF;
// custom <main>

  //Logger.root.onRecord.listen((LogRecord r) =>
  //    print("${r.loggerName}\t[${r.level}]:\t${r.message}"));

    var pkg = package('basic_types')
      ..defaultRequired = false
      ..enums = [
        ssEnum('color', [ 'red', 'green', 'blue' ])
      ]
      ..types = [
        schema('pod')
        ..properties = [
          prop('a')..init = 42,
        ],
        schema('composite_with_defaults')
        ..properties = [
          prop('a_number')..init = 3.14,
          prop('a_string')..init = "pi",
          prop('a_int')..init = 3,
          prop('a_object')..init = {},
          prop('a_array')..init = [],
          prop('a_array_of_int')..type = '[integer]',
          prop('a_array_of_number')..type = '[number]',
          prop('a_array_of_string')..type = '[string]',
          prop('a_array_of_pod')..type = '[pod]',
          prop('a_map_of_int')..type = '{integer}',
          prop('a_map_of_number')..type = '{number}',
          prop('a_map_of_string')..type = '{string}',
          prop('a_map_of_pod')..type = '{pod}',
          prop('a_map_string_to_pod')..type = 'pod[string]',
          prop('a_map_of_int')..type = 'integer[string]',
          prop('a_map_indexed_by_color')..type = 'integer[color]',
        ],
      ];

  test('composites', () {
    var checkResult = expectAsync((schema) {
        schema = schema.definitions['compositeWithDefaults'];
        expect(schema.validate({"aNumber" : 4.4}), true);
        expect(schema.validate({"aNumber" : "foo"}), false);
        expect(schema.validate({"aString" : "foo"}), true);
        expect(schema.validate({"aString" : 3.14}), false);
        expect(schema.validate({"aInt" : 3}), true);
        expect(schema.validate({"aInt" : 3.14}), false);
        expect(schema.validate({"aObject" : {}}), true);
        expect(schema.validate({"aObject" : 3}), false);
        expect(schema.validate({"aObject" : []}), false);
        expect(schema.validate({"aArray" : []}), true);
        expect(schema.validate({"aArray" : {}}), false);
        expect(schema.validate({"aArray" : 3}), false);
        expect(schema.validate({"aArrayOfInt" : 3}), false);
        expect(schema.validate({"aArrayOfInt" : ["a","b"]}), false);
        expect(schema.validate({"aArrayOfInt" : []}), true);
        expect(schema.validate({"aArrayOfInt" : [-1,2,3]}), true);

        expect(schema.validate({"aArrayOfNumber" : 3}), false);
        expect(schema.validate({"aArrayOfNumber" : ["a","b"]}), false);
        expect(schema.validate({"aArrayOfNumber" : []}), true);
        expect(schema.validate({"aArrayOfNumber" : [-1,2,3.14]}), true);

        expect(schema.validate({"aArrayOfString" : 3}), false);
        expect(schema.validate({"aArrayOfString" : [1,2]}), false);
        expect(schema.validate({"aArrayOfString" : ["hi", "mom"]}), true);

        expect(schema.validate({"aArrayOfPod" :  [ {'a' : 3}, {'a' : 5} ]}), true);

        expect(schema.validate({"aMapOfInt" : 3}), false);
        expect(schema.validate({"aMapOfInt" : {"a":"b"}}), false);
        expect(schema.validate({"aMapOfInt" : {}}), true);
        expect(schema.validate({"aMapOfInt" : {"a":-1, "b":2, "c":3} }), true);

        expect(schema.validate({"aMapOfNumber" : 3}), false);
        expect(schema.validate({"aMapOfNumber" : {"a":"b"}}), false);
        expect(schema.validate({"aMapOfNumber" : {}}), true);
        expect(schema.validate({"aMapOfNumber" : {"a":-15, "b":2, "c":3.14}}), true);


        expect(schema.validate({"aMapOfString" : 3}), false);
        expect(schema.validate({"aMapOfString" : {"a":1}}), false);
        expect(schema.validate({"aMapOfString" : {"a":"hi", "b":"mom"}}), true);

        expect(schema.validate({"aMapOfPod" : {'k1' : {'a' : 3}, 'k2' : {'a' : 5} } }), true);

        expect(schema.validate({"aMapStringToPod" : {'k1' : {'a' : 3}, 'k2' : {'a' : 5} } }), true);
        expect(schema.validate({"aMapOfInt" : {'k1' : 3, 'k2' : 5 } }), true);

        /* These no longer work since enums are serialized as their numeric
        test('aMapIndexedByColor ',
            () => expect(schema.validate({"aMapIndexedByColor" :
              { 0 : 3, 2 : 5 } }), true));

        test('aMapIndexedByColor ',
            () => expect(schema.validate({"aMapIndexedByColor" :
              { 0 : 3, 5 : 5 } }), false));
        */

    });

    pkg.schema.then((schema) {
      checkResult(schema);
    });


  });

  //////////////////////////////////////////////////////////////////////
  // a depends on b and b depends on c and order does not matter
  //////////////////////////////////////////////////////////////////////
  test('order_independence', () {
    var pkg = package('order_independence')
      ..types = [
        schema('a')..properties = [ prop('b') ],
        schema('c'),
        schema('b')..properties = [ prop('c') ],
      ];

    var checkResult = expectAsync((schema) => {});
    pkg.schema.then((schema) {
      checkResult(schema);
    });
  });

// end <main>


}
