{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    devenv.url = "github:cachix/devenv";

    zig-overlay.url = "github:mitchellh/zig-overlay";
    zig-overlay.inputs.nixpkgs.follows = "nixpkgs";

    zls-main.url = "github:zigtools/zls";
    zls-main.inputs.nixpkgs.follows = "nixpkgs";
    zls-main.inputs.flake-utils.follows = "flake-utils";
    zls-main.inputs.zig-overlay.follows = "zig-overlay";
  };

  nixConfig = {
    extra-trusted-public-keys = "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
    extra-substituters = "https://devenv.cachix.org";
  };

  outputs = {
    flake-utils,
    nixpkgs,
    zig-overlay,
    zls-main,
    devenv,
    ...
  } @ inputs:
    flake-utils.lib.eachDefaultSystem (system: let
        overlays = [
          (final: prev: {
            zigpkgs = zig-overlay.packages.${final.system};
            zls = zls-main.packages.${final.system}.zls;
          })
        ];
        pkgs = import nixpkgs {inherit system overlays;};

        # TODO: grab this from something, rather than hard coding it, perhaps current folder name?
        pname = "6502-emulator";
        version = "0.1.0"; # TODO: Grab this from .cz.toml?
      in rec
      {
        packages = {
          default = pkgs.stdenv.mkDerivation {
            inherit pname version;

            src = ./.;

            nativeBuildInputs = with pkgs; [
              zigpkgs.master
            ];

            ZIG_BUILD_FLAGS = "-p . --cache-dir . --global-cache-dir . -Dtarget=${system}";

            buildPhase = ''
              zig build $ZIG_BUILD_FLAGS
            '';

            doCheck = true;
            checkPhase = ''
              zig build test $ZIG_BUILD_FLAGS
            '';

            installPhase = ''
              mkdir -p $out/bin
              mv bin/* $out/bin
            '';
          };
        };

        devShells.default = devenv.lib.mkShell {
          inherit inputs pkgs;
          modules = [
            ({pkgs, ...}: {
              packages = with pkgs; [
                alejandra
                zls
                lldb
                commitizen
                kcov
              ];

              languages.nix.enable = true;
              languages.zig.enable = true;
              languages.zig.package = pkgs.zigpkgs.master;

              pre-commit.hooks.alejandra.enable = true;
              pre-commit.hooks.commitizen.enable = true;
              pre-commit.hooks.convco.enable = true;
              pre-commit.hooks."zigtest" = {
                enable = true;
                name = "zig test";
                description = "Runs zig build test on the project.";
                entry = "${pkgs.zigpkgs.master}/bin/zig build test --build-file ./build.zig";
                pass_filenames = false;
              };

              difftastic.enable = true;

              scripts.run-tests.exec = ''
                ${pkgs.zigpkgs.master}/bin/zig build test --summary all
              '';
              scripts.commit.exec = ''
                ${pkgs.commitizen}/bin/cz commit
              '';
              scripts.coverage.exec = ''
                kcov --exclude-pattern=/nix ./kcov-output ./zig-cache/o/*/test
              '';
            })
          ];
        };

        # For compatibility with older versions of the `nix` binary
        devShell = devShells.${system}.default;
      });
}
