{ nixpkgsSrc ? import ./nixpkgs.nix, pkgs ? (import nixpkgsSrc { })
, compiler ? null, extraOverrides ? _: _: { }, modifier ? x: x }:

let
  haskellPackages = if compiler == null then
    pkgs.haskellPackages
  else
    pkgs.haskell.packages.${compiler};

in haskellPackages.developPackage {
  name = "";
  root = pkgs.nix-gitignore.gitignoreSource [ ] ./.;
  overrides = with pkgs.haskell.lib;
    pkgs.lib.composeExtensions (self: _super: {
      optparse-generic = self.optparse-generic_1_4_4;
      optparse-applicative = self.optparse-applicative_0_16_0_0;
    }) extraOverrides;
  inherit modifier;
}
