import 'package:flutter/material.dart';
import 'core/network/socket.dart';
import 'features/auth/data/datasources/auth_remote_datasource_impl.dart';
import 'features/chat/data/datasources/remote/chat_remote_datasource_impl.dart';
import 'features/chat/domain/entities/message.dart';
import 'injection_container.dart';

class WebSocketTestPage extends StatefulWidget {
  static const routeName = '/socket-test';
  const WebSocketTestPage({super.key});

  @override
  State<WebSocketTestPage> createState() => _WebSocketTestPageState();
}

class _WebSocketTestPageState extends State<WebSocketTestPage> {
  final _userIdCtrl = TextEditingController(); // renamed (receiver user id)
  final _msgCtrl = TextEditingController();
  final _scroll = ScrollController();

  final _ws = sl<WebSocketService>();
  final _chatDs = sl<ChatRemoteDataSourceImpl>();

  bool _connected = false;
  bool _joined = false;
  final List<_UiMsg> _messages = [];

  String? _currentUserId;
  String? _activeChatId; // the real chat id after create/get

  @override
  void initState() {
    super.initState();
    _attachCallbacks();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final auth = sl<AuthRemoteDataSourceImpl>();
    final either = await auth.getCurrentUser();
    setState(() {
      _currentUserId = either.fold((_) => 'N/A', (u) => u.id);
    });
  }

  void _attachCallbacks() {
    _ws.onConnected = () {
      setState(() => _connected = true);
      _addSystem('[connected]');
    };
    _ws.onDisconnected = () {
      setState(() {
        _connected = false;
        _joined = false;
        _activeChatId = null;
      });
      _addSystem('[disconnected]');
    };
    _ws.onMessageError = (e) => _addSystem('[error] $e');
    _ws.onMessageReceived = (m) => _addIncoming(m);
    _ws.onMessageDelivered = (m) => _addIncoming(m, delivered: true);
  }

  void _addSystem(String text) {
    setState(() => _messages.add(_UiMsg.system(text)));
    _jumpBottom();
  }

  void _addIncoming(Message m, {bool delivered = false}) {
    setState(
      () => _messages.add(_UiMsg.incoming(_extractContent(m), delivered)),
    );
    _jumpBottom();
  }

  void _addOutgoing(String content) {
    setState(() => _messages.add(_UiMsg.outgoing(content)));
    _jumpBottom();
  }

  String _extractContent(Message m) {
    try {
      return (m as dynamic).content?.toString() ?? '';
    } catch (_) {
      return m.toString();
    }
  }

  Future<void> _connect() async => _ws.connect();
  void _disconnect() => _ws.disconnect();

  Future<void> _createOrJoinChat() async {
    if (!_connected) {
      _addSystem('[not connected]');
      return;
    }
    final otherUserId = _userIdCtrl.text.trim();
    if (otherUserId.isEmpty) {
      _addSystem('[receiver id empty]');
      return;
    }
    _addSystem('[resolving chat with $otherUserId]');
    try {
      final chat = await _chatDs.getOrCreateChat(otherUserId);
      _activeChatId = chat.id;
      _ws.joinChat(chat.id);
      setState(() => _joined = true);
      _addSystem('[joined chat ${chat.id}]');
    } catch (e) {
      _addSystem('[join error] $e');
    }
  }

  void _leave() {
    if (_activeChatId != null) {
      _ws.leaveChat(_activeChatId!);
      _addSystem('[left chat $_activeChatId]');
    }
    setState(() {
      _joined = false;
      _activeChatId = null;
    });
  }

  void _send() {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    if (!_joined || _activeChatId == null) {
      _addSystem('[no active chat]');
      return;
    }
    _ws.sendMessage(chatId: _activeChatId!, content: text);
    _addOutgoing(text);
    _msgCtrl.clear();
  }

  void _jumpBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent + 80,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _userIdCtrl.dispose();
    _msgCtrl.dispose();
    _scroll.dispose();
    _ws.onConnected = null;
    _ws.onDisconnected = null;
    _ws.onMessageError = null;
    _ws.onMessageReceived = null;
    _ws.onMessageDelivered = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final status = _connected
        ? _joined
              ? 'Connected • Chat: ${_activeChatId ?? "..."}'
              : 'Connected'
        : 'Disconnected';
    return Scaffold(
      appBar: AppBar(
        title: const Text('WebSocket Chat Test'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(18),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              'Current User: ${_currentUserId ?? "..."}',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Connect',
            onPressed: _connected ? null : _connect,
            icon: const Icon(Icons.power),
            color: _connected ? Colors.green : null,
          ),
          IconButton(
            tooltip: 'Disconnect',
            onPressed: _connected ? _disconnect : null,
            icon: const Icon(Icons.power_off),
          ),
        ],
      ),
      body: Column(
        children: [
          _TopBar(
            status: status,
            connected: _connected,
            joined: _joined,
            userIdCtrl: _userIdCtrl,
            activeChatId: _activeChatId,
            onCreateOrJoin: _joined ? _leave : _createOrJoinChat,
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _messages.length,
              itemBuilder: (_, i) {
                final m = _messages[i];
                return Align(
                  alignment: m.align,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: m.bg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      m.text + (m.delivered ? ' ✓' : ''),
                      style: TextStyle(
                        color: m.color,
                        fontSize: 14,
                        fontStyle: m.isSystem
                            ? FontStyle.italic
                            : FontStyle.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          _MessageInput(
            enabled: _connected && _joined,
            controller: _msgCtrl,
            onSend: _send,
          ),
        ],
      ),
    );
  }
}

// UI BAR
class _TopBar extends StatelessWidget {
  final String status;
  final bool connected;
  final bool joined;
  final TextEditingController userIdCtrl;
  final String? activeChatId;
  final VoidCallback onCreateOrJoin;
  const _TopBar({
    required this.status,
    required this.connected,
    required this.joined,
    required this.userIdCtrl,
    required this.activeChatId,
    required this.onCreateOrJoin,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 12, top: 10, bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                TextField(
                  controller: userIdCtrl,
                  enabled: connected && !joined,
                  decoration: const InputDecoration(
                    labelText: 'Receiver User ID',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Chat: ${activeChatId ?? '-'}',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: connected ? onCreateOrJoin : null,
            child: Text(joined ? 'Leave' : 'Get/Join'),
          ),
          const SizedBox(width: 8),
          Text(
            status,
            style: TextStyle(
              fontSize: 11,
              color: connected ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}

// MESSAGE INPUT
class _MessageInput extends StatelessWidget {
  final bool enabled;
  final TextEditingController controller;
  final VoidCallback onSend;
  const _MessageInput({
    required this.enabled,
    required this.controller,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              enabled: enabled,
              controller: controller,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
              decoration: const InputDecoration(
                hintText: 'Type a message',
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            onPressed: enabled ? onSend : null,
            icon: const Icon(Icons.send),
            color: enabled ? Theme.of(context).colorScheme.primary : null,
          ),
        ],
      ),
    );
  }
}

// UI MSG MODEL
class _UiMsg {
  final String text;
  final bool isSystem;
  final bool incoming;
  final bool delivered;

  _UiMsg.system(this.text)
    : isSystem = true,
      incoming = false,
      delivered = false;
  _UiMsg.incoming(this.text, this.delivered)
    : isSystem = false,
      incoming = true;
  _UiMsg.outgoing(this.text)
    : isSystem = false,
      incoming = false,
      delivered = true;

  Alignment get align => isSystem
      ? Alignment.center
      : (incoming ? Alignment.centerLeft : Alignment.centerRight);

  Color get bg => isSystem
      ? Colors.grey.shade300
      : (incoming ? Colors.blue.shade50 : Colors.green.shade50);

  Color get color => isSystem
      ? Colors.black54
      : (incoming ? Colors.blue.shade900 : Colors.green.shade900);
}
