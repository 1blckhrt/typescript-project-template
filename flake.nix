{
  description = "Nix flake for a TypeScript project template with pre-configured development environment and checks.";

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
          inherit system;
        });
  in {
    devShells = forEachSupportedSystem ({
      pkgs,
      system,
    }: {
      default = pkgs.mkShell {
        packages =
          builtins.attrValues {
            inherit
              (pkgs.nodePackages)
              nodejs
              pnpm
              typescript
              typescript-language-server
              eslint
              prettier
              ;
          }
          ++ self.checks.${system}.pre-commit.enabledPackages;

        shellHook = ''
          export PATH="./node_modules/.bin:$PATH"

          if [ ! -d node_modules ]; then
            echo "📦 Installing pnpm dependencies..."
            pnpm install
          fi

          ${self.checks.${system}.pre-commit.shellHook or ""}
        '';
      };
    });

    checks = forEachSupportedSystem ({
      pkgs,
      system,
    }: {
      pre-commit = hooks.lib.${system}.run {
        src = ./.;

        hooks = {
          eslint = {
            enable = true;
            entry = "pnpm exec eslint --fix";
            files = "\\.(ts|js|tsx|jsx)$";
          };

          prettier = {
            enable = true;
            entry = "pnpm exec prettier --ignore-unknown --write";
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
