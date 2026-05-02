from prometheus_client import Counter, start_http_server
from flask import Flask

app = Flask(__name__)

api_requests_total = Counter(
    'api_requests_total',
    'Total number of API requests by method, endpoint, and status.',
    ['method', 'endpoint', 'status']
)


@app.route('/api/users', methods=['GET'])
def get_users():
    api_requests_total.labels(method='GET', endpoint='/api/users', status='200').inc()
    return {'users': []}, 200


@app.route('/api/users', methods=['POST'])
def create_user():
    api_requests_total.labels(method='POST', endpoint='/api/users', status='201').inc()
    return {'created': True}, 201


if __name__ == '__main__':
    start_http_server(8000)
    print('Metrics server running on http://localhost:8000/metrics')
    print('Flask app running on http://localhost:5000')
    app.run(port=5000)
