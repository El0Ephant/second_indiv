import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:second_indiv/painters/ray_painter.dart';

import 'bloc/main_bloc.dart';

final canvasAreaKey = GlobalKey();

class MainPage extends StatelessWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 300,
              child: BlocBuilder<MainBloc, MainState>(
                builder: (context, state) {
                  final configs = state.configs.entries.toList();
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 20),
                    child: Column(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            context.read<MainBloc>().add(const BuildEvent());
                          },
                          child: state.loading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  'Построить',
                                ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: configs.length,
                          itemBuilder: (context, index) => Column(
                            children: [
                              Text(configs[index].key),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 2,
                                  horizontal: 15,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Показать'),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Checkbox(
                                      value: configs[index].value.isVisible,
                                      onChanged: (value) {
                                        if (value != null) {
                                          context.read<MainBloc>().add(
                                                ChangeConfigEvent(
                                                  configs[index].key,
                                                  ConfigParam.isVisible,
                                                  value,
                                                ),
                                              );
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 2,
                                  horizontal: 15,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Прозрачно'),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Checkbox(
                                      value: configs[index].value.isTransparent,
                                      onChanged: (value) {
                                        if (value != null) {
                                          context.read<MainBloc>().add(
                                                ChangeConfigEvent(
                                                  configs[index].key,
                                                  ConfigParam.isTransparent,
                                                  value,
                                                ),
                                              );
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 2,
                                  horizontal: 15,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Зеркально'),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Checkbox(
                                      value: configs[index].value.isMirror,
                                      onChanged: (value) {
                                        if (value != null) {
                                          context.read<MainBloc>().add(
                                                ChangeConfigEvent(
                                                  configs[index].key,
                                                  ConfigParam.isMirror,
                                                  value,
                                                ),
                                              );
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            BlocBuilder<MainBloc, MainState>(
              buildWhen: (previous, current) => current.shouldRebuild,
              builder: (context, state) {
                return Expanded(
                  child: RepaintBoundary(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        context.read<MainBloc>().width =
                            constraints.maxWidth.toInt();
                        context.read<MainBloc>().height =
                            constraints.maxHeight.toInt();
                        return ClipRRect(
                          key: canvasAreaKey,
                          child: CustomPaint(
                            foregroundPainter: switch (state) {
                              RenderedState() =>
                                RayPainter(pixels: state.pixels),
                              EmptyState() => null,
                            },
                            child: Container(
                              color: Theme.of(context).colorScheme.background,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class Configuration {
  bool isVisible;
  bool isMirror;
  bool isTransparent;

  Configuration(
      {this.isVisible = true,
      this.isMirror = false,
      this.isTransparent = false});
}
