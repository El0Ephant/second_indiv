import 'dart:math';
import 'dart:ui';

import 'package:second_indiv/models/camera.dart';
import 'package:second_indiv/models/matrix.dart';
import 'package:second_indiv/models/primitives.dart';
import 'package:second_indiv/models/intersectable.dart';
import 'package:second_indiv/models/model.dart';

class Sphere extends Model {
  @override
  final Point3D center;
  final double radius;

  Sphere.create({
    required super.color,
    required this.radius,
    required this.center,
    super.reflectivity = 0.0,
    super.transparency = 0.0,
    super.refractiveIndex = 1.03,
    required super.points,
    required super.polygonsByIndexes,
  });

  factory Sphere(
      {required color,
      required radius,
      required center,
      reflectivity = 0.0,
      transparency = 0.0,
      refractiveIndex = 1.03}) {
    var model = Model.icosahedron(color: color)
        .getTransformed(Matrix.scaling(Point3D(radius, radius, radius)))
        .getTransformed(Matrix.translation(center));

    return Sphere.create(
        color: color,
        radius: radius,
        center: center,
        reflectivity: reflectivity,
        transparency: transparency,
        points: model.points,
        polygonsByIndexes: model.polygonsByIndexes);
  }

  @override
  Intersection? getIntersection(
      {required Ray ray,
      required Camera camera,
      required Matrix view,
      required Matrix projection}) {
    Point3D oc = ray.start - center;
    double a = ray.direction.dot(ray.direction);
    double b = 2.0 * oc.dot(ray.direction);
    double c = oc.dot(oc) - radius * radius;
    double discriminant = b * b - 4 * a * c;

    if (discriminant < 0) {
      return null;
    } else {
      double t1 = (-b - sqrt(discriminant)) / (2 * a);
      double t2 = (-b + sqrt(discriminant)) / (2 * a);
      double t = t1 < t2 && t1 >= 0 ? t1 : t2;
      final intersection = ray.start + ray.direction * t;
      final normal = (intersection - center).normalized();
      if (t >= 0) {
        return Intersection(
            inside: ray.direction.dot(normal) > 0,
            normal: normal,
            point: intersection,
            depth: (intersection - ray.start).length());
      } else {
        return null;
      }
    }
  }
}
