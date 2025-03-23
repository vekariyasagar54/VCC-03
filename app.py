from flask import Flask
import multiprocessing

app = Flask(__name__)

def burn_cpu():
    # Infinite loop to burn CPU cycles
    while True:
        pass

@app.route('/')
def index():
    return "Flask App Running.", 200

@app.route('/load')
def load():
    # Get the number of CPU cores
    cpu_count = multiprocessing.cpu_count()
    # Create one process per core to maximize CPU usage
    processes = []
    for _ in range(cpu_count):
        p = multiprocessing.Process(target=burn_cpu)
        p.daemon = True  # Set as daemon so they exit when the main process ends
        p.start()
        processes.append(p)
    return f"CPU load started", 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
