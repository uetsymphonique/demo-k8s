#!/bin/bash

NAMESPACE="sock-shop"

# Get POD id
FRONT_END_POD=$(kubectl get pods -n $NAMESPACE -l name=front-end -o jsonpath="{.items[0].metadata.name}")
ORDERS_POD=$(kubectl get pods -n $NAMESPACE -l name=orders -o jsonpath="{.items[0].metadata.name}")
CARTS_POD=$(kubectl get pods -n $NAMESPACE -l name=carts -o jsonpath="{.items[0].metadata.name}")
CARTS_DB_POD=$(kubectl get pods -n $NAMESPACE -l name=carts-db -o jsonpath="{.items[0].metadata.name}")
USER_DB_POD=$(kubectl get pods -n $NAMESPACE -l name=user-db -o jsonpath="{.items[0].metadata.name}")
USER_POD=$(kubectl get pods -n $NAMESPACE -l name=user -o jsonpath="{.items[0].metadata.name}")
# Define delay time in seconds
DELAY=5

# Test 1
echo "---------------------------------------------------------------"
echo "Test 1: front-end --> carts (port 80)"
echo "Command: kubectl exec -it $FRONT_END_POD -n $NAMESPACE -- wget -q -T 5 -O- http://carts.$NAMESPACE.svc.cluster.local:80"
kubectl exec -it $FRONT_END_POD -n $NAMESPACE -- wget -q -T 5 -O- http://carts.$NAMESPACE.svc.cluster.local:80 && echo "--> Success" || echo "--> Blocked"
echo -e "\nExpected: Success"
sleep $DELAY

# Test 2
echo "---------------------------------------------------------------"
echo "Test 2: orders --> carts (port 80)"
echo "Command: kubectl exec -it $ORDERS_POD -n $NAMESPACE -- wget -q -T 5 -O- http://carts.$NAMESPACE.svc.cluster.local:80"
kubectl exec -it $ORDERS_POD -n $NAMESPACE -- wget -q -T 5 -O- http://carts.$NAMESPACE.svc.cluster.local:80 && echo "--> Success" || echo "--> Blocked"
echo -e "\nExpected: Connection should be blocked"
sleep $DELAY

# Test 3
echo "---------------------------------------------------------------"
echo "Test 3: front-end --> catalogue (GET method)"
echo "Command: kubectl exec -it $FRONT_END_POD -n $NAMESPACE -- wget -q -T 5 -O- http://catalogue.$NAMESPACE.svc.cluster.local:80/catalogue"
kubectl exec -it $FRONT_END_POD -n $NAMESPACE -- wget -q -T 5 -O- http://catalogue.$NAMESPACE.svc.cluster.local:80/catalogue && echo "--> Success" || echo "--> Blocked"
echo -e "\nExpected: Success (GET allowed)"
sleep $DELAY

# Test 4
echo "---------------------------------------------------------------"
echo "Test 4: front-end --> catalogue (POST method using curl)"
echo "Command: kubectl exec -it $FRONT_END_POD -n $NAMESPACE -- curl -X POST -s -o /dev/null -w '%{http_code}' http://catalogue.$NAMESPACE.svc.cluster.local:80/catalogue -d '{\"key\":\"value\"}' -H 'Content-Type: application/json'"

STATUS_CODE=$(kubectl exec -it $FRONT_END_POD -n $NAMESPACE -- curl -X POST -s -o /dev/null -w '%{http_code}' http://catalogue.$NAMESPACE.svc.cluster.local:80/catalogue -d '{"key":"value"}' -H 'Content-Type: application/json')

if [[ "$STATUS_CODE" -eq 200 ]]; then
    echo "--> Success"
else
    echo "--> Blocked"
fi

echo -e "\nResponse Status Code:"
echo "$STATUS_CODE"

echo -e "\nExpected: Connection should be blocked (POST not allowed)"
sleep $DELAY

# Test 5
echo "---------------------------------------------------------------"
echo "Test 5: carts-db --> user-db (MongoDB port 27017)"
echo "Command: kubectl exec -it $CARTS_DB_POD -n $NAMESPACE -- mongo --host user-db.$NAMESPACE.svc.cluster.local --port 27017 --eval 'db.stats()'"
kubectl exec -it $CARTS_DB_POD -n $NAMESPACE -- mongo --host user-db.$NAMESPACE.svc.cluster.local --port 27017 --eval "db.stats()" && echo "--> Success" || echo "--> Blocked"
echo -e "\nExpected: Connection should be blocked"
sleep $DELAY


echo "All tests completed."
