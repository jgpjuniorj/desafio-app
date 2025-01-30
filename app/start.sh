#!/bin/bash
# start.sh
./venv/bin/gunicorn --bind 0.0.0.0:5000 --timeout 120 app:app &
./venv/bin/gunicorn --bind 0.0.0.0:5001 --timeout 120 redirect:app &
wait