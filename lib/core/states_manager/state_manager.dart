import 'dart:async';

abstract class ScreenState<T> {
  const ScreenState();

  bool isEqual(T other);

  @override
  bool operator ==(Object other) {
    if (other is! T) {
      return false;
    }
    if (hashCode == other.hashCode) {
      return true;
    }
    return other is T && isEqual(other as T);
  }

  @override
  int get hashCode;
}

abstract class ScreenEvent<T> {
  const ScreenEvent();

  bool isEqual(T other);

  @override
  bool operator ==(Object other) {
    if (other is! T) {
      return false;
    }
    if (hashCode == other.hashCode) {
      return true;
    }
    final isReallyEqual = other is T && isEqual(other as T);
    return isReallyEqual;
  }

  @override
  int get hashCode;
}

/// Abstract class to manage state based on events.
///
/// [T] represents the state type extending [ScreenState].
/// [E] represents the event type extending [ScreenEvent].
abstract class StateManager<T extends ScreenState, E extends ScreenEvent> {
  /// Controller to manage and broadcast state changes.
  final StreamController<T> _stateController = StreamController<T>.broadcast();

  /// Getter for the state stream.
  Stream<T> get stateStream => _stateController.stream;

  E? _previousEvent;

  /// Adds an event to be processed.
  ///
  /// If the event is the same as the previous one, it will be ignored
  /// to prevent redundant state emissions.
  void addEvent(E event) {
    if (_previousEvent == event) {
      return;
    }
    _previousEvent = event;
    _processEvent(event);
  }

  /// Processes the given event and updates the state accordingly.
  ///
  /// Listens to the stream returned by [mapEventToState] and adds
  /// each new state to the [_stateController].
  void _processEvent(E event) {
    try {
      final Stream<T> stateStream = mapEventToState(event);
      // Listen to the state stream and add each state to the controller.
      stateStream.listen(
        (state) {
          _stateController.add(state);
        },
        onError: (error, stackTrace) {
          // Handle errors from the state stream.
          _stateController.addError(error, stackTrace);
        },
        onDone: () {
          // Optionally handle stream completion.
        },
        cancelOnError: false,
      );
    } catch (e, stackTrace) {
      // Handle synchronous errors.
      _stateController.addError(e, stackTrace);
    }
  }

  /// Listens to state changes of a specific subtype [S] of [T].
  ///
  /// Returns a stream that emits states of type [S] only.
  Stream<S> listenToState<S extends T>() {
    return _stateController.stream.where((state) => state is S).cast<S>();
  }

  /// Maps an event to a stream of states.
  ///
  /// Subclasses must implement this method to define how events
  /// are transformed into states.
  Stream<T> mapEventToState(E event);

  /// Disposes resources by closing the state controller.
  ///
  /// It's crucial to call this method when the [StateManager] is no longer needed
  /// to free up resources and prevent memory leaks.
  void dispose() {
    _stateController.close();
  }
}
