import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:second_indiv/main.dart';
import 'package:second_indiv/main_page.dart';
import 'package:second_indiv/models/camera.dart';
import 'package:second_indiv/models/matrix.dart';
import 'package:second_indiv/models/intersectable.dart';
import 'package:second_indiv/models/primitives.dart';
import 'package:second_indiv/models/model.dart';
import 'package:second_indiv/models/sphere.dart';
import 'package:meta/meta.dart';
import 'package:vector_math/vector_math.dart' as vm;

part 'main_event.dart';

part 'main_state.dart';

class MainBloc extends Bloc<MainEvent, MainState> {
  MainBloc()
      : super(
          EmptyState(
            configs: {
              "куб": Configuration(),
              "параллелепипед": Configuration(),
              "маленькая сфера": Configuration(),
              "большая сфера": Configuration(),
              "левая стена": Configuration(),
              "правая стена": Configuration(),
              "верхняя стена": Configuration(),
              "задняя стена": Configuration(),
              "нижняя стена": Configuration(),
            },
            model: Model.cube(color: Colors.white),
            camera: Camera(
              eye: Point3D(1, 1, 6),
              target: Point3D(1, 1, 5.9),
              up: Point3D(0, 1, 0),
            ),
          ),
        ) {
    on<ShowMessageEvent>((event, emit) {
      emit((state as EmptyState).copyWith(message: event.message));
    });
    on<BuildEvent>(_onBuildEvent);
    on<ChangeConfigEvent>(_onChangeConfigEvent);
  }

  void _onChangeConfigEvent(ChangeConfigEvent event, Emitter<MainState> emit) {
    var configs = state.configs;
    switch (event.param) {
      case ConfigParam.isVisible:
        configs[event.key]!.isVisible = event.value;
        break;
      case ConfigParam.isMirror:
        configs[event.key]!.isMirror = event.value;
        if (event.value) {
          configs[event.key]!.isTransparent = false;
        }
        break;
      case ConfigParam.isTransparent:
        configs[event.key]!.isTransparent = event.value;
        if (event.value) {
          configs[event.key]!.isMirror = false;
        }
        break;
    }
    switch (state) {
      case EmptyState():
        emit((state as EmptyState).copyWith(configs: configs));
      case RenderedState():
        emit((state as RenderedState)
            .copyWith(configs: configs, shouldRebuild: false));
    }
  }

  void _onBuildEvent(BuildEvent event, Emitter<MainState> emit) async {
    switch (state) {
      case EmptyState():
        emit((state as EmptyState).copyWith(loading: true));
        break;
      case RenderedState():
        emit((state as RenderedState).copyWith(loading: true));
        break;
    }

    scene = getModels();
    final pixels = _render(10);
    emit(
      RenderedState(
        shouldRebuild: true,
        pixels: pixels,
        camera: state.camera,
        configs: state.configs,
        loading: false,
      ),
    );
  }

  List<Model> scene = [];
  int width = 0;
  int height = 0;
  final ambient = Point3D(0.05, 0.05, 0.05);
  Matrix view = Matrix.unit();
  Matrix projection = Matrix.unit();
  final Light light = Light(
    position: Point3D(1.0, 1.95, 4.3),
    color: Point3D(0.7, 0.7, 0.7),
  );

  List<Model> getModels() {
    return [
      Model(
        reflectivity: state.configs["задняя стена"]!.isMirror ? 0.85 : 0.0,
        transparency: state.configs["задняя стена"]!.isTransparent ? 0.95 : 0.0,
        color: Colors.white,
        points: [
          Point3D(2.5, 2, 0),
          Point3D(2.5, 0, 0),
          Point3D(-0.5, 0, 0),
          Point3D(-0.5, 2, 0)
        ],
        polygonsByIndexes: [
          [0, 1, 2],
          [2, 3, 0]
        ],
      ),
      Model(
        reflectivity: state.configs["левая стена"]!.isMirror ? 0.85 : 0.0,
        transparency: state.configs["левая стена"]!.isTransparent ? 0.95 : 0.0,
        color: Colors.red,
        points: [
          Point3D(-0.5, 2, 0),
          Point3D(-0.5, 0, 0),
          Point3D(-0.5, 0, 5),
          Point3D(-0.5, 2, 5)
        ],
        polygonsByIndexes: [
          [0, 1, 2],
          [2, 3, 0]
        ],
      ),
      Model(
        reflectivity: state.configs["правая стена"]!.isMirror ? 0.85 : 0.0,
        transparency: state.configs["правая стена"]!.isTransparent ? 0.95 : 0.0,
        color: Colors.blue,
        points: [
          Point3D(2.5, 0, 0),
          Point3D(2.5, 2, 0),
          Point3D(2.5, 0, 5),
          Point3D(2.5, 2, 5)
        ],
        polygonsByIndexes: [
          [0, 1, 2],
          [2, 1, 3]
        ],
      ),
      Model(
        reflectivity: state.configs["верхняя стена"]!.isMirror ? 0.85 : 0.0,
        transparency:
            state.configs["верхняя стена"]!.isTransparent ? 0.95 : 0.0,
        color: Colors.white,
        points: [
          Point3D(2.5, 2, 0),
          Point3D(-0.5, 2, 5),
          Point3D(2.5, 2, 5),
          Point3D(-0.5, 2, 0)
        ],
        polygonsByIndexes: [
          [0, 1, 2],
          [0, 3, 1]
        ],
      ),
      Model(
        reflectivity: state.configs["нижняя стена"]!.isMirror ? 0.85 : 0.0,
        transparency: state.configs["нижняя стена"]!.isTransparent ? 0.95 : 0.0,
        color: Colors.white,
        points: [
          Point3D(-0.5, 0, 0),
          Point3D(2.5, 0, 0),
          Point3D(-0.5, 0, 5),
          Point3D(2.5, 0, 5)
        ],
        polygonsByIndexes: [
          [0, 1, 2],
          [1, 3, 2]
        ],
      ),
      Model.cube(
        color: Colors.yellow,
        reflectivity: state.configs["параллелепипед"]!.isMirror ? 0.85 : 0.0,
        transparency:
            state.configs["параллелепипед"]!.isTransparent ? 0.95 : 0.0,
      )
          .getTransformed(Matrix.scaling(Point3D(0.5, 0.8, 0.5)))
          .getTransformed(Matrix.rotation(vm.radians(-40), Point3D(0, 1, 0)))
          .getTransformed(Matrix.translation(Point3D(1.5, 0, 3.5))),
      Model.cube(
        color: Colors.yellow,
        reflectivity: state.configs["куб"]!.isMirror ? 0.85 : 0.0,
        transparency: state.configs["куб"]!.isTransparent ? 0.95 : 0.0,
      )
          .getTransformed(Matrix.scaling(Point3D(0.3, 0.3, 0.3)))
          .getTransformed(Matrix.rotation(vm.radians(15), Point3D(0, 1, 0)))
          .getTransformed(Matrix.translation(Point3D(0.2, 0, 4))),
      Sphere(
        reflectivity: state.configs["маленькая сфера"]!.isMirror ? 0.85 : 0.0,
        transparency:
            state.configs["маленькая сфера"]!.isTransparent ? 0.95 : 0.0,
        color: Colors.purple,
        radius: 0.5,
        center: Point3D(1.0, 0.5, 2.5),
      ),
      Sphere(
        reflectivity: state.configs["большая сфера"]!.isMirror ? 0.85 : 0.0,
        transparency:
            state.configs["большая сфера"]!.isTransparent ? 0.95 : 0.0,
        color: Colors.white,
        radius: 0.3,
        center: Point3D(0.6, 0.3, 3.5),
      ),
    ];
  }

  List<List<({Color color, Offset pos})?>> _render(int depth) {
    List<List<({Color color, Offset pos})?>> pixels =
        List.generate(height, (_) => List.filled(width, null));

    view = Matrix.view(state.camera.eye, state.camera.target, state.camera.up);
    projection = Matrix.cameraPerspective(state.camera.fov, width / height,
        state.camera.nearPlane, state.camera.farPlane);

    for (var pixelRay in state.camera.getRays(width, height)) {
      final pixel = pixelRay.pixel;
      Point3D? color = _trace(pixelRay.ray, depth);

      if (color != null) {
        final resColor = Color.fromRGBO((color.x * 255).floor(),
            (color.y * 255).floor(), (color.z * 255).floor(), 1.0);
        pixels[pixel.dy.toInt()][pixel.dx.toInt()] =
            (color: resColor, pos: pixel);
      }
    }

    return pixels;
  }

  Point3D? _trace(Ray ray, int depth) {
    if (depth <= 0) {
      return Point3D(0, 0, 0);
    }

    Model? intersectionModel;
    Intersection? nearestIntersection;

    for (var model in scene) {
      var intersection = model.getIntersection(
          camera: state.camera, projection: projection, view: view, ray: ray);
      if (intersection == null) {
        continue;
      }
      if (nearestIntersection == null ||
          intersection.depth < nearestIntersection.depth) {
        nearestIntersection = intersection;
        intersectionModel = model;
      }
    }

    if (nearestIntersection == null) return null;

    if (intersectionModel!.transparency > 0.1) {
      Point3D light = Point3D.zero();
      Ray? refractedRay =
          _refract(ray, nearestIntersection, intersectionModel.refractiveIndex);
      if (refractedRay != null) {
        light += (_trace(refractedRay, depth - 1) ?? Point3D(0, 0, 0)) *
            intersectionModel.transparency;
      }
      return light;
    }

    if (intersectionModel.reflectivity > 0.1) {
      Point3D reflectedRayDirection =
          _reflect(ray.direction, nearestIntersection.normal);
      Ray reflectedRay = Ray(
          start: nearestIntersection.point + reflectedRayDirection * 0.001,
          direction: reflectedRayDirection);
      Point3D reflectedColor =
          _trace(reflectedRay, depth - 1) ?? Point3D(0, 0, 0);
      return reflectedColor * intersectionModel.reflectivity;
    }

    Point3D light = _getLocalLight(nearestIntersection, intersectionModel);
    return light.multiply(intersectionModel.objectColor);
  }

  Point3D _reflect(Point3D vector, Point3D normal) {
    return vector - normal * 2 * vector.dot(normal);
  }

  Ray? _refract(
    Ray incidentRay,
    Intersection intersection,
    double refractiveIndex,
  ) {
    double ratio = intersection.inside ? refractiveIndex : 1 / refractiveIndex;
    final incident = incidentRay.direction.normalized();
    final normal = intersection.normal * (intersection.inside ? -1 : 1);

    double cosi = normal.dot(incident);
    double k = 1 - ratio * ratio * (1 - cosi * cosi);
    if (k < 0) return null;

    final refracted = incident * ratio - normal * (sqrt(k) + ratio * cosi);
    return Ray(
      start: intersection.point + refracted * 0.001,
      direction: refracted,
    );
  }

  Point3D _getLocalLight(Intersection intersection, Model model) {
    Point3D col = Point3D.zero();
    double illuminationRatio;
    Point3D lightDir = (intersection.point - light.position).normalized();
    bool shadow = false;
    for (var object in scene) {
      final shadowRay = Ray(
          start: intersection.point - lightDir * 0.001, direction: -lightDir);
      final shadowIntersection = object.getIntersection(
        ray: shadowRay,
        view: view,
        projection: projection,
        camera: state.camera,
      );
      if (shadowIntersection != null &&
          (intersection.point - light.position).length() >
              (intersection.point - shadowIntersection.point).length()) {
        shadow = true;
        break;
      }
    }
    illuminationRatio = shadow ? 0.1 : 1.0;
    col += light.color *
            max(intersection.normal.dot(-lightDir), 0.0) *
            illuminationRatio +
        ambient;
    return col..limitTop(1.0);
  }
}
