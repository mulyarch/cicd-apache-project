#!/bin/bash
set -e

echo "=== Integration Tests (Post-Deploy) ==="

# Get the LoadBalancer URL
LB_URL=$(kubectl get svc apache-hello-svc -n apache-app \
  -o jsonpath='{.status.loadBalancer.ingress.hostname}')

echo "Testing endpoint: $LB_URL"

# Wait for LB to be ready (can take 2-3 min)
MAX_RETRIES=30
RETRY=0
until curl -s -o /dev/null -w "%{http_code}" "http://$LB_URL" | grep -q "200"; do
  RETRY=$((RETRY+1))
  if [ $RETRY -ge $MAX_RETRIES ]; then
    echo "FAIL: LB not responding after $MAX_RETRIES attempts"
    exit 1
  fi
  echo "Waiting for LB... (attempt $RETRY/$MAX_RETRIES)"
  sleep 10
done

# Test 1: Response code
echo "Test 1: HTTP 200... PASS"

# Test 2: Content
CONTENT=$(curl -s "http://$LB_URL")
if echo "$CONTENT" | grep -q "Hello World"; then
  echo "Test 2: Content check... PASS"
else
  echo "Test 2: Content check... FAIL"
  exit 1
fi

# Test 3: Multiple pods are running
POD_COUNT=$(kubectl get pods -n apache-app --field-selector=status.phase=Running -o name | wc -l)
if [ "$POD_COUNT" -ge 2 ]; then
  echo "Test 3: Pod count ($POD_COUNT >= 2)... PASS"
else
  echo "Test 3: Pod count ($POD_COUNT < 2)... FAIL"
  exit 1
fi

echo "=== All integration tests passed! ==="
