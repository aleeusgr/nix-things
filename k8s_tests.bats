#!/usr/bin/env bats
# Kubernetes Services Testing Plan for NixOS
# Tests for certmgr, cfssl, kubectl, and minikube setup

setup() {
    # Run before each test
    # Optional: load bats helper libraries if available
    if [ -f '/usr/lib/bats/bats-support/load.bash' ]; then
        load '/usr/lib/bats/bats-support/load.bash'
    fi
    if [ -f '/usr/lib/bats/bats-assert/load.bash' ]; then
        load '/usr/lib/bats/bats-assert/load.bash'
    fi
}

# Test 1: Check cfssl service status
@test "cfssl service is running" {
    run systemctl is-active cfssl
    [ "$status" -eq 0 ]
    [ "$output" = "active" ]
}

@test "cfssl service has no errors" {
    run systemctl status cfssl
    [ "$status" -eq 0 ]
    [[ ! "$output" =~ "failed" ]]
    [[ ! "$output" =~ "error" ]]
}

# Test 2: Check certmgr service status
@test "certmgr service is running" {
    run systemctl is-active certmgr
    [ "$status" -eq 0 ]
    [ "$output" = "active" ]
}

@test "certmgr service has no errors" {
    run systemctl status certmgr.service
    [ "$status" -eq 0 ]
    [[ ! "$output" =~ "failed" ]]
    [[ ! "$output" =~ "error" ]]
}

# Test 3: Verify apitoken.secret file exists
@test "apitoken.secret file exists" {
    run test -f /var/lib/kubernetes/secrets/apitoken.secret
    [ "$status" -eq 0 ]
}

@test "apitoken.secret has correct permissions" {
    run ls -la /var/lib/kubernetes/secrets/apitoken.secret
    [ "$status" -eq 0 ]
    # File should exist and be readable
    [[ "$output" =~ "apitoken.secret" ]]
}

@test "apitoken.secret is not empty" {
    run test -s /var/lib/kubernetes/secrets/apitoken.secret
    [ "$status" -eq 0 ]
}

# Test 4: Check service logs for errors
@test "cfssl logs show no critical errors in current boot" {
    run journalctl -u cfssl -b --no-pager
    [ "$status" -eq 0 ]
    # Allow warnings but fail on errors or critical issues
    [[ ! "$output" =~ "level=error" ]]
    [[ ! "$output" =~ "CRITICAL" ]]
}

@test "certmgr logs show no critical errors in current boot" {
    run journalctl -u certmgr -b --no-pager
    [ "$status" -eq 0 ]
    # Allow warnings but fail on errors or critical issues
    [[ ! "$output" =~ "level=error" ]]
    [[ ! "$output" =~ "CRITICAL" ]]
}

# Test 5: Verify kubectl connection error (expected behavior without cluster)
@test "kubectl shows expected connection error without cluster" {
    run kubectl version 2>&1
    # Exit status should be non-zero (connection failed)
    [ "$status" -ne 0 ]
    # Should contain the expected error message
    [[ "$output" =~ "connection to the server localhost:8080 was refused" ]] || \
    [[ "$output" =~ "refused" ]] || \
    [[ "$output" =~ "connection refused" ]]
}

@test "kubectl binary is installed and accessible" {
    run which kubectl
    [ "$status" -eq 0 ]
    [[ "$output" =~ "kubectl" ]]
}

@test "kubectl version shows client version" {
    run kubectl version --client
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Client Version" ]]
}

# Test 6: Verify minikube installation
@test "minikube is installed" {
    run which minikube
    [ "$status" -eq 0 ]
    [[ "$output" =~ "minikube" ]]
}

@test "minikube version command works" {
    run minikube version
    [ "$status" -eq 0 ]
    [[ "$output" =~ "minikube version" ]]
}

@test "minikube binary is executable" {
    run test -x "$(which minikube)"
    [ "$status" -eq 0 ]
}

# Additional helper tests
@test "kubernetes secrets directory exists" {
    run test -d /var/lib/kubernetes/secrets
    [ "$status" -eq 0 ]
}

@test "systemd services are enabled at boot" {
    run systemctl is-enabled cfssl
    [ "$status" -eq 0 ]
    
    run systemctl is-enabled certmgr
    [ "$status" -eq 0 ]
}

# Integration test: verify full service chain
@test "all required services are active simultaneously" {
    cfssl_active=$(systemctl is-active cfssl)
    certmgr_active=$(systemctl is-active certmgr)
    
    [ "$cfssl_active" = "active" ]
    [ "$certmgr_active" = "active" ]
}

teardown() {
    # Run after each test (optional cleanup)
    :
}
