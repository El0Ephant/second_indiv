import 'package:second_indiv/models/primitives.dart';

import 'camera.dart';
import 'matrix.dart';

class Ray {
  final Point3D start, direction;
  const Ray({required this.start, required this.direction});
}

class Intersection {
  final double depth;
  final Point3D point;
  final Point3D normal;
  final bool inside;

  const Intersection(
      {required this.depth,
        required this.point,
        required this.normal,
        required this.inside});
}

abstract interface class Intersectable {
  Point3D get objectColor;

  double get reflectivity;

  double get transparency;

  double get refractiveIndex;

  Intersection? getIntersection(
      {required Ray ray,
        required Camera camera,
        required Matrix view,
        required Matrix projection});
}
