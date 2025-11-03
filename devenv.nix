{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: {
  packages = [
    pkgs.git
    pkgs.prettierd
    pkgs.prettier
    pkgs.eslint_d
    pkgs.nodePackages_latest.pnpm
    pkgs.nodePackages_latest.nodejs
    pkgs.nodePackages_latest.eslint
  ];

  languages = {
    typescript.enable = true;
    javascript = {
      enable = true;
      pnpm = {
        enable = true;
        install.enable = true;
      };
    };
  };

  scripts = {
    fix.exec = ''
      prettier --write --ignore-unknown . &&
      eslint --ext .ts,.js,.tsx,.jsx --fix --format=pretty src
    '';

    start.exec = ''
      node src/index.ts
    '';
  };

  git-hooks = {
    src = ./.;
    hooks = {
      alejandra.enable = true;
      convco.enable = true;

      eslint = {
        enable = true;
        files = "\\.(ts|js|tsx|jsx)$";
      };

      prettier = {
        enable = true;
        files = "\\.(ts|js|tsx|jsx|json|css|md)$";
        excludes = ["flake.lock"];
      };
    };
  };
}
