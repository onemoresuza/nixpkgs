{
  hareHook,
  hareThirdParty,
  lib,
  scdoc,
  stdenv,
  fetchFromSourcehut,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "hare-c";
  version = "0-unstable-2024-06-21";

  outputs = [
    "out"
    # "man"
    "bin"
  ];

  src = fetchFromSourcehut {
    owner = "~sebsite";
    repo = "hare-c";
    rev = "1bf070a9c05fce40bb63a6f30f8b2c240f1564ca";
    hash = "sha256-Hpc7l88EaAiNBU4XCmNUUQfIvg4XTfUmVJIXKOEGU1A=";
  };

  nativeBuildInputs = [
    hareHook
    scdoc
    hareThirdParty.hare-madeline
  ];

  dontConfigure = true;

  buildPhase = ''
    runHook preBuild

    mkdir bin
    for cmd in cmd/*; do
      hare build -o "bin/$cmd" "$cmd"
    done

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp ./bin/* $out/bin

    runHook postInstall
  '';

  meta = {
    description = "C parsing and checking library for Hare";
    homepage = "https://sr.ht/~sebsite/hare-c";
    license = lib.licenses.wtfpl;
    maintainers = with lib.maintainers; [ onemoresuza ];
    inherit (hareHook.meta) platforms badPlatforms;
  };
})
