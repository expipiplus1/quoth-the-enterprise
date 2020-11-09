{ nixpkgsSrc ? builtins.fetchTarball {
  url =
    "https://github.com/expipiplus1/nixpkgs/archive/14efdb229c6e08ba8d690de0d179f04b8d38e0b7.tar.gz"; # joe-haskell-cross-2
  sha256 = "0sv5yd25q3w56hz279d9pfb4nyb4vnajbcjmxlgq9vmsfzdgkj2a";
}, crossSystem ? null
, pkgs ? (import nixpkgsSrc { inherit crossSystem; }).pkgsMusl, compiler ? null
}:

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
