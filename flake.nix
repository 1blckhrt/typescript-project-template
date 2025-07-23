{
  description = "TypeScript project with devShell and pre-commit hooks (eslint, prettier)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    hooks,
    ...
  }: let
    supportedSystems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];

    forEachSupportedSystem = f:
      nixpkgs.lib.genAttrs supportedSystems (system:
        f {
          pkgs = import nixpkgs {inherit system;};
          system = system;
        });
  in {
    devShells = forEachSupportedSystem ({
      pkgs,
      system,
    }: {
      default = pkgs.mkShell {
        packages = with pkgs.nodePackages; [
          nodejs
          pnpm
          eslint
          prettier
          typescript
          typescript-language-server
        ];

        inherit (self.checks.${system}.pre-commit) shellHook;
      };
    });

    checks = forEachSupportedSystem ({
      pkgs,
      system,
    }: {
      pre-commit = hooks.lib.${system}.run {
        src = ./.;

        enabledPackages = [
          pkgs.nodePackages.pnpm
        ];

        hooks = {
          eslint = {
            enable = true;
            entry = "pnpx eslint --fix";
            files = "\\.(ts|js|tsx|jsx)$";
          };

          prettier = {
            enable = true;
            entry = "pnpx prettier --write --ignore-unknown";
            files = "\\.(ts|js|tsx|jsx|json|css|md)$";
            excludes = ["flake.lock"];
          };

          convco.enable = true;
          alejandra.enable = true;
        };
      };
    });

    formatter = forEachSupportedSystem ({pkgs, ...}: pkgs.alejandra);
  };
}
