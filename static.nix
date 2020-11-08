{ nixpkgsSrc ? builtins.fetchTarball {
  url =
    "https://github.com/expipiplus1/nixpkgs/archive/d732d4cee0c276f48b4de96ed69ccd6a660e9198.tar.gz"; # joe-haskell-cross
  sha256 = "1dbizm8s6kr05r8g5in20h9ncc4fcwqvdph8bdgkgcr8a1g6y273";
}, crossSystem ? null
, pkgs ? (import nixpkgsSrc { inherit crossSystem; }).pkgsStatic
, compiler ? null }:

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
