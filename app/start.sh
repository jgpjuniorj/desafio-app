#!/bin/bash
echo "Iniciando app na porta 5000..."
./venv/bin/gunicorn --bind 0.0.0.0:5000 --timeout 240 app:app &

echo "Aguardando 30 segundos..."
sleep 30

echo "Iniciando redirect na porta 5001..."
./venv/bin/gunicorn --bind 0.0.0.0:5001 --timeout 240 redirect:app &

echo "Aguardando processos em segundo plano..."
wait