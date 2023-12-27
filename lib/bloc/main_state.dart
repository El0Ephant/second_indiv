part of 'main_bloc.dart';

@immutable
sealed class MainState {
  final Camera camera;
  final bool shouldRebuild;
  final bool loading;
  final Map<String, Configuration> configs;

  const MainState({
    required this.camera,
    required this.configs,
    required this.shouldRebuild,
    required this.loading,
  });
}

class EmptyState extends MainState {
  final Model model;
  final String? message;

  const EmptyState(
      {required this.model,
      required super.configs,
      required super.camera,
      super.loading = false,
      super.shouldRebuild = false,
      this.message});

  @override
  EmptyState copyWith(
          {Model? model,
          Camera? camera,
          String? message,
          bool? loading,
          Map<String, Configuration>? configs}) =>
      EmptyState(
        model: model ?? this.model,
        camera: camera ?? this.camera,
        configs: configs ?? this.configs,
        message: message,
        loading: loading ?? this.loading,
      );
}

class RenderedState extends MainState {
  final List<List<({Color color, Offset pos})?>> pixels;

  const RenderedState({
    required this.pixels,
    required super.camera,
    required super.configs,
    required super.shouldRebuild,
    super.loading = false,
  });

  @override
  RenderedState copyWith({
    bool? shouldRebuild,
    List<List<({Color color, Offset pos})?>>? pixels,
    Camera? camera,
    Map<String, Configuration>? configs,
    bool? loading,
  }) =>
      RenderedState(
        camera: camera ?? this.camera,
        pixels: pixels ?? this.pixels,
        configs: configs ?? this.configs,
        shouldRebuild: shouldRebuild ?? this.shouldRebuild,
        loading: loading ?? this.loading,
      );
}
