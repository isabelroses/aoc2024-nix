let
  lock = builtins.fromJSON (builtins.readFile ./flake.lock);
  nodeName = lock.nodes.root.inputs.nixpkgs;
  url =
    lock.nodes.${nodeName}.locked.url
      or "https://github.com/nixos/nixpkgs/archive/${lock.nodes.${nodeName}.locked.rev}.tar.gz";

  nixpkgs = fetchTarball {
    inherit url;
    sha256 = lock.nodes.${nodeName}.locked.narHash;
  };

  pkgs = import nixpkgs { };
in
pkgs.lib
