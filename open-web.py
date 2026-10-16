import http.server
import socketserver
from pathlib import Path

ROOT = Path(__file__).resolve().parent / "build" / "web"
PORT = 8060


class Handler(http.server.SimpleHTTPRequestHandler):
    extensions_map = {
        **http.server.SimpleHTTPRequestHandler.extensions_map,
        ".js": "application/javascript",
        ".wasm": "application/wasm",
        ".pck": "application/octet-stream",
    }

    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=str(ROOT), **kwargs)


class Server(socketserver.TCPServer):
    allow_reuse_address = True


def main():
    try:
        httpd = Server(("127.0.0.1", PORT), Handler)
    except OSError:
        print("8060 端口已被占用。请关掉之前的调试窗口后再打开。")
        raise SystemExit(1)
    print(f"http://127.0.0.1:{PORT}/  按 Ctrl+C 停止", flush=True)
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        httpd.server_close()


if __name__ == "__main__":
    main()
