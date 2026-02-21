{ config, lib, pkgs, ... }:
let
  cfg = config.virtualisation.qemu-lab;
in {
  options.virtualisation.qemu-lab = {
    enable = lib.mkEnableOption "QEMU lab networking";

    isolated = {
      subnet = lib.mkOption {
        type = lib.types.str;
        default = "10.0.100";
        description = "First three octets of the isolated bridge subnet";
      };
      bridge = lib.mkOption {
        type = lib.types.str;
        default = "br-qemu-iso";
        description = "Bridge interface name for isolated network";
      };
    };

    hostonly = {
      subnet = lib.mkOption {
        type = lib.types.str;
        default = "10.0.200";
        description = "First three octets of the host-only bridge subnet";
      };
      bridge = lib.mkOption {
        type = lib.types.str;
        default = "br-qemu-host";
        description = "Bridge interface name for host-only network";
      };
    };

    dns = {
      upstreamServers = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "Upstream DNS servers for dnsmasq. Empty = don't override system DNS.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    networking.bridges.${cfg.isolated.bridge}.interfaces = [];
    networking.bridges.${cfg.hostonly.bridge}.interfaces = [];

    networking.interfaces.${cfg.isolated.bridge}.ipv4.addresses = [{
      address = "${cfg.isolated.subnet}.1";
      prefixLength = 24;
    }];

    networking.interfaces.${cfg.hostonly.bridge}.ipv4.addresses = [{
      address = "${cfg.hostonly.subnet}.1";
      prefixLength = 24;
    }];

    services.dnsmasq = {
      enable = true;
      resolveLocalQueries = false;
      settings = {
        bind-dynamic = true;
        listen-address = [
          "${cfg.isolated.subnet}.1"
          "${cfg.hostonly.subnet}.1"
        ];
        interface = [ cfg.isolated.bridge cfg.hostonly.bridge ];
        dhcp-range = [
          "interface:${cfg.isolated.bridge},${cfg.isolated.subnet}.100,${cfg.isolated.subnet}.200,12h"
          "interface:${cfg.hostonly.bridge},${cfg.hostonly.subnet}.100,${cfg.hostonly.subnet}.200,12h"
        ];
        no-resolv = true;
        no-poll = true;
        server = lib.mkIf (cfg.dns.upstreamServers != []) cfg.dns.upstreamServers;
      };
    };

    networking.firewall = {
      trustedInterfaces = [ cfg.isolated.bridge cfg.hostonly.bridge ];
      extraCommands = ''
        # NOTE: Isolated - drop all forwarding (no internet, no LAN)
        iptables -I FORWARD -i ${cfg.isolated.bridge} -j DROP
        iptables -I FORWARD -o ${cfg.isolated.bridge} -j DROP

        # NOTE: Host-only - drop forwarding too (no internet, just host <-> VM)
        iptables -I FORWARD -i ${cfg.hostonly.bridge} -j DROP
        iptables -I FORWARD -o ${cfg.hostonly.bridge} -j DROP
      '';
      extraStopCommands = ''
        iptables -D FORWARD -i ${cfg.isolated.bridge} -j DROP 2>/dev/null || true
        iptables -D FORWARD -o ${cfg.isolated.bridge} -j DROP 2>/dev/null || true
        iptables -D FORWARD -i ${cfg.hostonly.bridge} -j DROP 2>/dev/null || true
        iptables -D FORWARD -o ${cfg.hostonly.bridge} -j DROP 2>/dev/null || true
      '';
    };

    # NOTE: QEMU bridge helper needs setuid to create TAP interfaces on bridges
    environment.etc."qemu/bridge.conf".text = ''
      allow ${cfg.isolated.bridge}
      allow ${cfg.hostonly.bridge}
    '';

    security.wrappers.qemu-bridge-helper = {
      source = "${pkgs.qemu}/libexec/qemu-bridge-helper";
      owner = "root";
      group = "root";
      setuid = true;
    };
  };
}
