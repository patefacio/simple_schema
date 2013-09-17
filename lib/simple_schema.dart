library simple_schema;

import 'dart:io';
import 'dart:math';
import 'dart:convert';
import 'dart:json' as JSON;
import 'package:path/path.dart' as PATH;
import 'package:json_schema/json_schema.dart';
import 'package:quiver/iterables.dart';
import 'package:id/id.dart';
import 'dart:async';
import 'package:logging/logging.dart';
// custom <additional imports>

// end <additional imports>

part "src/simple_schema/simple_schema.dart";

final _logger = new Logger("simple_schema");

final RegExp _listRe = new RegExp(r"^\s*\[\s*(\w+)\s*\]\s*$");

final RegExp _mapRe = new RegExp(r"^\s*{\s*(\w+)\s*}\s*$");

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

String _normalize(String t) {
  String refType;
  if((refType = listOf(t)) != null) {
    return '[${idFromString(refType).camel}]';
  } else if((refType = mapOf(t)) != null) {
    return '{${idFromString(refType).camel}}';
  }
  return idFromString(t).camel;
}

// end <library simple_schema>

