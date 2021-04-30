{ nixpkgsSrc ? import ./nixpkgs.nix, pkgs ? (import nixpkgsSrc { })
, compiler ? null, extraOverrides ? _: _: { }, modifier ? x: x }:

let
  haskellPackages = if compiler == null then
    pkgs.haskellPackages
  else
    pkgs.haskell.packages.${compiler};

in haskellPackages.developPackage {
  name = "quoth-the-enterprise";
  root = pkgs.nix-gitignore.gitignoreSource [ ] ./.;
  overrides = extraOverrides;
  inherit modifier;
}
