import 'dart:io';

import 'package:shelf_plus/shelf_plus.dart';

void main() {
  final port = int.parse(Platform.environment['PORT'] ?? '8080');

  shelfRun(
    _initServer,
    defaultBindPort: port,
    defaultBindAddress: '0.0.0.0',
    defaultEnableHotReload: false,
  );
}

Handler _initServer() {
  final users = <WebSocketSession>[];

  final app = Router().plus;

  app.get('/', (_) => 'oi');

  app.get('/chat', () {
    return WebSocketSession(
      onOpen: (session) {
        users.add(session);
        users.where((user) => user != session).forEach((user) => user.send('alguém entrou no chat'));
        session.send('você entrou no chat');
      },
      onClose: (session) {
        users.remove(session);
        for (var user in users) {
          user.send('alguém saiu do chat');
        }
      },
      onMessage: (session, dynamic message) {
        for (var user in users) {
          user.send(message);
        }
      },
    );
  });

  return app;
}
