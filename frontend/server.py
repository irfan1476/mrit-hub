#!/usr/bin/env python3
import http.server
import socketserver
import os

PORT = 8080
os.chdir(os.path.dirname(os.path.abspath(__file__)))

Handler = http.server.SimpleHTTPRequestHandler
Handler.extensions_map.update({
    '.js': 'application/javascript',
    '.html': 'text/html',
    '.css': 'text/css',
})

with socketserver.TCPServer(("", PORT), Handler) as httpd:
    print(f"🚀 Frontend server running at http://localhost:{PORT}")
    print(f"📱 Open http://localhost:{PORT} in your browser")
    httpd.serve_forever()