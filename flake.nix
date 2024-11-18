{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";

  outputs =
    {
      self,
      nixpkgs,
    }:
    let
      inherit (nixpkgs) lib;
      supportedSystems = lib.systems.flakeExposed;
      perSystem = lib.genAttrs supportedSystems;
      pkgsFor = nixpkgs.legacyPackages;
    in
    {
      formatter = perSystem (system: pkgsFor.${system}.nixfmt-rfc-style);

      devShells.default = perSystem (
        system:
        pkgsFor.${system}.mkShellNoCC {
          packages = [
            self.formatter.${system}
            pkgsFor.${system}.nil
          ];
        }
      );
    };
}
