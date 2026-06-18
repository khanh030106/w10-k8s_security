#!/bin/bash
# Test Gatekeeper Policies
# Chạy: bash test-gatekeeper.sh

echo "================================================"
echo "TEST 1: Cấm image tag :latest"
echo "================================================"
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: test-latest
  namespace: demo
spec:
  containers:
  - name: nginx
    image: nginx:latest
    resources:
      limits:
        cpu: 100m
        memory: 128Mi
EOF
echo ""

echo "================================================"
echo "TEST 2: Bắt buộc có resources.limits"
echo "================================================"
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: test-no-limits
  namespace: demo
spec:
  containers:
  - name: nginx
    image: nginx:1.21
EOF
echo ""

echo "================================================"
echo "TEST 3: Cấm runAsUser: 0 (root)"
echo "================================================"
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: test-root
  namespace: demo
spec:
  containers:
  - name: nginx
    image: nginx:1.21
    securityContext:
      runAsUser: 0
    resources:
      limits:
        cpu: 100m
        memory: 128Mi
EOF
echo ""

echo "================================================"
echo "TEST 4: Cấm hostNetwork: true"
echo "================================================"
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: test-hostnet
  namespace: demo
spec:
  hostNetwork: true
  containers:
  - name: nginx
    image: nginx:1.21
    resources:
      limits:
        cpu: 100m
        memory: 128Mi
    securityContext:
      runAsUser: 1000
EOF
echo ""

echo "================================================"
echo "TEST 5: Custom - Bắt buộc label owner"
echo "================================================"
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: test-no-owner
  namespace: demo
spec:
  replicas: 1
  selector:
    matchLabels:
      app: test
  template:
    metadata:
      labels:
        app: test
    spec:
      containers:
      - name: nginx
        image: nginx:1.21
        resources:
          limits:
            cpu: 100m
            memory: 128Mi
        securityContext:
          runAsUser: 1000
EOF
echo ""

echo "================================================"
echo "TEST 6: Pod HỢP LỆ (phải PASS)"
echo "================================================"
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: test-valid
  namespace: demo
  labels:
    owner: khanh
spec:
  replicas: 1
  selector:
    matchLabels:
      app: test-valid
  template:
    metadata:
      labels:
        app: test-valid
    spec:
      containers:
      - name: nginx
        image: nginx:1.21
        resources:
          limits:
            cpu: 100m
            memory: 128Mi
          requests:
            cpu: 50m
            memory: 64Mi
        securityContext:
          runAsUser: 1000
EOF

echo ""
echo "================================================"
echo "KẾT QUẢ:"
echo "- Test 1-5 phải bị REJECT (Error from server)"
echo "- Test 6 phải PASS (deployment created)"
echo "================================================"
