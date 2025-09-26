const express = require('express');
const http = require('http');
const { Server } = require('socket.io');
const { exec } = require('child_process');
const path = require('path');

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

const PORT = process.env.PORT || 3000;
const PROJECT_ROOT = path.join(__dirname, '..'); // Project root directory
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
  });

  socket.on('connect_error', (error) => {
    console.error(`❌ Connection error for ${socket.id}:`, error);
  });

  socket.on('run_cursor_command', async (data) => {
    const { message, mode } = data;
    console.log(`🔧 Command from ${socket.id} (${mode}): ${message}`);

    // Prepare command based on mode
    let commandToExecute;
    let execOptions = {
      cwd: PROJECT_ROOT,
      timeout: 30000, // 30 second timeout
      env: { ...process.env, PATH: process.env.PATH } // Ensure PATH is available
    };

    if (mode === 'cursor-agent') {
      // For cursor-agent, use --print flag for non-interactive mode
      // Use full path to cursor-agent to avoid PATH issues
      commandToExecute = `cursor-agent -p "${message}" --output-format text`;
      // Don't wrap in bash -c for cursor-agent
      // Use PROJECT_ROOT for cursor-agent context
      execOptions.cwd = PROJECT_ROOT;
      console.log(`🔍 DEBUG: Executing cursor-agent command: ${commandToExecute}`);
      console.log(`🔍 DEBUG: Working directory: ${execOptions.cwd}`);
    } else {
      // For terminal commands, wrap in bash context
      commandToExecute = `bash -c "${message.replace(/"/g, '\\"')}"`;
      // Use PROJECT_ROOT for terminal commands
      execOptions.cwd = PROJECT_ROOT;
    }

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
          type: 'success',
          message: stdout || 'Command executed successfully (no output)',
          timestamp: new Date().toISOString()
        });
      }
      
      socket.emit('command_exit', 0);
    });
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
