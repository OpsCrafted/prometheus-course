#!/usr/bin/env python3
"""
Load Generator for Prometheus Course

Continuously sends HTTP requests to target endpoints with weighted
distribution: 70% to / (successful), 20% to /slow (1-2s latency),
10% to /error (returns 500). Supports graceful shutdown on
SIGTERM/SIGINT.
"""

import os
import sys
import time
import signal
import types
import random
import logging
import threading
from typing import NoReturn

import requests

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    datefmt='%Y-%m-%d %H:%M:%S'
)
logger = logging.getLogger(__name__)

# Global flag for graceful shutdown
shutdown_event = threading.Event()


def signal_handler(signum: int, frame: types.FrameType | None) -> None:
    """Handle SIGTERM and SIGINT signals for graceful shutdown."""
    global shutdown_event
    signal_name = signal.Signals(signum).name
    logger.info(
        f"Received {signal_name}, initiating graceful shutdown..."
    )
    shutdown_event.set()


def select_endpoint() -> str:
    """
    Select an endpoint using weighted random distribution.

    Returns:
        str: Endpoint path (/, /slow, or /error)
    """
    endpoints = ['/', '/slow', '/error']
    weights = [0.70, 0.20, 0.10]
    return random.choices(endpoints, weights=weights, k=1)[0]


def send_request(target_url: str, endpoint: str) -> dict:
    """
    Send HTTP GET request to target endpoint and measure latency.

    Args:
        target_url: Base URL of target service
        endpoint: Path to request (/, /slow, /error)

    Returns:
        dict: Request result containing status code, latency, and endpoint
    """
    url = f"{target_url}{endpoint}"
    start_time = time.time()

    try:
        response = requests.get(url, timeout=10)
        latency = time.time() - start_time

        return {
            'endpoint': endpoint,
            'status': response.status_code,
            'latency': latency,
            'success': True
        }
    except requests.exceptions.RequestException as e:
        latency = time.time() - start_time

        return {
            'endpoint': endpoint,
            'status': None,
            'latency': latency,
            'success': False,
            'error': str(e)
        }


def log_request(result: dict) -> None:
    """
    Log request details with timestamp, endpoint, status, and latency.

    Args:
        result: Request result dictionary
    """
    if result['success']:
        logger.info(
            f"endpoint={result['endpoint']} status={result['status']} "
            f"latency={result['latency']:.3f}s"
        )
    else:
        logger.warning(
            f"endpoint={result['endpoint']} error={result['error']} "
            f"latency={result['latency']:.3f}s"
        )


def run_load_generator(target_url: str, request_rate: float) -> NoReturn:
    """
    Run the load generator continuously.

    Args:
        target_url: Base URL of target service
        request_rate: Number of requests per second

    Raises:
        NoReturn: Infinite loop until shutdown
    """
    delay_between_requests = 1.0 / request_rate
    request_count = 0

    logger.info("Starting load generator")
    logger.info(f"Target URL: {target_url}")
    logger.info(f"Request rate: {request_rate} req/sec")
    logger.info(f"Delay between requests: {delay_between_requests:.3f}s")
    logger.info("Press Ctrl+C to stop")

    try:
        while not shutdown_event.is_set():
            endpoint = select_endpoint()
            result = send_request(target_url, endpoint)
            log_request(result)

            request_count += 1

            # Responsive shutdown: wait with timeout instead of sleep
            if shutdown_event.wait(timeout=delay_between_requests):
                break

    finally:
        logger.info(
            f"Load generator stopped. Total requests sent: "
            f"{request_count}"
        )


def main() -> None:
    """Main entry point."""
    # Read environment variables
    target_url = os.getenv('TARGET_URL', 'http://sample-app:8080')
    target_url = target_url.rstrip('/')
    request_rate_str = os.getenv('REQUEST_RATE', '10')

    # Parse request rate
    try:
        request_rate = float(request_rate_str)
        if request_rate <= 0:
            logger.error(
                f"REQUEST_RATE must be positive, got {request_rate}"
            )
            sys.exit(1)
    except ValueError:
        logger.error(
            f"REQUEST_RATE must be a number, got {request_rate_str}"
        )
        sys.exit(1)

    # Validate target URL
    if not target_url.startswith(('http://', 'https://')):
        logger.error(
            f"TARGET_URL must start with http:// or https://, got "
            f"{target_url}"
        )
        sys.exit(1)

    # Register signal handlers for graceful shutdown
    signal.signal(signal.SIGTERM, signal_handler)
    signal.signal(signal.SIGINT, signal_handler)

    # Run the load generator
    run_load_generator(target_url, request_rate)
    sys.exit(0)


if __name__ == '__main__':
    main()
