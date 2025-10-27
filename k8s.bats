#!/usr/bin/env bats
# Kubernetes Services Testing Plan for NixOS
# Tests for NixOS-managed Kubernetes cluster with Flannel CNI

setup() {
    # Run before each test
    if [ -f '/usr/lib/bats/bats-support/load.bash' ]; then
        load '/usr/lib/bats/bats-support/load.bash'
    fi
    if [ -f '/usr/lib/bats/bats-assert/load.bash' ]; then
        load '/usr/lib/bats/bats-assert/load.bash'
    fi
}

# Certificate Management Services
@test "cfssl service is running" {
    run systemctl is-active cfssl
    [ "$status" -eq 0 ]
    [ "$output" = "active" ]
}

@test "certmgr service is running" {
    run systemctl is-active certmgr
    [ "$status" -eq 0 ]
    [ "$output" = "active" ]
}

@test "certmgr depends on cfssl correctly" {
    run systemctl show certmgr --property=After
    [ "$status" -eq 0 ]
    [[ "$output" =~ "cfssl.service" ]]
}

@test "apitoken.secret file exists and is not empty" {
    run test -s /var/lib/kubernetes/secrets/apitoken.secret
    [ "$status" -eq 0 ]
}

# Core Kubernetes Control Plane Services
@test "kube-apiserver service is running" {
    run systemctl is-active kube-apiserver
    [ "$status" -eq 0 ]
    [ "$output" = "active" ]
}

@test "kube-controller-manager service is running" {
    run systemctl is-active kube-controller-manager
    [ "$status" -eq 0 ]
    [ "$output" = "active" ]
}

@test "kube-scheduler service is running" {
    run systemctl is-active kube-scheduler
    [ "$status" -eq 0 ]
    [ "$output" = "active" ]
}

@test "kubelet service is running" {
    run systemctl is-active kubelet
    [ "$status" -eq 0 ]
    [ "$output" = "active" ]
}

@test "kube-proxy service is running" {
    run systemctl is-active kube-proxy
    [ "$status" -eq 0 ]
    [ "$output" = "active" ]
}

# Flannel CNI Service
@test "flannel service is running" {
    run systemctl is-active flannel
    [ "$status" -eq 0 ]
    [ "$output" = "active" ]
}

@test "flannel subnet.env file exists" {
    run test -f /run/flannel/subnet.env
    [ "$status" -eq 0 ]
}

@test "flannel subnet.env contains network configuration" {
    run cat /run/flannel/subnet.env
    [ "$status" -eq 0 ]
    [[ "$output" =~ "FLANNEL_NETWORK" ]] || [[ "$output" =~ "FLANNEL_SUBNET" ]]
}

@test "flannel logs show no RBAC permission errors" {
    run journalctl -u flannel -n 100 --no-pager
    [ "$status" -eq 0 ]
    [[ ! "$output" =~ "is forbidden" ]]
    [[ ! "$output" =~ "cannot list resource" ]]
}

# Addon Manager
@test "kube-addon-manager service is running" {
    run systemctl is-active kube-addon-manager
    [ "$status" -eq 0 ]
    [ "$output" = "active" ]
}

@test "kube-addon-manager waits for apiserver" {
    run systemctl show kube-addon-manager --property=After
    [ "$status" -eq 0 ]
    [[ "$output" =~ "kube-apiserver.service" ]]
}

# Kubernetes Cluster Health
@test "kubectl can connect to cluster" {
    run sudo kubectl cluster-info
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Kubernetes" ]]
}

@test "kubectl shows cluster nodes" {
    run sudo kubectl get nodes
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Ready" ]] || [[ "$output" =~ "NotReady" ]]
}

@test "kube-system namespace exists" {
    run sudo kubectl get namespace kube-system
    [ "$status" -eq 0 ]
    [[ "$output" =~ "kube-system" ]]
}

@test "system pods exist in kube-system namespace" {
    run sudo kubectl get pods -n kube-system
    [ "$status" -eq 0 ]
    # Should have at least one pod (DNS addon or similar)
    [ "$(echo "$output" | wc -l)" -gt 1 ]
}

@test "coredns pods are running" {
    run sudo kubectl get pods -n kube-system -l k8s-app=kube-dns
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Running" ]] || [[ "$output" =~ "ContainerCreating" ]]
}

@test "flannel pods exist in kube-system" {
    run sudo kubectl get pods -n kube-system -l app=flannel
    [ "$status" -eq 0 ]
    # Should show flannel pods (may still be starting)
    [[ "$output" =~ "flannel" ]] || [ "$(echo "$output" | wc -l)" -gt 1 ]
}

# API Server Health
@test "apiserver is responding to health checks" {
    run curl -k -s https://api.kube:6443/healthz
    [ "$status" -eq 0 ]
    [[ "$output" =~ "ok" ]]
}

@test "apiserver is listening on port 6443" {
    run ss -tlnp | grep :6443
    [ "$status" -eq 0 ]
    [[ "$output" =~ "6443" ]]
}

# Service Logs Quality
@test "cfssl logs show no critical errors" {
    run journalctl -u cfssl -b --no-pager
    [ "$status" -eq 0 ]
    [[ ! "$output" =~ "level=error" ]]
    [[ ! "$output" =~ "CRITICAL" ]]
}

@test "certmgr logs show no critical errors" {
    run journalctl -u certmgr -b --no-pager
    [ "$status" -eq 0 ]
    [[ ! "$output" =~ "level=error" ]]
    [[ ! "$output" =~ "CRITICAL" ]]
}

@test "kube-apiserver logs show no critical errors" {
    run journalctl -u kube-apiserver -n 100 --no-pager
    [ "$status" -eq 0 ]
    [[ ! "$output" =~ "panic" ]]
    [[ ! "$output" =~ "fatal error" ]]
}

@test "kubelet logs show no pod creation failures" {
    run journalctl -u kubelet -n 100 --no-pager
    [ "$status" -eq 0 ]
    [[ ! "$output" =~ "failed to setup network" ]]
    [[ ! "$output" =~ "no such file or directory" ]]
}

# Application Pods (govtool namespace)
@test "govtool namespace exists" {
    run sudo kubectl get namespace govtool
    [ "$status" -eq 0 ]
    [[ "$output" =~ "govtool" ]]
}

@test "govtool pods are not stuck in ContainerCreating" {
    run sudo kubectl get pods -n govtool
    [ "$status" -eq 0 ]
    # Pods should be Running, or may not exist yet, but not stuck Creating for >5min
    if [[ "$output" =~ "ContainerCreating" ]]; then
        # Check age - parse AGE column
        stuck_pods=$(echo "$output" | grep ContainerCreating | awk '{print $5}' | grep -E '[0-9]+m|[0-9]+h|[0-9]+d')
        if [ -n "$stuck_pods" ]; then
            # If any pod shows minutes/hours/days in ContainerCreating, fail
            [[ ! "$stuck_pods" =~ "m" ]] && [[ ! "$stuck_pods" =~ "h" ]] && [[ ! "$stuck_pods" =~ "d" ]]
        fi
    fi
}

# KUBECONFIG Environment
@test "KUBECONFIG environment variable is set" {
    run bash -c 'echo $KUBECONFIG'
    [ "$status" -eq 0 ]
    [[ "$output" =~ "/etc/kubernetes" ]]
}

@test "kubeconfig file exists and is readable" {
    kubeconfig="/etc/kubernetes/cluster-admin.kubeconfig"
    run test -r "$kubeconfig"
    [ "$status" -eq 0 ]
}

# Tools Installation
@test "kubectl binary is installed" {
    run which kubectl
    [ "$status" -eq 0 ]
    [[ "$output" =~ "kubectl" ]]
}

@test "kubernetes-helm is installed" {
    run which helm
    [ "$status" -eq 0 ]
    [[ "$output" =~ "helm" ]]
}

# Integration Tests
@test "all critical services are active simultaneously" {
    services="cfssl certmgr kube-apiserver kube-controller-manager kube-scheduler kubelet flannel"
    for svc in $services; do
        status=$(systemctl is-active $svc)
        [ "$status" = "active" ]
    done
}

@test "networking stack is fully operational" {
    # Flannel running, subnet.env exists, and apiserver reachable
    run systemctl is-active flannel
    [ "$status" -eq 0 ]
    
    run test -f /run/flannel/subnet.env
    [ "$status" -eq 0 ]
    
    run curl -k -s https://api.kube:6443/healthz
    [ "$status" -eq 0 ]
}

teardown() {
    :
}
