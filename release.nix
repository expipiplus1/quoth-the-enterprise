{ nixpkgsSrc ? import ./nixpkgs.nix, pkgs ? import nixpkgsSrc { }
, compiler ? "ghc884" }:

with pkgs.haskell.lib;

let drv = import ./default.nix { inherit pkgs compiler; };

in {
  tarball = sdistTarball drv;
  sdistTest = buildFromSdist drv;
}
