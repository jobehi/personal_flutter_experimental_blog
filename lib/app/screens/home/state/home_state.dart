import 'package:flutter/material.dart';
import 'package:youssef_el_behi/core/states_manager/state_manager.dart';

abstract class HomeScreenState extends ScreenState<HomeScreenState> {
  const HomeScreenState();

  @override
  bool isEqual(HomeScreenState other);
}

class HomeScreenMouseOffsetState extends HomeScreenState {
  final Offset mousePositionPercentage;

  const HomeScreenMouseOffsetState({required this.mousePositionPercentage});

  @override
  isEqual(HomeScreenState other) {
    return other is HomeScreenMouseOffsetState &&
        other.mousePositionPercentage == mousePositionPercentage;
  }
}

abstract class HomeScreenEvent extends ScreenEvent<HomeScreenEvent> {
  const HomeScreenEvent();
}

class HomeScreenMouseOffsetEvent extends HomeScreenEvent {
  final Offset mousePositionPercentage;

  const HomeScreenMouseOffsetEvent({required this.mousePositionPercentage});

  @override
  bool isEqual(HomeScreenEvent other) {
    return other is HomeScreenMouseOffsetEvent &&
        other.mousePositionPercentage == mousePositionPercentage;
  }
}

class HomeStateManager extends StateManager<HomeScreenState, HomeScreenEvent> {
  static final HomeStateManager _instance = HomeStateManager._internal();

  factory HomeStateManager() {
    return _instance;
  }

  HomeStateManager._internal();

  @override
  Stream<HomeScreenState> mapEventToState(HomeScreenEvent event) async* {
    if (event is HomeScreenMouseOffsetEvent) {
      yield HomeScreenMouseOffsetState(
          mousePositionPercentage: event.mousePositionPercentage);
    }
  }
}
