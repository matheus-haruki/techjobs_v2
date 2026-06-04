import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:techjobs/core/components/custom_input_field.dart';

void main() {
  group('CustomInputField Widget Tests', () {
    testWidgets('CustomInputField renders with label and hint',
        (WidgetTester tester) async {
      final controller = TextEditingController();
      const label = 'Email';
      const hintText = 'Enter your email';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomInputField(
              label: label,
              hintText: hintText,
              controller: controller,
            ),
          ),
        ),
      );

      expect(find.text(label), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('CustomInputField accepts text input', (WidgetTester tester) async {
      final controller = TextEditingController();
      const inputText = 'test@example.com';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomInputField(
              label: 'Email',
              hintText: 'Enter email',
              controller: controller,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), inputText);
      expect(controller.text, inputText);
    });

    testWidgets('CustomInputField shows/hides password text',
        (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomInputField(
              label: 'Password',
              hintText: 'Enter password',
              controller: controller,
              isPassword: true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.visibility_off), findsOneWidget);

      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomInputField(
              label: 'Password',
              hintText: 'Enter password',
              controller: controller,
              isPassword: true,
            ),
          ),
        ),
      );
    });

    testWidgets('CustomInputField has no visibility icon for non-password fields',
        (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomInputField(
              label: 'Username',
              hintText: 'Enter username',
              controller: controller,
              isPassword: false,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.visibility_off), findsNothing);
      expect(find.byIcon(Icons.visibility), findsNothing);
    });

    testWidgets('CustomInputField applies email keyboard type',
        (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomInputField(
              label: 'Email',
              hintText: 'Enter email',
              controller: controller,
              keyboardType: TextInputType.emailAddress,
            ),
          ),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('CustomInputField respects initial controller value',
        (WidgetTester tester) async {
      final controller = TextEditingController(text: 'initial text');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomInputField(
              label: 'Text',
              hintText: 'Enter text',
              controller: controller,
            ),
          ),
        ),
      );

      expect(find.text('initial text'), findsOneWidget);
    });

    testWidgets('CustomInputField displays multiple fields correctly',
        (WidgetTester tester) async {
      final emailController = TextEditingController();
      final passwordController = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                CustomInputField(
                  label: 'Email',
                  hintText: 'Enter email',
                  controller: emailController,
                ),
                CustomInputField(
                  label: 'Password',
                  hintText: 'Enter password',
                  controller: passwordController,
                  isPassword: true,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.byType(CustomInputField), findsWidgets);
    });

    testWidgets('CustomInputField handles focus node correctly',
        (WidgetTester tester) async {
      final controller = TextEditingController();
      final focusNode = FocusNode();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomInputField(
              label: 'Focus Test',
              hintText: 'Enter text',
              controller: controller,
              focusNode: focusNode,
            ),
          ),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('CustomInputField clears text correctly', (WidgetTester tester) async {
      final controller = TextEditingController(text: 'initial');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomInputField(
              label: 'Clear Test',
              hintText: 'Enter text',
              controller: controller,
            ),
          ),
        ),
      );

      expect(controller.text, 'initial');
      controller.clear();
      expect(controller.text, '');
    });
  });
}
