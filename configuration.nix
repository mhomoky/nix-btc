{ config, pkgs, ... }:

{
  imports = [
    ./disko.nix
  ];

  networking.hostName = "nixbitcoin-portable";
  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_GB.UTF-8";

  users.users.nixbtc = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      # Add your SSH public key here
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJxbuUFahg5/QCUq56bqfpJeW/hof9RAzgw0XmEOON4F" # id_ed25519_private_cloud.pub
    ];
  };
  security.sudo.wheelNeedsPassword = false;

  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = false;

  # SOPS secrets
  sops = {
    age.keyFile = "/etc/age.key";
    secrets.tailscale-oauth = {
      sopsFile = ./secrets/tailscale-oauth.yaml;
      format = "yaml";
    };
  };

  # Tailscale using OAuth client/secret
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "both";
    extraUpFlags = [
      "--ssh"
      "--advertise-exit-node"
      "--accept-dns=false"
    ];
    # Use the decrypted secret
    authKeyFile = config.sops.secrets.tailscale-oauth.path;
  };

  # nix-bitcoin stack
  nix-bitcoin = {
    enable = true;
    bitcoin = {
      enable = true;
      package = pkgs.bitcoind-knots;
      extraConfig = ''
        txindex=1
        server=1
        rpcbind=0.0.0.0
        rpcallowip=192.168.0.0/16
      '';
    };
    lightning = {
      enable = true;
      implementation = "clightning";
    };
    fulcrum.enable = true;
  };

  networking.firewall.allowedTCPPorts = [ 8332 9735 50001 50002 22 80 443 ];
  networking.firewall.allowedUDPPorts = [ ];

  # Tor for external access
  services.tor.enable = true;
  services.tor.hiddenServices = {
    bitcoin = {
      version = 3;
      map = [{ port = 8332; target = 8332; }];
    };
    lightning = {
      version = 3;
      map = [{ port = 9735; target = 9735; }];
    };
    fulcrum = {
      version = 3;
      map = [{ port = 50002; target = 50002; }];
    };
  };

  # Ente Photos (web) via Docker
  virtualisation.oci-containers.containers = {
    ente-photos = {
      image = "enteio/photos:latest";
      ports = [ "3000:3000" ];
      environment = {
        ENTE_CONFIG = "/data/config.yaml";
      };
      volumes = [
        "/var/lib/ente:/data"
      ];
      extraOptions = [ "--restart=always" ];
    };
  };

  # Caddy with ACME/Let's Encrypt
  services.caddy = {
    enable = true;
    email = "mjhsdc@protonmail.com";
    virtualHosts."photos.rusty.red" = {
      extraConfig = ''
        reverse_proxy localhost:3000
      '';
    };
  };

  # Auto-upgrade
  system.autoUpgrade = {
    enable = true;
    allowReboot = false;
    flake = "github:mhomoky/nix-btc";
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  fileSystems."/".options = [ "noatime" "discard" ]; # Good for SSD and USB

  swapDevices = [ { device = "/swapfile"; size = 4096; } ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
