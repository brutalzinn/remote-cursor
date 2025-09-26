#!/usr/bin/env node

const { spawn } = require('child_process');
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

// Find the CLI server file
const serverPath = path.join(__dirname, 'simple_cli_server.js');

if (!fs.existsSync(serverPath)) {
  console.error('❌ Error: Server file not found at', serverPath);
  process.exit(1);
}

// Start the server with the specified port
const server = spawn('node', [serverPath], {
  stdio: 'inherit',
  env: {
    ...process.env,
    PORT: port,
    CURSOR_WORKING_DIR: workingDir
  }
});

server.on('error', (err) => {
  console.error('❌ Failed to start server:', err);
  process.exit(1);
});

server.on('close', (code) => {
  console.log(`\n🛑 Server stopped with code ${code}`);
  process.exit(code);
});

// Handle graceful shutdown
process.on('SIGINT', () => {
  console.log('\n🛑 Shutting down server...');
  server.kill('SIGINT');
});

process.on('SIGTERM', () => {
  console.log('\n🛑 Shutting down server...');
  server.kill('SIGTERM');
});
