part of 'main_bloc.dart';

@immutable
abstract class MainEvent {
  const MainEvent();
}
class ShowMessageEvent extends MainEvent {
  final String message;
  const ShowMessageEvent(this.message);
}

class BuildEvent extends MainEvent {
  const BuildEvent();
}

class ChangeConfigEvent extends MainEvent {
  final String key;
  final bool value;
  final ConfigParam param;
  const ChangeConfigEvent(this.key, this.param, this.value);
}

enum ConfigParam {
  isVisible,
  isMirror,
  isTransparent
}
