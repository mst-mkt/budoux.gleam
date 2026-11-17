{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nuten.url = "github:mst-mkt/nuten";
  };

  outputs =
    {
      self,
      nixpkgs,
      treefmt-nix,
      nuten,
      ...
    }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});

      treefmtOf =
        pkgs:
        treefmt-nix.lib.evalModule pkgs {
          imports = [ nuten.treefmtModule ];
          projectRootFile = "flake.nix";
          programs = {
            nixfmt.enable = true;
            gleam.enable = true;
            taplo.enable = true;
            oxfmt.enable = true;
            nuten.enable = true;
          };
          settings.formatter.taplo.excludes = [ "manifest.toml" ];
        };
    in
    {
      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell {
          packages = [
            pkgs.gleam
            pkgs.beamPackages.erlang
            pkgs.nodejs-slim_24
          ];
        };
      });

      formatter = forAllSystems (pkgs: (treefmtOf pkgs).config.build.wrapper);

      checks = forAllSystems (pkgs: {
        formatting = (treefmtOf pkgs).config.build.check self;
      });
    };
}
