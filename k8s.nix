# - source: https://wiki.nixos.org/wiki/Kubernetes
# - Check service status: `systemctl status certmgr cfssl`
# - Verify the file exists: `ls -la /var/lib/kubernetes/secrets/apitoken.secret`
# - Check logs: `journalctl -u certmgr -u cfssl -b`
# - verify `kubectl version` error: The connection to the server localhost:8080 was refused - did you specify the right host or port?
# - `systemctl status cfssl certmgr.service` shows no errors
# https://nixos.org/manual/nixos/stable/#sec-kubernetes
# [Certificate management](https://youtu.be/leR6m2plirs?t=513)

{ config, pkgs, ... }:
let
  kubeMasterIP = "127.0.0.1"; # use 10.1.1.2 to verify L5
  kubeMasterHostname = "api.kube";
  kubeMasterAPIServerPort = 6443;
in
{
  networking.extraHosts = "${kubeMasterIP} ${kubeMasterHostname}";

  environment.systemPackages = with pkgs; [
    kompose
    kubectl
    kubernetes
    minikube # look up services!
    helmfile
    kubernetes-helm
  ];

  services.kubernetes = {
    roles = ["master" "node"];
    masterAddress = kubeMasterHostname;
    apiserverAddress = "https://${kubeMasterHostname}:${toString kubeMasterAPIServerPort}";
    easyCerts = true;
    apiserver = {
      securePort = kubeMasterAPIServerPort;
      advertiseAddress = kubeMasterIP;
    };
    addons.dns.enable = true;
    kubelet.extraOpts = "--fail-swap-on=false";
  };

  # Fix certmgr circular dependency
  systemd.services.certmgr = {
    after = [ "cfssl.service" ];
    wants = [ "cfssl.service" ];
  };
  
  # Wait for API server to be actually ready
  systemd.services.kube-addon-manager = {
    after = [ "kube-apiserver.service" ];
    wants = [ "kube-apiserver.service" ];
    serviceConfig = {
      ExecStartPre = [
        ""
        "${pkgs.bash}/bin/bash -c 'for i in {1..60}; do ${pkgs.curl}/bin/curl -k -s https://${kubeMasterHostname}:${toString kubeMasterAPIServerPort}/healthz && break || sleep 1; done'"
      ];
    };
  };

  # Configure kubectl for your user:
  environment.sessionVariables = {
    KUBECONFIG = "/etc/${config.services.kubernetes.pki.etcClusterAdminKubeconfig}";
  };
}
