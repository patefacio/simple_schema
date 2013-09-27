library quantity_bin;

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
      case LINEAR: return "LINEAR";
      case STEP: return "STEP";
      case CUBIC: return "CUBIC";
    }
  }

  static InterpolationType fromString(String s) {
    switch(s) {
      case "LINEAR": return LINEAR;
      case "STEP": return STEP;
      case "CUBIC": return CUBIC;
    }
  }

  int toJson() {
    return this.value;
  }

  static int randJson() {
   return _randomJsonGenerator.nextInt(3);
  }

  static InterpolationType fromJson(int v) {
    switch(v) {
      case 0: return LINEAR;
      case 1: return STEP;
      case 2: return CUBIC;
    }
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
      case MONTHLY: return "MONTHLY";
      case ANNUAL: return "ANNUAL";
      case SEMIANNUAL: return "SEMIANNUAL";
      case ONCE: return "ONCE";
    }
  }

  static PaymentFrequencyType fromString(String s) {
    switch(s) {
      case "MONTHLY": return MONTHLY;
      case "ANNUAL": return ANNUAL;
      case "SEMIANNUAL": return SEMIANNUAL;
      case "ONCE": return ONCE;
    }
  }

  int toJson() {
    return this.value;
  }

  static int randJson() {
   return _randomJsonGenerator.nextInt(4);
  }

  static PaymentFrequencyType fromJson(int v) {
    switch(v) {
      case 0: return MONTHLY;
      case 1: return ANNUAL;
      case 2: return SEMIANNUAL;
      case 3: return ONCE;
    }
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
    Map jsonMap = convert.JSON.decode(json);
    Point result = new Point();
    result._fromJsonMapImpl(jsonMap);
    return result;
  }

  static Point fromJsonMap(Map jsonMap) {
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
  List<Point> data;

  // custom <class QuantityBin>
  // end <class QuantityBin>

  Map toJson() {
    return {
    "interpolationType": ebisu_utils.toJson(interpolationType),
    "data": ebisu_utils.toJson(data),
    };
  }

  static QuantityBin fromJson(String json) {
    Map jsonMap = convert.JSON.decode(json);
    QuantityBin result = new QuantityBin();
    result._fromJsonMapImpl(jsonMap);
    return result;
  }

  static QuantityBin fromJsonMap(Map jsonMap) {
    QuantityBin result = new QuantityBin();
    result._fromJsonMapImpl(jsonMap);
    return result;
  }

  void _fromJsonMapImpl(Map jsonMap) {
    interpolationType = (jsonMap["interpolationType"] is Map)?
      InterpolationType.fromJsonMap(jsonMap["interpolationType"]) :
      InterpolationType.fromJson(jsonMap["interpolationType"]);
    // data list of Point
    data = new List<Point>();
    jsonMap["data"].forEach((v) {
      data.add(Point.fromJsonMap(v));
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

