{
  config,
  lib,
  ...
}:
with lib; {
  config = mkIf config.swarm.server.k3s.enable {
    # Example ingress, that just returns hello world
    environment.etc."rancher/k3s/ingress.yaml".text = ''
      apiVersion: traefik.io/v1alpha1
      kind: IngressRoute
      metadata:
        name: k3s-ingress
      spec:
        entryPoints:
          - websecure
        routes:
          - match: Host('chito.rhodate.com')
            kind: Rule
            services:
              - name: example
                port: 80
        tls:
          secretName: tls-certificate
      ---
      apiVersion: v1
      kind: Service
      metadata:
        name: example
        namespace: default
      spec:
        type: ClusterIP
        selector:
          app: example
        ports:
          - name: http
            port: 80
            targetPort: 8080
      ---
      apiVersion: apps/v1
      kind: Deployment
      metadata:
        name: example
        namespace: default
      spec:
        replicas: 1
        selector:
          matchLabels:
            app: example
        template:
          metadata:
            labels:
              app: example
          spec:
            containers:
              - name: example
                image: traefik/whoami
    '';
  };
}
