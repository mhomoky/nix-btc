{
  description = "Portable Bitcoin Knots Node with Lightning, Fulcrum, Tailscale, SOPS, Ente Photos, Caddy, ACME";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nix-bitcoin.url = "github:fort-nix/nix-bitcoin/release";
    disko.url = "github:nix-community/disko";
    sops-nix.url = "github:Mic92/sops-nix";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, nix-bitcoin, disko, sops-nix, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      in {
        nixosConfigurations = {
          nixbitcoin-portable = pkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [
              ./configuration.nix
              nix-bitcoin.nixosModules.default
              disko.nixosModules.disko
              sops-nix.nixosModules.sops
            ];
          };
        };
      });
}
