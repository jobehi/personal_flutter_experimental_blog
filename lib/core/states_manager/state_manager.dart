import 'dart:async';
import 'dart:collection';

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

  /// Controller to manage incoming events.
  final StreamController<E> _eventController = StreamController<E>();

  /// Queue to hold incoming events.
  final Queue<E> _eventQueue = Queue<E>();

  /// Flag to indicate if an event is currently being processed.
  bool _isProcessing = false;

  /// Subscription to the event stream.
  late final StreamSubscription<E> _eventSubscription;

  StateManager() {
    // Listen to incoming events and add them to the queue.
    _eventSubscription = _eventController.stream.listen((event) {
      _enqueueEvent(event);
    });
  }

  /// Adds an event to the event stream.
  void addEvent(E event) {
    _eventController.add(event);
  }

  /// Enqueues an event and starts processing if not already doing so.
  void _enqueueEvent(E event) {
    _eventQueue.add(event);
    if (!_isProcessing) {
      _processNextEvent();
    }
  }

  /// Processes the next event in the queue.
  void _processNextEvent() async {
    if (_eventQueue.isEmpty) {
      _isProcessing = false;
      return;
    }

    _isProcessing = true;
    final E event = _eventQueue.removeFirst();

    try {
      final Stream<T> stateStream = mapEventToState(event);
      await for (var state in stateStream) {
        _stateController.add(state);
      }
    } catch (e, stackTrace) {
      _stateController.addError(e, stackTrace);
    } finally {
      // After processing the current event, process the next one.
      _processNextEvent();
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

  /// Disposes resources by closing controllers and subscriptions.
  ///
  /// It's crucial to call this method when the [StateManager] is no longer needed
  /// to free up resources and prevent memory leaks.
  void dispose() {
    _eventSubscription.cancel();
    _eventController.close();
    _stateController.close();
  }
}
