#!/bin/bash
set -e

echo "=== Docker Smoke Tests ==="

# Build the image
docker build -t apache-hello:test ./app

# Run container
CONTAINER_ID=$(docker run -d -p 8888:80 apache-hello:test)

# Wait for container to be healthy
sleep 3

# Test 1: HTTP response code
echo "Test 1: HTTP 200 response..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8888)
if [ "$HTTP_CODE" != "200" ]; then
  echo "FAIL: Expected 200, got $HTTP_CODE"
  docker stop $CONTAINER_ID && docker rm $CONTAINER_ID
  exit 1
fi
echo "PASS"

# Test 2: Content check
echo "Test 2: Content contains 'Hello World'..."
CONTENT=$(curl -s http://localhost:8888)
if ! echo "$CONTENT" | grep -q "Hello World"; then
  echo "FAIL: 'Hello World' not found in response"
  docker stop $CONTAINER_ID && docker rm $CONTAINER_ID
  exit 1
fi
echo "PASS"

# Test 3: Container is running
echo "Test 3: Container is running..."
STATUS=$(docker inspect --format='{{.State.Status}}' $CONTAINER_ID)
if [ "$STATUS" != "running" ]; then
  echo "FAIL: Container status is $STATUS"
  docker stop $CONTAINER_ID && docker rm $CONTAINER_ID
  exit 1
fi
echo "PASS"

# Cleanup
docker stop $CONTAINER_ID && docker rm $CONTAINER_ID
echo "=== All Docker tests passed! ==="
