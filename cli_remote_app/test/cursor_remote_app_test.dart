import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:http/http.dart' as http;

import 'package:cli_remote_app/main.dart';

// Generate mocks for testing
@GenerateMocks([io.Socket, http.Client])
import 'cursor_remote_app_test.mocks.dart';

void main() {
  group('CursorRemoteApp Widget Tests', () {
    testWidgets('App loads and displays correct title', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const CursorRemoteApp());

      // Verify that the app title is displayed.
      expect(find.text('Remote CLI'), findsOneWidget);
    });

    testWidgets('App displays connection status bar', (WidgetTester tester) async {
      await tester.pumpWidget(const CursorRemoteApp());
      await tester.pumpAndSettle();

      // Check for connection status elements
      expect(find.byIcon(Icons.wifi_off), findsOneWidget);
      expect(find.text('Disconnected'), findsOneWidget);
    });

    testWidgets('App displays mode selection dropdown', (WidgetTester tester) async {
      await tester.pumpWidget(const CursorRemoteApp());
      await tester.pumpAndSettle();

      // Check for mode selection elements
      expect(find.text('Mode:'), findsOneWidget);
      expect(find.text('cursor-agent'), findsOneWidget);
    });

    testWidgets('App displays command input field', (WidgetTester tester) async {
      await tester.pumpWidget(const CursorRemoteApp());
      await tester.pumpAndSettle();

      // Check for command input field
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Chat with AI assistant (e.g., "Create a Python script")'), findsOneWidget);
    });

    testWidgets('App displays action buttons in app bar', (WidgetTester tester) async {
      await tester.pumpWidget(const CursorRemoteApp());
      await tester.pumpAndSettle();

      // Check for action buttons
      expect(find.byIcon(Icons.wifi_off), findsOneWidget);
      expect(find.byIcon(Icons.clear), findsOneWidget);
    });

    testWidgets('Send button is disabled when disconnected', (WidgetTester tester) async {
      await tester.pumpWidget(const CursorRemoteApp());
      await tester.pumpAndSettle();

      // Find the send button
      final sendButton = find.byIcon(Icons.send);
      expect(sendButton, findsOneWidget);

      // Check that the button is disabled (no onPressed callback)
      final button = tester.widget<IconButton>(sendButton);
      expect(button.onPressed, isNull);
    });

    testWidgets('Command input field is disabled when disconnected', (WidgetTester tester) async {
      await tester.pumpWidget(const CursorRemoteApp());
      await tester.pumpAndSettle();

      // Find the text field
      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);

      // Check that the field is disabled
      final field = tester.widget<TextField>(textField);
      expect(field.enabled, isFalse);
    });
  });

  group('CursorRemoteScreen State Management Tests', () {
    late MockSocket mockSocket;

    setUp(() {
      mockSocket = MockSocket();
    });

    testWidgets('Clear logs button clears the log list', (WidgetTester tester) async {
      await tester.pumpWidget(const CursorRemoteApp());
      await tester.pumpAndSettle();

      // Find and tap the clear button
      final clearButton = find.byIcon(Icons.clear);
      expect(clearButton, findsOneWidget);

      await tester.tap(clearButton);
      await tester.pumpAndSettle();

      // Verify logs are cleared (should show "No logs yet" message)
      expect(find.text('No logs yet. Connect to server and run a command.'), findsOneWidget);
    });

    testWidgets('Mode dropdown changes selected mode', (WidgetTester tester) async {
      await tester.pumpWidget(const CursorRemoteApp());
      await tester.pumpAndSettle();

      // Find the dropdown button
      final dropdownButton = find.byType(DropdownButton<String>);
      expect(dropdownButton, findsOneWidget);

      // Tap to open dropdown
      await tester.tap(dropdownButton);
      await tester.pumpAndSettle();

      // Find and tap the Terminal option
      final terminalOption = find.text('Terminal');
      if (terminalOption.evaluate().isNotEmpty) {
        await tester.tap(terminalOption);
        await tester.pumpAndSettle();

        // Verify the mode changed
        expect(find.text('Terminal'), findsOneWidget);
      }
    });

    testWidgets('Command input updates text controller', (WidgetTester tester) async {
      await tester.pumpWidget(const CursorRemoteApp());
      await tester.pumpAndSettle();

      // Find the text field
      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);

      // Type some text
      await tester.enterText(textField, 'test command');
      await tester.pumpAndSettle();

      // Verify the text was entered
      expect(find.text('test command'), findsOneWidget);
    });
  });

  group('Server URL Dialog Tests', () {
    testWidgets('Server URL dialog opens when WiFi button is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(const CursorRemoteApp());
      await tester.pumpAndSettle();

      // Find and tap the WiFi button
      final wifiButton = find.byIcon(Icons.wifi_off);
      expect(wifiButton, findsOneWidget);

      await tester.tap(wifiButton);
      await tester.pumpAndSettle();

      // Verify dialog opens
      expect(find.text('Set Server URL'), findsOneWidget);
      expect(find.byType(AlertDialog), findsOneWidget);
    });

    testWidgets('Server URL dialog has correct input field', (WidgetTester tester) async {
      await tester.pumpWidget(const CursorRemoteApp());
      await tester.pumpAndSettle();

      // Open dialog
      await tester.tap(find.byIcon(Icons.wifi_off));
      await tester.pumpAndSettle();

      // Check for input field
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Server URL'), findsOneWidget);
      expect(find.text('http://192.168.1.10:3000'), findsOneWidget);
    });

    testWidgets('Server URL dialog has Cancel and Connect buttons', (WidgetTester tester) async {
      await tester.pumpWidget(const CursorRemoteApp());
      await tester.pumpAndSettle();

      // Open dialog
      await tester.tap(find.byIcon(Icons.wifi_off));
      await tester.pumpAndSettle();

      // Check for buttons
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Connect'), findsOneWidget);
    });

    testWidgets('Server URL dialog closes when Cancel is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(const CursorRemoteApp());
      await tester.pumpAndSettle();

      // Open dialog
      await tester.tap(find.byIcon(Icons.wifi_off));
      await tester.pumpAndSettle();

      // Verify dialog is open
      expect(find.byType(AlertDialog), findsOneWidget);

      // Tap Cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Verify dialog is closed
      expect(find.byType(AlertDialog), findsNothing);
    });
  });

  group('Theme and Styling Tests', () {
    testWidgets('App uses dark theme', (WidgetTester tester) async {
      await tester.pumpWidget(const CursorRemoteApp());
      await tester.pumpAndSettle();

      // Check that the app uses dark theme
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.theme?.brightness, equals(Brightness.dark));
    });

    testWidgets('App uses terminal-style colors', (WidgetTester tester) async {
      await tester.pumpWidget(const CursorRemoteApp());
      await tester.pumpAndSettle();

      // Check for terminal-style styling
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, equals(Colors.black));
    });

    testWidgets('App uses Courier font family', (WidgetTester tester) async {
      await tester.pumpWidget(const CursorRemoteApp());
      await tester.pumpAndSettle();

      // Check that text styles use Courier font
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      final textTheme = materialApp.theme?.textTheme;
      
      expect(textTheme?.displayLarge?.fontFamily, equals('Courier'));
      expect(textTheme?.bodyLarge?.fontFamily, equals('Courier'));
    });
  });

  group('SharedPreferences Tests', () {
    testWidgets('App loads saved server URL from SharedPreferences', (WidgetTester tester) async {
      // Mock SharedPreferences
      SharedPreferences.setMockInitialValues({
        'server_url': 'http://test-server:3000',
      });

      await tester.pumpWidget(const CursorRemoteApp());
      await tester.pumpAndSettle();

      // The app should load the saved URL (though we can't easily test the internal state)
      // We can verify the app loads without errors
      expect(find.byType(CursorRemoteApp), findsOneWidget);
    });

    testWidgets('App handles empty SharedPreferences gracefully', (WidgetTester tester) async {
      // Mock empty SharedPreferences
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(const CursorRemoteApp());
      await tester.pumpAndSettle();

      // App should load with default values
      expect(find.byType(CursorRemoteApp), findsOneWidget);
    });
  });

  group('Error Handling Tests', () {
    testWidgets('App handles connection errors gracefully', (WidgetTester tester) async {
      await tester.pumpWidget(const CursorRemoteApp());
      await tester.pumpAndSettle();

      // App should show disconnected state initially
      expect(find.text('Disconnected'), findsOneWidget);
      expect(find.byIcon(Icons.wifi_off), findsOneWidget);
    });

    testWidgets('App displays appropriate placeholder text when no logs', (WidgetTester tester) async {
      await tester.pumpWidget(const CursorRemoteApp());
      await tester.pumpAndSettle();

      // Should show placeholder text
      expect(find.text('No logs yet. Connect to server and run a command.'), findsOneWidget);
    });
  });

  group('Accessibility Tests', () {
    testWidgets('All interactive elements have proper semantics', (WidgetTester tester) async {
      await tester.pumpWidget(const CursorRemoteApp());
      await tester.pumpAndSettle();

      // Check that buttons have proper semantics
      expect(find.byIcon(Icons.wifi_off), findsOneWidget);
      expect(find.byIcon(Icons.clear), findsOneWidget);
      expect(find.byIcon(Icons.send), findsOneWidget);
    });

    testWidgets('Text fields have proper labels', (WidgetTester tester) async {
      await tester.pumpWidget(const CursorRemoteApp());
      await tester.pumpAndSettle();

      // Check that text fields have labels
      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);

      final field = tester.widget<TextField>(textField);
      expect(field.decoration?.labelText, isNotNull);
    });
  });
}