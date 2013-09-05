library test_make_schema;

import 'package:simple_schema/simple_schema.dart';
import 'package:json_schema/json_schema.dart';
import 'dart:convert' as convert;
import 'package:unittest/unittest.dart';
// custom <additional imports>
import 'package:json_schema/schema_dot.dart';
// end <additional imports>


// custom <library test_make_schema>
import 'package:plus/pprint.dart';
// end <library test_make_schema>

main() { 
// custom <main>

  test('basic_types', () {
    var package = package('basic_types')
      ..types = [
        schema('composite_with_defaults')
        ..properties = [
          prop('a_number')..init = 3.14,
          prop('a_string')..init = "pi",
          prop('a_int')..init = 3,
          prop('a_object')..init = {},
          prop('a_array')..init = [],
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
