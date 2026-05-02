import random
import threading
import time

from prometheus_client import Gauge, start_http_server
from flask import Flask

app = Flask(__name__)

db_pool_size = Gauge(
    'db_pool_size',
    'Current number of connections in the database pool.'
)

queue_depth = Gauge(
    'queue_depth',
    'Current number of items waiting in the processing queue.'
)


def update_gauges():
    while True:
        db_pool_size.set(random.randint(5, 20))
        queue_depth.set(random.randint(0, 100))
        time.sleep(5)


@app.route('/health')
def health():
    return {'status': 'ok'}, 200


if __name__ == '__main__':
    start_http_server(8000)
    print('Metrics server running on http://localhost:8000/metrics')
    print('Flask app running on http://localhost:5000')

    t = threading.Thread(target=update_gauges, daemon=True)
    t.start()

    app.run(port=5000)
