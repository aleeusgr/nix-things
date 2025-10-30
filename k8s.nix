# source: https://wiki.nixos.org/wiki/Kubernetes
# https://nixos.org/manual/nixos/stable/#sec-kubernetes
# [Certificate management](https://youtu.be/leR6m2plirs?t=513)
# claude.ai/chat/28f9b724-286f-466a-b915-ad4fee42c145

{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    kompose
    kubectl
    kubernetes
    minikube
    helmfile
    kubernetes-helm
    docker  # or podman, if you prefer
  ];

  # Enable docker for minikube
  virtualisation.docker.enable = true;
  
  # Add your user to docker group
  users.users.alex.extraGroups = [ "docker" ];

  # aaboyle878/govtool-k8-manifest
  # Minikube will manage its own kubeconfig in ~/.kube/config
  # No need to set KUBECONFIG to /etc/kubernetes
  networking.extraHosts = ''
    127.0.0.1 be.localhost
    127.0.0.1 oc.localhost
    127.0.0.1 pdf.localhost
    127.0.0.1 frontend.localhost
    127.0.0.1 metadata.localhost
  '';
}
