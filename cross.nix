{ nixpkgsSrc ? import ./nixpkgs.nix, crossSystem ? null
, pkgs ? (import nixpkgsSrc { inherit crossSystem; }), compiler ? null }:

let
  extraOverrides = with pkgs.haskell.lib;
    self: super: {
      QuickCheck = dontHaddock super.QuickCheck;
      primitive = dontHaddock super.primitive;
      basement = dontHaddock super.basement;
      file-embed = dontHaddock super.file-embed;
      cryptonite = dontHaddock super.cryptonite;

      # Remove use of TH
      wai-app-static =
        dontHaddock (appendPatch super.wai-app-static ./wai-cross.patch);

      # See https://github.com/NixOS/nixpkgs/issues/21200
      warp = appendConfigureFlag super.warp "--enable-split-sections";
    };

  modifier = with pkgs.haskell.lib; justStaticExecutables;

in import ./default.nix { inherit pkgs compiler extraOverrides modifier; }
