library quantity_bin;

import 'dart:convert' as convert;
import 'dart:math';
import 'package:ebisu/ebisu_utils.dart' as ebisu_utils;
// custom <additional imports>
// end <additional imports>


class InterpolationType {
  static const LINEAR = const InterpolationType._(0);
  static const STEP = const InterpolationType._(1);
  static const CUBIC = const InterpolationType._(2);

  static get values => [
    LINEAR,
    STEP,
    CUBIC
  ];

  final int value;

  const InterpolationType._(this.value);

  String toString() {
    switch(this) {
      case LINEAR: return "Linear";
      case STEP: return "Step";
      case CUBIC: return "Cubic";
    }
  }

  static InterpolationType fromString(String s) {
    switch(s) {
      case "Linear": return LINEAR;
      case "Step": return STEP;
      case "Cubic": return CUBIC;
    }
  }

  int toJson() => value;
  static InterpolationType fromJson(int v) => values[v];

  static String randJson() {
   return values[_randomJsonGenerator.nextInt(3)].toString();
  }

}

class PaymentFrequencyType {
  static const MONTHLY = const PaymentFrequencyType._(0);
  static const ANNUAL = const PaymentFrequencyType._(1);
  static const SEMIANNUAL = const PaymentFrequencyType._(2);
  static const ONCE = const PaymentFrequencyType._(3);

  static get values => [
    MONTHLY,
    ANNUAL,
    SEMIANNUAL,
    ONCE
  ];

  final int value;

  const PaymentFrequencyType._(this.value);

  String toString() {
    switch(this) {
      case MONTHLY: return "Monthly";
      case ANNUAL: return "Annual";
      case SEMIANNUAL: return "Semiannual";
      case ONCE: return "Once";
    }
  }

  static PaymentFrequencyType fromString(String s) {
    switch(s) {
      case "Monthly": return MONTHLY;
      case "Annual": return ANNUAL;
      case "Semiannual": return SEMIANNUAL;
      case "Once": return ONCE;
    }
  }

  int toJson() => value;
  static PaymentFrequencyType fromJson(int v) => values[v];

  static String randJson() {
   return values[_randomJsonGenerator.nextInt(4)].toString();
  }

}

class Point {
  num x = 0.0;
  num y = 0.0;

  // custom <class Point>
  // end <class Point>

  Map toJson() {
    return {
    "x": ebisu_utils.toJson(x),
    "y": ebisu_utils.toJson(y),
    };
  }

  static Point fromJson(String json) {
    if(json == null) return null;
    Map jsonMap = convert.JSON.decode(json);
    Point result = new Point();
    result._fromJsonMapImpl(jsonMap);
    return result;
  }

  static Point fromJsonMap(Map jsonMap) {
    if(jsonMap == null) return null;
    Point result = new Point();
    result._fromJsonMapImpl(jsonMap);
    return result;
  }

  void _fromJsonMapImpl(Map jsonMap) {
    x = jsonMap["x"];
    y = jsonMap["y"];
  }

  static Map randJson() {
    return {
    "x": ebisu_utils.randJson(_randomJsonGenerator, num),
    "y": ebisu_utils.randJson(_randomJsonGenerator, num),
    };
  }

}
point() => new Point();

class QuantityBin {
  InterpolationType interpolationType;
  List<Point> data = [];

  // custom <class QuantityBin>
  // end <class QuantityBin>

  Map toJson() {
    return {
    "interpolationType": ebisu_utils.toJson(interpolationType),
    "data": ebisu_utils.toJson(data),
    };
  }

  static QuantityBin fromJson(String json) {
    if(json == null) return null;
    Map jsonMap = convert.JSON.decode(json);
    QuantityBin result = new QuantityBin();
    result._fromJsonMapImpl(jsonMap);
    return result;
  }

  static QuantityBin fromJsonMap(Map jsonMap) {
    if(jsonMap == null) return null;
    QuantityBin result = new QuantityBin();
    result._fromJsonMapImpl(jsonMap);
    return result;
  }

  void _fromJsonMapImpl(Map jsonMap) {
    interpolationType = (jsonMap["interpolationType"] is Map)?
      InterpolationType.fromJsonMap(jsonMap["interpolationType"]) :
      InterpolationType.fromJson(jsonMap["interpolationType"]);

    // data is List<Point>
    data = [];
    jsonMap["data"].forEach((v) {
      data.add((v is Map)?
      Point.fromJsonMap(v) :
      Point.fromJson(v));
    });
  }

  static Map randJson() {
    return {
    "interpolationType": ebisu_utils.randJson(_randomJsonGenerator, InterpolationType.randJson),
    "data":
       ebisu_utils.randJson(_randomJsonGenerator, [],
        () => Point.randJson()),
    };
  }

}
quantityBin() => new QuantityBin();

Random _randomJsonGenerator = new Random(0);

// custom <library quantity_bin>

main() {
  print(ebisu_utils.prettyJsonMap(QuantityBin.randJson()));
}

// end <library quantity_bin>

