library test_make_schema;

import 'package:simple_schema/simple_schema.dart';
import 'package:json_schema/json_schema.dart';
import 'dart:convert' as convert;
import 'package:unittest/unittest.dart';
// custom <additional imports>
import 'package:json_schema/schema_dot.dart';
import 'package:logging/logging.dart';
// end <additional imports>


// custom <library test_make_schema>
// end <library test_make_schema>

main() { 
// custom <main>

  Logger.root.onRecord.listen((LogRecord r) =>
      print("${r.loggerName}\t[${r.level}]:\t${r.message}"));

  test('basic_types', () {
    var package = package('basic_types')
      ..defaultRequired = false
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
        ],
      ];


    var checkResult = expectAsync1((schema) {
        schema = schema.definitions['compositeWithDefaults'];
        test('aNumber is numeric', 
            () => expect(schema.validate({"aNumber" : 4.4}), true));
        test('aNumber is not a string', 
            () => expect(schema.validate({"aNumber" : "foo"}), false));
        test('aString is string',
            () => expect(schema.validate({"aString" : "foo"}), true));
        test('aString is not a number',
            () => expect(schema.validate({"aString" : 3.14}), false));
        test('aInt is an int',
            () => expect(schema.validate({"aInt" : 3}), true));
        test('aInt is not a double',
            () => expect(schema.validate({"aInt" : 3.14}), false));
        test('aObject is an object',
            () => expect(schema.validate({"aObject" : {}}), true));
        test('aObject is not an int',
            () => expect(schema.validate({"aObject" : 3}), false));
        test('aObject is not an array',
            () => expect(schema.validate({"aObject" : []}), false));
        test('aArray is an array',
            () => expect(schema.validate({"aArray" : []}), true));
        test('aArray is not an object',
            () => expect(schema.validate({"aArray" : {}}), false));
        test('aArray is not an int',
            () => expect(schema.validate({"aArray" : 3}), false));

        test('aArrayOfInt is not an int',
            () => expect(schema.validate({"aArrayOfInt" : 3}), false));
        test('aArrayOfInt is not an array of string',
            () => expect(schema.validate({"aArrayOfInt" : ["a","b"]}), false));
        test('aArrayOfInt is an empty array',
            () => expect(schema.validate({"aArrayOfInt" : []}), true));
        test('aArrayOfInt is an array of int',
            () => expect(schema.validate({"aArrayOfInt" : 
              [-1,2,3]}), true));


        test('aArrayOfString is not an int',
            () => expect(schema.validate({"aArrayOfString" : 3}), false));
        test('aArrayOfString is not an array of int',
            () => expect(schema.validate({"aArrayOfString" : [1,2]}), false));
        test('aArrayOfString is an array of string',
            () => expect(schema.validate({"aArrayOfString" : 
              ["hi", "mom"]}), true));

        test('aArrayOfPod is an array of pod',
            () => expect(schema.validate({"aArrayOfPod" : 
              [ {'a' : 3}, {'a' : 5} ]}), true));

    });

    package.schema.then((schema) {
      checkResult(schema);
    });

  });

  //////////////////////////////////////////////////////////////////////
  // a depends on b and b depends on c and order does not matter
  //////////////////////////////////////////////////////////////////////
  test('order_independence', () {
    var package = package('order_independence')
      ..types = [
        schema('a')..properties = [ prop('b') ],
        schema('c'),
        schema('b')..properties = [ prop('c') ],
      ];

    var checkResult = expectAsync1((schema) => {});
    package.schema.then((schema) {
      checkResult(schema);
    });
  });

// end <main>

}
