import 'dart:async';
import 'dart:convert';

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

  final List<Timer> _pendingTimers = [];
  final _chatIdRegex = RegExp(r'^[a-fA-F0-9]{24}$');

  bool _userLoaded = false;
  bool _userLoading = false;

  @override
  void initState() {
    super.initState();
    _attachCallbacks();
    _loadUser();
  }

  String? _jwtSub(String token) {
    try {
      final p = token.split('.');
      if (p.length < 2) return null;
      final norm = base64Url.normalize(p[1]);
      final jsonStr = utf8.decode(base64Url.decode(norm));
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return map['sub']?.toString();
    } catch (_) {
      return null;
    }
  }

  Future<void> _loadUser() async {
    if (_userLoading) return;
    _userLoading = true;
    try {
      final auth = sl<AuthRemoteDataSourceImpl>();

      // Get token first
      final tokenEither = await auth.authLocalDatasource.getAccessToken();
      String? token;
      tokenEither.fold((f) => _addSystem('[auth] token error: ${f.message}'), (
        t,
      ) {
        token = t;
        debugPrint('[AUTH] token: $t');
        debugPrint('[AUTH] jwt.sub=${_jwtSub(t)}');
      });
      if (token == null || token!.isEmpty) {
        setState(() {
          _currentUserId = null;
          _userLoaded = false;
        });
        _addSystem('[auth] abort (no token)');
        return;
      }

      // Fetch current user
      final either = await auth.getCurrentUser();
      String? fetchedId;
      String? failureMsg;
      either.fold((fail) {
        failureMsg = fail.message;
        debugPrint('[AUTH] getCurrentUser failure: $failureMsg');
      }, (u) => fetchedId = u.id);

      bool usedFallback = false;
      if ((fetchedId == null || fetchedId!.isEmpty) && failureMsg != null) {
        final sub = _jwtSub(token!);
        if (sub != null && sub.isNotEmpty) {
          fetchedId = sub;
          usedFallback = true;
        }
      }

      setState(() {
        _currentUserId = fetchedId;
        // userLoaded only true if we actually got user object (no failure) OR we accept fallback explicitly
        _userLoaded =
            (fetchedId != null &&
            fetchedId!.isNotEmpty &&
            (failureMsg == null || usedFallback));
      });

      if (failureMsg != null) {
        _addSystem('[auth] getCurrentUser failed: $failureMsg');
        if (usedFallback) {
          _addSystem('[auth] fallback to jwt.sub id=$_currentUserId');
        } else {
          _addSystem('[auth] no fallback id');
        }
      } else {
        _addSystem('[auth] user loaded id=$_currentUserId');
      }
    } catch (e) {
      _addSystem('[auth] exception $e');
      setState(() {
        _currentUserId = null;
        _userLoaded = false;
      });
    } finally {
      _userLoading = false;
    }
  }

  Future<bool> _ensureUserLoaded() async {
    if (_userLoaded) return true;
    _addSystem('[wait] loading user...');
    await _loadUser();
    if (!_userLoaded) {
      _addSystem('[abort] user not loaded');
      return false;
    }
    return true;
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
    _ws.onMessageDelivered = null; // not used now
  }

  // void _handleReceived(Message m) {
  //   final isMine =
  //       m.sender.id == _currentUserId ||
  //   final content = _extractContent(m);

  //   if (isMine) {
  //     final idx = _messages.indexWhere(
  //       (msg) =>
  //           !msg.isSystem &&
  //           !msg.incoming &&
  //           !msg.delivered &&
  //           msg.text == content,
  //     );
  //     if (idx != -1) {
  //       setState(() {
  //         _messages[idx] = _messages[idx].copyWith(delivered: true);
  //       });
  //       _jumpBottom();
  //     } else {
  //       _addSystem('[warn] received self message unmatched ($content)');
  //     }
  //   } else {
  //     _addIncoming(m, delivered: true);
  //   }
  // }

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

  int _addOutgoing(String content, {bool delivered = false}) {
    setState(
      () => _messages.add(_UiMsg.outgoing(content, delivered: delivered)),
    );
    _jumpBottom();
    return _messages.length - 1;
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
    if (!await _ensureUserLoaded()) return;
    final otherUserId = _userIdCtrl.text.trim();
    if (otherUserId.isEmpty) {
      _addSystem('[receiver id empty]');
      return;
    }
    _addSystem('[resolving chat with $otherUserId]');
    try {
      final chat = await _chatDs.getOrCreateChat(otherUserId);
      final cid = chat.id;
      _activeChatId = cid;
      _addSystem('[chat id=$cid]');
      _addSystem(
        '[chat participants: u1=${chat.user1.id} u2=${chat.user2.id}]',
      );
      final cur = _currentUserId;
      if (cur != null && cur.isNotEmpty) {
        if (cur != chat.user1.id && cur != chat.user2.id) {
          _addSystem('[warn] current user ($cur) not participant');
        }
      }
      // Join room(s)
      _ws.joinChat(cid);
      _addSystem('[join events emitted]');
      setState(() => _joined = true);

      // Determine current user id vs participants
      // If current user not loaded (token lacked sub), try infer: choose participant whose email == your login email if known else user2
      if (cur == null || cur.isEmpty) {
        // Fallback: prefer user2 (assuming you are the requester) else user1
        final inferred = chat.user2.id.isNotEmpty
            ? chat.user2.id
            : chat.user1.id;
        _currentUserId = inferred;
        _addSystem('[auth] inferred current user id=$inferred');
      }
      // Cache into socket service for senderId fallback
    } catch (e) {
      _addSystem('[join error] $e');
    }
  }

  void _leave() {
    if (_activeChatId != null) {
      _ws.leaveChat(_activeChatId!);
      _addSystem('[left chat $_activeChatId]');
      _activeChatId = null;
      setState(() => _joined = false);
    }
  }

  void _send() {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    if (_activeChatId == null) {
      _addSystem('[no active chat id]');
      return;
    }
    final idx = _addOutgoing(text, delivered: false);

    // NORMAL minimal send
    _ws.sendMessage(
      chatId: _activeChatId!,
      content: text,
      type: 'text',
      // try 'userId'; set false to try 'senderId'
    );

    // OPTIONAL: uncomment to run matrix instead of normal send
    // _ws.debugMessageSendMatrix(chatId: _activeChatId!, content: text);

    _pendingTimers.add(
      Timer(const Duration(seconds: 8), () {
        if (!mounted) return;
        if (idx < _messages.length && !_messages[idx].delivered) {
          _addSystem('[warn] no delivery echo for "$text"');
        }
      }),
    );
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
    for (final t in _pendingTimers) {
      t.cancel();
    }
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
    final userStatus = _userLoaded
        ? 'User: $_currentUserId'
        : _userLoading
        ? 'Loading user...'
        : 'User not loaded';
    return Scaffold(
      appBar: AppBar(
        title: const Text('WebSocket Chat Test'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(32),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  userStatus,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Reload User',
            onPressed: _loadUser,
            icon: const Icon(Icons.person_search),
          ),
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
            userLoaded: _userLoaded,
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
  final bool userLoaded;
  const _TopBar({
    required this.status,
    required this.connected,
    required this.joined,
    required this.userIdCtrl,
    required this.activeChatId,
    required this.onCreateOrJoin,
    required this.userLoaded,
  });

  @override
  Widget build(BuildContext context) {
    final canJoin = connected && userLoaded;
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
            onPressed: canJoin ? onCreateOrJoin : null,
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

  const _UiMsg._(this.text, this.isSystem, this.incoming, this.delivered);

  factory _UiMsg.system(String text) => _UiMsg._(text, true, false, false);
  factory _UiMsg.incoming(String text, bool delivered) =>
      _UiMsg._(text, false, true, delivered);
  factory _UiMsg.outgoing(String text, {bool delivered = false}) =>
      _UiMsg._(text, false, false, delivered);

  _UiMsg copyWith({bool? delivered}) =>
      _UiMsg._(text, isSystem, incoming, delivered ?? this.delivered);

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
