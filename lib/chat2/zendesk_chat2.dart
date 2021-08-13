import 'dart:async';

import 'package:zendesk2/chat2/model/chat_provider_model.dart';
import 'package:zendesk2/zendesk.dart';

class Zendesk2Chat {
  Zendesk2Chat._() {
    _channel.setMethodCallHandler(
      (call) async {
        try {
          switch (call.method) {
            case 'sendChatProvidersResult':
              final providerModel = ChatProviderModel.fromJson(call.arguments);
              _providersStream?.sink.add(providerModel);
              break;
          }
        } catch (e) {
          print(e);
        }
      },
    );
  }

  static final Zendesk2Chat instance = Zendesk2Chat._();

  static final _channel = Zendesk.instance.channel;

  /// added ignore so the source won't have warnings
  /// but don't forget to close or .dispose() when needed!!!
  /// ignore: close_sinks
  StreamController<ChatProviderModel>? _providersStream;

  bool _isLoggerEnabled = false;

  /// Initialize Chat Providers
  Future<void> init() async {
    try {
      await _channel.invokeMethod('init_chat');
    } catch (e) {
      print(e);
    }
  }

  /// Listen to all parameters of the connected Live Chat
  ///
  /// Stream is updated at Duration provided on ```startChatProviders```
  Stream<ChatProviderModel> get providersStream {
    _getChatProviders();
    return _providersStream!.stream.asBroadcastStream();
  }

  /// Set on Native/Custom chat user information
  ///
  /// ```name``` The name of the user identified
  ///
  /// ```email``` The email of the user identified
  ///
  /// ```phoneNumber``` The phone number of the user identified
  ///
  /// ```departmentName``` The chat department for chat, usually this field is empty
  ///
  /// ```tags``` The list of tags to represent the chat context
  Future<void> setVisitorInfo({
    String name = '',
    String email = '',
    String phoneNumber = '',
    String departmentName = '',
    List<String> tags = const [],
  }) async {
    final arguments = {
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'departmentName': departmentName,
      'tags': tags,
    };
    try {
      final result = await _channel.invokeMethod('setVisitorInfo', arguments);
      if (_isLoggerEnabled) {
        print('zendesk2: $result');
      }
    } catch (e) {
      print(e);
    }
  }

  /// LOG events of the SDK
  ///
  /// ```enabled``` if enabled, shows detailed information about the SDK actions
  Future<void> logger(bool enabled) async {
    _isLoggerEnabled = enabled;
    final arguments = {
      'enabled': enabled,
    };
    try {
      final result = await _channel.invokeMethod('logger', arguments);
      if (_isLoggerEnabled) {
        print('zendesk2: $result');
      }
    } catch (e) {
      print(e);
    }
  }

  /// Close connection and release resources
  Future<void> dispose() async {
    try {
      await _providersStream!.sink.close();
      await _providersStream!.close();
      _providersStream = null;
      final result = await _channel.invokeMethod('dispose_chat');
      if (_isLoggerEnabled) {
        print('zendesk2: $result');
      }
    } catch (e) {
      print(e);
    }
  }

  /// Start chat providers for custom UI handling
  ///
  /// ```periodicRetrieve``` periodic time to update the ```providersStream```
  /// ```autoConnect``` Determines if you also want to connect to the chat socket
  /// The user will not receive push notifications while connected
  Future<void> startChatProviders({bool autoConnect = true}) async {
    try {
      if (_providersStream != null) {
        await _providersStream!.sink.close();
        await _providersStream!.close();
      }
      _providersStream = StreamController<ChatProviderModel>();
      final result = await _channel.invokeMethod('startChatProviders');

      if (autoConnect) {
        await connect();
      }

      if (_isLoggerEnabled) {
        print('zendesk2: $result');
      }
    } catch (e) {
      print(e);
    }
  }

  /// Mark the user as connected, Call this method if you did not connect while initializing startChatProviders or when resuming from background state.
  /// The user will also stop receiving push notifications for new messages.
  Future<void> connect() async {
    try {
      final result = await _channel.invokeMethod('connect');
      if (_isLoggerEnabled) {
        print('zendesk2: $result');
      }
    } catch (e) {
      print(e);
    }
  }

  /// Disconect the web socket, important to call this to preserve battery power when app goes to background.
  ///  Usefull when going to background inside the chat screeen. The user will start receiving push notifications for new messages.
  Future<void> disconnect() async {
    try {
      final result = await _channel.invokeMethod('disconnect');
      if (_isLoggerEnabled) {
        print('zendesk2: $result');
      }
    } catch (e) {
      print(e);
    }
  }

  /// Providers only - send message
  ///
  /// ```message``` the message text that represents on live chat
  Future<void> sendMessage(String message) async {
    final arguments = {
      'message': message,
    };
    try {
      final result = await _channel.invokeMethod('sendMessage', arguments);
      if (_isLoggerEnabled) {
        print('zendesk2: $result');
      }
    } catch (e) {
      print(e);
    }
  }

  /// Providers only - update Zendesk panel if user is typing
  ///
  /// ```isTyping``` if true Zendesk panel will know that user is typing,
  /// otherwise not
  Future<void> sendTyping(bool isTyping) async {
    final arguments = {
      'isTyping': isTyping,
    };
    try {
      final result = await _channel.invokeMethod('sendIsTyping', arguments);
      if (_isLoggerEnabled) {
        print('zendesk2: $result');
      }
    } catch (e) {
      print(e);
    }
  }

  /// Providers only - end the live chat
  Future<void> endChat() async {
    try {
      final result = await _channel.invokeMethod('endChat');
      if (_isLoggerEnabled) {
        print('zendesk2: $result');
      }
    } catch (e) {
      print(e);
    }
  }

  /// Providers only - private function to update ```providersStream```
  Future<void> _getChatProviders() async {
    final value = await _channel.invokeMethod('getChatProviders');
    if (value != null) {
      final providerModel = ChatProviderModel.fromJson(value);
      _providersStream!.add(providerModel);
    }
  }

  /// Providers only - send file
  ///
  /// ```path``` the file path, that will represent the file attachment on live chat
  Future<void> sendFile(String path) async {
    final arguments = {
      'file': path,
    };
    try {
      final result = await _channel.invokeMethod('sendFile', arguments);
      if (_isLoggerEnabled) {
        print('zendesk2: $result');
      }
    } catch (e) {
      print(e);
    }
  }

  /// Providers only - retrieve all compatible file extensions for Zendesk live chat
  Future<List<String>?> getAttachmentExtensions() async {
    try {
      final value =
          await _channel.invokeMethod('compatibleAttachmentsExtensions');
      if (value != null && value is Iterable) {
        return value.map((e) => e.toString()).toList();
      }
    } catch (e) {
      print(e);
    }
    return null;
  }

  /// Register FCM Token for android push notifications
  Future<void> registerFCMToken(String token) async {
    try {
      final arguments = {
        'token': token,
      };
      final result = await _channel.invokeMethod('registerToken', arguments);
      if (_isLoggerEnabled) {
        print('zendesk2: $result');
      }
    } catch (e) {
      print(e);
    }
  }
}
