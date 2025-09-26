# Remote Cursor Control System

## Overview
A complete system that allows Flutter mobile apps to remotely control terminal commands and Cursor AI through a unified Node.js server.

## Architecture

### Components
1. **Flutter App** - Mobile client that sends commands and files
2. **Node.js Server** - Unified Express server with Socket.IO for real-time communication
3. **Terminal/Cursor AI** - Executes commands directly in the project directory

### Communication Flow
```
Flutter App → Socket.IO → Node.js Server → Terminal/Cursor AI
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
# Direct execution
node app.js serve                 # Default port 3000
node app.js serve --port=8080    # Custom port

# Via npm scripts
npm start                        # Start server
npm run dev                      # Start with nodemon

# Via global CLI (after install)
remoteme serve                   # Default port 3000
remoteme serve --port=8080       # Custom port

# Via Makefile
make start                       # Start server
make dev                         # Start with nodemon
make stop                        # Stop server
```

### Server Endpoints
- **Health Check:** `GET http://YOUR_IP:3000/health`
- **Available Modes:** `GET http://YOUR_IP:3000/modes`
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
  'message': 'ls -la',
  'mode': 'Terminal'  // or 'cursor-agent'
});
```

### Available Modes
- **Terminal** - Execute CLI commands directly
- **cursor-agent** - Use Cursor AI agent for code help

### Socket.IO Events
- `run_cursor_command` - Send commands to terminal or cursor-agent
- `connection_confirmed` - Server connection confirmation
- `command_feedback` - Receive execution feedback (success/warning/error)
- `command_exit` - Command execution completed with exit code

## Command Execution

### Supported Modes
1. **Terminal Mode**
   - Execute any CLI command directly
   - Commands run in the project directory
   - Full terminal output returned

2. **Cursor-Agent Mode**
   - Use Cursor AI agent for code assistance
   - Commands sent to `cursor-agent` with `--print` flag
   - Non-interactive mode for automated responses

### Command Examples
```javascript
// Terminal command
{
  message: "ls -la",
  mode: "Terminal"
}

// Cursor agent command
{
  message: "create a file called test.txt with content hello world",
  mode: "cursor-agent"
}
```

### Feedback System
- **Immediate acknowledgment** when command received
- **Success/error messages** with execution results
- **Real-time status updates** via Socket.IO
- **Exit codes** for command completion status

## Project Structure

### Server Files
- `server/app.js` - Unified CLI server (main application)
- `server/package.json` - Dependencies and scripts
- `server/node_modules/` - Node.js dependencies

### Flutter App
- `cli_remote_app/` - Flutter mobile application
- Uses FVM for Flutter version management
- Android target platform

## Security Considerations

### Network Access
- Server binds to `0.0.0.0` - accessible from any IP
- Use firewall rules to restrict access
- Consider VPN for remote access

### File Uploads
- Files stored in isolated upload directory
- No automatic execution of uploaded files
- File size and type validation recommended

### Command Security
- Commands executed in project directory
- 30-second timeout for command execution
- No system-level access by default

## Troubleshooting

### Common Issues
1. **"No route to host"** - Check IP address and port
2. **Commands not executing** - Check server logs and cursor-agent installation
3. **Server won't start** - Check if port is already in use
4. **Permission denied** - Check file permissions in project directory

### Debug Commands
```bash
# Check server status
curl http://192.168.0.126:3000/health

# Check running processes
ps aux | grep app.js

# Check port usage
ss -tlnp | grep 3000

# Test server directly
node app.js serve --port=3000
```

## Development Notes

### Key Features
- Real-time bidirectional communication via Socket.IO
- Dual-mode command execution (Terminal + cursor-agent)
- Error handling and logging
- Graceful shutdown handling
- Command timeout protection (30 seconds)
- Process management and monitoring

### Dependencies
- express - Web server framework
- socket.io - Real-time communication
- cors - Cross-origin resource sharing

## Usage Examples

### Terminal Command
```javascript
// Flutter app sends terminal command
socket.emit('run_cursor_command', {
  message: 'ls -la',
  mode: 'Terminal'
});

// Server executes and returns:
// ✅ Command success: total 8
// drwxr-xr-x 2 user user 4096 Jan 15 10:30 .
// drwxr-xr-x 3 user user 4096 Jan 15 10:29 ..
// -rw-r--r-- 1 user user  123 Jan 15 10:30 app.js
```

### Cursor Agent Command
```javascript
// Flutter app sends cursor-agent command
socket.emit('run_cursor_command', {
  message: 'create a file called hello.txt with content Hello World!',
  mode: 'cursor-agent'
});

// Server executes cursor-agent and returns:
// ✅ Command success: [cursor-agent output]
```

## Future Enhancements

### Potential Features
- Command history and replay
- Multiple project support
- User authentication
- Command queuing
- Real-time file watching
- Custom command handlers
- Web dashboard for monitoring
- File upload support
- Multiple terminal sessions

### Security Improvements
- JWT authentication
- Command validation
- Rate limiting
- Audit logging
- Command whitelist/blacklist
