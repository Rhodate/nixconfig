{
  pkgs,
  lib,
  ...
}: let
  certPath = "/var/lib/acme/${lib.swarm.domainName}/";
in {
  config.swarm.esh.templates = {
    tls-certificate = {
      template = ''
        apiVersion: traefik.io/v1alpha1
        kind: TLSStore
        metadata:
          name: default
        spec:
          defaultCertificate:
            secretName: "tls-certificate"
        ---
        apiVersion: v1
        kind: Secret
        type: Opaque
        metadata:
          name: "tls-certificate"
        data:
          tls.crt: <% cat ${certPath + "cert.pem"} | ${pkgs.uutils-coreutils}/bin/uutils-base64 -w 0 %>
          tls.key: <% cat ${certPath + "key.pem"} | ${pkgs.uutils-coreutils}/bin/uutils-base64 -w 0 %>
      '';
      destination = "/var/lib/rancher/k3s/server/manifests/tls-certificate.yaml";
    };
  };
}
