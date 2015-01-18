library simple_schema.simple_schema;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:ebisu/ebisu_utils.dart';
import 'package:id/id.dart';
import 'package:json_schema/json_schema.dart';
import 'package:logging/logging.dart';
import 'package:quiver/iterables.dart';
// custom <additional imports>

// end <additional imports>

part 'src/simple_schema/simple_schema.dart';

final _logger = new Logger('simple_schema');

final RegExp _listRe = new RegExp(r"^\s*\[\s*(\w+)\s*\]\s*$");
final RegExp _mapRe = new RegExp(r"^\s*{\s*(\w+)\s*}\s*$");
final RegExp _enumMapRe = new RegExp(r"^(\w+)\s*\[\s*(\w+)\s*\]\s*$");
final RegExp _normalizeRe = new RegExp(r"^\s*[\[{]\s*(\w+)\s*[\]}]\s*$");
// custom <library simple_schema>

String listOf(String t) {
  var match = _listRe.firstMatch(t);
  return match != null? match.group(1) : null;
}

String mapOf(String t) {
  var match = _mapRe.firstMatch(t);
  return match != null? match.group(1) : null;
}

enumMapOf(String t) => _enumMapRe.firstMatch(t);

String _normalize(String t) {
  String refType;
  var enumMatch;
  if((refType = listOf(t)) != null) {
    return '[${idFromString(refType).camel}]';
  } else if((refType = mapOf(t)) != null) {
    return '{${idFromString(refType).camel}}';
  } else if((enumMatch = enumMapOf(t)) != null) {
    var key = enumMatch.group(2);
    var value = enumMatch.group(1);
    return '${idFromString(value).camel}[${idFromString(key).camel}]';
  }
  return idFromString(t).camel;
}

// end <library simple_schema>
