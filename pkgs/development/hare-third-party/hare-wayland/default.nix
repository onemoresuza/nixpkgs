{
  fetchFromSourcehut,
  hareHook,
  hareThirdParty,
  lib,
  pkg-config,
  stdenv,
  wayland,
  wayland-protocols,
}:
stdenv.mkDerivation {
  pname = "hare-wayland";
  version = "0-unstable-2024-04-13";

  src = fetchFromSourcehut {
    owner = "~sircmpwn";
    repo = "hare-wayland";
    rev = "21ba2418387bd00221290b28e8056173a459fd4a";
    hash = "sha256-olBwcUAHDAsh0+D0IAr4b0CJmRXRK7q62O0e3NlVY+8=";
  };

  depsBuildBuild = [ pkg-config ];

  nativeBuildInputs = [
    pkg-config
    hareHook
    hareThirdParty.hare-xml
    wayland
    wayland-protocols
  ];

  patches = [ ./001-dont-regenarate-hare-wlscanner.patch ];

  makeFlags = [
    "PREFIX=${builtins.placeholder "out"}"
    "HARE=hare-unwrapped"
    "HAREFLAGS=-qR"
  ];

  doCheck = true;

  # hare-wlscanner must be run at build time, but it is also installed.
  postBuild = lib.optionalString (!(stdenv.buildPlatform.canExecute stdenv.hostPlatform)) ''
    rm hare-wlscanner
    make hare-wlscanner
  '';
}
