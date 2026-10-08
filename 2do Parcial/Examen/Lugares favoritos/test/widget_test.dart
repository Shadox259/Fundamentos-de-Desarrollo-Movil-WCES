import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lugares_app/main.dart';

void main() {
  testWidgets('Muestra el icono del splash', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.byIcon(Icons.place), findsWidgets);
  });
}