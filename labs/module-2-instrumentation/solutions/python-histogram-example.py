import random
import time

from prometheus_client import Histogram, start_http_server
from flask import Flask

app = Flask(__name__)

request_duration_seconds = Histogram(
    'request_duration_seconds',
    'Duration of HTTP requests in seconds.',
    buckets=[0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1.0]
)


@app.route('/api/slow')
def slow():
    start = time.time()
    sleep_ms = random.randint(10, 500)
    time.sleep(sleep_ms / 1000.0)
    duration = time.time() - start
    request_duration_seconds.observe(duration)
    return {'latency_ms': sleep_ms}, 200


if __name__ == '__main__':
    start_http_server(8000)
    print('Metrics server running on http://localhost:8000/metrics')
    print('Flask app running on http://localhost:5000')
    app.run(port=5000)
