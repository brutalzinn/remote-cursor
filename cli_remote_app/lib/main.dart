import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(const CursorRemoteApp());
}

class CursorRemoteApp extends StatelessWidget {
  const CursorRemoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Remote CLI',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.dark,
          // Terminal colors - pure black background with bright green text
          surface: Colors.black,
          onSurface: Colors.green.shade200,
          surfaceContainer: Colors.black,
          surfaceContainerHigh: Colors.grey[900],
          surfaceContainerHighest: Colors.grey[800],
          // Primary colors for terminal elements
          primary: Colors.green.shade200,
          onPrimary: Colors.black,
          primaryContainer: Colors.green[900],
          onPrimaryContainer: Colors.green.shade200,
          // Secondary colors for accents
          secondary: Colors.green.shade300,
          onSecondary: Colors.black,
          secondaryContainer: Colors.green[800],
          onSecondaryContainer: Colors.green.shade200,
          // Error colors for terminal errors
          error: Colors.red.shade300,
          onError: Colors.black,
          errorContainer: Colors.red[900],
          onErrorContainer: Colors.red.shade200,
          // Outline colors for borders
          outline: Colors.green.shade200,
          outlineVariant: Colors.green[700],
          // Background colors
          background: Colors.black,
          onBackground: Colors.green.shade200,
        ),
        // AppBar theme using ColorScheme
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.green,
          elevation: 0,
          centerTitle: true,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          titleTextStyle: TextStyle(
            color: Colors.green,
            fontFamily: 'Courier',
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        // Text theme with terminal styling
        textTheme: TextTheme(
          // Display styles
          displayLarge: TextStyle(
            color: Colors.green,
            fontFamily: 'Courier',
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
          displayMedium: TextStyle(
            color: Colors.green,
            fontFamily: 'Courier',
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
          displaySmall: TextStyle(
            color: Colors.green,
            fontFamily: 'Courier',
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          // Headline styles
          headlineLarge: TextStyle(
            color: Colors.green,
            fontFamily: 'Courier',
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
          headlineMedium: TextStyle(
            color: Colors.green,
            fontFamily: 'Courier',
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          headlineSmall: TextStyle(
            color: Colors.green,
            fontFamily: 'Courier',
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          // Title styles
          titleLarge: TextStyle(
            color: Colors.green,
            fontFamily: 'Courier',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          titleMedium: TextStyle(
            color: Colors.green,
            fontFamily: 'Courier',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          titleSmall: TextStyle(
            color: Colors.green,
            fontFamily: 'Courier',
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          // Body styles
          bodyLarge: TextStyle(
            color: Colors.green,
            fontFamily: 'Courier',
            fontSize: 14,
          ),
          bodyMedium: TextStyle(
            color: Colors.green,
            fontFamily: 'Courier',
            fontSize: 12,
          ),
          bodySmall: TextStyle(
            color: Colors.green,
            fontFamily: 'Courier',
            fontSize: 10,
          ),
          // Label styles
          labelLarge: TextStyle(
            color: Colors.green,
            fontFamily: 'Courier',
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          labelMedium: TextStyle(
            color: Colors.green,
            fontFamily: 'Courier',
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
          labelSmall: TextStyle(
            color: Colors.green,
            fontFamily: 'Courier',
            fontSize: 8,
            fontWeight: FontWeight.w500,
          ),
        ),
        // Input decoration theme
        inputDecorationTheme: InputDecorationTheme(
          hintStyle: TextStyle(
            color: Colors.green[600],
            fontFamily: 'Courier',
          ),
          labelStyle: TextStyle(
            color: Colors.green,
            fontFamily: 'Courier',
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.green),
            borderRadius: BorderRadius.circular(4),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.green),
            borderRadius: BorderRadius.circular(4),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.green, width: 2),
            borderRadius: BorderRadius.circular(4),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red),
            borderRadius: BorderRadius.circular(4),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red, width: 2),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        // Elevated button theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.green,
            side: BorderSide(color: Colors.green),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            textStyle: TextStyle(
              fontFamily: 'Courier',
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        // Text button theme
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.green,
            textStyle: TextStyle(
              fontFamily: 'Courier',
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        // Dropdown menu theme
        dropdownMenuTheme: DropdownMenuThemeData(
          textStyle: TextStyle(
            color: Colors.green,
            fontFamily: 'Courier',
          ),
          menuStyle: MenuStyle(
            backgroundColor: WidgetStateProperty.all(Colors.black),
            side: WidgetStateProperty.all(BorderSide(color: Colors.green)),
          ),
        ),
        // SnackBar theme
        snackBarTheme: SnackBarThemeData(
          backgroundColor: Colors.grey[900],
          contentTextStyle: TextStyle(
            color: Colors.green,
            fontFamily: 'Courier',
          ),
          actionTextColor: Colors.green,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.green),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        // Card theme
        cardTheme: CardThemeData(
          color: Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.green),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        // Divider theme
        dividerTheme: DividerThemeData(
          color: Colors.green,
          thickness: 1,
        ),
      ),
      home: const CursorRemoteScreen(),
    );
  }
}

class CursorRemoteScreen extends StatefulWidget {
  const CursorRemoteScreen({super.key});

  @override
  State<CursorRemoteScreen> createState() => _CursorRemoteScreenState();
}

class _CursorRemoteScreenState extends State<CursorRemoteScreen> {
  io.Socket? socket;
  final TextEditingController _commandController = TextEditingController();
  final List<String> _logs = [];
  final ScrollController _scrollController = ScrollController();
  bool _isConnected = false;
  String _serverUrl = 'http://192.168.0.126:3000'; // Default IP, user can change this
  bool _isCommandRunning = false;
  String _selectedMode = 'cursor-agent'; // Default mode
  List<String> _modes = ['cursor-agent', 'Terminal']; // Will be updated from server

  @override
  void initState() {
    super.initState();
    _loadServerUrl();
  }

  Future<void> _loadServerUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUrl = prefs.getString('server_url');
    if (savedUrl != null && savedUrl.isNotEmpty) {
      setState(() {
        _serverUrl = savedUrl;
      });
    }
    _connectToServer();
  }

  Future<void> _saveServerUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('server_url', url);
  }

  void _connectToServer() {
    try {
      if (_serverUrl.isEmpty) {
        _addLog('App Error: Server URL is empty', isSystem: true, isError: true);
        return;
      }
      
      _addLog('App: Connecting to $_serverUrl...', isSystem: true);
      
      // Dispose existing socket if any
      socket?.dispose();
      
      socket = io.io(_serverUrl, io.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .setReconnectionAttempts(5)
          .setReconnectionDelay(2000)
          .build());

      socket?.onConnect((_) {
        setState(() {
          _isConnected = true;
        });
        _addLog('✅ Connected to server', isSystem: true);
        _fetchAvailableModes(); // Fetch available modes when connected
      });

      socket?.on('connection_confirmed', (data) {
        final message = data['message'] ?? 'Connected to server';
        _addLog('📱 $message', isSystem: true);
      });

      socket?.onDisconnect((_) {
        setState(() {
          _isConnected = false;
        });
        _addLog('❌ Disconnected from server', isSystem: true);
      });

      socket?.onReconnect((_) {
        setState(() {
          _isConnected = true;
        });
        _addLog('🔄 Reconnected to server at $_serverUrl', isSystem: true);
        _fetchAvailableModes(); // Fetch available modes when reconnected
      });

      socket?.onReconnectError((error) {
        _addLog('❌ Reconnection failed: $error', isSystem: true, isError: true);
      });

      socket?.onReconnectFailed((_) {
        _addLog('❌ Reconnection failed after all attempts', isSystem: true, isError: true);
      });

      socket?.onConnectError((error) {
        setState(() {
          _isConnected = false;
        });
        _addLog('❌ Connection error: $error', isSystem: true, isError: true);
        _addLog('💡 Check if server is running at $_serverUrl', isSystem: true);
      });

      socket?.on('command_output', (data) {
        _addLog(data.toString());
      });

      socket?.on('command_feedback', (data) {
        final message = data['message'] ?? 'No message';
        final isSystem = data['isSystem'] ?? false;
        final isError = data['isError'] ?? false;
        
        // Just append what the server sends - no logic here
        _addLog(message, isSystem: isSystem, isError: isError);
      });

      socket?.on('command_exit', (exitCode) {
        setState(() {
          _isCommandRunning = false;
        });
        _addLog('Command finished with exit code: $exitCode', isSystem: true);
      });

      socket?.on('file_status', (data) {
        final message = data['message'] ?? 'File status update';
        _addLog(message, isSystem: true);
      });

    } catch (e) {
      _addLog('Failed to connect: $e', isSystem: true, isError: true);
    }
  }

  void _fetchAvailableModes() async {
    try {
      final response = await http.get(Uri.parse('$_serverUrl/modes'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final modes = data['modes'] as Map<String, dynamic>;
        setState(() {
          _modes = modes.keys.toList();
          if (!_modes.contains(_selectedMode)) {
            _selectedMode = _modes.isNotEmpty ? _modes.first : 'Terminal';
          }
        });
        _addLog('Available modes: ${_modes.join(', ')}', isSystem: true);
      }
    } catch (e) {
      _addLog('Failed to fetch modes: $e', isSystem: true, isError: true);
    }
  }

  void _addLog(String message, {bool isSystem = false, bool isError = false}) {
    setState(() {
      final timestamp = DateTime.now().toString().substring(11, 19);
      final prefix = isSystem ? '[SYSTEM]' : '';
      final errorPrefix = isError ? '[ERROR]' : '';
      _logs.add('$timestamp $errorPrefix$prefix $message');
    });
    
    // Auto-scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendCommand() {
    final command = _commandController.text.trim();
    if (command.isEmpty || !_isConnected || _isCommandRunning) return;

    setState(() {
      _isCommandRunning = true;
    });
    
    _addLog('Sending message to $_selectedMode: $command', isSystem: true);
    
    // Send command to server with mode information
    socket?.emit('run_cursor_command', {
      'message': command,
      'mode': _selectedMode
    });
    _commandController.clear();
  }

  void _stopCommand() {
    if (!_isCommandRunning) return;
    
    _addLog('App: Stopping command execution...', isSystem: true);
    
    // Send stop command to server
    socket?.emit('stop_command');
    
    setState(() {
      _isCommandRunning = false;
    });
    
    _addLog('App: Command stopped', isSystem: true);
  }

  // File upload method - COMMENTED OUT
  // Future<void> _uploadFile() async {
  //   _addLog('File upload feature temporarily disabled for faster compilation', isSystem: true);
  //   _addLog('You can still use the command input to send Cursor commands', isSystem: true);
  // }

  void _clearLogs() {
    setState(() {
      _logs.clear();
    });
  }


  void _changeServerUrl() {
    print('DEBUG: _changeServerUrl called'); // Debug log
    _addLog('Opening URL settings dialog...', isSystem: true); // Add to logs
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        print('DEBUG: Dialog builder called'); // Debug log
        final controller = TextEditingController(text: _serverUrl);
        return AlertDialog(
          title: Text(_isConnected ? 'Change Server URL' : 'Set Server URL'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'Server URL',
                  hintText: 'http://192.168.1.10:3000',
                ),
              ),
              if (!_isConnected) ...[
                const SizedBox(height: 16),
                Text(
                  'App is currently disconnected. Enter the server URL to connect.',
                  style: TextStyle(
                    color: Colors.red.shade300,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                print('DEBUG: Cancel button pressed'); // Debug log
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                print('DEBUG: Connect button pressed'); // Debug log
                final newUrl = controller.text.trim();
                if (newUrl.isNotEmpty) {
                  setState(() {
                    _serverUrl = newUrl;
                  });
                  await _saveServerUrl(newUrl); // Save the new URL
                  Navigator.of(context).pop();
                  socket?.disconnect();
                  _connectToServer();
                }
              },
              child: Text(_isConnected ? 'Reconnect' : 'Connect'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    socket?.dispose();
    _commandController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Remote CLI'),
        backgroundColor: Colors.black, // Force black AppBar
        actions: [
          IconButton(
            icon: Icon(_isConnected ? Icons.wifi : Icons.wifi_off),
            onPressed: () {
              print('DEBUG: WiFi button pressed, connected: $_isConnected'); // Debug log
              // Always allow URL change, whether connected or disconnected
              _changeServerUrl();
            },
            tooltip: 'Change Server URL',
          ),
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: _clearLogs,
            tooltip: 'Clear Logs',
          ),
        ],
      ),
      body: Column(
        children: [
          // Connection status bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.black, // Black background for DOS terminal look
            child: Row(
              children: [
                Icon(
                  _isConnected ? Icons.wifi : Icons.wifi_off,
                  color: _isConnected ? Colors.green.shade200 : Colors.red.shade300,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _isConnected ? 'Connected to $_serverUrl' : 'Disconnected',
                    style: TextStyle(
                      color: _isConnected ? Colors.green.shade200 : Colors.red.shade300,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Courier',
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (_isCommandRunning) ...[
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade200),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Running...',
                    style: TextStyle(
                      color: Colors.green.shade200,
                      fontFamily: 'Courier',
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Mode selection dropdown
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Theme.of(context).colorScheme.surface,
            child: Row(
              children: [
                const Icon(Icons.settings, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Mode: ',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.green.shade200,
                    fontFamily: 'Courier',
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _selectedMode,
                  isExpanded: false,
                  underline: Container(),
                  items: _modes.map((String mode) {
                    return DropdownMenuItem<String>(
                      value: mode,
                      child: Text(
                        mode,
                        style: TextStyle(
                          color: Colors.green.shade200,
                          fontFamily: 'Courier',
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedMode = newValue;
                      });
                      _addLog('Switched to $newValue mode', isSystem: true);
                    }
                  },
                ),
                const Spacer(),
                Icon(
                  _selectedMode == 'cursor-agent' ? Icons.smart_toy : Icons.terminal,
                  size: 20,
                  color: Colors.green.shade200,
                ),
              ],
            ),
          ),
          
          // Logs display
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(8),
              child: _logs.isEmpty
                  ? Center(
                      child: Text(
                        'No logs yet. Connect to server and run a command.',
                        style: TextStyle(
                          color: Colors.green.shade200,
                          fontFamily: 'Courier',
                        ),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      itemCount: _logs.length,
                      itemBuilder: (context, index) {
                        final log = _logs[index];
                        final isError = log.contains('[ERROR]');
                        final isSystem = log.contains('[SYSTEM]');
                        
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: SelectableText(
                            log,
                            style: TextStyle(
                              fontFamily: 'Courier', // DOS-style monospace font
                              fontSize: 12,
                              color: isError 
                                  ? Colors.red.shade300  // Bright red for errors
                                  : isSystem 
                                      ? Colors.green.shade200  // Bright green for system messages
                                      : Colors.green.shade300, // Bright green for regular messages
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
          
          // Command input area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                // Upload button - COMMENTED OUT
                // IconButton(
                //   onPressed: _isConnected ? _uploadFile : null,
                //   icon: const Icon(Icons.upload_file),
                //   tooltip: 'Upload File',
                // ),
                
                // Command input
                Expanded(
                  child: TextField(
                    controller: _commandController,
                    enabled: _isConnected && !_isCommandRunning,
                    decoration: InputDecoration(
                      hintText: _selectedMode == 'cursor-agent' 
                          ? 'Chat with AI assistant (e.g., "Create a Python script")'
                          : 'Enter terminal command (e.g., "run ls -la")',
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    onSubmitted: (_) => _sendCommand(),
                  ),
                ),
                
                // Toggle Send/Stop button
                IconButton(
                  onPressed: _isConnected ? (_isCommandRunning ? _stopCommand : _sendCommand) : null,
                  icon: Icon(_isCommandRunning ? Icons.stop : Icons.send),
                  tooltip: _isCommandRunning ? 'Stop Command' : 'Send Command',
                  color: _isCommandRunning ? Colors.red : null,
            ),
          ],
        ),
          ),
        ],
      ),
    );
  }
}