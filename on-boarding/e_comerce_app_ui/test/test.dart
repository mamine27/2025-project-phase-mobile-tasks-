import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('MyWidget has a title and message', (tester) async {
    // Create the widget by telling the tester to build it.
    await tester.pumpWidget(const some(title: 'a', message: 'M'));
    final titleFinder = find.text('a');

    expect(titleFinder, findsOneWidget);
  });
}

class some extends StatelessWidget {
  const some({super.key, required this.title, required this.message});

  final String title;
  final String message;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: Scaffold(
        appBar: AppBar(title: Text(title)),
        body: Center(child: Text(message)),
      ),
    );
  }
}
