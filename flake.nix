# SPDX-FileCopyrightText: 2026 Luflosi <UM980-GNSS-Module-Enclosure@luflosi.de>
# SPDX-License-Identifier: GPL-3.0-only

{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs, ... }:
    let
      lib = nixpkgs.lib;

      allSystems = [
        "aarch64-linux"
        "x86_64-linux"
      ];
      forAllSystems = function: lib.genAttrs allSystems function;
    in
    {
      legacyPackages = forAllSystems (
        system:
        import nixpkgs {
          inherit system;
        }
      );

      packages = forAllSystems (
        system:
        let
          pkgs = self.legacyPackages.${system};

          enclosure-stl =
            pkgs.runCommand "enclosure-stl"
              {
                src = ./UM980-GNSS-Module-Enclosure.scad;
                nativeBuildInputs = with pkgs; [ openscad-unstable ];
              }
              ''
                set -x
                mkdir "$out"
                openscad -D enable_lid=false -o "$out/enclosure.stl" "$src"
              '';

          top-stl =
            pkgs.runCommand "top-stl"
              {
                src = ./UM980-GNSS-Module-Enclosure.scad;
                nativeBuildInputs = with pkgs; [ openscad-unstable ];
              }
              ''
                set -x
                mkdir "$out"
                openscad -D enable_enclosure=false -o "$out/top.stl" "$src"
              '';

          default = pkgs.symlinkJoin {
            name = "stls";
            paths = [
              enclosure-stl
              top-stl
            ];
          };
        in
        {
          inherit enclosure-stl top-stl default;
        }
      );

      devShells = forAllSystems (
        system:
        let
          pkgs = self.legacyPackages.${system};
        in
        {
          default = pkgs.mkShellNoCC {
            packages = with pkgs; [
              openscad-unstable
              fstl
            ];
          };
        }
      );

      checks = forAllSystems (
        system:
        let
          pkgs = self.legacyPackages.${system};
        in
        self.packages.${system}
        // {
          devShell = self.devShells.${system}.default;

          check-editorconfig =
            pkgs.runCommand "check-editorconfig"
              {
                src = ./.;
                nativeBuildInputs = [ pkgs.editorconfig-checker ];
              }
              ''
                cd "$src"
                editorconfig-checker
                touch "$out"
              '';

          run-reuse =
            pkgs.runCommand "run-reuse"
              {
                src = ./.;
                nativeBuildInputs = with pkgs; [ reuse ];
              }
              ''
                cd "$src"
                reuse lint --lines
                touch "$out"
              '';

          run-zizmor =
            pkgs.runCommand "run-zizmor"
              {
                # zizmor needs this folder structure for some reason
                src = lib.fileset.toSource {
                  root = ./.;
                  fileset = ./.github/workflows;
                };
              }
              ''
                '${lib.getExe pkgs.zizmor}' --no-progress --offline "$src"
                touch "$out"
              '';
        }
      );
    };
}
