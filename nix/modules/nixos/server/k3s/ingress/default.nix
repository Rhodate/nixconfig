{...}: {
  services.k3s.manifests.traefik-config.content = {
    apiVersion = "helm.cattle.io/v1";
    kind = "HelmChartConfig";
    metadata = {
      name = "traefik";
      namespace = "kube-system";
    };
    spec.valuesContent = ''
      ports:
        ssh:
          port: 22
          exposedPort: 22
          expose:
            default: true
          protocol: TCP
          tls:
            enabled: false
    '';
  };
}
