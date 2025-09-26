#!/usr/bin/env node

const express = require('express');
const http = require('http');
const { Server } = require('socket.io');
const { exec, spawn } = require('child_process');
const path = require('path');
const fs = require('fs');

// Parse command line arguments
const args = process.argv.slice(2);
const command = args[0];

if (!command || command === '--help' || command === '-h') {
  console.log(`
Remote CLI - Terminal Control Server

Usage: remoteme serve [options]

Commands:
  serve           Start the CLI control server

Options:
  --port=PORT     Port to run the server on (default: 3000)
  --help, -h      Show this help message

Examples:
  remoteme serve                    # Start server on port 3000 in current directory
  remoteme serve --port=8080        # Start server on port 8080
  cd /path/to/project && remoteme serve  # Start server in specific project directory

The server enables remote CLI control via mobile app.
Connect your Flutter app to http://YOUR_IP:PORT to control terminal commands.
`);
  process.exit(0);
}

if (command !== 'serve') {
  console.error(`❌ Unknown command: ${command}`);
  console.error('Run "remoteme --help" for usage information.');
  process.exit(1);
}

const port = args.find(arg => arg.startsWith('--port='))?.split('=')[1] || '3000';

// Get the current working directory
const workingDir = process.cwd();
console.log(`🚀 Starting Remote CLI - Terminal Control Server`);
console.log(`📁 Working directory: ${workingDir}`);
console.log(`🌐 Server will run on port: ${port}`);
console.log(`📱 Connect your Flutter app to: http://YOUR_IP:${port}`);
console.log('');

// Set the working directory as an environment variable
process.env.CURSOR_WORKING_DIR = workingDir;

// Initialize Express app and Socket.IO
const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: "*",
    methods: ["GET", "POST"]
  },
  pingTimeout: 60000,
  pingInterval: 25000,
  maxHttpBufferSize: 1e6,
  allowEIO3: true
});

const PORT = process.env.PORT || port;
const PROJECT_ROOT = workingDir; // Use the working directory from CLI args
const SERVER_ROOT = __dirname; // Server directory

// Available terminal modes and their configurations
const AVAILABLE_MODES = {
  'Terminal': {
    name: 'Terminal',
    description: 'Execute CLI commands directly',
    icon: '💻',
    color: '#00ff00'
  },
  'cursor-agent': {
    name: 'cursor-agent', 
    description: 'AI Assistant for code help',
    icon: '🤖',
    color: '#00ff00'
  }
};

// Connection management
const activeConnections = new Map(); // socketId -> connection info


// Middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({ 
    status: 'healthy', 
    port: PORT,
    projectRoot: PROJECT_ROOT,
    timestamp: new Date().toISOString()
  });
});

// Get available terminal modes
app.get('/modes', (req, res) => {
  res.status(200).json({
    modes: AVAILABLE_MODES,
    timestamp: new Date().toISOString()
  });
});

// Socket.IO connection handling
io.on('connection', (socket) => {
  console.log(`📱 Client connected: ${socket.id} from ${socket.handshake.address}`);
  
  // Send connection confirmation
  socket.emit('connection_confirmed', {
    message: 'Connected to Remote CLI Server',
    timestamp: new Date().toISOString(),
    clientId: socket.id
  });

  socket.on('disconnect', (reason) => {
    console.log(`📱 Client disconnected: ${socket.id}, reason: ${reason}`);
    activeConnections.delete(socket.id);
  });

  socket.on('connect_error', (error) => {
    console.error(`❌ Connection error for ${socket.id}:`, error);
  });


  socket.on('stop_command', () => {
    console.log(`🛑 Stop command requested from ${socket.id}`);
    // For now, just acknowledge the stop request
    // In a more complex implementation, we could track and kill specific processes
    socket.emit('command_feedback', {
      type: 'info',
      message: 'Command stop requested',
      isSystem: true,
      isError: false,
      timestamp: new Date().toISOString()
    });
  });

  socket.on('run_cursor_command', async (data) => {
    const { message, mode } = data;
    console.log(`🔧 Command from ${socket.id} (${mode}): ${message}`);

    if (mode === 'cursor-agent') {
      // AI Agent mode - execute with cursor-agent
      console.log(`🤖 Running AI agent: ${message}`);
      
      // Send acknowledgment
      socket.emit('command_feedback', {
        type: 'info',
        message: `🤖 Running AI agent: ${message}`,
        timestamp: new Date().toISOString()
      });
      
      // Execute AI agent command
      const commandToExecute = `echo "${message.replace(/"/g, '\\"')}" | cursor-agent agent -p --output-format text`;
      const execOptions = {
        cwd: PROJECT_ROOT,
        timeout: 60000, // 1 minute timeout
        maxBuffer: 1024 * 1024 * 10 // 10MB buffer
      };

      exec(commandToExecute, execOptions, (error, stdout, stderr) => {
        if (error) {
          console.error(`❌ AI agent error: ${error.message}`);
          socket.emit('command_feedback', {
            type: 'error',
            message: `Error: ${error.message}`,
            timestamp: new Date().toISOString()
          });
          socket.emit('command_exit', error.code || 1);
          return;
        }

        if (stderr) {
          console.log(`📤 AI agent stderr: ${stderr}`);
          socket.emit('command_feedback', {
            type: 'error',
            message: stderr,
            timestamp: new Date().toISOString()
          });
        }

        if (stdout) {
          console.log(`📤 AI agent output: ${stdout}`);
          socket.emit('command_feedback', {
            type: 'ai_response',
            message: stdout,
            isSystem: false,
            isError: false,
            timestamp: new Date().toISOString()
          });
        }

        // Send completion signal
        socket.emit('command_feedback', {
          type: 'info',
          message: '\n✅ AI agent completed',
          timestamp: new Date().toISOString()
        });
        
        socket.emit('command_exit', 0);
      });

    } else {
      // For terminal commands, use exec as before
      const commandToExecute = `bash -c "${message.replace(/"/g, '\\"')}"`;
      const execOptions = {
        cwd: PROJECT_ROOT,
        timeout: 30000, // 30 second timeout
        env: { ...process.env, PATH: process.env.PATH }
      };

      exec(commandToExecute, execOptions, (error, stdout, stderr) => {
        if (error) {
          console.error(`❌ Command failed: ${error.message}`);
          socket.emit('command_feedback', {
            type: 'error',
            message: `Command failed: ${error.message}\n${stderr ? `Stderr: ${stderr}` : ''}`,
            timestamp: new Date().toISOString()
          });
          socket.emit('command_exit', error.code || 1);
          return;
        }

        if (stderr) {
          console.log(`⚠️ Command with warnings: ${stderr}`);
          socket.emit('command_feedback', {
            type: 'warning',
            message: `Command completed with warnings:\n${stderr}\n\nOutput:\n${stdout}`,
            timestamp: new Date().toISOString()
          });
        } else {
          console.log(`✅ Command success: ${stdout}`);
          socket.emit('command_feedback', {
            type: 'terminal_output',
            message: stdout || 'Command executed successfully (no output)',
            isSystem: false,
            isError: false,
            timestamp: new Date().toISOString()
          });
        }
        
        socket.emit('command_exit', 0);
      });
    }
  });
});

// Start server
server.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 CLI Remote Control Server running on port ${PORT}`);
  console.log(`📁 Project root: ${PROJECT_ROOT}`);
  console.log(`🌐 Access from: http://0.0.0.0:${PORT}`);
  console.log(`📱 Ready for mobile connections!`);
});

// Set max listeners to prevent memory leak warnings
server.setMaxListeners(15);

// Graceful shutdown
let isShuttingDown = false;

const gracefulShutdown = (signal) => {
  if (isShuttingDown) {
    console.log('🛑 Force shutdown...');
    process.exit(1);
  }
  
  isShuttingDown = true;
  console.log(`\n🛑 Received ${signal}. Shutting down server gracefully...`);
  
  // Clean up active connections
  console.log('🧹 Cleaning up active connections...');
  activeConnections.clear();
  
  server.close((err) => {
    if (err) {
      console.error('❌ Error during server shutdown:', err);
      process.exit(1);
    }
    console.log('✅ Server closed successfully');
    process.exit(0);
  });
  
  // Force shutdown after 10 seconds
  setTimeout(() => {
    console.log('⏰ Graceful shutdown timeout, forcing exit...');
    process.exit(1);
  }, 10000);
};

process.on('SIGINT', () => gracefulShutdown('SIGINT'));
process.on('SIGTERM', () => gracefulShutdown('SIGTERM'));
