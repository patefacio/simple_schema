module quantity_bin.quantity_bin;

import vibe.data.json;

enum InterpolationType { 
  Linear,
  Step,
  Cubic
}
enum PaymentFrequencyType { 
  Monthly,
  Annual,
  Semiannual,
  Once
}
struct Point { 
  double x = 0.0;
  double y = 0.0;

  // custom <struct public Point>
  // end <struct public Point>

}
struct QuantityBin { 
  InterpolationType interpolationType;
  immutable(Point)[] data;

  // custom <struct public QuantityBin>
  // end <struct public QuantityBin>

}
static if(1) unittest { 
  // custom <unittest quantity_bin>
  // end <unittest quantity_bin>
}
