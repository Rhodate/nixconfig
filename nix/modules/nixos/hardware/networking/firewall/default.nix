{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkOption types;
  ip = "${pkgs.iproute2}/bin/ip";
  nft = "${pkgs.nftables}/bin/nft";
  grep = "${pkgs.gnugrep}/bin/grep";
  head = "${pkgs.uutils-coreutils}/bin/uutils-head";
  trueCmd = "${pkgs.uutils-coreutils}/bin/uutils-true";
  cfg = config.swarm.hardware.networking.firewall;
in {
  options.swarm.hardware.networking.firewall = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable dynamic nftables firewall";
    };

    interface = mkOption {
      type = types.str;
      default = config.swarm.hardware.networking.networkDevice;
      description = "Network interface to detect local subnets.";
    };

    localTcpPorts = mkOption {
      type = types.attrsOf (types.listOf types.int);
      default = [];
      description = "Groups of TCP ports to accept from local/private/public prefixes.";
    };

    localUdpPorts = mkOption {
      type = types.attrsOf (types.listOf types.int);
      default = [];
      description = "Groups of UDP ports to accept from local/private/public prefixes.";
    };

    extraLocalCidrs = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Additional CIDRs to include in local port exposure rules.";
    };

    extraAcceptRules = mkOption {
      type = types.lines;
      default = "";
      description = "Additional accept rules to include in accept rules.";
    };
  };

  config = mkIf cfg.enable {
    networking.firewall.enable = false;
    networking.nftables.enable = true;
    networking.nftables.tables = {};

    boot.kernelModules = ["xt_MASQUERADE"];

    systemd.services.dynamic-default-firewall = {
      description = "Dynamic default nftables firewall";
      after = ["network-online.target"];
      wants = ["network-online.target"];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        set -euo pipefail

        prefix4=$(
          ${ip} -4 addr show dev ${cfg.interface} \
            | ${grep} -oP 'inet \K[\d.]+/\d+' \
            | ${head} -n1 || ${trueCmd}
        )

        ula6=fe80::/10

        public6=$(
          ${ip} -6 addr show dev ${cfg.interface} \
            | ${grep} -oP 'inet6 \K[0-9a-f:]+/\d+' \
            | ${grep} -v '^fe80' | ${grep} -v '^fd' \
            | ${head} -n1 || ${trueCmd}
        )

        ruleset=$(mktemp)

        cat > "$ruleset" <<EOF
        table inet default {
          chain input {
            type filter hook input priority 300; policy drop;

            # Accept established and loopback
            ct state established,related accept
            iifname "lo" accept

            # Baseline ICMPv6
            ip6 nexthdr icmpv6 icmpv6 type {
              destination-unreachable, packet-too-big, time-exceeded, parameter-problem,
              echo-request, echo-reply, nd-router-solicit, nd-router-advert,
              nd-neighbor-solicit, nd-neighbor-advert, nd-redirect
            } accept

            # Baseline ICMPv4
            ip protocol icmp icmp type {
              destination-unreachable, router-advertisement, time-exceeded, parameter-problem
            } accept
        EOF


        for prefix in "$prefix4" "$ula6" "$public6" ${lib.concatMapStringsSep " " (cidr: "\"${cidr}\"") cfg.extraLocalCidrs}; do
          if [ -n "$prefix" ]; then
            if [[ "$prefix" == *:* ]]; then
              proto="ip6"
            else
              proto="ip"
            fi

            echo "    $proto saddr $prefix tcp dport { 1-65535 } accept" >> "$ruleset"
            echo "    $proto saddr $prefix udp dport { 1-65535 } accept" >> "$ruleset"
          fi
        done

        ${
          let
            sshPort = toString (builtins.elemAt config.services.openssh.ports 0);
          in
            if config.swarm.ssh.enable then ''echo "    tcp dport ${sshPort} accept" >> "$ruleset"'' else ""
        }

        # Extra user-defined accept rules
        cat >> "$ruleset" <<EOF
            ${builtins.replaceStrings ["\n"] ["\n    "] cfg.extraAcceptRules}

            log
          }

          chain output {
            type filter hook output priority 300; policy accept;
          }
        }
        EOF

        if ${nft} list table inet default &>/dev/null; then
          ${nft} delete table inet default
        fi

        ${nft} -f "$ruleset"
        rm "$ruleset"
      '';
      wantedBy = ["multi-user.target"];
      path = with pkgs; [
        iproute2
        nftables
        gnugrep
        uutils-coreutils
      ];
    };

    systemd.paths.dynamic-default-firewall-refresh = {
      description = "Refresh dynamic default firewall on IP address change";
      pathConfig = {
        PathChanged = "/proc/net/if_inet6";
        PathChanged_2 = "/proc/net/fib_trie";
      };
      unitConfig = {
        Unit = "dynamic-default-firewall.service";
      };
      wantedBy = ["multi-user.target"];
    };
  };
}
