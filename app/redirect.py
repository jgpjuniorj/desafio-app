import os
import requests
from flask import Flask, request, Response

app = Flask(__name__)

TARGET_SERVICE = os.getenv('TARGET_SERVICE')

@app.route('/rota1', methods=['GET', 'POST'])
def proxy():
    target_url = f"{TARGET_SERVICE}/health"

    try:
        resp = requests.request(
            method=request.method,
            url=target_url,
            headers={key: value for (key, value) in request.headers if key.lower() != 'host'},
            data=request.get_data(),
            cookies=request.cookies,
            allow_redirects=False
        )

        response = Response(resp.content, resp.status_code)
        for key, value in resp.headers.items():
            response.headers[key] = value
        return response

    except requests.exceptions.RequestException as e:
        return f"Erro ao conectar ao serviço de destino: {e}", 500

if __name__ == '__main__':
    port = int(os.getenv('APP_PORT'))
    app.run(host='127.0.0.1', port=port)