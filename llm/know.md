# Remote Cursor Control System

## Overview
A complete system that allows Flutter mobile apps to remotely control Cursor AI through a Node.js server with MCP (Model Context Protocol) integration.

## Architecture

### Components
1. **Flutter App** - Mobile client that sends commands and files
2. **Node.js Server** - Express server with Socket.IO for real-time communication
3. **MCP Server** - Model Context Protocol server for Cursor integration
4. **Cursor AI** - Receives and executes commands through MCP

### Communication Flow
```
Flutter App → Socket.IO → Node.js Server → MCP Server → Cursor AI
                ↓
            File Upload → HTTP POST → Server Storage
```

## Server Configuration

### Installation
```bash
cd server
npm install
sudo npm link  # Install globally as 'remoteme'
```

### Running the Server
```bash
remoteme serve                    # Default port 3000
remoteme serve --port=3030        # Custom port (note: use = not space)
```

### Server Endpoints
- **Health Check:** `GET http://YOUR_IP:3000/health`
- **File Upload:** `POST http://YOUR_IP:3000/upload`
- **Socket.IO:** `ws://YOUR_IP:3000`

## Flutter App Integration

### Development Environment
- **FVM (Flutter Version Management)** is used for Flutter development
- **Current Flutter Version:** 3.35.4 (stable channel)
- **Dart Version:** 3.9.2
- **All Flutter commands must use FVM:** `fvm flutter <command>`
- **Target Platform:** Android only (mobile app)
- **Package Name:** `com.brutalzinn.cliremoteapp`

### FVM Commands
```bash
# Check Flutter version
fvm flutter --version

# Run Flutter doctor
fvm flutter doctor

# Analyze code
fvm flutter analyze

# Run tests
fvm flutter test

# Build Android APK
fvm flutter build apk

# Run on Android device/emulator
fvm flutter run

# Install APK on connected device
fvm flutter install
```

### Connection
```dart
// Connect to server
final socket = IO.io('http://192.168.0.126:3000');

// Send command
socket.emit('run_cursor_command', {
  'message': 'create a file called test.txt with content hello world',
  'agentId': 'default'
});
```

### File Upload
```dart
// Upload file via HTTP POST
var request = http.MultipartRequest(
  'POST', 
  Uri.parse('http://192.168.0.126:3000/upload')
);
request.files.add(await http.MultipartFile.fromPath('file', filePath));
var response = await request.send();
```

### Socket.IO Events
- `run_cursor_command` - Send commands to Cursor
- `upload_file` - Notify about file uploads
- `command_feedback` - Receive execution feedback
- `file_status` - Receive file upload status

## MCP Integration

### Configuration
File: `.cursor/mcp.json`
```json
{
  "mcpServers": {
    "remoteme-cursor-agent": {
      "command": "node",
      "args": ["/path/to/server/mcp_cursor_agent.js"],
      "cwd": "/path/to/project"
    }
  }
}
```

### MCP Tools Available
- `send_message_to_agent` - Send commands to Cursor
- `read_flutter_messages` - Read messages from Flutter app
- `show_flutter_messages` - Display recent Flutter messages
- `list_pending_messages` - List pending commands

## Command Execution

### Supported Commands
1. **File Creation**
   - Format: `"create a file called filename.txt with content hello world"`
   - Automatically executed by MCP server
   - Creates actual files in project directory

2. **General Commands**
   - Any text command sent to Cursor
   - Appears in Cursor's chat for manual execution

### Feedback System
- **Immediate acknowledgment** when command received
- **Success/error messages** with execution results
- **File upload confirmations** with details
- **Real-time status updates** via Socket.IO

## File Management

### Upload Directory
- Files stored in: `server/uploads/`
- Unique filenames with timestamps
- Original filenames preserved in metadata

### File Information
```json
{
  "filename": "file-1758854646443-141531597.txt",
  "originalName": "test_upload.txt",
  "size": 40,
  "path": "/path/to/uploads/file-1758854646443-141531597.txt"
}
```

## Security Considerations

### Network Access
- Server binds to `0.0.0.0` - accessible from any IP
- Use firewall rules to restrict access
- Consider VPN for remote access

### File Uploads
- Files stored in isolated upload directory
- No automatic execution of uploaded files
- File size and type validation recommended

### MCP Security
- MCP server runs with project permissions
- Commands executed in project directory
- No system-level access by default

## Troubleshooting

### Common Issues
1. **"No route to host"** - Check IP address and port
2. **MCP not working** - Restart Cursor after config changes
3. **Commands not executing** - Check MCP server logs
4. **File upload fails** - Check upload directory permissions

### Debug Commands
```bash
# Check server status
curl http://192.168.0.126:3000/health

# Check running processes
ps aux | grep remoteme

# Check port usage
ss -tlnp | grep 3000
```

## Development Notes

### Server Files
- `server/index.js` - Main Express server
- `server/mcp_cursor_agent.js` - MCP server implementation
- `server/cli.js` - Command-line interface
- `server/package.json` - Dependencies

### Key Features
- Real-time bidirectional communication
- Automatic command execution
- File upload with feedback
- Error handling and logging
- Graceful shutdown handling

### Dependencies
- express
- socket.io
- multer (file uploads)
- @modelcontextprotocol/sdk
- cors

## Usage Examples

### Basic Command
```javascript
// Flutter app sends command
socket.emit('run_cursor_command', {
  message: 'create a new file called hello.txt with content Hello World!',
  agentId: 'default'
});

// Server executes and returns:
// ✅ Command executed successfully!
// 📱 From Flutter App: create a new file called hello.txt with content Hello World!
// 📄 Result: Created file 'hello.txt' with content: "Hello World!"
```

### File Upload
```javascript
// Flutter app uploads file
const formData = new FormData();
formData.append('file', fileBlob);

fetch('http://192.168.0.126:3000/upload', {
  method: 'POST',
  body: formData
});

// Server responds with:
// ✅ File uploaded successfully!
// 📁 File: document.pdf
// 📊 Size: 1.23 KB
// 📂 Location: /path/to/uploads/file-1234567890.pdf
```

## Future Enhancements

### Potential Features
- Command history and replay
- Multiple project support
- User authentication
- Command queuing
- File synchronization
- Real-time file watching
- Custom command handlers
- Web dashboard for monitoring

### Security Improvements
- JWT authentication
- Command validation
- File type restrictions
- Rate limiting
- Audit logging
