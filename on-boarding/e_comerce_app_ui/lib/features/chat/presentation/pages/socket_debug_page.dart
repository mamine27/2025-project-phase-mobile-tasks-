import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/network/socket.dart';
import '../../../../injection_container.dart';

class SocketDebugPage extends StatefulWidget {
  static const routeName = '/socket-debug';

  const SocketDebugPage({super.key});

  @override
  State<SocketDebugPage> createState() => _SocketDebugPageState();
}

class _SocketDebugPageState extends State<SocketDebugPage> {
  final WebSocketService _socketService = sl<WebSocketService>();
  final List<String> _logs = [];
  bool _isConnected = false;
  String _status = 'Disconnected';
  final TextEditingController _chatIdCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _setupSocketListeners();
  }

  void _setupSocketListeners() {
    _socketService.onConnected = () {
      setState(() {
        _isConnected = true;
        _status = 'Connected';
        _logs.add('✅ Connected to server');
      });
    };

    _socketService.onDisconnected = () {
      setState(() {
        _isConnected = false;
        _status = 'Disconnected';
        _logs.add('❌ Disconnected from server');
      });
    };

    _socketService.onMessageError = (error) {
      setState(() {
        _logs.add('🔴 Error: $error');
      });
    };

    _socketService.onMessageReceived = (message) {
      setState(() {
        _logs.add('📨 Received: ${message.content}');
      });
    };

    _socketService.onMessageDelivered = (message) {
      setState(() {
        _logs.add('✅ Delivered: ${message.content}');
      });
    };
  }

  Future<void> _connect() async {
    setState(() {
      _status = 'Connecting...';
      _logs.add('🔄 Attempting to connect...');
    });

    try {
      await _socketService.connect();
    } catch (e) {
      setState(() {
        _status = 'Connection Failed';
        _logs.add('🔴 Connection failed: $e');
      });
    }
  }

  void _disconnect() {
    _socketService.disconnect();
    setState(() {
      _status = 'Disconnected';
      _logs.add('🔄 Disconnecting...');
    });
  }

  void _testSendMessage() {
    if (!_isConnected) {
      setState(() {
        _logs.add('🔴 Cannot send message: not connected');
      });
      return;
    }
    final cid = _chatIdCtrl.text.trim();
    if (cid.isEmpty) {
      setState(() => _logs.add('🔴 Please enter a real chatId first'));
      return;
    }

    setState(() {
      _logs.add('📤 Testing message send...');
    });

    _socketService.sendMessage(
      chatId: cid,
      content: 'Hello from Flutter!',
      type: 'text',
    );
  }

  void _testSendMessageWithUserId() {
    if (!_isConnected) {
      setState(() {
        _logs.add('🔴 Cannot send message: not connected');
      });
      return;
    }
    final cid = _chatIdCtrl.text.trim();
    if (cid.isEmpty) {
      setState(() => _logs.add('🔴 Please enter a real chatId first'));
      return;
    }

    setState(() {
      _logs.add('📤 Testing message send with userId...');
    });

    // Try sending with explicit userId
    _socketService.sendMessage(
      chatId: cid,
      content: 'Hello with userId!',
      type: 'text',
    );
  }

  void _testSendMessageWithToken() {
    if (!_isConnected) {
      setState(() {
        _logs.add('🔴 Cannot send message: not connected');
      });
      return;
    }
    final cid = _chatIdCtrl.text.trim();
    if (cid.isEmpty) {
      setState(() => _logs.add('🔴 Please enter a real chatId first'));
      return;
    }

    setState(() {
      _logs.add('📤 Testing message send with token...');
    });

    // Try sending with token in payload
    _socketService.sendMessage(
      chatId: cid,
      content: 'Hello with token!',
      type: 'text',
    );
  }

  void _testSendMessageMinimal() {
    if (!_isConnected) {
      setState(() {
        _logs.add('🔴 Cannot send message: not connected');
      });
      return;
    }
    final cid = _chatIdCtrl.text.trim();
    if (cid.isEmpty) {
      setState(() => _logs.add('🔴 Please enter a real chatId first'));
      return;
    }

    setState(() {
      _logs.add('📤 Testing minimal message send...');
    });

    // Try minimal payload
    _socketService.sendMessage(
      chatId: cid,
      content: 'Minimal test',
      type: 'text',
    );
  }

  void _clearLogs() {
    setState(() {
      _logs.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Socket Debug'),
        backgroundColor: const Color(0xFF3F51F3),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: _clearLogs,
            tooltip: 'Clear Logs',
          ),
        ],
      ),
      body: Column(
        children: [
          // Status and Controls
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _chatIdCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Chat ID',
                          hintText: 'Enter real chatId (24-char ObjectId)',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _logs.add(
                            'ℹ️ chatId set: ${_chatIdCtrl.text.trim()}',
                          );
                        });
                      },
                      child: const Text('Use'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Status: $_status',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _isConnected ? Colors.green : Colors.red,
                      ),
                    ),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: _isConnected ? null : _connect,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Connect'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _isConnected ? _disconnect : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Disconnect'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _isConnected ? _testSendMessage : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Test Send'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _isConnected
                              ? _testSendMessageMinimal
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Minimal'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _isConnected
                              ? _testSendMessageWithUserId
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('With UserId'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _isConnected
                              ? _testSendMessageWithToken
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('With Token'),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Server: ${WebSocketService.serverUrl}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // Logs
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Debug Logs:',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _logs.length,
                      itemBuilder: (context, index) {
                        final log = _logs[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            log,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.green,
                              fontFamily: 'monospace',
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _socketService.onConnected = null;
    _socketService.onDisconnected = null;
    _socketService.onMessageError = null;
    _socketService.onMessageReceived = null;
    _socketService.onMessageDelivered = null;
    super.dispose();
  }
}
