
import os
from flask import Flask, jsonify

app = Flask(__name__)

@app.route('/')
def home():
    return jsonify({"message": "Olá, mundo!"})

@app.route('/health')
def health():
    return jsonify({"status": "UP"}), 200

if __name__ == '__main__':
    port = int(os.getenv('APP_PORT'))
    app.run(host='127.0.0.1', port=port)