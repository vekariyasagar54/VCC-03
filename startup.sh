#!/bin/bash
# Update package list and install required packages
apt-get update -y
apt-get install -y python3 python3-pip

# Write the Flask application to a file
cat <<'EOF' > /home/ubuntu/dummy_flask_app.py
from flask import Flask
import multiprocessing

app = Flask(__name__)

def burn_cpu():
    while True:
        pass

@app.route("/")
def index():
    return "Dummy Flask App Running.", 200

@app.route("/load")
def load():
    cpu_count = multiprocessing.cpu_count()
    processes = []
    for _ in range(cpu_count):
        p = multiprocessing.Process(target=burn_cpu)
        p.daemon = True
        p.start()
        processes.append(p)
    return "CPU load started using {} processes.".format(cpu_count), 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)
EOF

# Install Flask
pip3 install Flask

# Start the Flask app in the background
nohup python3 /home/ubuntu/dummy_flask_app.py > /dev/null 2>&1 &
