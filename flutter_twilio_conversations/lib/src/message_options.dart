part of flutter_twilio_conversations;

class MessageOptions {
  //#region Private API properties
  String? _body;

  Map<String, dynamic>? _attributes;

  File? _input;

  String? _mimeType;

  String? _filename;

  int? _mediaProgressListenerId;

  /// Monotonic source for [_mediaProgressListenerId]. A wall-clock timestamp
  /// could collide when two media messages are prepared in the same tick.
  static int _nextMediaProgressListenerId = 0;

  /// Callbacks of every send that is currently in flight with a progress
  /// listener, keyed by [_mediaProgressListenerId].
  ///
  /// The plugin exposes a single media progress [EventChannel] for all sends.
  /// Flutter keeps one Dart handler per channel name, so each send must not
  /// open its own `receiveBroadcastStream()`: a second `listen` would replace
  /// the first, and a `cancel` would tear down the channel for everyone.
  /// Instead the package holds one shared subscription and fans events out
  /// by id.
  static final Map<int, _MediaProgressListener> _mediaProgressListeners = {};

  /// The shared subscription behind [_mediaProgressListeners]. Opened when the
  /// first listener registers and cancelled when the last one is disposed.
  static StreamSubscription<dynamic>? _mediaProgressSubscription;
  //#endregion

  //#region Public API methods
  /// Create message with given body text.
  ///
  /// If you specify [MessageOptions.withBody] then you will not be able to specify [MessageOptions.withMedia] because they are mutually exclusive message types.
  /// Created message type will be [MessageType.TEXT].
  void withBody(String body) {
    if (_input != null) {
      throw Exception('MessageOptions.withMedia has already been specified');
    }
    _body = body;
  }

  /// Set new message attributes.
  void withAttributes(Map<String, dynamic> attributes) {
    _attributes = attributes;
  }

  /// Create message with given media stream.
  ///
  /// If you specify [MessageOptions.withMedia] then you will not be able to specify [MessageOptions.withBody] because they are mutually exclusive message types. Created message type will be [MessageType.MEDIA].
  void withMedia(File input, String mimeType) {
    if (_body != null) {
      throw Exception('MessageOptions.withBody has already been specified');
    }
    _input = input;
    _mimeType = mimeType;
  }

  /// Provide optional filename for media.
  void withMediaFileName(String filename) {
    _filename = filename;
  }

  /// Subscribe to upload progress for the media attached with [withMedia].
  ///
  /// The listener is released automatically once [Messages.sendMessage]
  /// completes (successfully or not), so it never outlives the send.
  /// Concurrent sends each get their own listener as long as each uses its
  /// own [MessageOptions]: one options object serves one send. Sending the
  /// same object twice in parallel would share one listener id, and the
  /// first send to settle would release it for both.
  void withMediaProgressListener({
    void Function()? onStarted,
    void Function(int bytes)? onProgress,
    void Function(String mediaSid)? onCompleted,
  }) {
    _unregisterMediaProgressListener();
    final id = ++_nextMediaProgressListenerId;
    _mediaProgressListenerId = id;
    _mediaProgressListeners[id] = _MediaProgressListener(
      onStarted: onStarted,
      onProgress: onProgress,
      onCompleted: onCompleted,
    );
    _mediaProgressSubscription ??= TwilioConversationsClient
        ._mediaProgressChannel
        .receiveBroadcastStream()
        .listen(_dispatchMediaProgressEvent);
  }

  static void _dispatchMediaProgressEvent(dynamic event) {
    final eventData = Map<String, dynamic>.from(event);
    final listener =
        _mediaProgressListeners[eventData['mediaProgressListenerId']];
    if (listener == null) {
      return;
    }
    switch (eventData['name']) {
      case 'started':
        listener.onStarted?.call();
        break;
      case 'progress':
        listener.onProgress?.call(eventData['data'] as int);
        break;
      case 'completed':
        listener.onCompleted?.call(eventData['data'] as String);
        break;
    }
  }

  /// Drop this options object's callbacks from the registry without touching
  /// the shared subscription.
  void _unregisterMediaProgressListener() {
    final id = _mediaProgressListenerId;
    _mediaProgressListenerId = null;
    if (id != null) {
      _mediaProgressListeners.remove(id);
    }
  }

  /// Release the listener registered by [withMediaProgressListener] and, if
  /// it was the last one in flight, cancel the shared channel subscription.
  /// Called by [Messages.sendMessage] when the send settles; safe to call
  /// when no listener was registered.
  Future<void> _disposeMediaProgressListener() async {
    _unregisterMediaProgressListener();
    if (_mediaProgressListeners.isNotEmpty) {
      return;
    }
    final subscription = _mediaProgressSubscription;
    _mediaProgressSubscription = null;
    await subscription?.cancel();
  }
  //#endregion

  /// Create map from properties.
  Map<String, dynamic> toMap() {
    return {
      'body': _body,
      'attributes': _attributes,
      'input': _input?.path,
      'mimeType': _mimeType,
      'filename': _filename,
      'mediaProgressListenerId': _mediaProgressListenerId,
    };
  }
}

class _MediaProgressListener {
  final void Function()? onStarted;
  final void Function(int bytes)? onProgress;
  final void Function(String mediaSid)? onCompleted;

  const _MediaProgressListener({
    this.onStarted,
    this.onProgress,
    this.onCompleted,
  });
}
