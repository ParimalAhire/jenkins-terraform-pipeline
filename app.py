"""Small Flask service used to demonstrate a Jenkins CI/CD pipeline."""
import os
import socket
from datetime import datetime, timezone

from flask import Flask, jsonify

app = Flask(__name__)

APP_VERSION = os.environ.get("APP_VERSION", "dev")


@app.route("/")
def home():
    now = datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M:%S UTC")
    return (
        "<html><head><title>CI/CD Demo</title></head>"
        "<body style='font-family:sans-serif;max-width:560px;margin:60px auto'>"
        "<h1>Deployed by Jenkins</h1>"
        f"<p>Build version: <b>{APP_VERSION}</b></p>"
        f"<p>Container: <b>{socket.gethostname()}</b></p>"
        "<p>This version was deployed automatically after a git push.</p>"
        "</body></html>"
    )


@app.route("/health")
def health():
    return jsonify(status="ok")


@app.route("/version")
def version():
    return jsonify(version=APP_VERSION, host=socket.gethostname())


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
