import 'dart:io' as IO;
import '';

class WebSocketService {
  // 1. Connection Management
  static const String serverUrl =
      'https://g5-flutter-learning-path-be-tvum.onrender.com';
  IO.Socket? _socket;
  final AuthService _authService = AuthService();

  // 2. Event Callbacks (Observer Pattern)
  Function(Message)? onMessageReceived;
  Function(Message)? onMessageDelivered;
  Function(String)? onMessageError;
  Function()? onConnected;
  Function()? onDisconnected;
}
